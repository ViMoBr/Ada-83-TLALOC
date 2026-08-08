# LOT agrégat-de-chaînes — lecture des sondes @PD et témoin AGGSTR_TEST

## Verdict des sondes

Les 22 lignes @PD tranchent la grille en cas 1-2 combinés, avec un raffinement
décisif : les crochets contiennent, pour CHAQUE opérateur, les 3 octets bas d'une
ADRESSE, et ces adresses décroissent STRICTEMENT de 0x28 (40) d'une ligne à la
suivante, dans l'ordre des positions de OP_CLASS. Ce ne sont ni des textes
mélangés ni du bruit : ce sont les octets des data_ptr des doublets successifs
des 21 LITTÉRAUX de chaîne, figés une fois pour toutes à l'ÉLABORATION de
`BLTN_TEXT_ARRAY` (entrée de SEM_PHASE). Le tableau contient des tranches de
pointeurs au lieu des textes ; le rognage `!` ne trouve rien (L = 3 partout) ;
STORE_SYM stocke fidèlement ces noms-poison (caténation et hachage SAINS :
guillemets présents, déduplication cohérente, nœuds neufs 75.x/81.x) ; la
deflist part sur les doublons ; celle de `[P3,L30] "-"` reste vide ; HEAD lève.
La chaîne aval est entièrement disculpée — le poison est UN SEUL site :
la copie des composantes composites d'un agrégat de tableau dont les
composantes sont des LITTÉRAUX de chaîne.

C'est le motif de la règle unique n° 112 (« BLKMOV copiait le doublet
lui-même ») avec signature par-élément : résidu = pointeur DIFFÉRENT par
composante (un doublet anonyme par littéral, pas de 40 octets), là où SECV1
montrait un résidu UNIFORME (même objet source). Or EMIT_ONE_COMP applique déjà
CODE_COMPOSITE_DATA_ADDRESS, et DN_STRING_LITERAL est dans la liste des
producteurs d'@doublet : quelque chose ESQUIVE la discrimination — hypothèses
ouvertes : le nœud des composantes `OP_AND => "AND"` n'est pas DN_STRING_LITERAL
dans cet agrégat (chemin nommé), ou l'élaboration de cette constante ne passe
pas par EMIT_ONE_COMP. Le FINC du témoin ci-dessous (petit, lisible) le dira.

## COMMIT — témoin AGGSTR_TEST (rouge attendu, posé AVANT tout correctif)

Un NOUVEAU fichier, à côté des programmes de test (INDEX § 3.4). Reproduit le
motif à l'identique : package spec dans une procédure de bibliothèque (niveau 1,
comme PRENAME dans SEM_PHASE), tableau constant indexé par énuméré, composantes
STRING_3 rembourrées `!`, associations nommées DANS LE DÉSORDRE, boucle de
rognage. Les checks ENCADRENT la famille : copie de l'élément entier (le motif
du crash), double indexation caractère (chemin scalaire, attendu sain),
égalité composite directe, affectation (pas init) vers une variable STRING_3,
et un tableau jumeau à agrégat POSITIONNEL pour discriminer le chemin nommé.

### Nouveau fichier `aggstr_test.adb`

```ada
with TEXT_IO; use TEXT_IO;

procedure AGGSTR_TEST is

  NB_OK	: INTEGER := 0;
  NB_KO	: INTEGER := 0;

  package DICO is
    type CLE is ( K_A, K_B, K_C, K_D, K_E );
    subtype STR3 is STRING( 1..3 );
    TXT	: constant array ( CLE ) of STR3 := (
	K_C => "CC!",	K_A => "AND",	K_E => "E!!",
	K_D => "DD!",	K_B => "OR!"
	);								--| associations nommees dans le desordre, rembourrage '!'
    POSTXT	: constant array ( CLE ) of STR3 := (
	"AND",	"OR!",	"CC!",	"DD!",	"E!!"
	);								--| jumeau POSITIONNEL, memes textes
  end DICO;

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

  use DICO;

begin
  declare
    ITEM	: constant STRING := TXT( K_B );				--| LE motif du crash : init d'objet depuis element indexe
  begin
    CHECK( ITEM'LENGTH = 3, 1 );
    CHECK( ITEM = "OR!", 2 );
  end;

  CHECK( TXT( K_A )( 1 ) = 'A', 3 );					--| double indexation : chemin scalaire
  CHECK( TXT( K_A )( 3 ) = 'D', 4 );
  CHECK( TXT( K_D )( 2 ) = 'D', 5 );

  CHECK( TXT( K_E ) = "E!!", 6 );					--| egalite composite directe sur element indexe

  declare
    S3	: STR3	:= ( others=> '?' );
  begin
    S3 := TXT( K_C );							--| AFFECTATION (pas init) depuis element indexe
    CHECK( S3 = "CC!", 7 );
  end;

  CHECK( POSTXT( K_B ) = "OR!", 8 );					--| jumeau positionnel : discrimine le chemin nomme
  CHECK( POSTXT( K_E ) = "E!!", 9 );

  declare								--| boucle de rognage du motif reel
    ITEM	: constant STRING := TXT( K_E );
    L		: NATURAL := 3;
  begin
    while L > 0 and then ITEM( L ) = '!' loop
      L := L - 1;
    end loop;
    CHECK( L = 1, 10 );
  end;

  PUT( "RESULTAT :" );
  PUT( INTEGER'IMAGE( NB_OK ) );
  PUT( " OK," );
  PUT( INTEGER'IMAGE( NB_KO ) );
  PUT_LINE( " ECHECS" );
  if NB_KO = 0 then
    PUT_LINE( "AGGSTR_TEST PASSE" );
  else
    PUT_LINE( "AGGSTR_TEST ECHOUE" );
  end if;

exception
  when others =>
    PUT_LINE( "AGGSTR_TEST ECHOUE (EXCEPTION)" );
end AGGSTR_TEST;
```

### Oracle du commit témoin

- Juge validé par gnat : `RESULTAT : 10 OK, 0 ECHECS` + `AGGSTR_TEST PASSE`.
- Compilé par T1 (TLALOC-gnat), exécuté : **ROUGE attendu** — au minimum les
  checks 1-2 (le motif exact), vraisemblablement 6-7 ; les checks 3-5 (chemin
  scalaire) attendus sains ; 8-9 disent si le positionnel est touché aussi.
  Le DÉTAIL des numéros en échec localise le trou.

## Pièces à joindre au retour (avec le verdict)

1. La sortie complète d'AGGSTR_TEST (gnat puis T1).
2. Le FINC du témoin : `aggstr_test.FINC` en entier (il est court) — on y lira
   directement, pour chaque composante de l'agrégat TXT, si la séquence est
   `LVA <anon>_disp` … `La` … `BLKMOV` (règle appliquée) ou si le `La` manque
   (doublet copié) — et le NŒUD que le parseur a donné aux littéraux, via la
   forme des lignes émises.
3. En contrôle croisé sur la vraie victime :
   `grep -n -A2 "BLTN_TEXT_ARRAY" idl-sem_phase.FINC | head -60`
   (l'élaboration à l'entrée de SEM_PHASE — mêmes questions, même lecture).

Correctif ensuite, une fois le trou nommé par le FINC : une modification dans
l'expander (site de copie des composantes, ou liste de discrimination de
CODE_COMPOSITE_DATA_ADDRESS), livrée au format habituel avec le témoin comme
gardien et les oracles de non-régression (FINC bit-identiques hors famille,
filet complet, _standrd au-delà de SHORT_INTEGER).
