with TEXT_IO
use  TEXT_IO;
			--------------
procedure			TEST_EXCEPTION
is			--------------

  ERREUR	: exception;
  C	: CHARACTER;

begin
  loop
  PUT( "Entrez Q (quit) ou E (exception)" ); GET( C );
  end loop;

exception
  when ERREUR => PUT_LINE( "ERREUR" );

end	TEST_EXCEPTION;
	--------------
