# LIVRAISON — COMMIT 3 : le littéral de chaîne rejoint la règle n° 112
# (segfault RETMICRO1/RETSLICE : BLKMOV sans source)

Protocole ancré habituel, blocs au caractère près, rejeu fait sur la
copie portant M1+M2 (zones disjointes : s'applique aussi bien avant).


## DIAGNOSTIC (clos — chaque maillon vérifié FINC + registres + source)

Le BLKMOV fautif est celui de `BUF( 1..9 ) := "NULL_PROG"` — PREMIÈRE
instruction du corps. Le FINC montre : @dst empilé, len (9) empilé,
puis la directive `STR` (définition de constante, ZÉRO instruction),
puis `BLKMOV` — **la source n'est jamais empilée**. Aux registres :
src←9 (la longueur, déréférencée comme adresse → SIGSEGV sur le lods
même), count←@BUF (premier bloc co-pile : 0x407c60 ici, 0x40b0e8 dans
RETSLICE), dest←0 (pile vide dessous). Trois sur trois.

RECTIFICATION du dossier précédent : le crash de RETSLICE était LE MÊME
(même première instruction) — « CHECK_L6 » n'était que le dernier
symbole de carte avant le begin du corps principal. Il n'y a qu'UNE
prise ici, pas deux ; le « 9 fantôme » était len_dst. La proie D-C7a
reste devant : RETMICRO1 s'arrêtait AVANT de l'atteindre.

Chaîne causale côté expander :
1. Affectation à destination TRANCHE (expander-instructions.adb, branche
   DST_NAME.TY = DN_SLICE) : source non-agrégat non-tranche →
   `CODE_COMPOSITE_DATA_ADDRESS( SRC_EXP )`.
2. CCDA fait `CODE_EXP( EXP )` — et la branche littéral de CODE_EXP
   (CODE_AGG_EXP → CODE_STRING_LITERAL) émet la constante `STR` SANS
   RIEN EMPILER.
3. Le littéral n'étant pas dans la liste des producteurs d'@doublet de
   CCDA, pas de `La` non plus. Zéro push → BLKMOV décalé d'un cran.

Le trou est PRÉ-EXISTANT (aucune zone touchée par les commits 1-2) et
jamais exercé par le corpus : les initialisations À LA DÉCLARATION
passent par l'aliasing (vu dans l'élab d'EXPECTED), et tous les autres
consommateurs de littéraux ont leur PROPRE émission — l'idiome
`STR + LCA data_ptr + La` existe déjà mot pour mot aux branches
littéral de l'affectation INDEXÉE (« FIX v3 30/07 ») et de
l'affectation OBJET (« LIGNE AJOUTEE »). La destination-tranche est la
seule affectation sans le cas littéral. Un littéral nu en INSTRUCTION
d'affectation n'existait nulle part au corpus avant mes témoins.

Correctif à la RÈGLE (piège n° 121), pas troisième rustine locale :
CODE_EXP(littéral) devient un producteur d'@doublet (le doublet
STATIQUE du littéral existe déjà : LCA .data_ptr), et CCDA l'extrait.
Bénéfice collatéral : tout futur consommateur de CODE_EXP(littéral)
(retour de littéral, etc.) devient correct par construction.


====================================================================
## COMMIT 3 — trois modifications, expander-expressions.adb
====================================================================

--------------------------------------------------------------------
### M-A — CODE_AGG_EXP, branche DN_STRING_LITERAL (~l. 257)
--------------------------------------------------------------------

ANCRE (unique, inchangée) :
```
      elsif AGG_EXP.TY = DN_STRING_LITERAL  then
```

BLOC À SUPPRIMER :
```
        CODE_STRING_LITERAL( AGG_EXP, ANONYMOUS_NAME_AT( AGG_EXP ) );
```

BLOC DE REMPLACEMENT :
```
			--| Segfault RETMICRO1/RETSLICE (BUF(1..9) := "NULL_PROG", 03/08) :
			--| CODE_EXP d'un litteral emettait la constante STR SANS RIEN
			--| EMPILER -- tous les sites qui marchent (operande, actuel, init,
			--| qualifie, branches litteral des affectations objet et indexee)
			--| contournent CODE_EXP avec leur propre STR+LCA ; seule
			--| l'affectation a destination TRANCHE tombait ici via
			--| CODE_COMPOSITE_DATA_ADDRESS, et son BLKMOV partait sans source.
			--| CODE_EXP est un producteur de VALEUR : le litteral rejoint la
			--| regle n 112 en poussant son @doublet STATIQUE (LCA .data_ptr) ;
			--| l'extraction (La) est chez CODE_COMPOSITE_DATA_ADDRESS, amendee
			--| dans le meme commit.
        declare
          ANON	:constant STRING	:= ANONYMOUS_NAME_AT( AGG_EXP );
        begin
          CODE_STRING_LITERAL( AGG_EXP, ANON );
          PUT_LINE( tab & "LCA" & tab & ANON & ".data_ptr" );					-- @doublet statique du litteral
        end;
```

--------------------------------------------------------------------
### M-B1 — CODE_COMPOSITE_DATA_ADDRESS, liste des producteurs (~l. 1620)
--------------------------------------------------------------------

ANCRE (unique, inchangée) :
```
        if  E.TY = DN_USED_OBJECT_ID  or else  E.TY = DN_FUNCTION_CALL
```

