with MACHINE_CODE;
use  MACHINE_CODE;
					-------
	package body			TEXT_IO
is					-------

  STDOUT_PAGE_LENGTH	: COUNT		:= 0;
  STDOUT_LINE_LENGTH	: COUNT		:= 256;
  STDOUT_PAGE		: POSITIVE_COUNT	:= 1;
  STDOUT_LINE		: POSITIVE_COUNT	:= 1;
  STDOUT_COL		: POSITIVE_COUNT	:= 1;

  DEFAULT_INPUT		: FILE_TYPE;
  DEFAULT_OUTPUT		: FILE_TYPE;
  STD_INPUT		: FILE_TYPE;
  STD_OUTPUT		: FILE_TYPE;


			--   F I L E   M A N A G E M E N T


			------
  procedure		CREATE		( FILE :in out FILE_TYPE;
					  MODE :in FILE_MODE := OUT_FILE;
					  NAME :in STRING := "";
					  FORM :in STRING := ""
					)
  is			------

    ERR_OR_ID	: INTEGER;

		------------------
    function	CREATE_SYSTEM_CALL	( NAME :in STRING )	return INTEGER
    is		-----------------
    begin
      ASM_OP_2'( OPCODE => LA, LVL => 2, OFS => -8 );
      ASM_OP_0'( OPCODE => SYS_FILE_CREATE );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -16 );

    end	CREATE_SYSTEM_CALL;
	------------------

  begin
    ERR_OR_ID := CREATE_SYSTEM_CALL( NAME );
    if  ERR_OR_ID >= 0  then
      FILE.ID := ERR_OR_ID;
      FILE.NAME( 1 .. NAME'LENGTH ) := NAME;
      FILE.NAME_LEN := NAME'LENGTH;
      FILE.IS_OPENED := TRUE;
      FILE.MODE := MODE;
      FILE.PAGE_LENGTH := STDOUT_PAGE_LENGTH;
      FILE.LINE_LENGTH := STDOUT_LINE_LENGTH;
      FILE.PAGE := 1;
      FILE.LINE := 1;
      FILE.COL  := 1;
      FILE.IS_DEFAULT_IO	:= FALSE;
      FILE.LOOK_AHEAD	:= ASCII.NUL;
      FILE.HAS_LOOK_AHEAD	:= FALSE;
      FILE.AT_END_OF_FILE	:= FALSE;
    end if;

  end	CREATE;
	------


			----
  procedure		OPEN		( FILE :in out FILE_TYPE;
					  MODE :in FILE_MODE;
					  NAME :in STRING;
					  FORM :in STRING := ""
					)
  is			----

    ERR_OR_ID	: INTEGER;

		----------------
    function	OPEN_SYSTEM_CALL	( NAME :in STRING )	return INTEGER
    is		----------------
    begin
      ASM_OP_2'( OPCODE => LA, LVL => 2, OFS => -8 );
      ASM_OP_0'( OPCODE => SYS_FILE_OPEN );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -16 );							-- Retour du File ID

    end	OPEN_SYSTEM_CALL;
	----------------

  begin
    ERR_OR_ID := OPEN_SYSTEM_CALL( NAME );
    if  ERR_OR_ID >= 0  then
      FILE.ID := ERR_OR_ID;
      FILE.NAME( 1 .. NAME'LENGTH ) := NAME;
      FILE.NAME_LEN := NAME'LENGTH;
      FILE.IS_OPENED := TRUE;
      FILE.MODE := MODE;
      FILE.PAGE_LENGTH := STDOUT_PAGE_LENGTH;
      FILE.LINE_LENGTH := STDOUT_LINE_LENGTH;
      FILE.PAGE := 1;
      FILE.LINE := 1;
      FILE.COL  := 1;
      FILE.IS_DEFAULT_IO	:= FALSE;
      FILE.LOOK_AHEAD	:= ASCII.NUL;
      FILE.HAS_LOOK_AHEAD	:= FALSE;
      FILE.AT_END_OF_FILE	:= FALSE;
    end if;

  end	OPEN;
	----


			-----
  procedure		CLOSE		( FILE :in out FILE_TYPE )
  is			-----

    ERR_CODE	: INTEGER;

 		-----------------
    function	CLOSE_SYSTEM_CALL	( FILE_ID :in INTEGER )	return INTEGER
    is		-----------------
    begin
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );
      ASM_OP_0'( OPCODE => SYS_FILE_CLOSE );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -16 );			-- Retour du resultat syscall

    end	CLOSE_SYSTEM_CALL;
    -----------------

  begin
    ERR_CODE := CLOSE_SYSTEM_CALL( FILE.ID );
    FILE.ID := -1;
    FILE.IS_OPENED := FALSE;

  end	CLOSE;
	-----


			------
  procedure		DELETE		( FILE :in out FILE_TYPE )
  is			------

    ERR_CODE	: INTEGER;

		------------------
    function	DELETE_SYSTEM_CALL	( NAME : STRING )	return INTEGER
    is		------------------

    begin
      ASM_OP_2'( OPCODE => La, LVL => 2, OFS => -8 );
      ASM_OP_0'( OPCODE => SYS_FILE_DELETE );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -16 );			-- Retour du resultat syscall

    end	DELETE_SYSTEM_CALL;
	------------------

  begin
    ERR_CODE := DELETE_SYSTEM_CALL( FILE.NAME( 1 .. FILE.NAME_LEN ) );
    FILE.IS_OPENED := FALSE;

  end	DELETE;
	------


			-----
  procedure		RESET		( FILE :in out FILE_TYPE; MODE :in FILE_MODE )
  is			-----

    ERR_CODE	: INTEGER;

		--------------
    function	SEEK_SYSTEM_CALL	( FILE_ID :in INTEGER )		return INTEGER
    is		--------------
    begin
      ASM_OP_1'( OPCODE => LI, VAL => 0 );				-- OFFSET = 0 (debut du fichier)
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );			-- FILE_ID
      ASM_OP_0'( OPCODE => SYS_FILE_SET_POS );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -16 );			-- Retour du resultat syscall

    end	SEEK_SYSTEM_CALL;
	--------------

  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    ERR_CODE := SEEK_SYSTEM_CALL( FILE.ID );
    FILE.MODE := MODE;
    FILE.PAGE := 1;
    FILE.LINE := 1;
    FILE.COL  := 1;
    FILE.AT_END_OF_FILE := FALSE;
    FILE.HAS_LOOK_AHEAD := FALSE;

  end	RESET;
	-----


			-----
  procedure		RESET		( FILE :in out FILE_TYPE )
  is			-----
  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    RESET( FILE, FILE.MODE );

  end	RESET;
	-----


			----
  function		MODE		( FILE :in FILE_TYPE )		return FILE_MODE
  is			----
  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    return FILE.MODE;

  end	MODE;
	----


			----
  function		NAME		( FILE :in FILE_TYPE )		return STRING
  is			----
  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    return FILE.NAME( 1 .. FILE.NAME_LEN );

  end	NAME;
	----


			----
  function		FORM		( FILE :in FILE_TYPE )		return STRING
  is			----
  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    return "";

  end	FORM;
	----


			-------
  function		IS_OPEN		( FILE :in FILE_TYPE )		return BOOLEAN
  is			-------
  begin
    return FILE.IS_OPENED;

  end	IS_OPEN;
	-------


           		-- Control of default input and output files


			---------
  procedure		SET_INPUT		( FILE :in FILE_TYPE )
  is			---------
  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    if  FILE.MODE /= IN_FILE  then raise MODE_ERROR; end if;
    DEFAULT_INPUT := FILE;

  end	SET_INPUT;
	---------


			----------
  procedure		SET_OUTPUT	( FILE :in FILE_TYPE )
  is			----------
  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    if  FILE.MODE /= OUT_FILE  then raise MODE_ERROR; end if;
    DEFAULT_OUTPUT := FILE;

  end	SET_OUTPUT;
	----------


			--------------
  function		STANDARD_INPUT					return FILE_TYPE
  is			--------------
  begin
    return STD_INPUT;

  end	STANDARD_INPUT;
	--------------


			---------------
  function		STANDARD_OUTPUT					return FILE_TYPE
  is			---------------
  begin
    return STD_OUTPUT;

  end	STANDARD_OUTPUT;
	---------------


			-------------
  function		CURRENT_INPUT					return FILE_TYPE
  is			-------------
  begin
    return DEFAULT_INPUT;

  end	CURRENT_INPUT;
	-------------


			--------------
  function		CURRENT_OUTPUT					return FILE_TYPE
  is			--------------
  begin
    return DEFAULT_OUTPUT;

  end	CURRENT_OUTPUT;
	--------------


			-- Specification of line and page lengths


			---------------
  procedure		SET_LINE_LENGTH	( FILE :in FILE_TYPE; TO :in COUNT )
  is			---------------
  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    if  FILE.MODE /= OUT_FILE  then raise MODE_ERROR; end if;
    FILE.LINE_LENGTH := TO;

  end	SET_LINE_LENGTH;
	---------------


			---------------
  procedure		SET_LINE_LENGTH	( TO :in COUNT)
  is			---------------
  begin
    SET_LINE_LENGTH( DEFAULT_OUTPUT, TO );

  end	SET_LINE_LENGTH;
	---------------


			---------------
  procedure		SET_PAGE_LENGTH	( FILE :in FILE_TYPE; TO :in COUNT )
  is			---------------
  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    if  FILE.MODE /= OUT_FILE  then raise MODE_ERROR; end if;
    FILE.PAGE_LENGTH := TO;
  end	SET_PAGE_LENGTH;
	---------------


			---------------
  procedure		SET_PAGE_LENGTH	( TO :in COUNT)
  is			---------------
  begin
    SET_PAGE_LENGTH( DEFAULT_OUTPUT, TO );

  end	SET_PAGE_LENGTH;
	---------------


			-----------
  function		LINE_LENGTH	( FILE :in FILE_TYPE )		return COUNT
  is			-----------
  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    if  FILE.MODE /= OUT_FILE  then raise MODE_ERROR; end if;
    return FILE.LINE_LENGTH;

  end	LINE_LENGTH;
	-----------


			-----------
  function		LINE_LENGTH					return COUNT
  is			-----------
  begin
    return LINE_LENGTH( DEFAULT_OUTPUT );

  end	LINE_LENGTH;
	-----------


			-----------
  function		PAGE_LENGTH	( FILE :in FILE_TYPE )		return COUNT
  is			-----------
  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    if  FILE.MODE /= OUT_FILE  then raise MODE_ERROR; end if;
    return FILE.PAGE_LENGTH;

  end	PAGE_LENGTH;
	-----------


			-----------
  function		PAGE_LENGTH					return COUNT
  is			-----------
  begin
    return PAGE_LENGTH( DEFAULT_OUTPUT );

  end	PAGE_LENGTH;
	-----------


			-- Column, Line, and Page Control


			--------
  procedure		NEW_LINE		( FILE    :in FILE_TYPE;
					  SPACING :in POSITIVE_COUNT := 1 )
  is			--------
  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    if  FILE.MODE /= OUT_FILE  then raise MODE_ERROR; end if;

    PUT( FILE, ASCII.CR );
    FILE.COL := 1;											-- LRM 14.3.4(3) col := 1
    for  N in 1 .. SPACING  loop
      PUT( FILE, ASCII.LF );
    end loop;
    FILE.LINE := FILE.LINE + SPACING;
    if  FILE.PAGE_LENGTH /= 0  and then  FILE.LINE > FILE.PAGE_LENGTH  then
      PUT( FILE,ASCII.FF );
      FILE.PAGE := FILE.PAGE + 1;
      FILE.LINE := 1;
    end if;

  end	NEW_LINE;
	--------


			--------
  procedure		NEW_LINE		( SPACING :in POSITIVE_COUNT := 1 )
  is			--------
  begin
    NEW_LINE( DEFAULT_OUTPUT, SPACING );

  end	NEW_LINE;
	--------


			---------
  procedure		SKIP_LINE		( FILE	:in FILE_TYPE;
					  SPACING	:in POSITIVE_COUNT := 1 )
  is			---------

    CH		: CHARACTER;
    LINES_SKIPPED	: COUNT		:= 0;

  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    if  FILE.MODE /= IN_FILE  then raise MODE_ERROR; end if;

    loop
      exit when  FILE.AT_END_OF_FILE;
      GET( FILE, CH );
      exit when  FILE.AT_END_OF_FILE;
      if  CH = ASCII.LF  then
        LINES_SKIPPED := LINES_SKIPPED + 1;
        FILE.LINE := FILE.LINE + 1;
        FILE.COL := 1;
        exit when  LINES_SKIPPED >= SPACING;
      end if;
    end loop;

  end	SKIP_LINE;
	---------


			---------
  procedure		SKIP_LINE		( SPACING :in POSITIVE_COUNT := 1 )
  is			---------
  begin
    SKIP_LINE( DEFAULT_INPUT, SPACING );

  end	SKIP_LINE;
	---------


			-----------
  function		END_OF_LINE	( FILE :in FILE_TYPE)		return BOOLEAN
  is			-----------

    CH	: CHARACTER;

  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    if  FILE.MODE /= IN_FILE  then raise MODE_ERROR; end if;
    if  FILE.AT_END_OF_FILE  then return TRUE; end if;
    if  FILE.HAS_LOOK_AHEAD  then
      return FILE.LOOK_AHEAD = ASCII.LF;
    end if;
    -- Tenter de lire un caractere
    GET( FILE, CH );
    if  FILE.AT_END_OF_FILE  then
      return TRUE;
    else
      FILE.LOOK_AHEAD := CH;
      FILE.HAS_LOOK_AHEAD := TRUE;
      return CH = ASCII.LF;
    end if;

  end	END_OF_LINE;
	-----------


			-----------
  function		END_OF_LINE					return BOOLEAN
  is			-----------
  begin null;
    return END_OF_LINE( DEFAULT_INPUT );

  end	END_OF_LINE;
	-----------


			--------
  procedure		NEW_PAGE		( FILE :in FILE_TYPE )
  is			--------
  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    if  FILE.MODE /= OUT_FILE  then raise MODE_ERROR; end if;
    if  FILE.COL /= 1  then
      NEW_LINE( FILE );
    end if;
    PUT( FILE, ASCII.FF );
    FILE.PAGE := FILE.PAGE + 1;
    FILE.LINE := 1;

  end	NEW_PAGE;
	--------


			--------
  procedure		NEW_PAGE
  is			--------
  begin
    NEW_PAGE( DEFAULT_OUTPUT );

  end	NEW_PAGE;
	----


			---------
  procedure		SKIP_PAGE		( FILE :in FILE_TYPE )
  is			---------

    CH	: CHARACTER;

  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    if  FILE.MODE /= IN_FILE  then raise MODE_ERROR; end if;
    loop
      exit when  FILE.AT_END_OF_FILE;
      GET( FILE, CH );
      exit when  FILE.AT_END_OF_FILE;
      if  CH = ASCII.LF  then
        FILE.LINE := FILE.LINE + 1;
        FILE.COL := 1;
      end if;
      exit when  CH = ASCII.FF;
    end loop;
    FILE.PAGE := FILE.PAGE + 1;
    FILE.LINE := 1;
    FILE.COL := 1;

  end	SKIP_PAGE;
	---------


			---------
  procedure		SKIP_PAGE
  is			---------
  begin
    SKIP_PAGE( DEFAULT_INPUT );

  end	SKIP_PAGE;
	---------


			-----------
  function		END_OF_PAGE	( FILE :in FILE_TYPE ) 		return BOOLEAN
  is			-----------

    CH	: CHARACTER;

  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    if  FILE.MODE /= IN_FILE  then raise MODE_ERROR; end if;
    if  FILE.AT_END_OF_FILE  then return TRUE; end if;
    if  FILE.HAS_LOOK_AHEAD  then
      return FILE.LOOK_AHEAD = ASCII.FF;
    end if;
    -- Tenter de lire un caractere
    GET( FILE, CH );
    if  FILE.AT_END_OF_FILE  then
      return TRUE;
    else
      FILE.LOOK_AHEAD := CH;
      FILE.HAS_LOOK_AHEAD := TRUE;
      return CH = ASCII.FF;
    end if;

  end	END_OF_PAGE;
	-----------


			-----------
  function		END_OF_PAGE 					return BOOLEAN
  is			-----------
  begin
    return END_OF_PAGE( DEFAULT_INPUT );

  end	END_OF_PAGE;
	-----------


			-----------
  function		END_OF_FILE	( FILE :in FILE_TYPE )		return BOOLEAN
  is			-----------

    CH	: CHARACTER;

  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    if  FILE.MODE /= IN_FILE  then raise MODE_ERROR; end if;
    if  FILE.AT_END_OF_FILE  then return TRUE; end if;
    if  FILE.HAS_LOOK_AHEAD  then return FALSE; end if;
    -- Tenter de lire un caractere
    GET( FILE, CH );
    if  FILE.AT_END_OF_FILE  then
      return TRUE;
    else
      FILE.LOOK_AHEAD := CH;
      FILE.HAS_LOOK_AHEAD := TRUE;
      return FALSE;
    end if;

  end	END_OF_FILE;
	-----------


			-----------
  function		END_OF_FILE					return BOOLEAN
  is			-----------
  begin
    return END_OF_FILE( DEFAULT_INPUT );

  end	END_OF_FILE;
	-----------


			-------
  procedure		SET_COL		( FILE :in FILE_TYPE; TO :in POSITIVE_COUNT )
  is			-------
  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;

