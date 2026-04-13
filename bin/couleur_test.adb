with TEXT_IO;
use  TEXT_IO;
procedure COULEUR_TEST
is

  type COULEUR	is ( BLEU , BLANC, ROUGE );

  COUL	: COULEUR		:= BLANC;

  package IO_COULEUR is new ENUMERATION_IO( COULEUR );

  TST	:constant STRING	:= "INUTILE";

begin
  IO_COULEUR.PUT( COUL );
  PUT( TST );

end	COULEUR_TEST;