BLOC À SUPPRIMER :
```
        or else  E.TY = DN_QUALIFIED
```

BLOC DE REMPLACEMENT :
```
        or else  E.TY = DN_QUALIFIED  or else  E.TY = DN_STRING_LITERAL
```

--------------------------------------------------------------------
### M-B2 — CCDA, énoncé n° 112 de l'en-tête (~l. 1600)
--------------------------------------------------------------------

ANCRE (unique, inchangée) :
```
    --| deja, la regle unique avait le trou.  Amender l'enonce n 112 :
```

BLOC À SUPPRIMER :
```
    --| @doublet = objet entier, appel de fonction, QUALIFIE.
```

BLOC DE REMPLACEMENT :
```
    --| @doublet = objet entier, appel de fonction, QUALIFIE, tranche via
    --| CODE_EXP (commits tranches 03/08), LITTERAL de chaine (ce commit).
```

--------------------------------------------------------------------
### T — NOUVEAU TÉMOIN PERMANENT : litaff1.adb
--------------------------------------------------------------------

Le trou débusqué, au filet — littéral nu en instruction, les trois
destinations (objet entier, tranche en tête, tranche décalée : l'offset
destination est jugé aussi).

```
with TEXT_IO;			use TEXT_IO;

procedure LITAFF1
is
  OK_COUNT	: NATURAL := 0;
  KO_COUNT	: NATURAL := 0;

  W9	: STRING( 1..9 );
  B12	: STRING( 1..12 );

  procedure CHECK( LABEL :STRING; COND :BOOLEAN )
  is
  begin
    if  COND  then
      OK_COUNT := OK_COUNT + 1;
    else
      KO_COUNT := KO_COUNT + 1;
      PUT_LINE( "ECHEC " & LABEL );
    end if;
  end CHECK;

begin
  PUT_LINE( "=== LITAFF1 : litteral de chaine en instruction d'affectation ===" );

  W9 := "NULL_PROG";					-- litteral -> objet entier (instruction)
  CHECK( "L1 objet := litteral", W9 = "NULL_PROG" );

  B12 := "------------";				-- litteral -> objet entier, autre taille
  B12( 1..3 ) := "xyz";				-- litteral -> tranche en tete
  CHECK( "L2 tranche tete := litteral", B12 = "xyz---------" );

  B12( 4..6 ) := "abc";				-- litteral -> tranche DECALEE (offset destination)
  CHECK( "L3 tranche decalee := litteral", B12 = "xyzabc------" );

  PUT_LINE( "RESULTAT :" & NATURAL'IMAGE( OK_COUNT ) & " OK,"
	  & NATURAL'IMAGE( KO_COUNT ) & " ECHECS" );
  if  KO_COUNT = 0  then
    PUT_LINE( "LITAFF1 PASSE" );
  else
    PUT_LINE( "LITAFF1 ECHOUE" );
  end if;

end LITAFF1;
```

--------------------------------------------------------------------
### ORACLES DU COMMIT 3
--------------------------------------------------------------------

1. **Filet syntaxique** : `gnat -gnats -gnat83` sur
   expander-expressions.adb (M1+M2+M3) et litaff1.adb — zéro erreur.

2. **Oracle témoin** : LITAFF1 — « RESULTAT : 3 OK, 0 ECHECS » +
   « LITAFF1 PASSE », identique des deux côtés (gnat -gnat83 et
   TLALOC).

3. **Diff FINC** (ré-expansion de litaff1/retmicro1) : chaque
   affectation littérale montre désormais `STR ANON...` suivi de
   `LCA ANON....data_ptr` puis `La` avant le BLKMOV — trois valeurs
   empilées, trois dépilées. Aucun autre site ne bouge (les branches
   littéral existantes court-circuitent CODE_EXP et sont inchangées).

4. **L'oracle qui compte — RETMICRO1 atteint enfin sa proie** : la
   première instruction franchie, le témoin livre M1-M4 (le retour de
   tranche dynamique, D-C7a). Joindre sa sortie COMPLÈTE des deux
   côtés — c'est elle qui ouvre la manche suivante. RETSLICE
   (réordonné LRM 3.9) redevient rejouable ensuite pour les R1-R7.


====================================================================
## HORS COMMIT — à consigner
====================================================================

- Piège de session (famille du n° 112, troisième occurrence du motif
  « producteur absent de la règle unique ») : quand un émetteur ne
  produit RIEN pour une forme, chaque consommateur pousse sa rustine
  locale et le premier chemin sans rustine segfaute des années plus
  tard. Le grep de clôture est celui du NŒUD (DN_STRING_LITERAL) —
  fait, huit sites recensés, tous classés.
- Les branches littéral locales (actuels 962, affectation objet 2022,
  affectation indexée 1888, init 1020, qualifié 4663, opérande 3350)
  restent correctes et INCHANGÉES ; les fusionner vers le producteur
  unique est une dette de simplification, PAS de ce commit (bénir
  l'observé, n° 122).
- Toujours pendantes : la demande du jeu de macros réel du build (LVA
  absent de mon codi_x86_64.finc), et le chantier F3 (défauts de MAKE
  = poubelle [DN_ARGUMENT_ID,P9873,L100] — source de MAKE + FINC à
  joindre quand la manche D-C7a sera close).
