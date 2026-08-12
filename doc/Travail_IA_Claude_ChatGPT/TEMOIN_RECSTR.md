# LOT chiffres longs — analyse de la victoire et témoin RECSTR_TEST

## Bilan de l'étape (à consigner au journal)

SEM_PHASE bootstrappée COMPLÈTE sur _standrd.ads — le listing intégral jusqu'à
`_DURATION` + « Ok 25 msec » — ET l'expander de T2 a tourné derrière : le
territoire T2-expander est ouvert. L'oracle ultime (FINC de T2 vs FINC de T1)
donne : MÊME TAILLE EXACTE après normalisation CRLF (18 932 = 18 932 octets),
et SIX lignes de différence, toutes des `LI` de constantes longues. Actions de
clôture des lots précédents, désormais dues : retrait des sondes @PD
(instructions livrées), commits documentation en attente (pièges 139-142,
entrées ORACLES), et l'entrée de journal de la victoire.

## La famille suivante, cernée par le motif

Décomposition en quads des six lignes :

    T1 : 0021 4748 3647        T2 : 0021 0021 4748
    T1 : 0005 3687 0912        T2 : 0005 0005 3687
    T1 : -017 1798 69184       T2 : -017 1017 17986

Lecture : le quad le plus profond (récursion) est JUSTE ; ensuite, chaque
niveau restitue les quads DÉCALÉS D'UN OPÉRANDE — `R & STR2 & STR1` sort
`R & R & STR2`. La source de ces chiffres est PRINT_NUM (idl.adb l.514),
exécuté par T2 avec du code machine émis par T1 : la famille est une
miscompilation T1 du motif de RECURSE_DOUBLETS — fonction RÉCURSIVE sans
paramètre retournant STRING, effet de bord montant sur `ID`, deux constantes
STRING locales initialisées par appels de fonction (TO_QUAD_DIGITS), et la
récursion comme opérande GAUCHE d'une caténation CHAÎNÉE dans le return.
Jamais exercé avant : les valeurs à ≤ 4 chiffres significatifs par doublet
haut passent des chemins plus courts, et rien dans le filet ne récursait en
caténation.

## COMMIT — témoin RECSTR_TEST (rouge attendu, posé AVANT tout correctif)

Nouveau fichier, à côté des programmes de test (INDEX § 3.4). Reproduit le
motif de RECURSE_DOUBLETS membre à membre : récursion sans paramètre, ID
montant muté, S2/S1 constantes locales issues d'appels, return récursif en
tête de caténation chaînée, cas terminal à un seul morceau.

### Nouveau fichier `recstr_test.adb`

```ada
with TEXT_IO; use TEXT_IO;

procedure RECSTR_TEST is

  NB_OK	: INTEGER := 0;
  NB_KO	: INTEGER := 0;

  ID	: INTEGER := 1;
  PROF	: INTEGER := 3;

  procedure CHECK ( COND :BOOLEAN; NUM :INTEGER ) is
  begin
    if COND then
      NB_OK := NB_OK + 1;
    else
      NB_KO := NB_KO + 1;
      PUT( "* ECHEC test" );
      PUT( INTEGER'IMAGE( NUM ) );
      NEW_LINE;
    end if;
  end CHECK;

  function QUAD ( K :INTEGER; C :CHARACTER ) return STRING is
    S	: STRING( 1..4 ) := ( others=> C );
  begin
    S( 4 ) := CHARACTER'VAL( CHARACTER'POS( '0' ) + K );			--| ex. QUAD(2,'A') = "AAA2"
    return S;
  end QUAD;

  function RECURSE return STRING is
    S2	: constant STRING := QUAD( ID, 'A' );				--| motif RECURSE_DOUBLETS : deux constantes
    S1	: constant STRING := QUAD( ID, 'B' );				--| STRING locales issues d'appels
  begin
    if ID = PROF then
      return S1;							--| cas terminal : un seul morceau
    else
      ID := ID + 1;							--| effet de bord montant, AVANT la recursion
      return RECURSE & S2 & S1;						--| recursion en TETE de catenation chainee
    end if;
  end RECURSE;

begin
  declare
    R	: constant STRING := RECURSE;
  begin
    CHECK( R'LENGTH = 20, 1 );
    CHECK( R = "BBB3AAA2BBB2AAA1BBB1", 2 );				--| terminal(ID=3) puis S2&S1 de ID=2 puis de ID=1
  end;

  ID := 1;
  PROF := 2;
  declare
    R	: constant STRING := RECURSE;
  begin
    CHECK( R = "BBB2AAA1BBB1", 3 );					--| profondeur 2 : un seul niveau de catenation
  end;

  ID := 1;
  PROF := 1;
  declare
    R	: constant STRING := RECURSE;
  begin
    CHECK( R = "BBB1", 4 );						--| pas de recursion : cas terminal direct
  end;

  PUT( "RESULTAT :" );
  PUT( INTEGER'IMAGE( NB_OK ) );
  PUT( " OK," );
  PUT( INTEGER'IMAGE( NB_KO ) );
  PUT_LINE( " ECHECS" );
  if NB_KO = 0 then
    PUT_LINE( "RECSTR_TEST PASSE" );
  else
    PUT_LINE( "RECSTR_TEST ECHOUE" );
  end if;

exception
  when others =>
    PUT_LINE( "RECSTR_TEST ECHOUE (EXCEPTION)" );
end RECSTR_TEST;
```

### Oracle du commit témoin

- gnat : `RESULTAT : 4 OK, 0 ECHECS` + `RECSTR_TEST PASSE`.
- T1 : **ROUGE attendu** — au premier chef le check 2 (le motif complet ;
  la corruption `_standrd` prédit une valeur du type
  `BBB3BBB3AAA2…` : opérandes décalés d'un cran). Le check 4 (sans
  récursion) et le check 3 (un niveau) ENCADRENT la profondeur de
  déclenchement. La VALEUR FAUTIVE EXACTE imprimée par un PUT_LINE de R
  ajouté à la main si besoin — ou communiquée via l'échec — oriente le
  diagnostic fin.

## Pièces à joindre au retour

1. Sortie complète gnat puis T1 (avec, si rouge, la valeur de R du check 2 —
   ajouter au besoin `PUT_LINE( R );` avant le CHECK, à retirer ensuite).
2. Le FINC du témoin en entier (court) — on y lira l'émission de la
   caténation chaînée avec la récursion en opérande G : cellules
   `ANON_*_G/D/R`, doublets-résultat, et l'ordre des BLKMOV.
3. En contrôle croisé sur la vraie victime : la section PRINT_NUM /
   RECURSE_DOUBLETS de IDL.FINC (grep RECURSE, une centaine de lignes).

Correctif ensuite au format habituel une fois le trou nommé par le FINC —
même protocole que les lots agrégats et opérateurs. Le segfault de
_standrd.adb reste en file, après cette famille.
