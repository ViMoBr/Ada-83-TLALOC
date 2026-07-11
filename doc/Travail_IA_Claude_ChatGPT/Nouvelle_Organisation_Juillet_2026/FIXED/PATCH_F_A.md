# PATCH F-A — Garde anti-trou-silencieux `FIX*FIX` / `FIX/FIX`

**Fichier** : `expander-expressions.adb`
**Procédure** : `CODE_DN_BLTN_OPERATOR_ID`
**Ancrage** : immédiatement APRÈS `POP( PRM_S, PRM_2 );` (l. 3434 de la
version auditée), AVANT le bloc `if OP_STR = """&"""` (l. 3436).

Même position doctrinale que la garde `NOT` composite (l. 3417) : router /
diagnostiquer AVANT toute émission par `CODE_EXP`.

---

## Pourquoi la garde ne peut PAS tester `RES_TYPE`

Fait établi au dump F-0 (Q1) : sur un `FIX*FIX`, le `DN_FUNCTION_CALL` ne
porte **AUCUN** `SM_EXP_TYPE` — sem ne matérialise pas `universal_fixed`,
il laisse le champ absent. Donc en l. 3393 :

    RES_TYPE : TREE := D( SM_EXP_TYPE, FUNCTION_CALL );   -- = TREE_VOID !

`RES_TYPE` vaut `TREE_VOID`, `IS_FLOAT` tombe à FALSE, et le `MUL` cru sort
en silence. **La garde doit donc tester le type des OPÉRANDES**, seule
information disponible à ce point.

---

## Texte du patch

```ada
        POP( PRM_S, PRM_2 );

		------------------------------------------------------------
		-- F-A : garde anti-trou-silencieux FIXED * FIXED, FIXED / FIXED
		--
		-- LRM 4.5.5 : FIX*FIX et FIX/FIX rendent universal_fixed, qui ne
		-- peut etre consomme que sous CONVERSION EXPLICITE ( T(X*Y) ).
		-- Le pilotage de ces deux operateurs appartient donc a
		-- CODE_CONVERSION (cible DN_FIXED), seul detenteur du SMALL cible
		-- (dump F-0, Q1 : le DN_FUNCTION_CALL ne porte PAS de SM_EXP_TYPE,
		-- sem ne materialise pas universal_fixed -- RES_TYPE = TREE_VOID).
		--
		-- Atteindre ce point signifie donc l'un des deux cas :
		--   (a) F-D pas encore livree : la conversion n'intercepte pas
		--       encore, et la branche entiere en aval emettrait un MUL/DIV
		--       CRU sur les representations -- FAUX d'un facteur SMALL,
		--       et SILENCIEUSEMENT (piege n 53).
		--   (b) F-D livree : un X*Y fixed apparait HORS conversion, ce que
		--       le LRM interdit -- sem aurait du le rejeter.
		-- Dans les deux cas : se signaler, ne jamais corrompre en silence.
		--
		-- PORTEE (dump F-0, 9.6) : FIX*INTEGER TOMBE AUSSI ICI. Sem insere
		-- une CONVERSION IMPLICITE de l'entier vers le type fixed, donc les
		-- DEUX operandes du "*" sont DN_FIXED dans l'arbre :
		--     "*" { A : DN_FIXED(T8) ; DN_CONVERSION -> DN_FIXED(T8)
		--                                | AS_EXP: N : DN_INTEGER }
		-- C'est VOULU : si cette conversion emet son CVTIX, elle SCALE N
		-- (3 -> 48 avec SMALL 1/16) et A*N calcule rA*48 au lieu de rA*3 --
		-- FAUX d'un facteur SMALL. Le FIX*INTEGER n'est donc PAS acquis,
		-- contrairement a ce qu'on supposait avant le dump. La garde le
		-- REVELE au lieu de le laisser passer : c'est sa raison d'etre.
		-- (F-B tranchera : le cas FIX*INT doit-il elider la conversion de
		--  l'entier, ou la conserver et diviser par le SMALL ensuite ?)
        declare
          PRM1_TYPE	: TREE	:= D( SM_EXP_TYPE, PRM_1 );
          PRM2_TYPE	: TREE	:= D( SM_EXP_TYPE, PRM_2 );
        begin
          if  ( OP_STR = """*"""  or else  OP_STR = """/""" )
            and then  PRM1_TYPE /= TREE_VOID
            and then  PRM2_TYPE /= TREE_VOID
            and then  PRM1_TYPE.TY = DN_FIXED
            and then  PRM2_TYPE.TY = DN_FIXED
          then
            PUT_LINE( "; CODE_DN_BLTN_OPERATOR_ID : " & OP_STR
                    & " FIXED*FIXED HORS CONVERSION -- A FAIRE (pilier fixed, F-D)" );
            raise PROGRAM_ERROR;
          end if;
        end;
		------------------------------------------------------------

        if  OP_STR = """&"""  then
```

---

## Propriétés

1. **Ne touche pas aux chemins corrects.** `FIX+FIX`, `FIX-FIX` et les
   comparaisons ne remplissent pas la condition (opérateur non `*`/`/`) :
   ils restent sur la branche entière, qui est correcte par construction.

2. **Attrape TOUS les `*` / `/` fixed**, y compris `FIX*INTEGER` —
   la conversion implicite insérée par sem rend ses deux opérandes
   `DN_FIXED` (dump §9.6). C'est délibéré : ce cas n'est **pas** acquis, il
   est seulement *non jugé*. La garde le révèle.

3. **Devient inatteignable après F-D** — puisque `CODE_CONVERSION`
   interceptera en amont. Elle reste alors comme **filet permanent** contre
   un `universal_fixed` consommé hors conversion (cas (b)).

4. **Motif conforme** au piège n° 53 : commentaire FINC bruyant +
   `raise PROGRAM_ERROR`, exactement comme la garde des opérateurs unaires
   non gérés (l. 3696) et `CODE_RETURN` / C7-C8.

---

## Régression attendue à la livraison

La garde va **faire tomber tout code existant qui contient un `FIX*FIX`**.
Règle de tri (identique au §7 de la note checks) : un `PROGRAM_ERROR` sur
cette garde est une **DETTE RENDUE VISIBLE**, pas une régression du patch.

**La portée est plus large que prévu** (§9.6) : `DURATION * INTEGER`, légal
et courant (LRM 9.6), tombera AUSSI — ses deux opérandes sont `DN_FIXED`
après la conversion implicite. Il faut donc s'attendre à une chute
**immédiate et bruyante** dans CALENDAR.

Points à vérifier en priorité :

- **CALENDAR / DURATION** : `DURATION * INTEGER` et `DURATION / INTEGER`.
  Chute ATTENDUE. Si le résultat était juste jusqu'ici, comprendre POURQUOI
  (la conversion implicite est-elle réellement émise, ou `CODE_CONVERSION`
  la court-circuite-t-elle quand source = INTEGER et cible = FIXED ?
  cf. l. 5505-5509 : le chemin `SRC_TYPE.TY = DN_INTEGER` émet bien un
  `CVTIX`...). **C'est LA question de F-B.**
- **TEXT_IO.FIXED_IO** : scanner / formateur.
- **Filet + ACVC série C4A**.

Si la chute CALENDAR révèle que `DURATION * INTEGER` était FAUX depuis le
début et que personne ne l'a vu, c'est un **fossile** au sens du §7 bis de
la note checks — à consigner dans PIEGES.

Si une chute survient dans du code TLALOC lui-même, c'est un **fossile**
au sens du §7 bis — à consigner dans PIEGES, pas à contourner en
affaiblissant la garde.
