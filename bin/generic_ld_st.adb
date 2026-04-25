with TEXT_IO;
use  TEXT_IO;
		-------------
procedure		GENERIC_LD_ST
is		-------------

  type COULEUR	is ( BLEU, BLANC, ROUGE );

  package IO_COULEUR	is new ENUMERATION_IO( COULEUR );

  C	: COULEUR;
  F	: FILE_TYPE;

begin
  OPEN( F, IN_FILE, "enum_data.dat" );
  IO_COULEUR.GET( F, C );
  IO_COULEUR.PUT( C );

end	GENERIC_LD_ST;
	-------------
