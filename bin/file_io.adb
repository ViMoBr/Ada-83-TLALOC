with TEXT_IO;
use TEXT_IO;
		-------
procedure		FILE_IO
is		-------
  F	: FILE_TYPE;
  S	: STRING( 1 .. 64 );
  LAST	: NATURAL;

begin
  CREATE( F, OUT_FILE, "essai.txt" );
  PUT_LINE( F, "Bonjour fichier" );
  CLOSE( F );

  OPEN( F, IN_FILE, "essai.txt" );
  GET_LINE( F, S, LAST );
  CLOSE( F );

  PUT_LINE( S( 1 .. LAST ) );

  OPEN( F, IN_FILE, "essai.txt" );
  DELETE( F );
end	FILE_IO;
	-------
