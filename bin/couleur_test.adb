with TEXT_IO;
use  TEXT_IO;
procedure COULEUR_TEST
is

  type COULEUR	is ( BLEU , BLANC, ROUGE );

  COUL	: COULEUR		:= ROUGE;

  package IO_COULEUR is new ENUMERATION_IO( COULEUR );

begin
  IO_COULEUR.PUT( COUL );

end	COULEUR_TEST;
