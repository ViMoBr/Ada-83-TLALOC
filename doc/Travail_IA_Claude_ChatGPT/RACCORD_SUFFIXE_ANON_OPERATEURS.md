# RACCORD au lot collision ANON — le nommage positionnel ne peut pas suffire

## Lecture du FINC du témoin

Le doublet-résultat du `+` de la ligne 57 s'appelle `ANON_57_8` — position de
l'EXPRESSION — et l'agrégat opérande gauche aussi : la collision est intacte.
La leçon : dans l'arbre de T1, `LX_SRCPOS` d'un `DN_USED_OP` porte la position
de DÉBUT D'EXPRESSION, pas celle du lexème de l'opérateur — l'hypothèse du lot
précédent était fausse, et AUCUN nommage purement positionnel ne peut séparer
une expression infixe de son opérande gauche (elles commencent au même
caractère, par grammaire). Il faut une source d'unicité hors position : le
générateur d'étiquettes de l'expander (`NEW_LABEL`, déterministe, version
`return STRING` déjà au catalogue) fournit le suffixe. Les noms deviennent
`ANON_l_c_L<n>` pour les SEULS lieux-résultat d'appels d'opérateurs ; tout
autre appel garde son nom à l'octet près. La consommation d'un numéro décale
les étiquettes suivantes de la même unité — confiné aux unités à opérateurs
utilisateur, déjà dans le périmètre du diff.

Les trois modifications s'appliquent à l'état APRÈS le commit 2 du lot
collision (elles retirent le mécanisme ANON_SRC, inopérant, et posent le
suffixe).

---

## COMMIT 2-bis — expander-expressions.adb, PREPARE_FUNCTION_RESULT_PLACE

### Modification 1 — remplacer ANON_SRC par la fonction locale RESULT_ANON_NAME

ANCRE (texte existant, inchangé, unique) :

```ada
    RET_NAME	: TREE	:= D( AS_NAME, FUNC_SPEC );	 -- nom du type de retour (DN_FUNCTION_SPEC)
```

BLOC À SUPPRIMER (les six lignes immédiatement sous l'ancre — le bloc posé au
commit 2 du lot collision, ligne de commentaire longue comprise, à reprendre
telle qu'elle est dans votre fichier) :

```ada
    RET_TS	: TREE	:= TREE_VOID;
    ANON_SRC	: TREE	:= CALL_NODE;
  begin
        if  D( AS_NAME, CALL_NODE ).TY = DN_USED_OP  then
	ANON_SRC := D( AS_NAME, CALL_NODE );							-- OPDEF_TEST 7-8 / segfault 0x45825b : appel d'OPERATEUR infixe -- la position de l'expression = celle de l'operande GAUCHE ; si celui-ci est un appel a resultat record, VAR ANON_l_c emis en DOUBLE dans le namespace (fasmg multi-passes : cellule degeneree, @ nul dans DABS). Nommer le doublet-resultat sur le LEXEME de l'operateur : position unique par construction.
        end if;
```

BLOC DE REMPLACEMENT :

```ada
    RET_TS	: TREE	:= TREE_VOID;

    function  RESULT_ANON_NAME  return STRING
    is			----------------
			--| OPDEF_TEST 7-8 / segfaults 0x45825b puis temoin : la position
			--| d'une expression INFIXE = celle de son operande GAUCHE (meme
			--| LX_SRCPOS sur le DN_USED_OP -- verifie au FINC du temoin :
			--| doublet-resultat ANON_57_8 = agregat gauche ANON_57_8). Aucun
			--| nommage positionnel ne peut les separer : suffixe par le
			--| generateur d'etiquettes (deterministe) pour les SEULS
			--| lieux-resultat d'appels d'operateurs -- ANON_l_c_L<n>. Les
			--| appels non-operateurs gardent leur nom a l'octet pres.
    begin
      if  D( AS_NAME, CALL_NODE ).TY = DN_USED_OP  then
	return ANONYMOUS_NAME_AT( CALL_NODE ) & '_' & NEW_LABEL;
      else
	return ANONYMOUS_NAME_AT( CALL_NODE );
      end if;
    end RESULT_ANON_NAME;
  begin
```

### Modification 2 — branche record

ANCRE (texte existant, inchangé, unique) :

```ada
	  ANON_STR  : constant STRING := ANONYMOUS_NAME_AT( ANON_SRC );
```

BLOC À SUPPRIMER : l'ancre elle-même.

BLOC DE REMPLACEMENT :

```ada
	  ANON_STR  : constant STRING := RESULT_ANON_NAME;
```

### Modification 3 — branche tableau contraint

ANCRE (texte existant, inchangé, unique) :

```ada
	    ANON_STR	: constant STRING	:= ANONYMOUS_NAME_AT( ANON_SRC );
```

BLOC À SUPPRIMER : l'ancre elle-même.

BLOC DE REMPLACEMENT :

```ada
	    ANON_STR	: constant STRING	:= RESULT_ANON_NAME;
```

---

## Oracles (inchangés dans leur cascade, précisés au point 1)

1. T1 reconstruit. OPDEF_TEST : `8 OK, 0 ECHECS` + `OPDEF_TEST PASSE`.
   FINC du témoin : les lieux-résultat des opérateurs lisent
   `ANON_l_c_L<n>` ; contrôle mécanique
   `grep "^VAR	ANON" OPDEF_TEST.FINC | sort | uniq -d` vide — et le même
   contrôle en boucle sur tous les FINC de la chaîne.
2. FINC des témoins hors OPDEF_TEST : BIT-IDENTIQUES (la branche suffixée ne
   s'ouvre que sur AS_NAME = DN_USED_OP).
3. Cascade du lot inchangée : filet vert ; diff de chaîne confiné ; trace S
   bit-exacte ; T2 reconstruit → `_standrd.ads` M, visée listing complet
   jusqu'à `_DURATION` + « Ok » ; puis retrait des sondes @PD.

Documentation : dans l'entrée du piège n° 141 (commit 3 du lot, si non encore
appliqué), remplacer la phrase « Nommage bascule sur le LEXEME de l'operateur
(DN_USED_OP porte sa propre LX_SRCPOS, unique). » par :

```
    Le LEXEME n'offre pas d'issue : LX_SRCPOS du DN_USED_OP = debut
    d'expression = position de l'operande gauche (verifie au FINC).
    Unicite par SUFFIXE hors position : ANON_l_c_L<n> via NEW_LABEL
    (deterministe), pour les seuls lieux-resultat d'operateurs.
```
