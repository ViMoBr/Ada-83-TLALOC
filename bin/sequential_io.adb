with TEXT_IO, SYSTEM, MACHINE_CODE;
use  TEXT_IO, SYSTEM, MACHINE_CODE;

					--------------
	package body			SEQUENTIAL_IO
is					--------------

			--   F I L E   M A N A G E M E N T

			------
  procedure		CREATE		( FILE :in out FILE_TYPE;
					  MODE :in FILE_MODE	:= OUT_FILE;
					  NAME :in STRING	:= "";
					  FORM :in STRING	:= ""
					)
  is			------

    ERR_OR_ID	: INTEGER;

		------------------
    function	CREATE_SYSTEM_CALL	( NAME :in STRING )		return INTEGER
    is		------------------
    begin
      ASM_OP_2'( OPCODE => LA, LVL => 2, OFS => -8 );			-- @descripteur de NAME
      ASM_OP_0'( OPCODE => SYS_FILE_CREATE );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -24 );			-- Retour du File ID apres le GFP

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
      FILE.AT_END_OF_FILE := FALSE;
    end if;

  end	CREATE;
	------


			----
  procedure		OPEN		( FILE :in out FILE_TYPE;
					  MODE :in FILE_MODE;
					  NAME :in STRING;
					  FORM :in STRING	:= ""
					)
  is			----

    ERR_OR_ID	: INTEGER;

		----------------
    function	OPEN_SYSTEM_CALL	( NAME :in STRING )		return INTEGER
    is		----------------
    begin
      ASM_OP_2'( OPCODE => LA, LVL => 2, OFS => -8 );			-- @descripteur de NAME
      ASM_OP_0'( OPCODE => SYS_FILE_OPEN );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -24 );			-- Retour du File ID apres le GFP

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
      FILE.AT_END_OF_FILE := FALSE;
    end if;

  end	OPEN;
	----


			-----
  procedure		CLOSE		( FILE :in out FILE_TYPE )
  is			-----

    ERR_CODE	: INTEGER;

		-----------------
    function	CLOSE_SYSTEM_CALL	( FILE_ID :in INTEGER )		return INTEGER
    is		-----------------
    begin
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );			-- FILE_ID
      ASM_OP_0'( OPCODE => SYS_FILE_CLOSE );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -24 );			-- Retour du resultat syscall apres le GFP

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
    function	DELETE_SYSTEM_CALL	( NAME : STRING )		return INTEGER
    is		------------------
    begin
      ASM_OP_2'( OPCODE => La, LVL => 2, OFS => -8 );			-- @descripteur de NAME
      ASM_OP_0'( OPCODE => SYS_FILE_DELETE );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -24 );			-- Retour du resultat syscall apres le GFP

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

		----------------
    function	SEEK_SYSTEM_CALL	( FILE_ID :in INTEGER )		return INTEGER
    is		----------------
    begin
      ASM_OP_1'( OPCODE => LI, VAL => 0 );				-- OFFSET = 0 (debut du fichier)
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );			-- FILE_ID
      ASM_OP_0'( OPCODE => SYS_FILE_SET_POS );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -24 );			-- Retour du resultat syscall

    end	SEEK_SYSTEM_CALL;
	----------------

  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    ERR_CODE := SEEK_SYSTEM_CALL( FILE.ID );
    FILE.MODE := MODE;
    FILE.AT_END_OF_FILE := FALSE;

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


			--   I N P U T   /   O U T P U T   O P E R A T I O N S


			----
  procedure		READ		( FILE :in  FILE_TYPE;
					  ITEM :out ELEMENT_TYPE
					)
  is			----

    BYTES_READ	: INTEGER;
    SIZE_BYTES	: INTEGER	:= ELEMENT_TYPE'SIZE / SYSTEM.STORAGE_UNIT;

		----------------
    function	READ_SYSTEM_CALL	( FILE_ID :in INTEGER; LENGTH :in INTEGER; ADR :SYSTEM.ADDRESS )
					return INTEGER
    is		----------------
    begin
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -16 );			-- LENGTH en octets
      ASM_OP_2'( OPCODE => La, LVL => 2, OFS => -24 );			-- @ITEM_DATA (data_ptr reel via ADR)
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );			-- FILE_ID
      ASM_OP_0'( OPCODE => SYS_FILE_READ );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -32 );			-- Retour du BYTES_READ apres le GFP

    end	READ_SYSTEM_CALL;
	----------------

  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    if  FILE.MODE = OUT_FILE    then raise MODE_ERROR;   end if;
    if  FILE.AT_END_OF_FILE     then raise END_ERROR;    end if;
				-- Lit a la position courante (avancement sequentiel)
    BYTES_READ := READ_SYSTEM_CALL( FILE.ID, SIZE_BYTES, ITEM'ADDRESS );
    if  BYTES_READ < SIZE_BYTES  then
      raise END_ERROR;
    end if;

  end	READ;
	----


			-----
  procedure		WRITE		( FILE :in FILE_TYPE;
					  ITEM :in ELEMENT_TYPE
					)
  is			-----

    ERR_CODE	: INTEGER;
    SIZE_BYTES	: INTEGER	:= ELEMENT_TYPE'SIZE / SYSTEM.STORAGE_UNIT;

		-----------------
    function	WRITE_SYSTEM_CALL	( FILE_ID :in INTEGER; LENGTH :in INTEGER; ADR :SYSTEM.ADDRESS )
					return INTEGER
    is		-----------------
    begin
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -16 );			-- LENGTH en octets
      ASM_OP_2'( OPCODE => La, LVL => 2, OFS => -24 );			-- @ITEM_DATA (data_ptr reel via ADR)
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );			-- FILE_ID
      ASM_OP_0'( OPCODE => SYS_FILE_WRITE );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -32 );			-- Retour du resultat syscall apres le GFP

    end	WRITE_SYSTEM_CALL;
	-----------------

  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    if  FILE.MODE = IN_FILE     then raise MODE_ERROR;   end if;
				-- Ecrit a la position courante (avancement sequentiel)
    ERR_CODE := WRITE_SYSTEM_CALL( FILE.ID, SIZE_BYTES, ITEM'ADDRESS );

  end	WRITE;
	-----


			-----------
  function		END_OF_FILE	( FILE :in FILE_TYPE )		return BOOLEAN
  is			-----------

    POS_BYTES	: INTEGER;
    SIZ_BYTES	: INTEGER;

		---------------------
    function	GET_POS_SYSTEM_CALL	( FILE_ID :in INTEGER )		return INTEGER
    is		---------------------
    begin
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );
      ASM_OP_0'( OPCODE => SYS_FILE_GET_POS );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -24 );

    end	GET_POS_SYSTEM_CALL;
	---------------------

		---------------------
    function	GET_SIZE_SYSTEM_CALL	( FILE_ID :in INTEGER )		return INTEGER
    is		---------------------
    begin
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );
      ASM_OP_0'( OPCODE => SYS_FILE_GET_SIZE );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -24 );

    end	GET_SIZE_SYSTEM_CALL;
	---------------------

  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    if  FILE.MODE = OUT_FILE    then raise MODE_ERROR;   end if;
    POS_BYTES := GET_POS_SYSTEM_CALL( FILE.ID );
    SIZ_BYTES := GET_SIZE_SYSTEM_CALL( FILE.ID );
    return POS_BYTES >= SIZ_BYTES;

  end	END_OF_FILE;
	-----------


	--------------
end	SEQUENTIAL_IO;
	--------------
