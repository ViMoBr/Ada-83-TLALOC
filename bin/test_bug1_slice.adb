with TEXT_IO;
use  TEXT_IO;
		---------------
procedure		TEST_BUG1_SLICE
is		---------------

  NOM_TEXTE		: STRING( 1 .. 11  )	:= "Compile.Txt";
  UPPER_NAME		: STRING( NOM_TEXTE'RANGE );
  NAME_END		: NATURAL			:= 0;

begin
  for  I in NOM_TEXTE'RANGE  loop
    if  NOM_TEXTE( I ) in 'a' .. 'z'  then
      UPPER_NAME( I ) := CHARACTER'VAL( CHARACTER'POS( 'A' )
				+ CHARACTER'POS( NOM_TEXTE( I ) ) - CHARACTER'POS( 'a' ) );
    else UPPER_NAME( I ) := NOM_TEXTE( I );
    end if;
    if  NOM_TEXTE( I ) = '.'  then
      return;
    end if;
    NAME_END := I;
  end loop;

  declare
    NOM_FAS	: STRING renames UPPER_NAME( UPPER_NAME'FIRST .. NAME_END );
  begin
        PUT_line( NOM_FAS & ".fas" );
  end;
end	TEST_BUG1_SLICE;
