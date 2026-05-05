with TEXT_IO; use TEXT_IO;
with DIRECT_IO;
			--------------
procedure			DIRECT_IO_TEST
is			--------------

  package INT_IO		is new INTEGER_IO( INTEGER );
  use INT_IO;

  package LF_TEXT_IO	is new FLOAT_IO( LONG_FLOAT );
  use LF_TEXT_IO;

  package LF_IO		is new DIRECT_IO( LONG_FLOAT );
  use LF_IO;

  F   : LF_IO.FILE_TYPE;
  X1  : LONG_FLOAT := 3.1415;
  X2  : LONG_FLOAT := 6.5;
  X3  : LONG_FLOAT := -2.25;

  R1  : LONG_FLOAT := 0.0;
  R2  : LONG_FLOAT := 0.0;
  R3  : LONG_FLOAT := 0.0;

  TMP	: LF_IO.COUNT	:= 0;

begin
  PUT( "LONG_FLOAT SIZE = " ); PUT( LONG_FLOAT'SIZE ); PUT_LINE( " bits" );

  -- Ecriture sequentielle de 3 valeurs
  CREATE( F, OUT_FILE, "long_float_direct.dat" );
  PUT_LINE( "create ok" );

  WRITE( F, X1 );
  PUT_LINE( "write #1 ok" );

  WRITE( F, X2 );
  PUT_LINE( "write #2 ok" );

  PUT( "INDEX = " );

  TMP := INDEX( F );
  PUT( INTEGER( TMP ) );
  NEW_LINE;

  WRITE( F, X3 );
  PUT_LINE( "write #3 ok" );

  PUT( "size after writes = " );

  TMP := SIZE( F );
  PUT( INTEGER( TMP ) );
  NEW_LINE;

  CLOSE( F );
  PUT_LINE( "close after writes ok" );

  -- Reouverture en lecture et verification sequentielle
  OPEN( F, IN_FILE, "long_float_direct.dat" );
  PUT_LINE( "open in_file ok" );

  READ( F, R1 );
  READ( F, R2 );
  READ( F, R3 );

  PUT( "read seq #1 = " ); PUT( R1 ); NEW_LINE;
  PUT( "read seq #2 = " ); PUT( R2 ); NEW_LINE;
  PUT( "read seq #3 = " ); PUT( R3 ); NEW_LINE;

  CLOSE( F );
  PUT_LINE( "close after sequential read ok" );

  -- Lecture positionnee
  OPEN( F, IN_FILE, "long_float_direct.dat" );
  PUT_LINE( "open again for positioned read ok" );

  READ( F, R2, 2 );
  PUT( "read positioned #2 = " ); PUT( R2 ); NEW_LINE;

  READ( F, R3, 3 );
  PUT( "read positioned #3 = " ); PUT( R3 ); NEW_LINE;

  CLOSE( F );
  PUT_LINE( "close after positioned read ok" );

  -- Reecriture positionnee du 2e element
  OPEN( F, INOUT_FILE, "long_float_direct.dat" );
  PUT_LINE( "open inout_file ok" );

  WRITE( F, X1, 2 );
  PUT_LINE( "rewrite position 2 ok" );

  PUT( "size after rewrite = " );
  PUT( INTEGER( SIZE( F ) ) );
  NEW_LINE;

  CLOSE( F );
  PUT_LINE( "close after rewrite ok" );

  -- Verification finale
  OPEN( F, IN_FILE, "long_float_direct.dat" );
  PUT_LINE( "open final check ok" );

  READ( F, R1, 1 );
  READ( F, R2, 2 );
  READ( F, R3, 3 );

  PUT( "final #1 = " ); PUT( R1 ); NEW_LINE;
  PUT( "final #2 = " ); PUT( R2 ); NEW_LINE;
  PUT( "final #3 = " ); PUT( R3 ); NEW_LINE;

  CLOSE( F );
  PUT_LINE( "final close ok" );

end	DIRECT_IO_TEST;
	--------------
