with SYSTEM, MACHINE_CODE;
use  SYSTEM, MACHINE_CODE;
					----------
	package body			DIRECT_IO
is					----------

	-- LRM 14.2.5 : DIRECT_IO traite un fichier comme un tableau
	-- d'elements de meme taille. L'element d'index N occupe les
	-- octets [(N-1)*SIZE_BYTES .. N*SIZE_BYTES - 1].
	--
	-- ELEMENT_TYPE est un parametre formel prive : la taille en
	-- octets devrait etre lue au runtime via le mecanisme des
	-- generiques (GFP_disp + __u_ofs vers le patron de type).
	-- L'expander ne supporte pas encore DN_PRIVATE_DEF a ce niveau,
	-- donc cette implementation s'appuie sur INTEGER'SIZE comme
	-- taille de reference. DIRECT_IO est testable des aujourd'hui
	-- avec ELEMENT_TYPE = INTEGER.
	--
	-- L'index courant n'est pas stocke dans le record FILE_TYPE
	-- (FILE est passe en mode `in` par le LRM, pas modifiable par
	-- du code Ada pur). Il est obtenu a la demande via lseek
	-- SEEK_CUR (macro SYS_FILE_GET_POS).


			-------------------
  function	BYTES_PER_ELEMENT					return INTEGER
  is		-------------------

	-- TAILLE EN OCTETS DE ELEMENT_TYPE.
	--
	-- L'expander ne genere actuellement aucun mecanisme pour
	-- communiquer au modele generique la taille d'un parametre
	-- formel "is private". Pour completer le support :
	--
	--   * expander-structures.adb : ajouter une branche
	--     DN_PRIVATE_DEF dans la boucle GPRM (~ligne 230) pour
	--     emettre `PRM ELEMENT_TYPE__u_ofs`.
	--
	--   * expander-declarations.adb : etendre la branche de
	--     CODE_INSTANTIATION (~ligne 1106) pour les types
	--     non-DN_ENUMERATION (DN_INTEGER, DN_FLOAT, DN_RECORD,
	--     DN_ARRAY...) afin d'emettre :
	--         VAR ELEMENT_TYPE__u_ofs, q
	--             LCA <TYPE>.SIZ
	--             Sa <lvl>, ELEMENT_TYPE__u_ofs
	--
	-- Une fois ces extensions en place, ce corps sera :
	--
	--     ASM_OP_2'( OPCODE => LA,  LVL => 1, OFS => -16 );    -- @GFP_disp instance
	--     ASM_OP_3'( OPCODE => LIA, LVL => -1, DISP => -8, OFS => 0 );  -- patron + 0 = @SIZ
	--     ASM_OP_2'( OPCODE => Ld,  LVL => -1, OFS => 0 );     -- charge dword SIZ (en bits)
	--     ASM_OP_1'( OPCODE => LI,  VAL => 8 );
	--     ASM_OP_0'( OPCODE => DIV );                          -- bits / 8 = octets
	--     ASM_OP_2'( OPCODE => SD,  LVL => 1, OFS => -8 );     -- result__ofs
	--
	-- En attendant, on rend INTEGER'SIZE / 8 = 4 : DIRECT_IO est
	-- testable avec ELEMENT_TYPE = INTEGER.
  begin
    return ELEMENT_TYPE'SIZE / SYSTEM.STORAGE_UNIT;
