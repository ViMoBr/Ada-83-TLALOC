# CORRECTIF Ada 83 des témoins (LRM 3.9 + indexation de littéral)

Deux fautes dans mes témoins : (1) `"NULL_PROG"( I )` — un littéral de
chaîne n'est pas un nom indexable en Ada 83 → constante nommée ;
(2) ordre déclaratif — les corps sont des *later declarative items* :
TOUS les objets avant TOUT corps.

## RETMICRO1 (version Ada 83 stricte, remplace la précédente)

```
with TEXT_IO;			use TEXT_IO;

procedure RETMICRO1
is
  BUF		: STRING( 1..255 );
  LEN		: NATURAL := 0;

  R9		: STRING( 1..9 );
  EXPECTED	: constant STRING( 1..9 ) := "NULL_PROG";
  N		: NATURAL;

  function TS return STRING
  is
  begin
    return BUF( 1..LEN );
  end TS;

begin
  BUF( 1..9 ) := "NULL_PROG";
  LEN := 9;

  PUT( "M1 brut    [" );
  PUT( TS );						-- consommation la plus directe
  PUT_LINE( "]" );

  R9 := TS;						-- affectation depuis le resultat
  PUT( "M2 affecte [" );
  PUT( R9 );
  PUT_LINE( "]" );

  if  TS = "NULL_PROG"  then				-- l'egalite de R1, jugee sans CHECK
    PUT_LINE( "M3 egalite VRAI" );
  else
    PUT_LINE( "M3 egalite FAUX" );
  end if;

  N := 0;						-- octets reellement copies, sans doublet
  for I in 1..9 loop
    if  R9( I ) = EXPECTED( I )  then
      N := N + 1;
    end if;
  end loop;
  PUT( "M4 octets egaux :" );
  PUT( NATURAL'IMAGE( N ) );
  NEW_LINE;

  PUT_LINE( "RETMICRO1 FIN" );
end RETMICRO1;
```

Attendu inchangé :
```
M1 brut    [NULL_PROG]
M2 affecte [NULL_PROG]
M3 egalite VRAI
M4 octets egaux : 9
RETMICRO1 FIN
```

## RETMICRO2 — inchangé

Son unique item déclaratif est le corps de P : conforme tel quel.

## RETSLICE — réordonnancement si recompilation

Même faute LRM 3.9 : `R9` y est déclaré APRÈS le corps de TS. Si vous
recompilez RETSLICE (p. ex. pour ré-exercer les R* après correctifs),
remonter la déclaration :

Déplacer la ligne
```
  R9	: STRING( 1..9 );
```
pour qu'elle suive immédiatement
```
  LEN	: NATURAL := 0;
```
(avant `function TS`). Aucun autre changement ; les assertions et le
trailer sont inchangés. NB : le crash observé n'est pas affecté par ce
point de légalité — la chaîne l'a accepté et le FINC joint reste la
pièce d'autopsie valide.
