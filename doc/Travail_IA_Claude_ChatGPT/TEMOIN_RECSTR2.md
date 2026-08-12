# LOT chiffres longs, itération 2 — RECSTR_TEST vert : bissection des ingrédients

## Lecture du vert

Le squelette (récursion sans paramètre + ID muté + deux constantes locales +
récursion en tête de caténation) est SAIN sous T1 : RECSTR_TEST 4/4. La
famille tient donc aux ingrédients que le premier témoin avait stylisés,
présents dans RECURSE_DOUBLETS/TO_QUAD_DIGITS et absents du squelette :
(a) les opérandes de caténation sont des TRANCHES PLEINES des constantes
(`STR2( STR2'FIRST .. STR2'LAST )`), pas les constantes ; (b) TO_QUAD_DIGITS
construit son résultat par un AGRÉGAT À BORNES DYNAMIQUES
(`STRING'( 1 .. COMPL => '0' )`, bornes VIDES quand COMPL = 0) caténé à une
tranche de 'IMAGE ; (c) le type SHORT représenté 16 bits (`mod 10_000`,
`SHORT'IMAGE`). RECSTR_TEST reste au filet comme contrôle du squelette ;
RECSTR2_TEST transplante la chair, ingrédient par ingrédient, données de
_standrd comprises — si la famille se reproduit, le check 6 doit rendre
littéralement `002100214748`.

## COMMIT — témoin RECSTR2_TEST (rouge attendu, posé AVANT tout correctif)

### Nouveau fichier `recstr2_test.adb`

```ada
with TEXT_IO; use TEXT_IO;

procedure RECSTR2_TEST is

  NB_OK	: INTEGER := 0;
  NB_KO	: INTEGER := 0;

  type SHORT is range -32_768 .. 32767;
  for SHORT'SIZE use 16;

  TABH	: array ( 1..2 ) of SHORT := ( 1 => 4748, 2 => 0 );		--| DD2 par niveau (donnees de 2147483647)
  TABL	: array ( 1..2 ) of SHORT := ( 1 => 3647, 2 => 21 );		--| DD1 par niveau
  NSIZ	: INTEGER := 2;
  IDX	: INTEGER := 1;

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

  function TO_QUAD ( S :SHORT ) return STRING is
    IMAG	:constant STRING	:= SHORT'IMAGE( S );
    COMPL	: NATURAL := 4 - (IMAG'LENGTH - 1);
  begin
    return STRING'( 1 .. COMPL => '0' ) & IMAG( IMAG'FIRST+1 .. IMAG'LAST );
  end TO_QUAD;

  function RECURSE2 return STRING is
    DD2	: SHORT	:= TABH( IDX ) mod 10_000;
    DD1	: SHORT	:= TABL( IDX ) mod 10_000;
    STR2	:constant STRING	:= TO_QUAD( DD2 );
    STR1	:constant STRING	:= TO_QUAD( DD1 );
  begin
    if IDX = NSIZ then
      if DD2 = 0 then
        return STR1( STR1'FIRST .. STR1'LAST );
      else
        return STR2( STR2'FIRST .. STR2'LAST ) & STR1( STR1'FIRST .. STR1'LAST );
      end if;
    else
      IDX := IDX + 1;
      return RECURSE2 & STR2( STR2'FIRST .. STR2'LAST ) & STR1( STR1'FIRST .. STR1'LAST );
    end if;
  end RECURSE2;

begin
  CHECK( TO_QUAD( 21 ) = "0021", 1 );					--| agregat 1..2 => '0' catene a une tranche d'IMAGE
  CHECK( TO_QUAD( 4748 ) = "4748", 2 );					--| COMPL = 0 : agregat a BORNES VIDES en tete de catenation
  declare
    S	: SHORT := 14748;
  begin
    CHECK( TO_QUAD( S mod 10_000 ) = "4748", 3 );			--| mod sur type represente 16 bits
  end;

  declare								--| tranches pleines de constantes dynamiques
    A	: constant STRING := TO_QUAD( 11 );				--| en catenation, SANS recursion
    B	: constant STRING := TO_QUAD( 22 );
  begin
    CHECK( "X" & A( A'FIRST .. A'LAST ) & B( B'FIRST .. B'LAST ) = "X00110022", 4 );
  end;

  declare								--| cas terminal seul (profondeur 1)
    R	: constant STRING := RECURSE2;
  begin
    IDX := 1;								--| (RECURSE2 a consomme IDX 1->2)
    CHECK( R = "002147483647", 5 );					--| LE motif complet, donnees de _standrd
    CHECK( R'LENGTH = 12, 6 );
  end;

  PUT( "RESULTAT :" );
  PUT( INTEGER'IMAGE( NB_OK ) );
  PUT( " OK," );
  PUT( INTEGER'IMAGE( NB_KO ) );
  PUT_LINE( " ECHECS" );
  if NB_KO = 0 then
    PUT_LINE( "RECSTR2_TEST PASSE" );
  else
    PUT_LINE( "RECSTR2_TEST ECHOUE" );
  end if;

exception
  when others =>
    PUT_LINE( "RECSTR2_TEST ECHOUE (EXCEPTION)" );
end RECSTR2_TEST;
```

### Oracle du commit témoin

- gnat : `RESULTAT : 6 OK, 0 ECHECS` + `RECSTR2_TEST PASSE`.
- T1 : la grille bissecte —
  - check 1 ou 2 rouge → TO_QUAD isolé : famille « agrégat à bornes
    dynamiques/vides en opérande de caténation » (ou tranche d'IMAGE) ;
  - checks 1-4 verts et 5 rouge → la combinaison récursion × tranches de
    constantes : lire la VALEUR (ajouter `PUT_LINE( R );` au besoin) — la
    prédiction issue de _standrd est `002100214748` au caractère près ;
  - check 3 seul rouge → `mod` sur type représenté ;
  - check 4 rouge → tranches pleines en caténation, sans récursion.
- Joindre la sortie T1 (avec la valeur de R si 5 est rouge), et le FINC
  `RECSTR2_TEST.FINC` en entier.

Rappel des clôtures dues, indépendantes de ce lot : retrait des sondes @PD,
commits documentation (pièges 139-142, entrées ORACLES), journal de la
victoire _standrd.ads.