--    return FILE_TYPE'SIZE / SYSTEM.STORAGE_UNIT;

  end	BYTES_PER_ELEMENT;
	-------------------


			--   F I L E   M A N A G E M E N T

			------
  procedure		CREATE		( FILE :in out FILE_TYPE;
					  MODE :in FILE_MODE	:= INOUT_FILE;
					  NAME :in STRING		:= "";
					  FORM :in STRING		:= ""
					)
  is			------

    ERR_OR_ID	: INTEGER;

		------------------
    function	CREATE_SYSTEM_CALL	( NAME :in STRING )		return INTEGER
    is		------------------
    begin
      ASM_OP_2'( OPCODE => LA, LVL => 2, OFS => -8 );			-- @descripteur de NAME
      ASM_OP_0'( OPCODE => SYS_FILE_CREATE );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -16 );			-- Retour du File ID

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
      FILE.INDEX := 1;
      FILE.AT_END_OF_FILE := FALSE;
    end if;

  end	CREATE;
	------


			----
  procedure		OPEN		( FILE : in out FILE_TYPE;
					  MODE : in FILE_MODE;
					  NAME : in STRING;
					  FORM : in STRING		:= ""
					)
  is			----

    ERR_OR_ID	: INTEGER;

		----------------
    function	OPEN_SYSTEM_CALL	( NAME :in STRING )		return INTEGER
    is		----------------
    begin
      ASM_OP_2'( OPCODE => LA, LVL => 2, OFS => -8 );			-- @descripteur de NAME
      ASM_OP_0'( OPCODE => SYS_FILE_OPEN );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -16 );			-- Retour du File ID

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
      FILE.INDEX := 1;
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
    function	DELETE_SYSTEM_CALL	( NAME : STRING )		return INTEGER
    is		------------------
    begin
      ASM_OP_2'( OPCODE => La, LVL => 2, OFS => -8 );			-- @descripteur de NAME
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

		----------------
    function	SEEK_SYSTEM_CALL	( FILE_ID :in INTEGER )		return INTEGER
    is		----------------
    begin
      ASM_OP_1'( OPCODE => LI, VAL => 0 );				-- OFFSET = 0 (debut du fichier)
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );			-- FILE_ID
      ASM_OP_0'( OPCODE => SYS_FILE_SET_POS );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -16 );			-- Retour du resultat syscall

    end	SEEK_SYSTEM_CALL;
	----------------

  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    ERR_CODE := SEEK_SYSTEM_CALL( FILE.ID );
    FILE.MODE := MODE;
    FILE.INDEX := 1;
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
					  ITEM :out ELEMENT_TYPE;
					  FROM :in  POSITIVE_COUNT
					)
  is			----

    BYTES_READ	: INTEGER;
    SIZE_BYTES	: INTEGER	:= BYTES_PER_ELEMENT;
    DUMMY	: INTEGER;

		----------------
    function	SEEK_SYSTEM_CALL	( FILE_ID :in INTEGER; OFFSET :in INTEGER )	return INTEGER
    is		----------------
    begin
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -16 );			-- OFFSET en octets
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );			-- FILE_ID
      ASM_OP_0'( OPCODE => SYS_FILE_SET_POS );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -24 );			-- Retour du resultat syscall

    end	SEEK_SYSTEM_CALL;
	----------------

		----------------
    function	READ_SYSTEM_CALL	( FILE_ID :in INTEGER; LENGTH :in INTEGER )	return INTEGER
    is		----------------
    begin
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -16 );			-- LENGTH en octets
      ASM_OP_2'( OPCODE => La, LVL => 1, OFS => -16 );			-- @ITEM (param out READ : adresse de la zone destination)
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );			-- FILE_ID
      ASM_OP_0'( OPCODE => SYS_FILE_READ );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -24 );			-- Retour du BYTES_READ

    end	READ_SYSTEM_CALL;
	----------------

  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    if  FILE.MODE = OUT_FILE  then raise MODE_ERROR; end if;
    if  INTEGER( FROM ) <= 0  then raise USE_ERROR; end if;

    DUMMY      := SEEK_SYSTEM_CALL( FILE.ID, ( INTEGER( FROM ) - 1 ) * SIZE_BYTES );
    BYTES_READ := READ_SYSTEM_CALL( FILE.ID, SIZE_BYTES );
    if  BYTES_READ < SIZE_BYTES  then
      raise END_ERROR;
    end if;

  end	READ;
	----


			----
  procedure		READ		( FILE :in  FILE_TYPE;
					  ITEM :out ELEMENT_TYPE
					)
  is			----

    BYTES_READ	: INTEGER;
    SIZE_BYTES	: INTEGER	:= BYTES_PER_ELEMENT;

		----------------
    function	READ_SYSTEM_CALL	( FILE_ID :in INTEGER; LENGTH :in INTEGER )	return INTEGER
    is		----------------
    begin
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -16 );			-- LENGTH
      ASM_OP_2'( OPCODE => La, LVL => 1, OFS => -16 );			-- @ITEM
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );			-- FILE_ID
      ASM_OP_0'( OPCODE => SYS_FILE_READ );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -24 );

    end	READ_SYSTEM_CALL;
	----------------

  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    if  FILE.MODE = OUT_FILE  then raise MODE_ERROR; end if;
				-- Lit a la position courante du fichier (qui est l'index courant)
    BYTES_READ := READ_SYSTEM_CALL( FILE.ID, SIZE_BYTES );
    if  BYTES_READ < SIZE_BYTES  then
      raise END_ERROR;
    end if;

  end	READ;
	----


			-----
  procedure		WRITE		( FILE :in FILE_TYPE;
					  ITEM :in ELEMENT_TYPE;
					  TO   :in POSITIVE_COUNT
					)
  is			-----

    ERR_CODE	: INTEGER;
    SIZE_BYTES	: INTEGER	:= BYTES_PER_ELEMENT;
    DUMMY	: INTEGER;

		----------------
    function	SEEK_SYSTEM_CALL	( FILE_ID :in INTEGER; OFFSET :in INTEGER )	return INTEGER
    is		----------------
    begin
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -16 );
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );
      ASM_OP_0'( OPCODE => SYS_FILE_SET_POS );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -24 );

    end	SEEK_SYSTEM_CALL;
	----------------

		-----------------
    function	WRITE_SYSTEM_CALL	( FILE_ID :in INTEGER; LENGTH :in INTEGER )	return INTEGER
    is		-----------------
    begin
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -16 );			-- LENGTH
      ASM_OP_2'( OPCODE => La, LVL => 1, OFS => -16 );			-- @ITEM (param in WRITE : adresse de la zone source)
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );			-- FILE_ID
      ASM_OP_0'( OPCODE => SYS_FILE_WRITE );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -24 );

    end	WRITE_SYSTEM_CALL;
	-----------------

  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    if  FILE.MODE = IN_FILE  then raise MODE_ERROR; end if;
    if  INTEGER( TO ) <= 0  then raise USE_ERROR; end if;

    DUMMY    := SEEK_SYSTEM_CALL( FILE.ID, ( INTEGER( TO ) - 1 ) * SIZE_BYTES );
    ERR_CODE := WRITE_SYSTEM_CALL( FILE.ID, SIZE_BYTES );

  end	WRITE;
	-----


			-----
  procedure		WRITE		( FILE :in FILE_TYPE;
					  ITEM :in ELEMENT_TYPE )
  is			-----

    ERR_CODE	: INTEGER;
    SIZE_BYTES	: INTEGER	:= BYTES_PER_ELEMENT;

		-----------------
    function	WRITE_SYSTEM_CALL	( FILE_ID :in INTEGER; LENGTH :in INTEGER )	return INTEGER
    is		-----------------
    begin
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -16 );
      ASM_OP_2'( OPCODE => La, LVL => 1, OFS => -16 );
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );
      ASM_OP_0'( OPCODE => SYS_FILE_WRITE );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -24 );

    end	WRITE_SYSTEM_CALL;
	-----------------

  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    if  FILE.MODE = IN_FILE  then raise MODE_ERROR; end if;
				-- Ecrit a la position courante
    ERR_CODE := WRITE_SYSTEM_CALL( FILE.ID, SIZE_BYTES );

  end	WRITE;
	-----


			---------
  procedure		SET_INDEX	( FILE :in FILE_TYPE; TO :in POSITIVE_COUNT )
  is			---------

    ERR_CODE	: INTEGER;
    SIZE_BYTES	: INTEGER	:= BYTES_PER_ELEMENT;

		----------------
    function	SEEK_SYSTEM_CALL	( FILE_ID :in INTEGER; OFFSET :in INTEGER )	return INTEGER
    is		----------------
    begin
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -16 );			-- OFFSET en octets
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );			-- FILE_ID
      ASM_OP_0'( OPCODE => SYS_FILE_SET_POS );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -24 );

    end	SEEK_SYSTEM_CALL;
	----------------

  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    if  INTEGER( TO ) <= 0  then raise USE_ERROR; end if;
				-- Repositionne physiquement le fichier ; INDEX() lira la
				-- nouvelle position via lseek SEEK_CUR.
    ERR_CODE := SEEK_SYSTEM_CALL( FILE.ID, ( INTEGER( TO ) - 1 ) * SIZE_BYTES );

  end	SET_INDEX;
	---------


			-----
  function		INDEX		( FILE :in FILE_TYPE )		return POSITIVE_COUNT
  is			-----

    BYTES		: INTEGER;
    SIZE_BYTES	: INTEGER	:= BYTES_PER_ELEMENT;

		---------------------
    function	GET_POS_SYSTEM_CALL	( FILE_ID :in INTEGER )		return INTEGER
    is		---------------------
    begin
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );			-- FILE_ID
      ASM_OP_0'( OPCODE => SYS_FILE_GET_POS );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -16 );			-- Retour de la position en octets

    end	GET_POS_SYSTEM_CALL;
	---------------------

  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    BYTES := GET_POS_SYSTEM_CALL( FILE.ID );
				-- INDEX en base 1 : position 0 octet -> index 1
    return POSITIVE_COUNT( ( BYTES / SIZE_BYTES ) + 1 );

  end	INDEX;
	-----


			----
  function		SIZE		( FILE :in FILE_TYPE )		return COUNT
  is			----

    BYTES		: INTEGER;
    SIZE_BYTES	: INTEGER	:= BYTES_PER_ELEMENT;

		---------------------
    function	GET_SIZE_SYSTEM_CALL	( FILE_ID :in INTEGER )		return INTEGER
    is		---------------------
    begin
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );			-- FILE_ID
      ASM_OP_0'( OPCODE => SYS_FILE_GET_SIZE );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -16 );			-- Retour de la taille en octets

    end	GET_SIZE_SYSTEM_CALL;
	---------------------

  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    BYTES := GET_SIZE_SYSTEM_CALL( FILE.ID );
    return COUNT( BYTES / SIZE_BYTES );

  end	SIZE;
	----


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
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -16 );

    end	GET_POS_SYSTEM_CALL;
	---------------------

		---------------------
    function	GET_SIZE_SYSTEM_CALL	( FILE_ID :in INTEGER )		return INTEGER
    is		---------------------
    begin
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );
      ASM_OP_0'( OPCODE => SYS_FILE_GET_SIZE );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -16 );

    end	GET_SIZE_SYSTEM_CALL;
	---------------------

  begin
    if  FILE.IS_OPENED = FALSE  then raise STATUS_ERROR; end if;
    if  FILE.MODE = OUT_FILE  then raise MODE_ERROR; end if;
    POS_BYTES := GET_POS_SYSTEM_CALL( FILE.ID );
    SIZ_BYTES := GET_SIZE_SYSTEM_CALL( FILE.ID );
    return POS_BYTES >= SIZ_BYTES;

  end	END_OF_FILE;
	-----------


	---------
end	DIRECT_IO;
	---------
