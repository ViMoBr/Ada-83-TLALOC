# LIVRAISON — segfault 0x46ff17 (ERR_PHASE sur null_prog, TO_CHN_L187 d'idl.adb)

Protocole : une modification = une ancre (texte existant unique, inchangé)
+ bloc à supprimer + bloc de remplacement, tabulations préservées.
Les blocs sont à prendre AU CARACTÈRE PRÈS (les lignes de commentaire du
remplacement commencent par TROIS tabulations ; les lignes de code par
huit espaces, comme l'original).
Contre-épreuve faite par rejeu programmatique sur source vierge :
ancre unique, bloc contigu, remplacement propre.


## DIAGNOSTIC (chaîne causale complète, chaque maillon vérifié au source)

Le site en faute est `THE_CHN := TO_CHN( SUITE_TREES( PAG(CUR_RP).DATA.all(
START..START-1+NB_TREES) ) )` — l'actual de l'instance UNCHECKED_CONVERSION
est une **DN_CONVERSION enveloppant une DN_SLICE**.

1. Dispatcher des actuels (expander-instructions.adb, INVERSE_RECURSE_ON_
   PARAMETERS) : DN_CONVERSION ne matche aucune branche → branche par
   défaut `else CODE_EXP( ACT_PRM )` (l. 1017-1019).
2. CODE_CONVERSION cible DN_CONSTRAINED_ARRAY = identité (INTENTIONNEL C1,
   « identité sur l'@doublet ») → il relaie tel quel ce que laisse
   `CODE_EXP( SRC_EXP )`.
3. **Le maillon cassé** : CODE_EXP → CODE_NAME → CODE_NAME_EXP
   (expander-expressions.adb l. 137-138) appelle `CODE_SLICE( NAME_EXP )`
   avec le défaut `IS_DESTINATION := TRUE` → la tranche laisse
   **@data, LEN** — DEUX valeurs — dans un contexte de VALEUR.
4. L'appel `CALL TO_CHN_L187` part donc avec TROIS pushes
   [@doublet-résultat ANON_501, @data_tranche, LEN] pour DEUX PRM
   (S_ofs, result__ofs). Décalage d'un slot : `-S_ofs` (sommet) reçoit
   LEN = NB_TREES×4 = **24**, `-result__ofs` reçoit @data_tranche.
5. Corps synthétisé de TO_CHN : `La 3, -result__ofs / La` lit
   @data_tranche et le déréférence — pointeur page valide, passe.
   `Ld _CHN.SIZ / LI 8 / DIV` (rbx=8 ✓, cqto/idiv ✓). Puis
   `La 3, -S_ofs / La` : charge 24 puis `mov (%rax),%rax` avec
   **rax = 0x18 = 24** → SIGSEGV à 0x46ff17, entre TO_CHN_L187
   (0x46FE7F) et l'élaboration de THE_CHN (0x46FF5D). Toute la
   géométrie observée (registres, adresse, map) découle de ce seul
   push excédentaire.

La preuve par la doctrine existante : les QUATRE sites de la maison qui
consomment une tranche en position de valeur contournaient déjà ce
défaut en forçant `IS_DESTINATION => FALSE` (mode source = doublet
anonyme, une seule valeur) :
- return d'une tranche (expander-instructions.adb l. 1156-1162, avec le
  commentaire qui nomme exactement notre bug : « le chemin par defaut
  (CODE_EXP -> CODE_NAME -> CODE_SLICE en mode destination) laisserait
  @data, len ») ;
- actual DN_SLICE nu (instructions l. 966-967) ;
- init d'objet par tranche (declarations l. 1141) ;
- alias/renommage de tranche (declarations l. 1515).

Symétriquement, TOUS les consommateurs légitimes de la forme @data+LEN
appellent CODE_SLICE **directement** avec TRUE explicite (affectation
source tranche l. 2027 et 2141 ; CODE_OBJECT_ADDRESS DN_SLICE,
expressions l. 1618 + DROP). Aucun ne passe par CODE_EXP. Le défaut de
la ligne 138 est donc corrigeable à la règle (piège n° 121 : quand les
sites locaux contredisent la règle unique, c'est la règle qu'on audite)
sans casser aucun chemin existant.

NB — deux bugs distincts dans votre observation : ce correctif solde le
segfault d'AFFICHAGE. L'erreur de compilation parasite sur le `is`
(PAR_PHASE / parse.bin) est le chantier SUIVANT ; le correctif rend
justement ERR_PHASE capable d'imprimer son message complet, qui devient
la première pièce de cette prochaine chasse.


====================================================================
## COMMIT 1 — CODE_EXP(tranche) = producteur de valeur : mode source
====================================================================

Un seul fichier modifié, une seule modification, plus un témoin ajouté.

--------------------------------------------------------------------
### M1 — expander-expressions.adb (CODE_NAME_EXP, ~l. 137)
--------------------------------------------------------------------

ANCRE (unique dans le fichier, inchangée) :
```
      elsif  NAME_EXP.TY = DN_SLICE  then
```

BLOC À SUPPRIMER (immédiatement sous l'ancre) :
```
        CODE_SLICE( NAME_EXP );
```

BLOC DE REMPLACEMENT (commentaires : 3 tabulations ; code : 8 espaces) :
```
			--| Segfault 0x46ff17 (ERR_PHASE sur null_prog, TO_CHN_L187 d'idl.adb,
			--| 03/08) : une tranche en position de VALEUR (ici l'actual d'une
			--| instance UNCHECKED_CONVERSION, DN_CONVERSION sur tranche) passait
			--| par le mode destination -- @data, LEN, DEUX valeurs -- et l'appel
			--| partait avec un push de trop : -S_ofs recevait LEN (=24) et le
			--| La du corps synthetise le dereferencait.  CODE_EXP est un
			--| producteur de VALEUR : une tranche y suit la regle n 112
			--| (@doublet, mode source), comme aux quatre sites qui contournaient
			--| deja ce defaut (return, init d'objet, actual nu, alias).  Les
			--| consommateurs de @data+LEN appellent tous CODE_SLICE directement
			--| (IS_DESTINATION => TRUE explicite) : inchanges.
        CODE_SLICE( NAME_EXP, IS_DESTINATION => FALSE );
```

--------------------------------------------------------------------
### T1 — NOUVEAU FICHIER : slconv1.adb (témoin, permanent au filet)
--------------------------------------------------------------------

Miroir de la géométrie du crash (UC entre sous-types tableau contraints,
actual = conversion d'une tranche), auto-jugeant, format maison.
S2 garde la non-régression du chemin @data+LEN direct (affectation
source tranche, TRUE explicite, non touché par M1).

```
with TEXT_IO;			use TEXT_IO;
with UNCHECKED_CONVERSION;

procedure SLCONV1
is
  OK_COUNT	: NATURAL	:= 0;
  KO_COUNT	: NATURAL	:= 0;

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

  BIG	: STRING( 1..12 )	:= "ABCDEFGHIJKL";

  subtype MID4	is STRING( 5..8 );
  subtype CHN4	is STRING( 1..4 );

  function TO_CHN4	is new UNCHECKED_CONVERSION( MID4, CHN4 );

  R	: CHN4;

begin
  PUT_LINE( "=== SLCONV1 : tranche en valeur (conversion + UC) ===" );

  R := TO_CHN4( MID4( BIG( 5..8 ) ) );				-- le chemin du segfault 0x46ff17
  CHECK( "S1 UC( conversion( tranche ) )", R = "EFGH" );

  R := BIG( 9..12 );						-- non-regression @data+LEN direct (CODE_ASSIGN, TRUE explicite)
  CHECK( "S2 affectation source tranche", R = "IJKL" );

  CHECK( "S3 UC en operande d'egalite", TO_CHN4( MID4( BIG( 1..4 ) ) ) = "ABCD" );

  PUT_LINE( "RESULTAT :" & NATURAL'IMAGE( OK_COUNT ) & " OK,"
	  & NATURAL'IMAGE( KO_COUNT ) & " ECHECS" );
  if  KO_COUNT = 0  then
    PUT_LINE( "SLCONV1 PASSE" );
  else
    PUT_LINE( "SLCONV1 ECHOUE" );
  end if;

end SLCONV1;
```

--------------------------------------------------------------------
### ORACLES DU COMMIT 1
--------------------------------------------------------------------

1. **Filet syntaxique** : `gnat -gnats -gnat83` sur
   expander-expressions.adb modifié — zéro erreur.

2. **Oracle témoin** : compilation et exécution de slconv1.adb par la
   chaîne TLALOC (côté gnat-généré) ; la ligne « SLCONV1 PASSE ».
   Avant M1, S1 doit précisément reproduire la faute (push
   excédentaire → décalage des PRM) : le témoin est discriminant.

3. **Diff FINC** (ré-expansion d'idl.adb) : au site d'appel de
   TO_CHN_L187, la séquence `LI 4 / MUL` finale de l'ancien mode
   destination disparaît au profit d'un bloc
   `namespace ANON_... ; ensemble doublet @data/@info pour slice anonyme source`
   (motif identique à l'ANON_502_14 déjà présent au return de
   PRINT_NAME) suivi d'un unique `LVA ..._disp` — exactement DEUX
   pushes avant le CALL. Aucun autre site du diff ne doit bouger
   (les quatre contournements FALSE et les TRUE explicites sont
   inchangés).

4. **Oracle bootstrap** (la cible) : re-génération, ré-assemblage,
   puis `./A83.sh ./ ./null_prog.adb S` — plus de segfault à
   0x46ff17 ; ERR_PHASE imprime son message d'erreur COMPLET
   (message parasite attendu : le bug parser reste ouvert). Ce texte
   complet est la première pièce de la chasse suivante.


====================================================================
## HORS COMMIT — dettes et suites consignées, à ne pas embarquer
====================================================================

- **Dette solderable ouverte par M1** : le refus bruyant
  `CODE_COMPOSITE_DATA_ADDRESS tranche (@data,LEN hors contrat)`
  devient sur-conservateur — après M1 une tranche via CODE_EXP produit
  un @doublet régulier (La en extrairait data_ptr). Le solder est un
  commit SÉPARÉ avec son propre témoin (tranche en composant
  d'agrégat, la dette AUDITS nommée) — doctrine n° 122 : bénir
  l'observé, jamais la classe.
- **Amendement n° 112 à consigner** (PIEGES.md, au moment du versement
  du piège de session) : les producteurs d'@doublet sont désormais
  objet entier, appel de fonction, qualifié, **et tranche via
  CODE_EXP** ; la forme @data+LEN n'existe plus que par appel DIRECT
  de CODE_SLICE( TRUE ).
- **Chasse suivante** : l'erreur parasite `is / col 1` de PAR_PHASE
  sur null_prog (soupçon parse.bin partagé avec le compilateur gnat).
  M1 n'y touche pas ; il rend l'erreur lisible.