-- A FINIR LRM 14.3.4 (28-33)
    if  FILE.MODE /= IN_FILE  then
      FILE.COL := TO;
    else
      FILE.COL := TO;
    end if;

  end	SET_COL;
	-------


			-------
  procedure		SET_COL		( TO :in POSITIVE_COUNT )
  is			-------
  begin
    SET_COL( DEFAULT_OUTPUT, TO );

  end	SET_COL;
	-------


			--------
  procedure 		SET_LINE		( FILE :in FILE_TYPE; TO :in POSITIVE_COUNT )
  is			--------
  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;

-- A FINIR LRM 14.3.4 (35-40)
    if  FILE.MODE /= IN_FILE  then
      FILE.LINE := TO;
    else
      FILE.LINE := TO;
    end if;

  end	SET_LINE;
	--------


			--------
  procedure		SET_LINE		( TO :in POSITIVE_COUNT )
  is			--------
  begin
    SET_LINE( DEFAULT_OUTPUT, TO );

  end	SET_LINE;
	--------


			---
  function		COL		( FILE :in FILE_TYPE )		return POSITIVE_COUNT
  is			---
  begin
    if  FILE.COL > COUNT'LAST  then raise LAYOUT_ERROR; end if;
    return FILE.COL;

  end	COL;
	---


			---
  function		COL						return POSITIVE_COUNT
  is			---
  begin
    return COL( DEFAULT_OUTPUT );

  end	COL;
	---


			----
  function		LINE		( FILE :in FILE_TYPE )		return POSITIVE_COUNT
  is			----
  begin
    if  FILE.LINE > COUNT'LAST  then raise LAYOUT_ERROR; end if;
    return FILE.LINE;

  end	LINE;
	----


			----
  function		LINE						return POSITIVE_COUNT
  is			----
  begin
    return LINE( DEFAULT_OUTPUT );

  end	LINE;
	----


			----
  function		PAGE		( FILE :in FILE_TYPE )		return POSITIVE_COUNT
  is			----
  begin
    if  FILE.PAGE > COUNT'LAST  then raise LAYOUT_ERROR; end if;
    return FILE.PAGE;

  end	PAGE;
	----


			----
  function		PAGE 						return POSITIVE_COUNT
  is			----
  begin
    return PAGE( DEFAULT_OUTPUT );

  end	PAGE;
	----


			-- Character Input-Output


			---
  procedure		GET		( FILE :in FILE_TYPE; ITEM :out CHARACTER )
  is			---

    BYTES_READ	: INTEGER;

		----------------
    function	READ_SYSTEM_CALL		( FILE_ID :in INTEGER )		return INTEGER
    is		----------------
    begin
      ASM_OP_1'( OPCODE => LI, VAL => 1 );								-- push LENGTH = 1 octet (immediat)
      ASM_OP_2'( OPCODE => La, LVL => 1, OFS => -16 );							-- push @ITEM : charge l'adresse destination (out param GET level 1 offset -16)
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );							-- push FILE_ID (in param READ_SYSTEM_CALL level 2 offset -8)
      ASM_OP_0'( OPCODE => SYS_FILE_READ );								-- (-8) FILE_ID ; (-16) @ITEM ; (-24) LENGTH
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -16 );							-- Retour du BYTES_READ

    end	READ_SYSTEM_CALL;
	-----------------

  begin
    if  FILE.HAS_LOOK_AHEAD  then
      ITEM := FILE.LOOK_AHEAD;
      FILE.HAS_LOOK_AHEAD := FALSE;
    elsif  FILE.ID = -1  then										-- standard console input
      ASM_OP_2'( OPCODE => La, LVL => 1, OFS => -16 );							-- push @ITEM : charge l'adresse destination (out param GET level 1 offset -16)
      ASM_OP_0'( OPCODE => SYS_GET_CHAR );								-- get console char
    else
      BYTES_READ := READ_SYSTEM_CALL( FILE.ID );								-- general file
      if  BYTES_READ = 0  then
        FILE.AT_END_OF_FILE := TRUE;
        ITEM := ASCII.NUL;
      end if;
    end if;

  end	GET;
	----


			---
  procedure		GET		( ITEM :out CHARACTER )
  is			---
  begin
    GET( DEFAULT_INPUT, ITEM );

  end	GET;
	----


			---
  procedure		PUT		( FILE :in FILE_TYPE; ITEM :in CHARACTER )
  is			---

    ERR_CODE	: INTEGER;

  		-----------------
    function	WRITE_SYSTEM_CALL		( ID : INTEGER )		return INTEGER
    is		-----------------
    begin
      ASM_OP_1'( OPCODE => LI,  VAL => 1 );								-- push LENGTH en -24
      ASM_OP_2'( OPCODE => LVa, LVL => 1, OFS => -16 );							-- push @CHAR (in param PUT level 1 offset -16)
      ASM_OP_2'( OPCODE => Ld,  LVL => 2, OFS => -8 );							-- ID  (in param WRITE_SYSTEM_CALL level 2 offset -8)
      ASM_OP_0'( OPCODE => SYS_FILE_WRITE );								-- (-8) FILE_ID ; (-16) @ITEM ; (-24) LENGTH
      ASM_OP_2'( OPCODE => SD,  LVL => 2, OFS => -16 );							-- Retour du resultat syscall

    end	WRITE_SYSTEM_CALL;
	-----------------
  begin
    if  FILE.ID = -1  then										-- standard console output
      ASM_OP_2'( OPCODE => LB, LVL => 1, OFS => -16 );
      ASM_OP_0'( OPCODE => SYS_PUT_CHAR );
    else
      ERR_CODE := WRITE_SYSTEM_CALL( FILE.ID );								-- general file
    end if;

  end	PUT;
	----


			---
  procedure		PUT		( ITEM :in CHARACTER )
  is			---
  begin
    PUT( DEFAULT_OUTPUT, ITEM );

  end	PUT;
	----


			-- String Input-Output


			---
  procedure		GET		( FILE :in FILE_TYPE; ITEM :out STRING )
  is			---

    BYTES_READ	: INTEGER;

		-----------------
    function	READ_SYSTEM_CALL		( FILE_ID :INTEGER; LENGTH :POSITIVE )		return INTEGER
    is		-----------------
    begin
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -16 );			-- LENGTH
      ASM_OP_2'( OPCODE => LIa, LVL => 1, OFS => -16 );			-- @CHARS : adresse des donnees de ITEM (2e param de GET)
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );			-- FILE_ID
      ASM_OP_0'( OPCODE => SYS_FILE_READ );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -24 );			-- Retour du BYTES_READ

    end	READ_SYSTEM_CALL;
	-----------------

  begin
    if  FILE.ID = -1  then
      for  I  in  ITEM'FIRST .. ITEM'LAST  loop
        GET( FILE, ITEM( I ) );
      end loop;
    else
      BYTES_READ := READ_SYSTEM_CALL( FILE.ID, ITEM'LENGTH );
    end if;

  end	GET;
	----


			---
  procedure		GET		( ITEM :out STRING )
  is			---
  begin
    GET( DEFAULT_INPUT, ITEM );

  end	GET;
	----


			---
  procedure		PUT		( FILE :in FILE_TYPE; ITEM :in STRING )
  is			---

    ERR_CODE	: INTEGER;

  		-----------------
    function	WRITE_SYSTEM_CALL		( FILE_ID :INTEGER; LENGTH :POSITIVE )		return INTEGER
    is		-----------------
    begin
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -16 );							-- LENGTH en -16
      ASM_OP_2'( OPCODE => LIa, LVL => 1, OFS => -16 );							-- @CHARS sur parametre ITEM de PUT
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );							-- ID
      ASM_OP_0'( OPCODE => SYS_FILE_WRITE );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -24 );							-- Retour du resultat syscall

    end	WRITE_SYSTEM_CALL;
	-----------------
  begin
    if  FILE.ID = -1  then
      ASM_OP_2'( OPCODE => LA, LVL => 1, OFS => -16 );
      ASM_OP_0'( OPCODE => SYS_PUT_STR );
    else
      ERR_CODE := WRITE_SYSTEM_CALL( FILE.ID, ITEM'LENGTH );
    end if;

  end	PUT;
	---


			---
  procedure		PUT		( ITEM :in STRING )
  is			---
  begin
    PUT( DEFAULT_OUTPUT, ITEM );

  end	PUT;
	----


			--------
  procedure		GET_LINE		( FILE :in FILE_TYPE;
					  ITEM :out STRING;
					  LAST :out NATURAL
					)
  is			--------

    CH	: CHARACTER;
    POS	: NATURAL		:= ITEM'FIRST;

  begin
    if  FILE.ID = -1  then									-- standard console input : utiliser SYS_GET_STR (mode canonique avec echo)
      ASM_OP_2'( OPCODE => La, LVL => 1, OFS => -24 );					-- push @LAST  (adresse du parametre out LAST)
      ASM_OP_2'( OPCODE => La, LVL => 1, OFS => -16 );					-- push @ITEM descripteur (adresse du parametre out ITEM = descripteur string)
      ASM_OP_0'( OPCODE => SYS_GET_STR );							-- lit une ligne stdin avec echo, stocke longueur dans LAST
    else
      LAST := ITEM'FIRST - 1;
      loop
        exit when  POS > ITEM'LAST;
        exit when  FILE.AT_END_OF_FILE;
        GET( FILE, CH );
        exit when  FILE.AT_END_OF_FILE;
        exit when  CH = ASCII.LF;
        if  CH /= ASCII.CR  then
	ITEM( POS ) := CH;
	LAST := POS;
	POS := POS + 1;
        end if;
      end loop;
    end if;

  end	GET_LINE;
	--------


			--------
  procedure		GET_LINE		( ITEM :out STRING; LAST :out NATURAL )
  is			--------
  begin
    GET_LINE( DEFAULT_INPUT, ITEM, LAST );

  end	GET_LINE;
	--------


			--------
  procedure		PUT_LINE		( FILE :in FILE_TYPE; ITEM :in STRING )
  is			--------
  begin
    PUT( FILE, ITEM );
    NEW_LINE( FILE );

  end	PUT_LINE;
	--------


			--------
  procedure		PUT_LINE		( ITEM :in STRING )
  is			--------
  begin
    PUT( DEFAULT_OUTPUT, ITEM );
    NEW_LINE( DEFAULT_OUTPUT );

  end	PUT_LINE;
	--------


			-- Generic package for Input-Output of Integer Types


  				----------
  package	body			INTEGER_IO
  is				----------

			---
    procedure		GET		( FILE  :in FILE_TYPE;
					  ITEM  :out NUM;
					  WIDTH :in FIELD := 0
					)
    is

      CH			: CHARACTER;
      VAL			: LONG_INTEGER	:= 0;     -- accumulation en 64 bits
      NEG			: BOOLEAN		:= FALSE;
      CHARS_READ		: NATURAL		:= 0;
      DONE		: BOOLEAN		:= FALSE;
      BASE		: LONG_INTEGER	:= 10;    -- base courante
      IN_BASED		: BOOLEAN		:= FALSE;

    begin

      if  WIDTH = 0  then
        loop
          exit when  FILE.AT_END_OF_FILE;
          GET( FILE, CH );
          exit when  FILE.AT_END_OF_FILE;
          exit when  CH /= ' '  and then  CH /= ASCII.HT
                              and then  CH /= ASCII.LF
                              and then  CH /= ASCII.CR;
        end loop;
      else
        GET( FILE, CH );
        CHARS_READ := 0;
      end if;

      -- Signe optionnel
      if  not FILE.AT_END_OF_FILE  and then  CH = '-'  then
        NEG := TRUE;
        if  WIDTH > 0  then
          CHARS_READ := CHARS_READ + 1;
          if  CHARS_READ >= WIDTH  then  DONE := TRUE;
          else  GET( FILE, CH );
          end if;
        else
          GET( FILE, CH );
        end if;
      elsif  not FILE.AT_END_OF_FILE  and then  CH = '+'  then
        if  WIDTH > 0  then
          CHARS_READ := CHARS_READ + 1;
          if  CHARS_READ >= WIDTH  then  DONE := TRUE;
          else  GET( FILE, CH );
          end if;
        else
          GET( FILE, CH );
        end if;
      end if;

      loop
        exit when  DONE  or else  FILE.AT_END_OF_FILE;
        if  WIDTH > 0  and then  CHARS_READ >= WIDTH  then  exit;  end if;

        if  CH >= '0'  and then  CH <= '9'  then
          VAL := BASE * VAL                               -- base courante (10 ou base#)
                     + LONG_INTEGER( CHARACTER'POS( CH ) - CHARACTER'POS( '0' ) );
          if  WIDTH > 0  then
            CHARS_READ := CHARS_READ + 1;
            if  CHARS_READ >= WIDTH  then  DONE := TRUE;
            else  GET( FILE, CH );
            end if;
          else
            GET( FILE, CH );
          end if;

        elsif  ( CH = 'A'  or else  CH = 'B'  or else  CH = 'C'
              or else  CH = 'D'  or else  CH = 'E'  or else  CH = 'F'
              or else  CH = 'a'  or else  CH = 'b'  or else  CH = 'c'
              or else  CH = 'd'  or else  CH = 'e'  or else  CH = 'f' )
              and then  IN_BASED  then
          if  CH >= 'a'  then
            VAL := BASE * VAL
                       + LONG_INTEGER( CHARACTER'POS( CH ) - CHARACTER'POS( 'a' ) + 10 );
          else
            VAL := BASE * VAL
                       + LONG_INTEGER( CHARACTER'POS( CH ) - CHARACTER'POS( 'A' ) + 10 );
          end if;
          if  WIDTH > 0  then
            CHARS_READ := CHARS_READ + 1;
            if  CHARS_READ >= WIDTH  then  DONE := TRUE;
            else  GET( FILE, CH );
            end if;
          else
            GET( FILE, CH );
          end if;

        elsif  CH = '#'  and then  not IN_BASED  then
          BASE     := VAL;                                -- VAL contient la base
          VAL      := 0;
          IN_BASED := TRUE;
          if  WIDTH > 0  then
            CHARS_READ := CHARS_READ + 1;
            if  CHARS_READ >= WIDTH  then  DONE := TRUE;
            else  GET( FILE, CH );
            end if;
          else
            GET( FILE, CH );
          end if;

        elsif  CH = '#'  and then  IN_BASED  then
          if  WIDTH > 0  then  CHARS_READ := CHARS_READ + 1;  end if;
          DONE := TRUE;

        else
          if  WIDTH = 0  then
            FILE.LOOK_AHEAD     := CH;
            FILE.HAS_LOOK_AHEAD := TRUE;
          end if;
          DONE := TRUE;
        end if;
      end loop;

      if  NEG  then  ITEM := -NUM( VAL );
      else           ITEM := NUM(  VAL );
      end if;

    end	GET;
	---


			---
    procedure		GET		( ITEM  :out NUM; WIDTH : in FIELD := 0)
    is			---
    begin
      GET( DEFAULT_INPUT, ITEM, WIDTH );

    end	GET;
	----


			---
    procedure		PUT		( FILE  :in FILE_TYPE;
					  ITEM  :in NUM;
					  WIDTH :in FIELD		:= DEFAULT_WIDTH;
					  BASE  :in NUMBER_BASE	:= DEFAULT_BASE
					)
    is			---

      LBASE		: LONG_INTEGER		:= LONG_INTEGER( BASE );
      AVAL		: LONG_INTEGER;		-- valeur absolue, toujours >= 0
      STR			: STRING( 1 .. 68 );
      POS			: POSITIVE		:= STR'LAST;
      IS_NEGATIVE		: BOOLEAN			:= ITEM < 0;
      DIGIT		: INTEGER;
      DLEN		: NATURAL;
      TLEN		: NATURAL;

    begin
      -- Conversion en valeur absolue dans LONG_INTEGER :
      -- meme NUM'FIRST (ex: -2147483648) ne deborde pas en LONG_INTEGER.
      if  IS_NEGATIVE  then
        AVAL := -LONG_INTEGER( ITEM );
      else
        AVAL :=  LONG_INTEGER( ITEM );
      end if;

      loop
        DIGIT := INTEGER( AVAL mod LBASE );     -- AVAL >= 0, resultat toujours >= 0
        if  DIGIT < 10  then
          STR( POS ) := CHARACTER'VAL( CHARACTER'POS( '0' ) + DIGIT );
        else
          STR( POS ) := CHARACTER'VAL( CHARACTER'POS( 'A' ) + DIGIT - 10 );
        end if;
        AVAL := AVAL / LBASE;
        exit when  AVAL = 0;
        POS  := POS - 1;
      end loop;

      DLEN := STR'LAST - POS + 1;
      TLEN := DLEN;
      if  IS_NEGATIVE  then  TLEN := TLEN + 1;  end if;
      if  BASE /= 10  then
        if  BASE >= 10  then  TLEN := TLEN + 4;
        else                  TLEN := TLEN + 3;
        end if;
      end if;

      if  WIDTH > TLEN  then
        for  I in 1 .. WIDTH - TLEN  loop
          PUT( FILE, ' ' );
        end loop;
      end if;

      if  IS_NEGATIVE  then  PUT( FILE, '-' );  end if;

      if  BASE /= 10  then
        if  BASE >= 10  then
          PUT( FILE, '1' );
          PUT( FILE, CHARACTER'VAL( CHARACTER'POS( '0' ) + BASE - 10 ) );
        else
          PUT( FILE, CHARACTER'VAL( CHARACTER'POS( '0' ) + BASE ) );
        end if;
        PUT( FILE, '#' );
      end if;

      PUT( FILE, STR( POS .. STR'LAST ) );

      if  BASE /= 10  then  PUT( FILE, '#' );  end if;

    end	PUT;
	---


			---
    procedure		PUT		( ITEM  :in NUM;
					  WIDTH :in FIELD		:= DEFAULT_WIDTH;
					  BASE  :in NUMBER_BASE	:= DEFAULT_BASE
					)
    is			---
    begin
      PUT( DEFAULT_OUTPUT, ITEM, WIDTH, BASE );

    end	PUT;
	----


			---
    procedure		GET		( FROM :in STRING;						-- LRM 14.3.7(14)
					  ITEM :out NUM;
					  LAST :out POSITIVE
					)
    is			---

      POS			: POSITIVE	:= FROM'FIRST;
      VAL			: INTEGER		:= 0;
      NEG			: BOOLEAN		:= FALSE;
      DONE		: BOOLEAN		:= FALSE;
      BASE		: INTEGER		:= 10;
      IN_BASED		: BOOLEAN		:= FALSE;
      CH			: CHARACTER;

    begin

      -- Saut des separateurs initiaux (blancs et horizontaux)
      -- LRM 14.3.7 : meme regle que GET fichier WIDTH=0,
      -- mais seuls les blancs sont sautes (pas les LF --
      -- un STRING ne contient pas de line terminators au sens TEXT_IO).
      while  POS <= FROM'LAST  and then
             ( FROM( POS ) = ' '  or else  FROM( POS ) = ASCII.HT )  loop
        POS := POS + 1;
      end loop;

      -- Signe optionnel
      if  POS <= FROM'LAST  then
        CH := FROM( POS );
        if  CH = '-'  then
          NEG := TRUE;
          POS := POS + 1;
        elsif  CH = '+'  then
          POS := POS + 1;
        end if;
      end if;

      -- Chiffres, based literals
      loop
        exit when  DONE  or else  POS > FROM'LAST;
        CH := FROM( POS );

        if  CH >= '0'  and then  CH <= '9'  then
					-- ATTENTION il faudra verifier que le chiffre est compatible avec la base ! Sinon raise DATA_ERROR
          VAL := BASE * VAL + INTEGER( CHARACTER'POS( CH ) - CHARACTER'POS( '0' ) );
          LAST := POS;
          POS  := POS + 1;

        elsif  ( CH = 'A'  or else  CH = 'B'  or else  CH = 'C'
              or else  CH = 'D'  or else  CH = 'E'  or else  CH = 'F'
              or else  CH = 'a'  or else  CH = 'b'  or else  CH = 'c'
              or else  CH = 'd'  or else  CH = 'e'  or else  CH = 'f' )
              and then  IN_BASED  then
          if  CH >= 'a'  then
            VAL := BASE * VAL + INTEGER( CHARACTER'POS( CH ) - CHARACTER'POS( 'a' ) + 10 );
          else
            VAL := BASE * VAL + INTEGER( CHARACTER'POS( CH ) - CHARACTER'POS( 'A' ) + 10 );
          end if;
          LAST := POS;
          POS  := POS + 1;

        elsif  CH = '#'  and then  not IN_BASED  then
          -- Premier '#' : VAL contient la base
          BASE     := VAL;
          VAL      := 0;
          IN_BASED := TRUE;
          LAST     := POS;
          POS      := POS + 1;

        elsif  CH = '#'  and then  IN_BASED  then
          -- Second '#' : fin du based literal
          LAST := POS;
          DONE := TRUE;

        else
          -- Caractere hors-token : on s'arrete, LAST reste sur le precedent
          DONE := TRUE;
        end if;
      end loop;

      if  NEG  then  ITEM := -NUM( VAL );
      else           ITEM :=  NUM( VAL );
      end if;

    end	GET;
	----


			---
    procedure		PUT		( TO   :out STRING;						-- LRM 14.3.7(17)
					  ITEM :in NUM;
					  BASE :in NUMBER_BASE	:= DEFAULT_BASE
					)
    is			---

      LBASE		: LONG_INTEGER		:= LONG_INTEGER( BASE );
      AVAL		: LONG_INTEGER;
      STR			: STRING( 1 .. 68 );
      POS			: POSITIVE		:= STR'LAST;
      IS_NEGATIVE		: BOOLEAN			:= ITEM < 0;
      DIGIT		: INTEGER;
      DLEN		: NATURAL;
      TLEN		: NATURAL;
      DST			: POSITIVE;

    begin

      if  IS_NEGATIVE  then
        AVAL := -LONG_INTEGER( ITEM );
      else
        AVAL :=  LONG_INTEGER( ITEM );
      end if;

      -- Meme extraction droite-a-gauche que PUT(FILE,...)
      loop
        DIGIT := INTEGER( AVAL mod LBASE );
        if  DIGIT < 10  then
          STR( POS ) := CHARACTER'VAL( CHARACTER'POS( '0' ) + DIGIT );
        else
          STR( POS ) := CHARACTER'VAL( CHARACTER'POS( 'A' ) + DIGIT - 10 );
        end if;
        AVAL := AVAL / LBASE;
        exit when  AVAL = 0;
        POS  := POS - 1;
      end loop;

      -- Calcul de la longueur totale formate (meme logique que PUT FILE)
      DLEN := STR'LAST - POS + 1;
      TLEN := DLEN;
      if  IS_NEGATIVE  then  TLEN := TLEN + 1;  end if;
      if  BASE /= 10  then
        if  BASE >= 10  then  TLEN := TLEN + 4;
        else                  TLEN := TLEN + 3;
        end if;
      end if;

      -- LRM 14.3.7 : si TLEN > TO'LENGTH -> LAYOUT_ERROR (non implemente).
      -- Ecriture dans TO, justifie a droite avec espaces a gauche,
      -- comme PUT(FILE, WIDTH => TO'LENGTH).
       if  TLEN > TO'LENGTH  then
        -- A remplacer ulterieurement par :
        --   raise LAYOUT_ERROR;
        for  I in TO'FIRST .. TO'LAST  loop
          TO( I ) := '*';
        end loop;
        return;
      end if;
      DST := TO'FIRST;

      -- Espaces de remplissage
      if  TO'LENGTH > TLEN  then
        for  I in 1 .. TO'LENGTH - TLEN  loop
          TO( DST ) := ' ';
          DST := DST + 1;
        end loop;
      end if;

      -- Signe
      if  IS_NEGATIVE  then
        TO( DST ) := '-';
        DST := DST + 1;
      end if;

      -- Prefixe base
      if  BASE /= 10  then
        if  BASE >= 10  then
          TO( DST ) := '1';
          DST := DST + 1;
          TO( DST ) := CHARACTER'VAL( CHARACTER'POS( '0' ) + BASE - 10 );
          DST := DST + 1;
        else
          TO( DST ) := CHARACTER'VAL( CHARACTER'POS( '0' ) + BASE );
          DST := DST + 1;
        end if;
        TO( DST ) := '#';
        DST := DST + 1;
      end if;

      -- Digits
      for  I in POS .. STR'LAST  loop
        TO( DST ) := STR( I );
        DST := DST + 1;
      end loop;

      -- Suffixe base
      if  BASE /= 10  then
        TO( DST ) := '#';
      end if;

    end	PUT;
	----


  end	INTEGER_IO;
	----------


			-- Generic package for Input-Output of Real Types


				--------
  package	body			FLOAT_IO
  is				--------

    			---
    procedure		GET		( FILE  :in FILE_TYPE;
					  ITEM  :out NUM;
					  WIDTH :in FIELD		:= 0
					)
    is			---

      CH		: CHARACTER;
      VAL		: NUM		:= 0.0;
      FRAC	: NUM		:= 0.1;
      NEG		: BOOLEAN		:= FALSE;
      IN_FRAC	: BOOLEAN		:= FALSE;
      EXP_VAL	: INTEGER		:= 0;
      EXP_NEG	: BOOLEAN		:= FALSE;
      CHARS_READ	: NATURAL		:= 0;
      DONE	: BOOLEAN		:= FALSE;

    begin

      if  WIDTH = 0  then
        loop
          exit when  FILE.AT_END_OF_FILE;
          GET( FILE, CH );
          exit when  FILE.AT_END_OF_FILE;
          exit when  CH /= ' '  and then  CH /= ASCII.HT
                              and then  CH /= ASCII.LF
                              and then  CH /= ASCII.CR;
        end loop;
      else
        GET( FILE, CH );
        CHARS_READ := 0;
      end if;

      -- Signe optionnel
      if  not FILE.AT_END_OF_FILE  and then  CH = '-'  then
        NEG := TRUE;
        if  WIDTH > 0  then
          CHARS_READ := CHARS_READ + 1;
          if  CHARS_READ >= WIDTH  then  DONE := TRUE;
          else  GET( FILE, CH );
          end if;
        else
          GET( FILE, CH );
        end if;
      elsif  not FILE.AT_END_OF_FILE  and then  CH = '+'  then
        if  WIDTH > 0  then
          CHARS_READ := CHARS_READ + 1;
          if  CHARS_READ >= WIDTH  then  DONE := TRUE;
          else  GET( FILE, CH );
          end if;
        else
          GET( FILE, CH );
        end if;
      end if;

      -- Mantisse et exposant
      loop
        exit when  DONE  or else  FILE.AT_END_OF_FILE;
        if  WIDTH > 0  and then  CHARS_READ >= WIDTH  then  exit;  end if;

        if  CH = '.'  then
          IN_FRAC := TRUE;
          if  WIDTH > 0  then
            CHARS_READ := CHARS_READ + 1;
            if  CHARS_READ >= WIDTH  then  DONE := TRUE;
            else  GET( FILE, CH );
            end if;
          else
            GET( FILE, CH );
          end if;

        elsif  CH = 'E'  or else  CH = 'e'  then
          if  WIDTH > 0  then
            CHARS_READ := CHARS_READ + 1;
            if  CHARS_READ >= WIDTH  then  DONE := TRUE;
            else  GET( FILE, CH );
            end if;
          else
            GET( FILE, CH );
          end if;
          if  not DONE  and then  not FILE.AT_END_OF_FILE  then
            if  CH = '-'  then
              EXP_NEG := TRUE;
              if  WIDTH > 0  then
                CHARS_READ := CHARS_READ + 1;
                if  CHARS_READ >= WIDTH  then  DONE := TRUE;
                else  GET( FILE, CH );
                end if;
              else
                GET( FILE, CH );
              end if;
            elsif  CH = '+'  then
              if  WIDTH > 0  then
                CHARS_READ := CHARS_READ + 1;
                if  CHARS_READ >= WIDTH  then  DONE := TRUE;
                else  GET( FILE, CH );
                end if;
              else
                GET( FILE, CH );
              end if;
            end if;
          end if;
          -- Chiffres de l'exposant
          loop
            exit when  DONE  or else  FILE.AT_END_OF_FILE;
            exit when  CH < '0'  or else  CH > '9';
            EXP_VAL := 10 * EXP_VAL
                           + CHARACTER'POS( CH ) - CHARACTER'POS( '0' );
            if  WIDTH > 0  then
              CHARS_READ := CHARS_READ + 1;
              if  CHARS_READ >= WIDTH  then  DONE := TRUE;
              else  GET( FILE, CH );
              end if;
            else
              GET( FILE, CH );
            end if;
          end loop;
          if  WIDTH = 0  and then  not FILE.AT_END_OF_FILE
                         and then  ( CH < '0'  or else  CH > '9' )  then
            FILE.LOOK_AHEAD     := CH;
            FILE.HAS_LOOK_AHEAD := TRUE;
          end if;
          DONE := TRUE;

        elsif  CH >= '0'  and then  CH <= '9'  then
          if  IN_FRAC  then
            VAL  := VAL + FRAC
                        * NUM( CHARACTER'POS( CH ) - CHARACTER'POS( '0' ) );
            FRAC := FRAC / 10.0;
          else
            VAL  := 10.0 * VAL
                        + NUM( CHARACTER'POS( CH ) - CHARACTER'POS( '0' ) );
          end if;
          if  WIDTH > 0  then
            CHARS_READ := CHARS_READ + 1;
            if  CHARS_READ >= WIDTH  then  DONE := TRUE;
            else  GET( FILE, CH );
            end if;
          else
            GET( FILE, CH );
          end if;

        else
          if  WIDTH = 0  then
            FILE.LOOK_AHEAD     := CH;
            FILE.HAS_LOOK_AHEAD := TRUE;
          end if;
          DONE := TRUE;
        end if;
      end loop;

      if  EXP_NEG  then
        for  J in 1 .. EXP_VAL  loop  VAL := VAL / 10.0;  end loop;
      else
        for  J in 1 .. EXP_VAL  loop  VAL := VAL * 10.0;  end loop;
      end if;

      if  NEG  then  ITEM := -VAL;
      else           ITEM :=  VAL;
      end if;

    end	GET;
	----


			---
    procedure		GET		( ITEM  :out NUM; WIDTH :in FIELD := 0)
    is			---
    begin
      GET( DEFAULT_INPUT, ITEM, WIDTH );

    end	GET;
	----


    			---
    procedure		PUT		( FILE :in FILE_TYPE;
					  ITEM :in NUM;
					  FORE :in FIELD		:= DEFAULT_FORE;
					  AFT  :in FIELD		:= DEFAULT_AFT;
					  EXP  :in FIELD		:= DEFAULT_EXP
					)
    is			---

      VAL		: NUM		:= ITEM;
      IS_NEGATIVE	: BOOLEAN		:= ITEM < 0.0;
      E		: INTEGER		:= 0;
      DIGIT	: INTEGER;
      FORE_LEN	: NATURAL;

    begin
      -- Traiter le signe
      if  IS_NEGATIVE  then
        VAL := -ITEM;
      end if;

      -- Calculer l'exposant : normaliser 1.0 <= VAL < 10.0
      if  VAL /= 0.0  then
        while  VAL >= 10.0  loop
          VAL := VAL / 10.0;
          E := E + 1;
        end loop;

        while  VAL < 1.0  loop
          VAL := VAL * 10.0;
          E := E - 1;
        end loop;
      end if;

      -- Arrondir la mantisse au nombre de chiffres demandes.
      -- L'extraction ulterieure des chiffres est volontairement tronquee.
      declare
        ROUNDING	: NUM	:= 0.5;
      begin
        for  I in  1 .. AFT  loop
          ROUNDING := ROUNDING / 10.0;
        end loop;

        VAL := VAL + ROUNDING;
      end;

      -- Propager une retenue issue de l'arrondi :
      -- 9.9999996E+n devient 1.000000E+(n+1).
      if  VAL >= 10.0  then
        VAL := VAL / 10.0;
        E := E + 1;
      end if;

      -- Padding FORE : le champ FORE inclut le signe et le chiffre avant le point
      -- Format : [-]d.dddE[+|-]dd
      -- Nombre de caracteres avant le point : 1 chiffre (+ signe eventuel)
      FORE_LEN := 1;
      if  IS_NEGATIVE  then
        FORE_LEN := 2;
      end if;
      if  FORE > FORE_LEN  then
        for  I in 1 .. FORE - FORE_LEN  loop
          PUT( FILE, ' ' );
        end loop;
      end if;

      -- Signe
      if  IS_NEGATIVE  then
        PUT( FILE, '-' );
      end if;

      -- Chiffre avant le point decimal
      DIGIT := INTEGER( VAL );
      if  DIGIT > 9  then DIGIT := 9; end if;				-- securite arrondi
      if  DIGIT < 0  then DIGIT := 0; end if;
      PUT( FILE, CHARACTER'VAL( CHARACTER'POS( '0' ) + DIGIT ) );
      VAL := ( VAL - NUM( DIGIT ) ) * 10.0;

      -- Point decimal
      PUT( FILE, '.' );

      -- Chiffres apres le point
      for  I in 1 .. AFT  loop
        DIGIT := INTEGER( VAL );
        if  DIGIT > 9  then DIGIT := 9; end if;
        if  DIGIT < 0  then DIGIT := 0; end if;
        PUT( FILE, CHARACTER'VAL( CHARACTER'POS( '0' ) + DIGIT ) );
        VAL := ( VAL - NUM( DIGIT ) ) * 10.0;
      end loop;

      -- Partie exposant
      if  EXP > 0  then
        PUT( FILE, 'E' );
        if  E < 0  then
          PUT( FILE, '-' );
          E := -E;
        else
          PUT( FILE, '+' );
        end if;
        -- Ecrire l'exposant avec EXP chiffres (padding zero a gauche)
        declare
          EXP_STR	: STRING( 1 .. EXP );
          POS	: NATURAL	:= EXP;
          EVAL	: INTEGER	:= E;
        begin
          for  I in reverse 1 .. EXP  loop
            EXP_STR( I ) := CHARACTER'VAL( CHARACTER'POS( '0' ) + EVAL mod 10 );
            EVAL := EVAL / 10;
          end loop;
          PUT( FILE, EXP_STR );
        end;
      end if;

    end	PUT;
    ----


    			---
    procedure		PUT		( ITEM :in NUM;
					  FORE :in FIELD		:= DEFAULT_FORE;
					  AFT  :in FIELD		:= DEFAULT_AFT;
					  EXP  :in FIELD		:= DEFAULT_EXP
					)
    is			---
    begin
      PUT( DEFAULT_OUTPUT, ITEM, FORE, AFT, EXP );

    end	PUT;
	----


			---
    procedure		GET		( FROM :in STRING;
					  ITEM :out NUM;
					  LAST :out POSITIVE
					)
    is			---

      POS		: POSITIVE	:= FROM'FIRST;
      VAL		: NUM		:= 0.0;
      FRAC	: NUM		:= 0.1;
      NEG		: BOOLEAN		:= FALSE;
      IN_FRAC	: BOOLEAN		:= FALSE;
      EXP_VAL	: INTEGER		:= 0;
      EXP_NEG	: BOOLEAN		:= FALSE;
      DONE	: BOOLEAN		:= FALSE;
      CH		: CHARACTER;

    begin
      -- Saut des separateurs initiaux (blancs et HT uniquement,
      -- pas de LF : un STRING n'est pas un flux de lignes)
      while  POS <= FROM'LAST  and then
             ( FROM( POS ) = ' '  or else  FROM( POS ) = ASCII.HT )  loop
        POS := POS + 1;
      end loop;

      -- Signe optionnel
      if  POS <= FROM'LAST  then
        CH := FROM( POS );
        if  CH = '-'  then
          NEG := TRUE;
          POS := POS + 1;
        elsif  CH = '+'  then
          POS := POS + 1;
        end if;
      end if;

      -- Mantisse et exposant
      loop
        exit when  DONE  or else  POS > FROM'LAST;
        CH := FROM( POS );

        if  CH = '.'  then
          IN_FRAC := TRUE;
          LAST    := POS;
          POS     := POS + 1;

        elsif  CH = 'E'  or else  CH = 'e'  then
          LAST := POS;
          POS  := POS + 1;
          -- Signe de l'exposant
          if  POS <= FROM'LAST  then
            CH := FROM( POS );
            if  CH = '-'  then
              EXP_NEG := TRUE;
              LAST    := POS;
              POS     := POS + 1;
            elsif  CH = '+'  then
              LAST := POS;
              POS  := POS + 1;
            end if;
          end if;
          -- Chiffres de l'exposant
          loop
            exit when  POS > FROM'LAST;
            CH := FROM( POS );
            exit when  CH < '0'  or else  CH > '9';
            EXP_VAL := 10 * EXP_VAL
                           + CHARACTER'POS( CH ) - CHARACTER'POS( '0' );
            LAST := POS;
            POS  := POS + 1;
          end loop;
          DONE := TRUE;

        elsif  CH >= '0'  and then  CH <= '9'  then
          if  IN_FRAC  then
            VAL  := VAL + FRAC
                        * NUM( CHARACTER'POS( CH ) - CHARACTER'POS( '0' ) );
            FRAC := FRAC / 10.0;
          else
            VAL  := 10.0 * VAL
                        + NUM( CHARACTER'POS( CH ) - CHARACTER'POS( '0' ) );
          end if;
          LAST := POS;
          POS  := POS + 1;

        else
          -- Caractere hors-token : LAST reste sur le precedent
          DONE := TRUE;
        end if;
      end loop;

      -- Application de l'exposant
      if  EXP_NEG  then
        for  J in 1 .. EXP_VAL  loop  VAL := VAL / 10.0;  end loop;
      else
        for  J in 1 .. EXP_VAL  loop  VAL := VAL * 10.0;  end loop;
      end if;

      if  NEG  then  ITEM := -VAL;
      else           ITEM :=  VAL;
      end if;

    end	GET;
	----


			---
    procedure		PUT		( TO   :out STRING;
					  ITEM :in NUM;
					  AFT  :in FIELD		:= DEFAULT_AFT;
					  EXP  :in INTEGER		:= DEFAULT_EXP
					)
    is			---

      IMAGE		: STRING( 1 .. 80 );
      LEN			: NATURAL		:= 0;
      POS			: INTEGER;
      PAD			: INTEGER;

      VAL			: LONG_FLOAT	:= LONG_FLOAT( ITEM );
      ROUNDING		: LONG_FLOAT	:= 0.5;
      FRC_PART		: LONG_FLOAT	:= 0.0;

      IS_NEGATIVE		: BOOLEAN		:= FALSE;
      BAD_LAYOUT		: BOOLEAN		:= FALSE;

      DIGIT		: INTEGER;
      IPART		: LONG_INTEGER;
      IPART_WORK		: LONG_INTEGER;
      IBUF		: STRING( 1 .. 40 );
      NB			: NATURAL		:= 0;

      E			: INTEGER		:= 0;

			---------
      function		FLOOR_POS		( X : LONG_FLOAT )		return LONG_INTEGER
      is			---------
        R : LONG_INTEGER := LONG_INTEGER( X );
      begin
        -- La conversion Ada LONG_INTEGER(X) arrondit.
        -- Pour le formatage, on veut floor(X), avec X >= 0.0.
        if  LONG_FLOAT( R ) > X  then
          R := R - 1;
        end if;

        return R;

      end	FLOOR_POS;
	---------


			----
      procedure		EMIT		( CH :in CHARACTER )
      is			----
      begin
        if  LEN < IMAGE'LAST  then
          LEN := LEN + 1;
          IMAGE( LEN ) := CH;
        else
          BAD_LAYOUT := TRUE;
        end if;

      end	EMIT;
	----


			-------------
      procedure		EMIT_FRACTION	( FRACTION :in LONG_FLOAT )
      is			-------------
        F : LONG_FLOAT := FRACTION;
        D : INTEGER;
      begin
        for  K in 1 .. AFT  loop
          F := F * 10.0;
          D := INTEGER( FLOOR_POS( F ) );

          if  D > 9  then
            D := 9;
          elsif  D < 0  then
            D := 0;
          end if;

          EMIT( CHARACTER'VAL( CHARACTER'POS( '0' ) + D ) );
          F := F - LONG_FLOAT( D );
        end loop;

      end	EMIT_FRACTION;
	-------------

    begin

      ------------------------------------------------------------
      -- Conversion initiale du type fixed formel vers LONG_FLOAT.
      -- Toute la mise en forme est ensuite faite en flottant.
      ------------------------------------------------------------

      if  VAL < 0.0  then
        IS_NEGATIVE := TRUE;
        VAL := -VAL;
      end if;

      if  IS_NEGATIVE  then
        EMIT( '-' );
      end if;

      ------------------------------------------------------------
      -- EXP <= 0 : notation decimale ordinaire
      --             [-]ddd.ddd
      ------------------------------------------------------------

      if  EXP <= 0  then

        -- Arrondi global avant extraction des chiffres.
        for  K in 1 .. AFT  loop
          ROUNDING := ROUNDING / 10.0;
        end loop;

        if  VAL /= 0.0  then
          VAL := VAL + ROUNDING;
        end if;

        IPART := FLOOR_POS( VAL );
        FRC_PART := VAL - LONG_FLOAT( IPART );

        -- Construire la partie entiere en ordre inverse.
        IPART_WORK := IPART;

        if  IPART_WORK = 0  then
          NB := 1;
          IBUF( 1 ) := '0';
        else
          while  IPART_WORK > 0  loop
            NB := NB + 1;
            IBUF( NB ) :=
              CHARACTER'VAL
                ( CHARACTER'POS( '0' )
                  + INTEGER( IPART_WORK mod 10 ) );
            IPART_WORK := IPART_WORK / 10;
          end loop;
        end if;

        -- Emettre les chiffres de la partie entiere dans le bon ordre.
        for  K in reverse 1 .. NB  loop
          EMIT( IBUF( K ) );
        end loop;

        EMIT( '.' );
        EMIT_FRACTION( FRC_PART );

      ------------------------------------------------------------
      -- EXP > 0 : notation scientifique
      --           [-]d.dddE[+|-]dd...
      ------------------------------------------------------------

      else

        -- Normaliser 1.0 <= VAL < 10.0.
        if  VAL /= 0.0  then
          while  VAL >= 10.0  loop
            VAL := VAL / 10.0;
            E := E + 1;
          end loop;

          while  VAL < 1.0  loop
            VAL := VAL * 10.0;
            E := E - 1;
          end loop;
        end if;

        -- Arrondir la mantisse a AFT chiffres.
        ROUNDING := 0.5;

        for  K in 1 .. AFT  loop
          ROUNDING := ROUNDING / 10.0;
        end loop;

        if  VAL /= 0.0  then
          VAL := VAL + ROUNDING;
        end if;

        -- Propager la retenue eventuelle :
        -- 9.9999996E+n devient 1.000000E+(n+1).
        if  VAL >= 10.0  then
          VAL := VAL / 10.0;
          E := E + 1;
        end if;

        -- Chiffre avant le point.
        DIGIT := INTEGER( FLOOR_POS( VAL ) );

        if  DIGIT > 9  then
          DIGIT := 9;
        elsif  DIGIT < 0  then
          DIGIT := 0;
        end if;

        EMIT( CHARACTER'VAL( CHARACTER'POS( '0' ) + DIGIT ) );

        FRC_PART := VAL - LONG_FLOAT( DIGIT );

        EMIT( '.' );
        EMIT_FRACTION( FRC_PART );

        -- Exposant.
        EMIT( 'E' );

        if  E < 0  then
          EMIT( '-' );
          E := -E;
        else
          EMIT( '+' );
        end if;

        declare
          EXP_STR	: STRING( 1 .. EXP );
          EVAL		: INTEGER	:= E;
          CHECK		: INTEGER	:= E;
        begin
          -- Verifier que l'exposant tient dans EXP chiffres.
          for  K in 1 .. EXP  loop
            CHECK := CHECK / 10;
          end loop;

          if  CHECK /= 0  then
            BAD_LAYOUT := TRUE;
          end if;

          -- Image de l'exposant avec zeros de tete.
          for  K in reverse 1 .. EXP  loop
            EXP_STR( K ) :=
              CHARACTER'VAL
                ( CHARACTER'POS( '0' ) + EVAL mod 10 );
            EVAL := EVAL / 10;
          end loop;

          for  K in 1 .. EXP  loop
            EMIT( EXP_STR( K ) );
          end loop;
        end;

      end if;

      ------------------------------------------------------------
      -- Justification dans TO.
      -- La variante STRING n'a pas FORE : TO'LENGTH est le champ.
      ------------------------------------------------------------

      if  BAD_LAYOUT  or else  LEN > TO'LENGTH  then

        -- A remplacer ulterieurement par :
        --   raise LAYOUT_ERROR;
        for  K in TO'FIRST .. TO'LAST  loop
          TO( K ) := '*';
        end loop;

      else

        PAD := TO'LENGTH - LEN;

        POS := TO'FIRST;

        for  K in 1 .. PAD  loop
          TO( POS ) := ' ';
          POS := POS + 1;
        end loop;

        for  K in 1 .. LEN  loop
          TO( POS ) := IMAGE( K );
          POS := POS + 1;
        end loop;

      end if;

    end	PUT;
	---


	--------
  end	FLOAT_IO;
	--------


				--------
  package	body			FIXED_IO
  is				--------

    			---
    procedure		GET		( FILE  :in FILE_TYPE;
					  ITEM  :out NUM;
					  WIDTH :in FIELD		:= 0
					)
    is			---

      CH		: CHARACTER;
      VAL		: LONG_FLOAT	:= 0.0;
      FRAC	: LONG_FLOAT	:= 0.1;
      NEG		: BOOLEAN		:= FALSE;
      IN_FRAC	: BOOLEAN		:= FALSE;
      EXP_VAL	: INTEGER		:= 0;
      EXP_NEG	: BOOLEAN		:= FALSE;
      CHARS_READ	: NATURAL		:= 0;
      DONE	: BOOLEAN		:= FALSE;

    begin

      if  WIDTH = 0  then
        loop
          exit when  FILE.AT_END_OF_FILE;
          GET( FILE, CH );
          exit when  FILE.AT_END_OF_FILE;
          exit when  CH /= ' '  and then  CH /= ASCII.HT
                              and then  CH /= ASCII.LF
                              and then  CH /= ASCII.CR;
        end loop;
      else
        GET( FILE, CH );
        CHARS_READ := 0;
      end if;

      -- Signe optionnel
      if  not FILE.AT_END_OF_FILE  and then  CH = '-'  then
        NEG := TRUE;
        if  WIDTH > 0  then
          CHARS_READ := CHARS_READ + 1;
          if  CHARS_READ >= WIDTH  then  DONE := TRUE;
          else  GET( FILE, CH );
          end if;
        else
          GET( FILE, CH );
        end if;
      elsif  not FILE.AT_END_OF_FILE  and then  CH = '+'  then
        if  WIDTH > 0  then
          CHARS_READ := CHARS_READ + 1;
          if  CHARS_READ >= WIDTH  then  DONE := TRUE;
          else  GET( FILE, CH );
          end if;
        else
          GET( FILE, CH );
        end if;
      end if;

      -- Mantisse et exposant
      loop
        exit when  DONE  or else  FILE.AT_END_OF_FILE;
        if  WIDTH > 0  and then  CHARS_READ >= WIDTH  then  exit;  end if;

        if  CH = '.'  then
          IN_FRAC := TRUE;
          if  WIDTH > 0  then
            CHARS_READ := CHARS_READ + 1;
            if  CHARS_READ >= WIDTH  then  DONE := TRUE;
            else  GET( FILE, CH );
            end if;
          else
            GET( FILE, CH );
          end if;

        elsif  CH = 'E'  or else  CH = 'e'  then
          if  WIDTH > 0  then
            CHARS_READ := CHARS_READ + 1;
            if  CHARS_READ >= WIDTH  then  DONE := TRUE;
            else  GET( FILE, CH );
            end if;
          else
            GET( FILE, CH );
          end if;
          if  not DONE  and then  not FILE.AT_END_OF_FILE  then
            if  CH = '-'  then
              EXP_NEG := TRUE;
              if  WIDTH > 0  then
                CHARS_READ := CHARS_READ + 1;
                if  CHARS_READ >= WIDTH  then  DONE := TRUE;
                else  GET( FILE, CH );
                end if;
              else
                GET( FILE, CH );
              end if;
            elsif  CH = '+'  then
              if  WIDTH > 0  then
                CHARS_READ := CHARS_READ + 1;
                if  CHARS_READ >= WIDTH  then  DONE := TRUE;
                else  GET( FILE, CH );
                end if;
              else
                GET( FILE, CH );
              end if;
            end if;
          end if;
          loop
            exit when  DONE  or else  FILE.AT_END_OF_FILE;
            exit when  CH < '0'  or else  CH > '9';
            EXP_VAL := 10 * EXP_VAL
                           + CHARACTER'POS( CH ) - CHARACTER'POS( '0' );
            if  WIDTH > 0  then
              CHARS_READ := CHARS_READ + 1;
              if  CHARS_READ >= WIDTH  then  DONE := TRUE;
              else  GET( FILE, CH );
              end if;
            else
              GET( FILE, CH );
            end if;
          end loop;
          if  WIDTH = 0  and then  not FILE.AT_END_OF_FILE
                         and then  ( CH < '0'  or else  CH > '9' )  then
            FILE.LOOK_AHEAD     := CH;
            FILE.HAS_LOOK_AHEAD := TRUE;
          end if;
          DONE := TRUE;

        elsif  CH >= '0'  and then  CH <= '9'  then
          if  IN_FRAC  then
            VAL  := VAL + FRAC
                        * LONG_FLOAT( CHARACTER'POS( CH ) - CHARACTER'POS( '0' ) );
            FRAC := FRAC / 10.0;
          else
            VAL  := 10.0 * VAL
                        + LONG_FLOAT( CHARACTER'POS( CH ) - CHARACTER'POS( '0' ) );
          end if;
          if  WIDTH > 0  then
            CHARS_READ := CHARS_READ + 1;
            if  CHARS_READ >= WIDTH  then  DONE := TRUE;
            else  GET( FILE, CH );
            end if;
          else
            GET( FILE, CH );
          end if;

        else
          if  WIDTH = 0  then
            FILE.LOOK_AHEAD     := CH;
            FILE.HAS_LOOK_AHEAD := TRUE;
          end if;
          DONE := TRUE;
        end if;
      end loop;

      if  EXP_NEG  then
        for  J in 1 .. EXP_VAL  loop  VAL := VAL / 10.0;  end loop;
      else
        for  J in 1 .. EXP_VAL  loop  VAL := VAL * 10.0;  end loop;
      end if;

      if  NEG  then  ITEM := NUM( -VAL );
      else           ITEM := NUM(  VAL );
      end if;

    end	GET;
	---


			---
    procedure		GET		( ITEM  :out NUM; WIDTH :in FIELD := 0 )
    is			---
    begin
      GET( DEFAULT_INPUT, ITEM, WIDTH );

    end	GET;
	----


    			---
    procedure		PUT		( FILE :in FILE_TYPE;
					  ITEM :in NUM;
					  FORE :in FIELD 		:= DEFAULT_FORE;
					  AFT  :in FIELD		:= DEFAULT_AFT;
					  EXP  :in FIELD		:= DEFAULT_EXP
					)
    is			---

      VAL		: LONG_FLOAT	:= LONG_FLOAT( ITEM );
      IS_NEGATIVE	: BOOLEAN		:= LONG_FLOAT( ITEM ) < 0.0;
      ROUNDING	: LONG_FLOAT	:= 0.5;
      INT_PART	: LONG_FLOAT;
      FRC_PART	: LONG_FLOAT;
      DIGIT	: LONG_INTEGER;

      BAD_LAYOUT	: BOOLEAN		:= FALSE;

      IPART	: LONG_INTEGER;
      IPART_WORK	: LONG_INTEGER;
      IBUF	: STRING( 1 .. 40 );
      NB		: NATURAL		:= 0;

      E		: INTEGER		:= 0;

			---------
      function		FLOOR_POS		( X : LONG_FLOAT )		return LONG_INTEGER
      is			---------
        R		: LONG_INTEGER	:= LONG_INTEGER( X );

      begin
        if  LONG_FLOAT( R ) > X  then
	R := R - 1;
        end if;
        return  R;

      end	FLOOR_POS;
	---------


			-------------
      procedure		EMIT_FRACTION	( FRACTION :in LONG_FLOAT )
      is			-------------
        F : LONG_FLOAT := FRACTION;
        D : INTEGER;
      begin
        for  K in 1 .. AFT  loop
          F := F * 10.0;
          D := INTEGER( FLOOR_POS( F ) );

          if  D > 9  then
            D := 9;
          elsif  D < 0  then
            D := 0;
          end if;

          PUT( FILE, CHARACTER'VAL( CHARACTER'POS( '0' ) + D ) );
          F := F - LONG_FLOAT( D );
        end loop;

      end	EMIT_FRACTION;
	-------------


    begin
      if  IS_NEGATIVE  then
        VAL := -VAL;
      end if;

      if  EXP = 0  then

        -- Arrondir a AFT chiffres avant extraction.
        for  K in 1 .. AFT  loop
	ROUNDING := ROUNDING / 10.0;
        end loop;

        VAL := VAL + ROUNDING;

        INT_PART := LONG_FLOAT( FLOOR_POS( VAL ) );
        FRC_PART := VAL - INT_PART;

        declare
	IBUF	: STRING( 1 .. 40 );
	NB	: NATURAL		:= 0;
	IPART	: LONG_INTEGER	:= LONG_INTEGER( INT_PART );
	FLEN	: NATURAL;
        begin
	if  IPART = 0  then
	  NB := 1;
	  IBUF( 1 ) := '0';
	else
	  while  IPART > 0  loop
	    NB := NB + 1;
	    IBUF( NB ) := CHARACTER'VAL( CHARACTER'POS( '0' ) + IPART mod 10 );
	    IPART := IPART / 10;
	  end loop;
          end if;

          FLEN := NB;
          if  IS_NEGATIVE  then
            FLEN := FLEN + 1;
          end if;

	if  FORE > FLEN  then
	  for  K in 1 .. FORE - FLEN  loop
	    PUT( FILE, ' ' );
	  end loop;
	end if;

	if  IS_NEGATIVE  then
	  PUT( FILE, '-' );
	end if;

	for  K in reverse 1 .. NB  loop
	  PUT( FILE, IBUF( K ) );
	end loop;
        end;

        PUT( FILE, '.' );

        for  K in 1 .. AFT  loop
	FRC_PART := FRC_PART * 10.0;
	DIGIT := FLOOR_POS( FRC_PART );

	if  DIGIT > 9  then DIGIT := 9; end if;
	if  DIGIT < 0  then DIGIT := 0; end if;

	PUT( FILE, CHARACTER'VAL( CHARACTER'POS( '0' ) + INTEGER( DIGIT ) ) );
          FRC_PART := FRC_PART - LONG_FLOAT( DIGIT );
        end loop;

      else											-- EXP > 0
        -- Normaliser 1.0 <= VAL < 10.0.
        if  VAL /= 0.0  then
          while  VAL >= 10.0  loop
            VAL := VAL / 10.0;
            E := E + 1;
          end loop;

          while  VAL < 1.0  loop
            VAL := VAL * 10.0;
            E := E - 1;
          end loop;
        end if;

        -- Arrondir la mantisse a AFT chiffres.
        ROUNDING := 0.5;

        for  K in 1 .. AFT  loop
          ROUNDING := ROUNDING / 10.0;
        end loop;

        if  VAL /= 0.0  then
          VAL := VAL + ROUNDING;
        end if;

        -- Propager la retenue eventuelle :
        -- 9.9999996E+n devient 1.000000E+(n+1).
        if  VAL >= 10.0  then
          VAL := VAL / 10.0;
          E := E + 1;
        end if;

        -- Chiffre avant le point.
        DIGIT := LONG_INTEGER( FLOOR_POS( VAL ) );

        if  DIGIT > 9  then
          DIGIT := 9;
        elsif  DIGIT < 0  then
          DIGIT := 0;
        end if;

        PUT( FILE, CHARACTER'VAL( CHARACTER'POS( '0' ) + DIGIT ) );

        FRC_PART := VAL - LONG_FLOAT( DIGIT );

        PUT( FILE, '.' );
        EMIT_FRACTION( FRC_PART );

        -- Exposant.
        PUT( FILE, 'E' );

        if  E < 0  then
          PUT( FILE, '-' );
          E := -E;
        else
          PUT( FILE, '+' );
        end if;

        declare
          EXP_STR	: STRING( 1 .. EXP );
          EVAL		: INTEGER	:= E;
          CHECK		: INTEGER	:= E;
        begin
          -- Verifier que l'exposant tient dans EXP chiffres.
          for  K in 1 .. EXP  loop
            CHECK := CHECK / 10;
          end loop;

          if  CHECK /= 0  then
            BAD_LAYOUT := TRUE;
          end if;

          -- Image de l'exposant avec zeros de tete.
          for  K in reverse 1 .. EXP  loop
            EXP_STR( K ) :=
              CHARACTER'VAL
                ( CHARACTER'POS( '0' ) + EVAL mod 10 );
            EVAL := EVAL / 10;
          end loop;

          for  K in 1 .. EXP  loop
            PUT( FILE, EXP_STR( K ) );
          end loop;
        end;

       end if;

    end	PUT;
	---


			---
    procedure		PUT		( ITEM :in NUM;
					  FORE :in FIELD		:= DEFAULT_FORE;
					  AFT  :in FIELD		:= DEFAULT_AFT;
					  EXP  :in FIELD		:= DEFAULT_EXP
					)
    is			---
    begin
      PUT( DEFAULT_OUTPUT, ITEM, FORE, AFT, EXP );

    end	PUT;
	----


			---
    procedure		GET		( FROM :in STRING;
					  ITEM :out NUM;
					  LAST :out POSITIVE
					)
    is			---

      I			: INTEGER		:= FROM'FIRST;
      VAL			: LONG_FLOAT	:= 0.0;
      FRAC		: LONG_FLOAT	:= 0.1;
      NEG			: BOOLEAN		:= FALSE;
      IN_FRAC		: BOOLEAN		:= FALSE;
      HAVE_DIGIT		: BOOLEAN		:= FALSE;
      HAVE_FRAC_DIGIT	: BOOLEAN		:= FALSE;
      EXP_SEEN		: BOOLEAN		:= FALSE;
      EXP_VAL		: INTEGER		:= 0;
      EXP_NEG		: BOOLEAN		:= FALSE;
      HAVE_EXP_DIGIT	: BOOLEAN		:= FALSE;
      BAD_IMAGE		: BOOLEAN		:= FALSE;

begin

  -- Ignorer les espaces initiaux.
  while  I <= FROM'LAST
    and then
      ( FROM( I ) = ' '  or else  FROM( I ) = ASCII.HT )
  loop
    I := I + 1;
  end loop;

  -- Signe optionnel.
  if  I <= FROM'LAST  and then  FROM( I ) = '-'  then
    NEG := TRUE;
    I := I + 1;

  elsif  I <= FROM'LAST  and then  FROM( I ) = '+'  then
    I := I + 1;
  end if;

  -- Mantisse decimale.
  while  I <= FROM'LAST  loop

    if  FROM( I ) >= '0'  and then  FROM( I ) <= '9'  then

      HAVE_DIGIT := TRUE;

      if  IN_FRAC  then
        HAVE_FRAC_DIGIT := TRUE;

        VAL :=
          VAL
          + FRAC
          * LONG_FLOAT
              ( CHARACTER'POS( FROM( I ) )
                - CHARACTER'POS( '0' ) );

        FRAC := FRAC / 10.0;

      else
        VAL :=
          10.0 * VAL
          + LONG_FLOAT
              ( CHARACTER'POS( FROM( I ) )
                - CHARACTER'POS( '0' ) );
      end if;

      I := I + 1;

    elsif  FROM( I ) = '.'  and then  not IN_FRAC  then

      IN_FRAC := TRUE;
      I := I + 1;

    elsif  ( FROM( I ) = 'E'  or else  FROM( I ) = 'e' )
      and then  HAVE_DIGIT
    then

      EXP_SEEN := TRUE;
      I := I + 1;

      -- Signe optionnel de l'exposant.
      if  I <= FROM'LAST  and then  FROM( I ) = '-'  then
        EXP_NEG := TRUE;
        I := I + 1;

      elsif  I <= FROM'LAST  and then  FROM( I ) = '+'  then
        I := I + 1;
      end if;

      -- Chiffres de l'exposant.
      while  I <= FROM'LAST
        and then  FROM( I ) >= '0'
        and then  FROM( I ) <= '9'
      loop
        HAVE_EXP_DIGIT := TRUE;

        EXP_VAL :=
          10 * EXP_VAL
          + CHARACTER'POS( FROM( I ) )
          - CHARACTER'POS( '0' );

        I := I + 1;
      end loop;

      exit;

    else
      exit;
    end if;

  end loop;

  -- Controle lexical minimal.
  -- Lorsque les exceptions seront actives, ce chemin devra faire :
  --   raise DATA_ERROR;
  BAD_IMAGE :=
    not HAVE_DIGIT
    or else  ( IN_FRAC  and then  not HAVE_FRAC_DIGIT )
    or else  ( EXP_SEEN  and then  not HAVE_EXP_DIGIT );

  if  BAD_IMAGE  then
    ITEM := NUM( 0.0 );

    if  FROM'FIRST <= FROM'LAST  then
      LAST := FROM'FIRST;
    else
      LAST := 1;
    end if;

    return;
  end if;

  -- Appliquer l'exposant decimal.
  if  EXP_NEG  then
    for  J in 1 .. EXP_VAL  loop
      VAL := VAL / 10.0;
    end loop;
  else
    for  J in 1 .. EXP_VAL  loop
      VAL := VAL * 10.0;
    end loop;
  end if;

  -- I designe le premier caractere non consomme.
  LAST := POSITIVE( I - 1 );

  -- Conversion unique LONG_FLOAT -> type fixed reel de l'instance.
  if  NEG  then
    ITEM := NUM( -VAL );
  else
    ITEM := NUM( VAL );
  end if;

    end	GET;
	---


			---
    procedure		PUT		( TO   :out STRING;
					  ITEM :in NUM;
					  AFT  :in FIELD		:= DEFAULT_AFT;
					  EXP  :in INTEGER		:= DEFAULT_EXP
					)
    is			---

      IMAGE		: STRING( 1 .. 80 );
      LEN			: NATURAL		:= 0;
      POS			: INTEGER;
      PAD			: INTEGER;

      VAL			: LONG_FLOAT	:= LONG_FLOAT( ITEM );
      ROUNDING		: LONG_FLOAT	:= 0.5;
      FRC_PART		: LONG_FLOAT	:= 0.0;

      IS_NEGATIVE		: BOOLEAN		:= FALSE;
      BAD_LAYOUT		: BOOLEAN		:= FALSE;

      DIGIT		: INTEGER;
      IPART		: LONG_INTEGER;
      IPART_WORK		: LONG_INTEGER;
      IBUF		: STRING( 1 .. 40 );
      NB			: NATURAL		:= 0;

      E			: INTEGER		:= 0;

			---------
      function		FLOOR_POS		( X : LONG_FLOAT )		return LONG_INTEGER
      is			---------
        R : LONG_INTEGER := LONG_INTEGER( X );
      begin
        -- La conversion Ada LONG_INTEGER(X) arrondit.
        -- Pour le formatage, on veut floor(X), avec X >= 0.0.
        if  LONG_FLOAT( R ) > X  then
          R := R - 1;
        end if;

        return R;

      end	FLOOR_POS;
	---------


			----
      procedure		EMIT		( CH :in CHARACTER )
      is			----
      begin
        if  LEN < IMAGE'LAST  then
          LEN := LEN + 1;
          IMAGE( LEN ) := CH;
        else
          BAD_LAYOUT := TRUE;
        end if;

      end	EMIT;
	----


			-------------
      procedure		EMIT_FRACTION	( FRACTION :in LONG_FLOAT )
      is			-------------
        F : LONG_FLOAT := FRACTION;
        D : INTEGER;
      begin
        for  K in 1 .. AFT  loop
          F := F * 10.0;
          D := INTEGER( FLOOR_POS( F ) );

          if  D > 9  then
            D := 9;
          elsif  D < 0  then
            D := 0;
          end if;

          EMIT( CHARACTER'VAL( CHARACTER'POS( '0' ) + D ) );
          F := F - LONG_FLOAT( D );
        end loop;

      end	EMIT_FRACTION;
	-------------

    begin

      ------------------------------------------------------------
      -- Conversion initiale du type fixed formel vers LONG_FLOAT.
      -- Toute la mise en forme est ensuite faite en flottant.
      ------------------------------------------------------------

      if  VAL < 0.0  then
        IS_NEGATIVE := TRUE;
        VAL := -VAL;
      end if;

      if  IS_NEGATIVE  then
        EMIT( '-' );
      end if;

      ------------------------------------------------------------
      -- EXP <= 0 : notation decimale ordinaire
      --             [-]ddd.ddd
      ------------------------------------------------------------

      if  EXP <= 0  then

        -- Arrondi global avant extraction des chiffres.
        for  K in 1 .. AFT  loop
          ROUNDING := ROUNDING / 10.0;
        end loop;

        if  VAL /= 0.0  then
          VAL := VAL + ROUNDING;
        end if;

        IPART := FLOOR_POS( VAL );
        FRC_PART := VAL - LONG_FLOAT( IPART );

        -- Construire la partie entiere en ordre inverse.
        IPART_WORK := IPART;

        if  IPART_WORK = 0  then
          NB := 1;
          IBUF( 1 ) := '0';
        else
          while  IPART_WORK > 0  loop
            NB := NB + 1;
            IBUF( NB ) :=
              CHARACTER'VAL
                ( CHARACTER'POS( '0' )
                  + INTEGER( IPART_WORK mod 10 ) );
            IPART_WORK := IPART_WORK / 10;
          end loop;
        end if;

        -- Emettre les chiffres de la partie entiere dans le bon ordre.
        for  K in reverse 1 .. NB  loop
          EMIT( IBUF( K ) );
        end loop;

        EMIT( '.' );
        EMIT_FRACTION( FRC_PART );

      ------------------------------------------------------------
      -- EXP > 0 : notation scientifique
      --           [-]d.dddE[+|-]dd...
      ------------------------------------------------------------

      else

        -- Normaliser 1.0 <= VAL < 10.0.
        if  VAL /= 0.0  then
          while  VAL >= 10.0  loop
            VAL := VAL / 10.0;
            E := E + 1;
          end loop;

          while  VAL < 1.0  loop
            VAL := VAL * 10.0;
            E := E - 1;
          end loop;
        end if;

        -- Arrondir la mantisse a AFT chiffres.
        ROUNDING := 0.5;

        for  K in 1 .. AFT  loop
          ROUNDING := ROUNDING / 10.0;
        end loop;

        if  VAL /= 0.0  then
          VAL := VAL + ROUNDING;
        end if;

        -- Propager la retenue eventuelle :
        -- 9.9999996E+n devient 1.000000E+(n+1).
        if  VAL >= 10.0  then
          VAL := VAL / 10.0;
          E := E + 1;
        end if;

        -- Chiffre avant le point.
        DIGIT := INTEGER( FLOOR_POS( VAL ) );

        if  DIGIT > 9  then
          DIGIT := 9;
        elsif  DIGIT < 0  then
          DIGIT := 0;
        end if;

        EMIT( CHARACTER'VAL( CHARACTER'POS( '0' ) + DIGIT ) );

        FRC_PART := VAL - LONG_FLOAT( DIGIT );

        EMIT( '.' );
        EMIT_FRACTION( FRC_PART );

        -- Exposant.
        EMIT( 'E' );

        if  E < 0  then
          EMIT( '-' );
          E := -E;
        else
          EMIT( '+' );
        end if;

        declare
          EXP_STR	: STRING( 1 .. EXP );
          EVAL		: INTEGER	:= E;
          CHECK		: INTEGER	:= E;
        begin
          -- Verifier que l'exposant tient dans EXP chiffres.
          for  K in 1 .. EXP  loop
            CHECK := CHECK / 10;
          end loop;

          if  CHECK /= 0  then
            BAD_LAYOUT := TRUE;
          end if;

          -- Image de l'exposant avec zeros de tete.
          for  K in reverse 1 .. EXP  loop
            EXP_STR( K ) :=
              CHARACTER'VAL
                ( CHARACTER'POS( '0' ) + EVAL mod 10 );
            EVAL := EVAL / 10;
          end loop;

          for  K in 1 .. EXP  loop
            EMIT( EXP_STR( K ) );
          end loop;
        end;

      end if;

      ------------------------------------------------------------
      -- Justification dans TO.
      -- La variante STRING n'a pas FORE : TO'LENGTH est le champ.
      ------------------------------------------------------------

      if  BAD_LAYOUT  or else  LEN > TO'LENGTH  then

        -- A remplacer ulterieurement par :
        --   raise LAYOUT_ERROR;
        for  K in TO'FIRST .. TO'LAST  loop
          TO( K ) := '*';
        end loop;

      else

        PAD := TO'LENGTH - LEN;

        POS := TO'FIRST;

        for  K in 1 .. PAD  loop
          TO( POS ) := ' ';
          POS := POS + 1;
        end loop;

        for  K in 1 .. LEN  loop
          TO( POS ) := IMAGE( K );
          POS := POS + 1;
        end loop;

      end if;

    end	PUT;
	----

	--------
  end	FIXED_IO;
	--------


			-- Generic package for Input-Output of Enumeration types


			--------------
  package	body		ENUMERATION_IO
  is			--------------

    			---
    procedure		PUT		( FILE  :in FILE_TYPE;
					  ITEM  :in ENUM;
					  WIDTH :in FIELD		:= DEFAULT_WIDTH;
					  SET   :in TYPE_SET	:= DEFAULT_SETTING
					)
    is			---

		---------------
      function	GET_ENUM_IMAGES			return STRING
      is		---------------
      begin
        ASM_OP_2'( OPCODE => La,  LVL => 1, OFS => -40 );							-- empiler @GFP_disp
        ASM_OP_3'( OPCODE => LIVa,  DISP => -8, OFS=> 16 );							-- deref __u_ofs → IMAGES
        ASM_OP_2'( OPCODE => Sa,  LVL => 2, OFS => -8 );							-- stocker dans result_ofs

      end	GET_ENUM_IMAGES;
      	---------------

    begin
      declare
        IMAGES_STR		:constant STRING		:= GET_ENUM_IMAGES;
        POS_VAL		: INTEGER			:= ENUM'POS( ITEM );
        I			: POSITIVE		:= IMAGES_STR'FIRST;
        REP		: INTEGER;
        LEN		: INTEGER;
        IMG_START		: POSITIVE;
        PAD		: INTEGER;
      begin
        -- Parcourir les triplets (REP, LEN, cars...) dans IMAGES_STR
        while  I <= IMAGES_STR'LAST  loop
          REP := CHARACTER'POS( IMAGES_STR( I ) );
          LEN := CHARACTER'POS( IMAGES_STR( I + 1 ) );
          if  REP = POS_VAL  then
            IMG_START := I + 2;
            -- Padding avec des espaces si WIDTH > LEN
            PAD := WIDTH - LEN;
            if  PAD > 0  then
              for  J in 1 .. PAD  loop
                PUT( FILE, ' ' );
              end loop;
            end if;
            -- Ecrire les caracteres de l'image
            for  J in 0 .. LEN - 1  loop
              if  SET = LOWER_CASE  then
                declare
                  CH	: CHARACTER	:= IMAGES_STR( IMG_START + J );
                begin
                  if  CH >= 'A'  and then  CH <= 'Z'  then
                    CH := CHARACTER'VAL( CHARACTER'POS( CH ) + 32 );
                  end if;
                  PUT( FILE, CH );
                end;
              else
                PUT( FILE, IMAGES_STR( IMG_START + J ) );
              end if;
            end loop;
            return;
          end if;
          I := I + 2 + LEN;
        end loop;
      end;

    end	PUT;
	---

			---
    procedure		PUT		( ITEM  :in ENUM;
					  WIDTH :in FIELD		:= DEFAULT_WIDTH;
					  SET   :in TYPE_SET	:= DEFAULT_SETTING
					)
    is			---
    begin
      PUT( DEFAULT_OUTPUT, ITEM, WIDTH, SET );

    end	PUT;
	----


    			---
    procedure		GET		( FILE :in FILE_TYPE; ITEM :out ENUM)
    is			---

      TOKEN	: STRING( 1 .. 80 );
      TOK_LEN	: NATURAL		:= 0;
      TOK_TOO_LONG	: BOOLEAN		:= FALSE;

      CH		: CHARACTER;
      DONE	: BOOLEAN		:= FALSE;

      I		: POSITIVE;
      REP		: INTEGER;
      IMG_LEN	: INTEGER;
      IMG_START	: POSITIVE;
      FOUND	: BOOLEAN		:= FALSE;
      OK		: BOOLEAN;
      HAS_QUOTE	: BOOLEAN;
      IMG_CH	: CHARACTER;
      TOK_CH	: CHARACTER;

		---------------
      function	GET_ENUM_IMAGES			return STRING
      is		---------------
      begin
        ASM_OP_2'( OPCODE => La,   LVL => 1, OFS => -24 );							-- empiler @GFP_disp
        ASM_OP_3'( OPCODE => LIVa, DISP => -8, OFS => 16 );							-- deref __u_ofs -> IMAGES
        ASM_OP_2'( OPCODE => Sa,   LVL => 2, OFS => -8 );							-- stocker dans result_ofs

      end	GET_ENUM_IMAGES;
      	---------------


		-----
      function	UPPER		( CH : CHARACTER ) return CHARACTER
      is		-----
      begin
        if  CH >= 'a'  and then  CH <= 'z'  then
          return CHARACTER'VAL( CHARACTER'POS( CH ) - 32 );
        else
          return CH;
        end if;

      end	UPPER;
	-----

		------------
      function	IS_SEPARATOR	( CH : CHARACTER ) return BOOLEAN
      is		------------
      begin
        return
          CH = ' '
          or else CH = ASCII.HT
          or else CH = ASCII.LF
          or else CH = ASCII.CR
          or else CH = ASCII.FF;

      end	IS_SEPARATOR;
	------------

		-------------
      function	IS_IDENT_CHAR	( CH : CHARACTER ) return BOOLEAN
      is		-------------
      begin
        return
          ( CH >= 'A'  and then  CH <= 'Z' )
          or else
          ( CH >= 'a'  and then  CH <= 'z' )
          or else
          ( CH >= '0'  and then  CH <= '9' )
          or else
          CH = '_';

      end	IS_IDENT_CHAR;
	-------------


		----------
      procedure	UNGET_CHAR	( CH :in CHARACTER )
      is		----------
      begin
        FILE.LOOK_AHEAD     := CH;
        FILE.HAS_LOOK_AHEAD := TRUE;

      end	UNGET_CHAR;
	----------
    begin
      declare
        IMAGES_STR	: constant STRING	:= GET_ENUM_IMAGES;

      begin
