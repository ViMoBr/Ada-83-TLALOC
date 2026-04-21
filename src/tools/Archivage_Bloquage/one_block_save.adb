with TEXT_IO;
use  TEXT_IO;
			--------------
procedure			ONE_BLOCK_SAVE
is			--------------

--  BLOCK_WIDTH		: constant NATURAL	:= 150;	 -- caracteres utiles par ligne
--  NUM_PREFIX_LEN		: constant NATURAL	:= 5;	 -- "NNNN " en tete
--  BLOCKS_PER_NUMBER		: constant NATURAL	:= 10;	 -- numerotation tous les N blocs
--  BLOCKS_PER_SECTION	: constant NATURAL	:= 50;	 -- ligne	vide tous	les N blocs

  LIST_FILE_STR		: STRING(	1 .. 128 );
  LIST_FILE_LEN		: NATURAL		:= 0;
  LIST_FILE		: FILE_TYPE;

  PROCESSED_FILE_STR	: STRING(	1 .. 256 );
  PROCESSED_FILE_STR_LEN	: NATURAL		:= 0;

  BLOCKED_FILE		: FILE_TYPE;

		--------------------
  function	STRIP_LEADING_DOTDOT	( PATHED_FILE_NAME :STRING )	return STRING
  is		--------------------
    -- Supprime les	sequences	initiales	"../" et "./" d'un chemin,
    -- de	sorte que	"../../src/foo/bar.adb" devienne "src/foo/bar.adb".
    ID			: NATURAL	:= PATHED_FILE_NAME'FIRST;
  begin
    loop
      if	ID + 2 <=	PATHED_FILE_NAME'LAST
        and then PATHED_FILE_NAME( ID .. ID+2 ) =	"../"
      then
        ID := ID + 3;
      elsif  ID + 1	<= PATHED_FILE_NAME'LAST
        and then PATHED_FILE_NAME( ID .. ID+1 ) =	"./"
      then
        ID := ID + 2;
      else
        exit;
      end	if;
    end loop;
    return PATHED_FILE_NAME( ID .. PATHED_FILE_NAME'LAST );

  end	STRIP_LEADING_DOTDOT;
	--------------------


		----------
  procedure	BLOCK_FILE	( FILE_IN, FILE_OUT	:in FILE_TYPE )
  is		----------
    PROCESS_IN_BUFFER	: STRING(	1 .. 512 );
    LINE_LEN		: NATURAL		:= 0;
--    PROCESS_OUT_BUFFER	: STRING(	1 .. BLOCK_WIDTH );
--    OCAR			: NATURAL		:= 0;
--    BLOCK_COUNT		: NATURAL		:= 0;

  begin
			-----------------
			PROCESS_ALL_LINES:
    while	 not END_OF_FILE( FILE_IN )  loop
      GET_LINE( FILE_IN, PROCESS_IN_BUFFER, LINE_LEN );
		----------------
		PROCESS_ONE_LINE:
      for	 ICAR in 1 .. LINE_LEN  loop

        if  PROCESS_IN_BUFFER( ICAR ) =	ASCII.HT	then
	PUT( FILE_OUT, CHARACTER'VAL( 172 ) );

        elsif  CHARACTER'POS(	PROCESS_IN_BUFFER( ICAR ) ) in 32 .. 126  then
	PUT( FILE_OUT, PROCESS_IN_BUFFER( ICAR ) );
        end if;

      end	loop	PROCESS_ONE_LINE;
		----------------

      PUT( FILE_OUT, CHARACTER'VAL( 182 ) );

    end loop	PROCESS_ALL_LINES;
		-----------------

  end	BLOCK_FILE;
	----------


begin
  PUT( "NOM DU FICHIER LISTE DE TEXTES SOURCES : " );
  GET_LINE( LIST_FILE_STR, LIST_FILE_LEN );
  OPEN( LIST_FILE, IN_FILE, LIST_FILE_STR( 1 .. LIST_FILE_LEN ) );

  CREATE(	BLOCKED_FILE, OUT_FILE, "../Archivage_Encode/TLALOC_block.txt" );

  while  not END_OF_FILE( LIST_FILE )  loop
    GET_LINE( LIST_FILE, PROCESSED_FILE_STR, PROCESSED_FILE_STR_LEN );
    if  PROCESSED_FILE_STR_LEN /= 0 and	then PROCESSED_FILE_STR( 1 ) /= '#'  then
		----------------
		PROCESS_ONE_FILE:
      declare
        PROCESSED_FILE	: FILE_TYPE;
        OPEN_OK		: BOOLEAN	:= FALSE;
      begin
        begin
	OPEN( PROCESSED_FILE, IN_FILE, PROCESSED_FILE_STR( 1 .. PROCESSED_FILE_STR_LEN ) );
	OPEN_OK := TRUE;
        exception
	when NAME_ERROR =>
	PUT_LINE(	"FICHIER SOURCE INEXISTANT " &  PROCESSED_FILE_STR( 1 .. PROCESSED_FILE_STR_LEN	) );
        end;

        if  OPEN_OK	 then
	declare
	  REL_PATH	:constant	STRING
			:= STRIP_LEADING_DOTDOT( PROCESSED_FILE_STR( 1 ..	PROCESSED_FILE_STR_LEN ) );
	  OUT_FILE_STR	:constant	STRING	:= "./" & REL_PATH;
	begin
	  PUT_LINE( "PROCESSING : " &	REL_PATH );
	  PUT( BLOCKED_FILE, "-- " & OUT_FILE_STR & CHARACTER'VAL( 182 ) );
	  BLOCK_FILE( PROCESSED_FILE, BLOCKED_FILE );
	  CLOSE( PROCESSED_FILE );
	end;
        end if;

      end	PROCESS_ONE_FILE;
	----------------
    end if;
  end loop;

  CLOSE( BLOCKED_FILE );
  CLOSE( LIST_FILE );

exception
  when NAME_ERROR =>
    PUT_LINE( "FICHIER LISTE INEXISTANT " &  LIST_FILE_STR(	1 .. LIST_FILE_LEN ) );
end	ONE_BLOCK_SAVE;
