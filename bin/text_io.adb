with MACHINE_CODE;
use  MACHINE_CODE;
					-------
	package body			TEXT_IO
is					-------

  STDOUT_PAGE_LENGTH	: COUNT		:= 72;
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
      FILE.ID := OPEN_SYSTEM_CALL( NAME );
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
    if  FILE.LINE > FILE.PAGE_LENGTH  then
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
    is			---

      CHN	: STRING( 1 .. 40 );
      LEN	: NATURAL		:= 0;
      VAL	: NUM		:= 0;
      NEG	: BOOLEAN		:= FALSE;
      I	: NATURAL;

    begin
      GET_LINE( FILE, CHN, LEN );
      -- Sauter les espaces de tete
      I := 1;
      while  I <= LEN  and then  CHN( I ) = ' '  loop
        I := I + 1;
      end loop;
      -- Signe optionnel
      if  I <= LEN  and then  CHN( I ) = '-'  then
        NEG := TRUE;
        I := I + 1;
      elsif  I <= LEN  and then  CHN( I ) = '+'  then
        I := I + 1;
      end if;
      -- Digits
      while  I <= LEN  loop
        exit when  CHN( I ) < '0'  or  CHN( I ) > '9';
        VAL := 10 * VAL + NUM( CHARACTER'POS( CHN( I ) ) - CHARACTER'POS( '0' ) );
        I := I + 1;
      end loop;
      if  NEG  then
        ITEM := -VAL;
      else
        ITEM := VAL;
      end if;

    end	GET;
	----

			---
    procedure		GET		( ITEM  :out NUM; WIDTH : in FIELD := 0)
    is			---

      CHN	: STRING( 1 .. 40 );
      LEN	: NATURAL		:= 40;
      VAL	: NUM		:= 0;

    begin
      GET_LINE( CHN, LEN );
      for  I in 1 .. LEN  loop
        VAL := 10 * VAL + CHARACTER'POS( CHN( I ) ) - CHARACTER'POS( '0' );
      end loop;
      ITEM := VAL;
      PUT( CHN );
    end	GET;
	----

			---
    procedure		PUT		( FILE  :in FILE_TYPE;
					  ITEM  :in NUM;
					  WIDTH :in FIELD		:= DEFAULT_WIDTH;
					  BASE  :in NUMBER_BASE	:= DEFAULT_BASE
					)
    is			---

      VAL		: NUM			:= ITEM;
      STR		: STRING( 1 .. 68 );
      POS		: POSITIVE		:= STR'LAST;
      IS_NEGATIVE	: BOOLEAN			:= ITEM < 0;
      DIGIT	: INTEGER;
      DLEN		: NATURAL;		-- longueur digits
      TLEN		: NATURAL;		-- longueur totale formatee

    begin
      if  IS_NEGATIVE  then
        VAL := -ITEM;
      end if;

      -- Conversion digit par digit dans la base demandee (droite a gauche dans STR)
      loop
        DIGIT := INTEGER( VAL mod NUM( BASE ) );
        if  DIGIT < 10  then
          STR( POS ) := CHARACTER'VAL( CHARACTER'POS( '0' ) + DIGIT );
        else
          STR( POS ) := CHARACTER'VAL( CHARACTER'POS( 'A' ) + DIGIT - 10 );
        end if;
        VAL := VAL / NUM( BASE );
        exit when  VAL = 0;
        POS := POS - 1;
      end loop;

      -- STR( POS .. STR'LAST ) contient les digits

      -- Calcul de la longueur totale formatee
      DLEN := STR'LAST - POS + 1;
      TLEN := DLEN;
      if  IS_NEGATIVE  then
        TLEN := TLEN + 1;					-- pour le '-'
      end if;
      if  BASE /= 10  then
        if  BASE >= 10  then
          TLEN := TLEN + 4;				-- "NN#" + "#" = 2+1+1
        else
          TLEN := TLEN + 3;				-- "N#" + "#"  = 1+1+1
        end if;
      end if;

      -- Padding a gauche avec des espaces
      if  WIDTH > TLEN  then
        for  I in 1 .. WIDTH - TLEN  loop
          PUT( FILE, ' ' );
        end loop;
      end if;

      -- Signe
      if  IS_NEGATIVE  then
        PUT( FILE, '-' );
      end if;

      -- Prefixe base
      if  BASE /= 10  then
        if  BASE >= 10  then
          PUT( FILE, '1' );
          PUT( FILE, CHARACTER'VAL( CHARACTER'POS( '0' ) + BASE - 10 ) );
        else
          PUT( FILE, CHARACTER'VAL( CHARACTER'POS( '0' ) + BASE ) );
        end if;
        PUT( FILE, '#' );
      end if;

      -- Digits
      PUT( FILE, STR( POS .. STR'LAST ) );

      -- Suffixe base
      if  BASE /= 10  then
        PUT( FILE, '#' );
      end if;

    end	PUT;
	----

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
    procedure		GET		( FROM :in STRING;
					  ITEM :out NUM;
					  LAST :out POSITIVE
					)
    is			---
    begin null;

    end	GET;
	----

			---
    procedure		PUT		( TO   :out STRING;
					  ITEM :in NUM;
					  BASE :in NUMBER_BASE	:= DEFAULT_BASE
					)
    is			---
    begin null;

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

      CHN	: STRING( 1 .. 80 );
      LEN	: NATURAL		:= 0;
      VAL	: NUM		:= 0.0;
      FRAC	: NUM		:= 0.1;
      NEG	: BOOLEAN		:= FALSE;
      I	: NATURAL;
      IN_FRAC	: BOOLEAN		:= FALSE;
      IN_EXP	: BOOLEAN		:= FALSE;
      EXP_VAL	: INTEGER		:= 0;
      EXP_NEG	: BOOLEAN		:= FALSE;

    begin
      GET_LINE( FILE, CHN, LEN );
      I := 1;
      -- Sauter les espaces de tete
      while  I <= LEN  and then  CHN( I ) = ' '  loop
        I := I + 1;
      end loop;
      -- Signe optionnel
      if  I <= LEN  and then  CHN( I ) = '-'  then
        NEG := TRUE;
        I := I + 1;
      elsif  I <= LEN  and then  CHN( I ) = '+'  then
        I := I + 1;
      end if;
      -- Partie entiere et fractionnaire
      while  I <= LEN  loop
        if  CHN( I ) = '.'  then
          IN_FRAC := TRUE;
        elsif  CHN( I ) = 'E'  or  CHN( I ) = 'e'  then
          IN_EXP := TRUE;
          I := I + 1;
          if  I <= LEN  and then  CHN( I ) = '-'  then
            EXP_NEG := TRUE;
            I := I + 1;
          elsif  I <= LEN  and then  CHN( I ) = '+'  then
            I := I + 1;
          end if;
          while  I <= LEN  and then  CHN( I ) >= '0'  and then  CHN( I ) <= '9'  loop
            EXP_VAL := 10 * EXP_VAL + CHARACTER'POS( CHN( I ) ) - CHARACTER'POS( '0' );
            I := I + 1;
          end loop;
          exit;
        elsif  CHN( I ) >= '0'  and then  CHN( I ) <= '9'  then
          if  IN_FRAC  then
            VAL := VAL + FRAC * NUM( CHARACTER'POS( CHN( I ) ) - CHARACTER'POS( '0' ) );
            FRAC := FRAC / 10.0;
          else
            VAL := 10.0 * VAL + NUM( CHARACTER'POS( CHN( I ) ) - CHARACTER'POS( '0' ) );
          end if;
        else
          exit;
        end if;
        I := I + 1;
      end loop;
      -- Appliquer exposant
      if  EXP_NEG  then
        for  J in 1 .. EXP_VAL  loop  VAL := VAL / 10.0;  end loop;
      else
        for  J in 1 .. EXP_VAL  loop  VAL := VAL * 10.0;  end loop;
      end if;
      if  NEG  then
        ITEM := -VAL;
      else
        ITEM := VAL;
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


    procedure		GET		( FROM :in STRING;
					  ITEM :out NUM;
					  LAST :out POSITIVE
					)
    is
    begin null;

    end	GET;
	----

			---
    procedure		PUT		( TO   :out STRING;
					  ITEM :in NUM;
					  AFT  :in FIELD		:= DEFAULT_AFT;
					  EXP  :in INTEGER		:= DEFAULT_EXP
					)
    is			---
    begin null;

    end	PUT;
	----

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

      CHN		: STRING( 1 .. 80 );
      LEN		: NATURAL		:= 0;
      VAL		: NUM		:= 0.0;
      FRAC	: NUM		:= NUM'DELTA;
      NEG		: BOOLEAN		:= FALSE;
      I		: NATURAL;
      IN_FRAC	: BOOLEAN		:= FALSE;
      EXP_VAL	: INTEGER		:= 0;
      EXP_NEG	: BOOLEAN		:= FALSE;

    begin
      GET_LINE( FILE, CHN, LEN );
      I := 1;
      -- Sauter les espaces de tete
      while  I <= LEN  and then  CHN( I ) = ' '  loop
        I := I + 1;
      end loop;
      -- Signe optionnel
      if  I <= LEN  and then  CHN( I ) = '-'  then
        NEG := TRUE;
        I := I + 1;
      elsif  I <= LEN  and then  CHN( I ) = '+'  then
        I := I + 1;
      end if;
      -- Partie entiere et fractionnaire
      while  I <= LEN  loop
        if  CHN( I ) = '.'  then
          IN_FRAC := TRUE;
        elsif  CHN( I ) = 'E'  or  CHN( I ) = 'e'  then
          I := I + 1;
          if  I <= LEN  and then  CHN( I ) = '-'  then
            EXP_NEG := TRUE;
            I := I + 1;
          elsif  I <= LEN  and then  CHN( I ) = '+'  then
            I := I + 1;
          end if;
          while  I <= LEN  and then  CHN( I ) >= '0'  and then  CHN( I ) <= '9'  loop
            EXP_VAL := 10 * EXP_VAL + CHARACTER'POS( CHN( I ) ) - CHARACTER'POS( '0' );
            I := I + 1;
          end loop;
          exit;
        elsif  CHN( I ) >= '0'  and then  CHN( I ) <= '9'  then
          if  IN_FRAC  then
            VAL := VAL + NUM( FRAC * NUM( CHARACTER'POS( CHN( I ) ) - CHARACTER'POS( '0' ) ) );
            FRAC := FRAC / 10;
          else
            VAL := 10 * VAL + NUM( CHARACTER'POS( CHN( I ) ) - CHARACTER'POS( '0' ) );
          end if;
        else
          exit;
        end if;
        I := I + 1;
      end loop;
      -- Appliquer exposant (rarement present pour un fixed, mais accepte)
      if  EXP_NEG  then
        for  J in 1 .. EXP_VAL  loop  VAL := VAL / 10;  end loop;
      else
        for  J in 1 .. EXP_VAL  loop  VAL := VAL * 10;  end loop;
      end if;
      if  NEG  then
        ITEM := -VAL;
      else
        ITEM := VAL;
      end if;

    end	GET;
	----

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

      VAL		: NUM		:= ITEM;
      IS_NEGATIVE	: BOOLEAN		:= ITEM < 0.0;
      E		: INTEGER		:= 0;
      DIGIT	: INTEGER;
      INT_PART	: NUM;
      FRC_PART	: NUM;

    begin
      -- Traiter le signe : on travaille sur la valeur absolue
      if  IS_NEGATIVE  then
        VAL := -ITEM;
      end if;

      ----------------------------------------------------------------
      -- Cas EXP = 0 : notation decimale etendue [-]ddd.ddd (defaut fixed)
      ----------------------------------------------------------------
--      if  EXP = 0  then

        -- Separer partie entiere et partie fractionnaire
        INT_PART := NUM( LONG_INTEGER( VAL ) );
        if  INT_PART > VAL  then									-- securite si arrondi par exces
          INT_PART := INT_PART - 1.0;
        end if;
        FRC_PART := VAL - INT_PART;

        -- Construire la chaine des chiffres de la partie entiere (au moins un '0')
        declare
          IBUF	: STRING( 1 .. 40 );
          NB	: NATURAL			:= 0;
	IPART	: LONG_INTEGER		:= LONG_INTEGER( INT_PART );
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

          -- Longueur du champ avant le point : chiffres + signe eventuel
          FLEN := NB;
          if  IS_NEGATIVE  then
            FLEN := FLEN + 1;
          end if;
          -- Padding a gauche pour atteindre FORE
          if  FORE > FLEN  then
            for  K in 1 .. FORE - FLEN  loop
              PUT( FILE, ' ' );
            end loop;
          end if;

          -- Signe
          if  IS_NEGATIVE  then
            PUT( FILE, '-' );
          end if;

          -- Chiffres de la partie entiere (IBUF est en ordre inverse)
          for  K in reverse 1 .. NB  loop
            PUT( FILE, IBUF( K ) );
          end loop;
        end;

        -- Point decimal
        PUT( FILE, '.' );

        -- Chiffres apres le point
        for  K in 1 .. AFT  loop
	FRC_PART := FRC_PART * 10;
	DIGIT := INTEGER( FRC_PART - NUM( 0.5 * NUM'SMALL ) );						-- troncature
	if  DIGIT > 9  then DIGIT := 9; end if;
	if  DIGIT < 0  then DIGIT := 0; end if;
	PUT( FILE, CHARACTER'VAL( CHARACTER'POS( '0' ) + DIGIT ) );
	FRC_PART := FRC_PART - NUM( DIGIT );
        end loop;

      ----------------------------------------------------------------
      -- Cas EXP > 0 : notation scientifique [-]d.dddE[+|-]dd
      ----------------------------------------------------------------
--      else

        -- Normaliser 1.0 <= VAL < 10.0 et calculer l'exposant
--        if  VAL /= 0.0  then
--          while  VAL >= 10.0  loop
--            VAL := VAL / 10;
--            E := E + 1;
--          end loop;
--          while  VAL < 1.0  loop
--            VAL := VAL * 10;
--            E := E - 1;
--          end loop;
--        end if;

        -- Padding FORE : 1 chiffre avant le point (+ signe eventuel)
--        declare
--          FORE_LEN	: NATURAL	:= 1;
--        begin
--          if  IS_NEGATIVE  then
--            FORE_LEN := 2;
--          end if;
--          if  FORE > FORE_LEN  then
--            for  K in 1 .. FORE - FORE_LEN  loop
--              PUT( FILE, ' ' );
--            end loop;
--          end if;
--        end;

        -- Signe
--        if  IS_NEGATIVE  then
--          PUT( FILE, '-' );
--        end if;

        -- Chiffre avant le point
--        DIGIT := INTEGER( VAL - NUM( 0.5 * NUM'DELTA ) );
--        if  DIGIT > 9  then DIGIT := 9; end if;
--        if  DIGIT < 0  then DIGIT := 0; end if;
--        PUT( FILE, CHARACTER'VAL( CHARACTER'POS( '0' ) + DIGIT ) );
--        VAL := ( VAL - NUM( DIGIT ) ) * 10;

        -- Point decimal
--        PUT( FILE, '.' );

        -- Chiffres apres le point
--        for  K in 1 .. AFT  loop
--          DIGIT := INTEGER( VAL - NUM( 0.5 * NUM'DELTA ) );
--          if  DIGIT > 9  then DIGIT := 9; end if;
--          if  DIGIT < 0  then DIGIT := 0; end if;
--          PUT( FILE, CHARACTER'VAL( CHARACTER'POS( '0' ) + DIGIT ) );
--          VAL := ( VAL - NUM( DIGIT ) ) * 10;
--        end loop;

        -- Exposant
--        PUT( FILE, 'E' );
--        if  E < 0  then
--          PUT( FILE, '-' );
--          E := -E;
--        else
--          PUT( FILE, '+' );
--        end if;
--        declare
--          EXP_STR	: STRING( 1 .. EXP );
--          EVAL	: INTEGER	:= E;
--        begin
--          for  K in reverse 1 .. EXP  loop
--            EXP_STR( K ) := CHARACTER'VAL( CHARACTER'POS( '0' ) + EVAL mod 10 );
--            EVAL := EVAL / 10;
--          end loop;
--          PUT( FILE, EXP_STR );
--        end;

--      end if;

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
    begin null;

    end	GET;
	----

			---
    procedure		PUT		( TO   :out STRING;
					  ITEM :in NUM;
					  AFT  :in FIELD		:= DEFAULT_AFT;
					  EXP  :in INTEGER		:= DEFAULT_EXP
					)
    is			---
    begin null;

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

      function		GET_ENUM_IMAGES			return STRING
      is		---------------
      begin
        ASM_OP_2'( OPCODE => La,  LVL => 1, OFS => -24 );							-- empiler @GFP_disp (GET: 3 PRM)
        ASM_OP_3'( OPCODE => LIVa,  DISP => -8, OFS=> 16 );							-- deref __u_ofs → IMAGES
        ASM_OP_2'( OPCODE => Sa,  LVL => 2, OFS => -8 );							-- stocker dans result_ofs
      end	GET_ENUM_IMAGES;
      		---------------
    begin
      declare
        IMAGES_STR		:constant STRING	:= GET_ENUM_IMAGES;
        CHN			: STRING( 1 .. 80 );
        LEN			: NATURAL		:= 0;
        I			: POSITIVE;
        TOK_START		: POSITIVE;
        TOK_LEN		: NATURAL;
        REP			: INTEGER;
        IMG_LEN		: INTEGER;
        IMG_START		: POSITIVE;
        FOUND		: BOOLEAN		:= FALSE;
        IMG_CH		: CHARACTER;
        TOK_CH		: CHARACTER;
      begin
        -- Lire un token depuis le fichier
        GET_LINE( FILE, CHN, LEN );
        -- Sauter les espaces de tete
        I := 1;
        while  I <= LEN  and then  CHN( I ) = ' '  loop
          I := I + 1;
        end loop;
        TOK_START := I;
        -- Lire le token (lettres, chiffres, underscores)
        while  I <= LEN  loop
          if  CHN( I ) >= 'A'  and then  CHN( I ) <= 'Z'  then
            I := I + 1;
          elsif  CHN( I ) >= 'a'  and then  CHN( I ) <= 'z'  then
            I := I + 1;
          elsif  CHN( I ) >= '0'  and then  CHN( I ) <= '9'  then
            I := I + 1;
          elsif  CHN( I ) = '_'  then
            I := I + 1;
          else
            exit;
          end if;
        end loop;
        TOK_LEN := I - TOK_START;

        -- Parcourir les images pour trouver la correspondance
        I := IMAGES_STR'FIRST;
        while  I <= IMAGES_STR'LAST  loop
          REP := CHARACTER'POS( IMAGES_STR( I ) );
          IMG_LEN := CHARACTER'POS( IMAGES_STR( I + 1 ) );
          IMG_START := I + 2;
          if  IMG_LEN = TOK_LEN  then
            FOUND := TRUE;
            for  J in 0 .. IMG_LEN - 1  loop
              IMG_CH := IMAGES_STR( IMG_START + J );
              TOK_CH := CHN( TOK_START + J );
              if  TOK_CH >= 'a'  and then  TOK_CH <= 'z'  then
                TOK_CH := CHARACTER'VAL( CHARACTER'POS( TOK_CH ) - 32 );
              end if;
              if  IMG_CH /= TOK_CH  then
                FOUND := FALSE;
              end if;
            end loop;
            if  FOUND  then
              ITEM := ENUM'VAL( REP );
              return;
            end if;
          end if;
          I := I + 2 + IMG_LEN;
        end loop;
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
    begin null;

    end	GET;
	---

			---
    procedure		PUT		( TO   :out STRING;
					  ITEM :in ENUM;
					  SET  :in TYPE_SET		:= DEFAULT_SETTING
					)
    is			---
    begin null;

    end	PUT;
	----

  end	ENUMERATION_IO;
	--------------

begin
  STD_INPUT.NAME_LEN	:= 0;
  STD_INPUT.MODE		:= IN_FILE;
  STD_INPUT.PAGE_LENGTH	:= 72;
  STD_INPUT.LINE_LENGTH	:= 256;
  STD_INPUT.PAGE := 1;
  STD_INPUT.LINE := 1;
  STD_INPUT.COL  := 1;

  STD_OUTPUT.NAME_LEN	:= 0;
  STD_OUTPUT.MODE		:= OUT_FILE;
  STD_OUTPUT.PAGE_LENGTH	:= 72;
  STD_OUTPUT.LINE_LENGTH	:= 256;
  STD_OUTPUT.PAGE := 1;
  STD_OUTPUT.LINE := 1;
  STD_OUTPUT.COL  := 1;

end	TEXT_IO;
	-------