SKIP_BLANKS:
        loop
	GET( FILE, CH );
        exit when not IS_SEPARATOR( CH );
      end loop  SKIP_BLANKS;

      ------------------------------------------------------------
      -- 2. Lire l'image du literal enumere.
      --
      --    Cas courant : identificateur Ada, donc lettres/chiffres/'_'.
      --    Cas CHARACTER : image de forme 'X', lue jusqu'au second
      --    apostrophe inclus.
      --
      --    Le premier caractere lu qui n'appartient plus au token est
      --    remis en anticipation.
      ------------------------------------------------------------

      if  CH = '''  then

        -- Literal caractere : recopier l'apostrophe initiale.
        TOK_LEN := 1;
        TOKEN( 1 ) := CH;

        loop
          GET( FILE, CH );

          if  TOK_LEN < TOKEN'LAST  then
            TOK_LEN := TOK_LEN + 1;
            TOKEN( TOK_LEN ) := CH;
          else
            TOK_TOO_LONG := TRUE;
          end if;

          exit when CH = ''';
        end loop;

      else											-- Identificateur enumere.
        loop
          if  IS_IDENT_CHAR( CH )  then

            if  TOK_LEN < TOKEN'LAST  then
              TOK_LEN := TOK_LEN + 1;
              TOKEN( TOK_LEN ) := CH;
            else
              TOK_TOO_LONG := TRUE;
            end if;

            GET( FILE, CH );

          else
            UNGET_CHAR( CH );
            DONE := TRUE;
          end if;

          exit when DONE;
        end loop;

      end if;

      ------------------------------------------------------------
      -- 3. Chercher l'image correspondante dans IMAGES_STR.
      --    Les identificateurs sont compares sans tenir compte de
      --    la casse. Les images contenant une apostrophe sont
      --    comparees exactement, pour ne pas confondre 'a' et 'A'.
      ------------------------------------------------------------

      if  TOK_LEN = 0  or else  TOK_TOO_LONG  then

        -- A remplacer plus tard par :
        --   raise DATA_ERROR;
        ITEM := ENUM'FIRST;
        return;

      end if;

      I := IMAGES_STR'FIRST;

      while  I <= IMAGES_STR'LAST  loop

        REP       := CHARACTER'POS( IMAGES_STR( I ) );
        IMG_LEN   := CHARACTER'POS( IMAGES_STR( I + 1 ) );
        IMG_START := I + 2;

        if  IMG_LEN = TOK_LEN  then

          HAS_QUOTE := FALSE;

          for  J in 0 .. IMG_LEN - 1  loop
            if  IMAGES_STR( IMG_START + J ) = '''  then
              HAS_QUOTE := TRUE;
            end if;
          end loop;

          OK := TRUE;

          for  J in 0 .. IMG_LEN - 1  loop
            IMG_CH := IMAGES_STR( IMG_START + J );
            TOK_CH := TOKEN( J + 1 );

            if  HAS_QUOTE  then
              -- Images de caracteres : comparaison exacte.
              if  TOK_CH /= IMG_CH  then
                OK := FALSE;
              end if;
            else
              -- Identificateurs : insensibles a la casse.
              if  UPPER( TOK_CH ) /= UPPER( IMG_CH )  then
                OK := FALSE;
              end if;
            end if;
          end loop;

          if  OK  then
            ITEM := ENUM'VAL( REP );
            return;
          end if;

        end if;

        I := I + 2 + IMG_LEN;
      end loop;

      ------------------------------------------------------------
      -- 4. Aucune image trouvee.
      ------------------------------------------------------------

      -- A remplacer plus tard par :
      --   raise DATA_ERROR;
      ITEM := ENUM'FIRST;
      end;

    end	GET;
	---


			---
    procedure		GET		( ITEM :out ENUM)
    is			---
    begin
      GET( DEFAULT_INPUT, ITEM );

    end	GET;
	---


			---
    procedure		GET		( FROM :in STRING;
					  ITEM :out ENUM;
					  LAST :out POSITIVE
					)
    is			---

      I			: INTEGER		:= FROM'FIRST;
      P			: INTEGER;
      REP			: INTEGER;
      LEN			: INTEGER;
      IMG_START		: INTEGER;

      MATCH_FOUND		: BOOLEAN		:= FALSE;
      MATCH_REP		: INTEGER		:= 0;
      MATCH_LEN		: INTEGER		:= 0;

      OK			: BOOLEAN;

		---------------
      function	GET_ENUM_IMAGES			return STRING
      is		---------------
      begin
        ASM_OP_2'( OPCODE => La,   LVL => 1, OFS => -32 );							-- empiler @GFP_disp
        ASM_OP_3'( OPCODE => LIVa, DISP => -8, OFS => 16 );							-- deref __u_ofs -> IMAGES
        ASM_OP_2'( OPCODE => Sa,   LVL => 2, OFS => -8 );							-- stocker dans result_ofs

      end	GET_ENUM_IMAGES;
      	---------------

		-----
      function	UPPER		( CH : CHARACTER )		return CHARACTER
      is		-----
      begin
        if  CH >= 'a'  and then  CH <= 'z'  then
	return  CHARACTER'VAL( CHARACTER'POS( CH ) - 32 );
        else
	return  CH;
        end if;

      end	UPPER;
	-----

		---------
      function	SAME_CHAR		( LEFT, RIGHT : CHARACTER )	return BOOLEAN
      is		---------
      begin
        return  UPPER( LEFT ) = UPPER( RIGHT );

      end	SAME_CHAR;
	---------

    begin
      declare
        IMAGES_STR		: constant STRING	:= GET_ENUM_IMAGES;

      begin
IGNORE_BLANKS:
        while  I <= FROM'LAST  and then
          ( FROM( I ) = ' '
            or else FROM( I ) = ASCII.HT
            or else FROM( I ) = ASCII.LF
            or else FROM( I ) = ASCII.FF )
        loop
	I := I + 1;
        end loop  IGNORE_BLANKS;

        P := IMAGES_STR'FIRST;

      -- IMAGES_STR contient des triplets :
      --   REP, LEN, caracteres_de_l_image
        while  P <= IMAGES_STR'LAST  loop

	REP := CHARACTER'POS( IMAGES_STR( P ) );
	LEN := CHARACTER'POS( IMAGES_STR( P + 1 ) );

	IMG_START := P + 2;

	if  I + LEN - 1 <= FROM'LAST  then
	  OK := TRUE;

	  for  J in 0 .. LEN - 1  loop
	    if  not SAME_CHAR( FROM( I + J ), IMAGES_STR( IMG_START + J ) )  then
	      OK := FALSE;
	    end if;
	  end loop;

	  if  OK  then
            -- Retenir la plus longue image correspondante.
            -- C'est utile si deux images ont un prefixe commun.
	    if  not MATCH_FOUND  or else  LEN > MATCH_LEN  then
	      MATCH_FOUND := TRUE;
	      MATCH_REP   := REP;
	      MATCH_LEN   := LEN;
	    end if;
	  end if;

	end if;

	P := P + 2 + LEN;
        end loop;

        if  MATCH_FOUND  then
	ITEM := ENUM'VAL( MATCH_REP );
	LAST := POSITIVE( I + MATCH_LEN - 1 );

        else
        -- A remplacer plus tard par :
        --   raise DATA_ERROR;
	ITEM := ENUM'FIRST;

	if  FROM'FIRST <= FROM'LAST  then
	  LAST := FROM'FIRST;
	else
	  LAST := 1;
	end if;

        end if;
      end;

    end	GET;
	---


			---
    procedure		PUT		( TO   :out STRING;
					  ITEM :in ENUM;
					  SET  :in TYPE_SET		:= DEFAULT_SETTING
					)
    is			---

		---------------
      function	GET_ENUM_IMAGES			return STRING
      is		---------------
      begin
        ASM_OP_2'( OPCODE => La,   LVL => 1, OFS => -32 );		-- empiler @GFP_disp
        ASM_OP_3'( OPCODE => LIVa, DISP => -8, OFS => 16 );		-- deref __u_ofs -> IMAGES
        ASM_OP_2'( OPCODE => Sa,   LVL => 2, OFS => -8 );		-- stocker dans result_ofs

      end	GET_ENUM_IMAGES;
      	---------------

    begin
      declare
        IMAGES_STR		: constant STRING		:= GET_ENUM_IMAGES;
        POS_VAL		: INTEGER			:= ENUM'POS( ITEM );
        I			: POSITIVE		:= IMAGES_STR'FIRST;
        REP		: INTEGER;
        LEN		: INTEGER;
        IMG_START		: POSITIVE;
        PAD		: INTEGER;
        DST		: INTEGER;
        CH		: CHARACTER;
      begin

        -- Par defaut, remplir le champ avec des blancs.
        for  K in TO'FIRST .. TO'LAST  loop
          TO( K ) := ' ';
        end loop;

        -- Parcourir les triplets (REP, LEN, caracteres...) dans IMAGES_STR.
        while  I <= IMAGES_STR'LAST  loop

          REP := CHARACTER'POS( IMAGES_STR( I ) );
          LEN := CHARACTER'POS( IMAGES_STR( I + 1 ) );

          if  REP = POS_VAL  then

            IMG_START := I + 2;

            if  LEN > TO'LENGTH  then

              -- A remplacer plus tard par :
              --   raise LAYOUT_ERROR;
              for  K in TO'FIRST .. TO'LAST  loop
                TO( K ) := '*';
              end loop;

              return;

            end if;

--            PAD := TO'LENGTH - LEN;
--            DST := TO'FIRST + PAD;
            DST := TO'FIRST;

            for  J in 0 .. LEN - 1  loop
              CH := IMAGES_STR( IMG_START + J );

              if  SET = LOWER_CASE  then
                if  CH >= 'A'  and then  CH <= 'Z'  then
                  CH := CHARACTER'VAL( CHARACTER'POS( CH ) + 32 );
                end if;
              end if;

              TO( DST + J ) := CH;
            end loop;

            return;

          end if;

          I := I + 2 + LEN;
        end loop;

        -- Cas normalement impossible : ITEM doit toujours avoir une image.
        -- A remplacer plus tard par une exception interne ou DATA_ERROR.
        for  K in TO'FIRST .. TO'LAST  loop
          TO( K ) := '*';
        end loop;

      end;

    end	PUT;
	---


  end	ENUMERATION_IO;
	--------------


begin
  STD_INPUT.NAME_LEN	:= 0;
  STD_INPUT.MODE		:= IN_FILE;
  STD_INPUT.PAGE_LENGTH	:= 0;
  STD_INPUT.LINE_LENGTH	:= 256;
  STD_INPUT.PAGE := 1;
  STD_INPUT.LINE := 1;
  STD_INPUT.COL  := 1;
  STD_INPUT.IS_OPENED	:= TRUE;

  STD_OUTPUT.NAME_LEN	:= 0;
  STD_OUTPUT.MODE		:= OUT_FILE;
  STD_OUTPUT.PAGE_LENGTH	:= 0;
  STD_OUTPUT.LINE_LENGTH	:= 256;
  STD_OUTPUT.PAGE := 1;
  STD_OUTPUT.LINE := 1;
  STD_OUTPUT.COL  := 1;
  STD_OUTPUT.IS_OPENED	:= TRUE;

  DEFAULT_INPUT		:= STD_INPUT;
  DEFAULT_OUTPUT		:= STD_OUTPUT;

end	TEXT_IO;
	-------
