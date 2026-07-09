------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

separate ( EXPANDER )

					-----
	package body			UTILS
is					-----


--  INACTIVE	: BOOLEAN renames TRUE;

  INT_LABEL	: LABEL_TYPE	:= 1;
  FS		: FILE_TYPE;


			--================--
  procedure		  OPEN_OUTPUT_FILE		( FILE_NAME :STRING )
  is			--================--

  begin
    CREATE ( FS, OUT_FILE, FILE_NAME( FILE_NAME'FIRST .. FILE_NAME'LAST-4 ) & ".FINC" );				-- FASM INCLUDE
    SET_OUTPUT ( FS );										-- CODAGE SUR SORTIE STANDARD
    INT_LABEL := 1;

  end	  OPEN_OUTPUT_FILE;
	--================--


			--=================--
  procedure		  CLOSE_OUTPUT_FILE
  is			--=================--

  begin
    SET_OUTPUT ( STANDARD_OUTPUT );
    CLOSE ( FS );

  end	  CLOSE_OUTPUT_FILE;
	--=================--


  package INT_IO	is new INTEGER_IO ( INTEGER ); use INT_IO;
  package LBL_IO	is new INTEGER_IO ( LABEL_TYPE ); use LBL_IO;


			--=========--
  function		  NEW_LABEL						return LABEL_TYPE
  is			--=========--

    LBL	: LABEL_TYPE	:= INT_LABEL;

  begin
    INT_LABEL := INT_LABEL + 1;
    return LBL;

  end	  NEW_LABEL;
	--=========--


			--=========--
  function		  NEW_LABEL						return STRING
  is			--=========--

    LSTR  :constant STRING	:= LABEL_TYPE'IMAGE( INT_LABEL );

  begin
    INT_LABEL := INT_LABEL + 1;
    return 'L' & LSTR( LSTR'FIRST+1 .. LSTR'LAST );

  end	  NEW_LABEL;
	--=========--


			--=========--
  function		  LABEL_STR			( LBL : LABEL_TYPE )	return STRING
  is			--=========--

    LSTR  :constant STRING	:= LABEL_TYPE'IMAGE( LBL );

  begin
    return 'L' & LSTR( LSTR'FIRST+1 .. LSTR'LAST );

  end	  LABEL_STR;
	--=========--


			--=========--
  procedure		  INC_LEVEL
  is			--=========--
  begin
    CUR_LEVEL := CUR_LEVEL + 1;

--    if DEBUG then put_line( "inc lvl cur= " & LEVEL_NUM'IMAGE( CUR_LEVEL ) ); end if;

--   exception
--     when CONSTRAINT_ERROR => raise STATIC_LEVEL_OVERFLOW;

  end	  INC_LEVEL;
	--=========--


			--=========--
  procedure		  DEC_LEVEL
  is			--=========--

  begin
    CUR_LEVEL := CUR_LEVEL - 1;

--    if DEBUG then put_line( "dec lvl cur= " & LEVEL_NUM'IMAGE( CUR_LEVEL ) ); end if;

--   exception
--     when CONSTRAINT_ERROR => raise STATIC_LEVEL_UNDERFLOW;
--
  end	  DEC_LEVEL;
	--=========--


			--=========--
  function		  TYPE_SIZE		( TYPE_SPEC :TREE )		return NATURAL
  is			--=========--

  begin
    case TYPE_SPEC.TY is
    when DN_ACCESS			=> return ADDR_SIZE;
    when DN_RECORD
	=> return ( DI( CD_IMPL_SIZE, TYPE_SPEC ) + STORAGE_UNIT - 1 ) / STORAGE_UNIT;
    when DN_CONSTRAINED_RECORD
	=> return TYPE_SIZE( D( SM_BASE_TYPE, TYPE_SPEC ) );
    when DN_ARRAY			=> return 2 * ADDR_SIZE;
    when DN_ENUMERATION | DN_INTEGER	=> return INTG_SIZE;
    when DN_FLOAT			=> return ADDR_SIZE;			-- 8 octets = 64 bits IEEE 754 double
    when DN_L_PRIVATE		=> return TYPE_SIZE( D( SM_TYPE_SPEC, TYPE_SPEC ) );
    when others =>
      PUT_LINE( "CODAGE_INTERMEDIAIRE.TYPE_SIZE : TYPE_SPEC.TY ILLICITE " & NODE_NAME'IMAGE( TYPE_SPEC.TY ) );
--      raise PROGRAM_ERROR;
    end case;
    return 0;

  end	  TYPE_SIZE;
	--=========--



			--=================--
  function		  CODE_DATA_TYPE_OF		( EXP_OR_TYPE_SPEC :TREE )	return CHARACTER
  is			--=================--

  begin
    if  EXP_OR_TYPE_SPEC.TY in CLASS_EXP  then
      declare
        EXP	: TREE	renames EXP_OR_TYPE_SPEC;

      begin
        case EXP.TY is
        when DN_FUNCTION_CALL | DN_PARENTHESIZED | DN_USED_OBJECT_ID =>
	return CODE_DATA_TYPE_OF( D( SM_EXP_TYPE, EXP ) );

        when others =>
	PUT_LINE( "ERREUR CODE_DATA_TYPE_OF : EXP.TY ILLICITE " & NODE_NAME'IMAGE( EXP.TY ) );
	raise PROGRAM_ERROR;
        end case;

      end;

    elsif  EXP_OR_TYPE_SPEC.TY in CLASS_TYPE_SPEC  then
      declare
        TYPE_SPEC	: TREE	renames EXP_OR_TYPE_SPEC;

      begin
        case TYPE_SPEC.TY is
        when DN_ACCESS =>
	return 'A';

        when DN_ENUMERATION =>
	declare
	  TYPE_SOURCE_NAME  : TREE		:= D( XD_SOURCE_NAME, TYPE_SPEC );
	  TYPE_SYMREP	: TREE		:= D( LX_SYMREP, TYPE_SOURCE_NAME );
	  NAME		: constant STRING	:= PRINT_NAME( TYPE_SYMREP );

	begin
	  if NAME = "BOOLEAN" then
	    return 'B';
	  elsif NAME = "CHARACTER" then
	    return 'B';
	  else
	    return 'I';
	  end if;
	end;

        when DN_INTEGER | DN_NUMERIC_LITERAL =>
	return 'I';

        when others =>
	PUT_LINE( "ERREUR CODE_DATA_TYPE_OF : TYPE_SPEC.TY ILLICITE " & NODE_NAME'IMAGE( TYPE_SPEC.TY ) );
	raise PROGRAM_ERROR;
        end case;
      end;

    else
      PUT_LINE ( "!!! CODE_DATA_TYPE_OF : EXP_OR_TYPE_SPEC.TY ILLICITE " & NODE_NAME'IMAGE ( EXP_OR_TYPE_SPEC.TY ) );
      raise PROGRAM_ERROR;
    end if;

  end	  CODE_DATA_TYPE_OF;
	--=================--


			--====================--
  function		  NUMBER_OF_DIMENSIONS	( EXP :TREE )	return NATURAL
  is			--====================--

  begin
    if  EXP.TY in CLASS_CONSTRAINED  then
      return NUMBER_OF_DIMENSIONS( D( SM_BASE_TYPE, EXP ) );

    elsif  EXP.TY = DN_FUNCTION_CALL or EXP.TY = DN_USED_OBJECT_ID  then
      return NUMBER_OF_DIMENSIONS( D( SM_EXP_TYPE, EXP ) );

    elsif  EXP.TY = DN_ARRAY  then
      return DI( CD_DIMENSIONS, EXP );

    else
      PUT_LINE( "ERREUR NUMBER_OF_DIMENSIONS : TYPE EXPRESSION ILLICITE" & NODE_NAME'IMAGE( EXP.TY ) );
      raise PROGRAM_ERROR;
    end if;

  end	  NUMBER_OF_DIMENSIONS;
	--====================--


			--===========--
  function		  CONSTRAINED		( TYPE_SPEC :TREE )		return BOOLEAN
  is			--===========--

  begin
    return not ( TYPE_SPEC.TY in CLASS_UNCONSTRAINED );

  end	  CONSTRAINED;
	--===========--



			--==============--
  procedure		  LOAD_TYPE_SIZE		( TYPE_SPEC :TREE )
  is			--==============--

  begin
    if  CONSTRAINED( TYPE_SPEC )  then
      PUT_LINE( ASCII.HT & "LI" & ASCII.HT &  INTEGER'IMAGE( TYPE_SIZE( TYPE_SPEC ) ) );

    else
      PUT_LINE( "ERREUR LOAD_TYPE_SIZE : TYPE_SPEC NON CONTRAINT" );
      raise PROGRAM_ERROR;

    end if;

  end	  LOAD_TYPE_SIZE;
	--==============--


			--=============--
  function		  OPER_SIZ_CHAR		( DEFN :TREE )		return CHARACTER
  is			--=============--
  begin
    if  DEFN.TY = DN_FLOAT  or  DEFN.TY = DN_ACCESS  then return 'q'; end if;
    declare
      SIZ		: NATURAL		:= DI( CD_IMPL_SIZE, DEFN );
    begin
      if  SIZ <= 0  then PUT_LINE( "'; EXPANDER.UTILS.OPER_SIZ_CHAR SIZ = 0 ! "
	& NODE_NAME'IMAGE( DEFN.TY )
	& ' ' & PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, DEFN ) ) )
	);
      raise  PROGRAM_ERROR;
      end if;
      if	 SIZ <= 8		then return 'b';
      elsif SIZ <= 16	then return 'w';
      elsif SIZ <= 32	then return 'd';
      elsif SIZ <= 64	then return 'q';
      else return 'v';
      end if;
    end;

  end	  OPER_SIZ_CHAR;
	--=============--


			--=============--
  function		  EXP_TYPE_CHAR		( EXP :TREE )	return CHARACTER
  is			--=============--

    EXP_TYPE	: TREE		:= D( SM_EXP_TYPE, EXP );

  begin
    -- Les flottants sont toujours en double IEEE 754 = 64 bits = qword
    if  EXP_TYPE.TY = DN_FLOAT  or  EXP_TYPE.TY = DN_ACCESS then return 'q'; end if;
    declare
      SIZ		: NATURAL		:= DI( CD_IMPL_SIZE, EXP_TYPE );
    begin
    if	 SIZ <= 8		then return 'b';
    elsif  SIZ <= 16	then return 'w';
    elsif  SIZ <= 32	then return 'd';
    elsif  SIZ <= 64	then return 'q';
    else return 'v';
    end if;
    end;

  end	  EXP_TYPE_CHAR;
	--=============--


			--========--
  procedure		  LOAD_MEM			( DEFN :TREE )
  is			--========--

  begin
    if  CODI.IN_GENERIC_BODY
        and then  DEFN.TY in CLASS_PARAM_NAME
        and then  EXPRESSIONS.IS_GENERIC_FORMAL_OBJECT( DEFN )  then
      declare
        DEFN_STR		:constant STRING	:= PRINT_NAME( D( LX_SYMREP, DEFN ) );
        OBJ_TYPE		: TREE		:= D( SM_OBJ_TYPE, DEFN );
        HAS_GENERIC_TYPE	: BOOLEAN
			:= EXPRESSIONS.IS_GENERIC_FORMAL_TYPE( D( XD_SOURCE_NAME, OBJ_TYPE ) );
      begin

        if  HAS_GENERIC_TYPE  then
	PUT_LINE( tab & "La " & IMAGE( CODI.GENERIC_BASE_LEVEL + 1 ) & "," & tab & "-GFP_ofs" );
	PUT_LINE( tab & "LVA ," & tab & "-" & DEFN_STR & "_ofs" );

	PUT_LINE( tab & "La" & LEVEL_NUM'IMAGE( CODI.GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );
	PUT_LINE( tab & "La ," & tab & '-'
			& PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, D( SM_OBJ_TYPE, DEFN ) ) ) )
			& "__ld_ofs" );
	PUT_LINE( tab & "CALLI" );

        else
	while  OBJ_TYPE.TY = DN_PRIVATE  or else  OBJ_TYPE.TY = DN_L_PRIVATE  loop
	  OBJ_TYPE := D( SM_TYPE_SPEC, OBJ_TYPE );
	end loop;

	PUT_LINE( tab & "La " & IMAGE( CODI.GENERIC_BASE_LEVEL + 1 ) & "," & tab & "-GFP_ofs" );

	if  OBJ_TYPE.TY in CLASS_SCALAR  or else  OBJ_TYPE.TY = DN_ACCESS  then
	  PUT_LINE( tab & "L" & OPER_SIZ_CHAR( OBJ_TYPE ) & " ," & tab & "-" & DEFN_STR & "_disp" );

	else
	  PUT_LINE( tab & "LVA ," & tab & "-" & DEFN_STR & "_disp" );
	end if;
        end if;
        return;
      end;
    end if;

    if  DEFN.TY in CLASS_PARAM_NAME  then								-- in_id in_out_id out_id
      if  (DEFN.TY = DN_IN_ID) and (D( SM_OBJ_TYPE, DEFN ).TY in CLASS_SCALAR
			or else D( SM_OBJ_TYPE, DEFN ).TY = DN_ACCESS)	then
				-------------------
				SCALAR_IN_PARAMETER:
        declare
	SIZ_CHAR  : CHARACTER	:= OPER_SIZ_CHAR( D( SM_OBJ_TYPE, DEFN ) );

        begin
	PUT( tab & "L" & SIZ_CHAR & ' ' & INTEGER'IMAGE( DI( CD_LEVEL, DEFN ) ) & ',' & tab );
	PUT( '-' & PRINT_NAME( D( LX_SYMREP, DEFN ) ) );							-- ATTENTION signe offset de params opposé aux vars
	PUT_LINE( "_ofs" );										-- offset de parametre scalaire
        end	SCALAR_IN_PARAMETER;
		-------------------

      elsif  D( SM_OBJ_TYPE, DEFN ).TY in CLASS_SCALAR
	or else  D( SM_OBJ_TYPE, DEFN ).TY = DN_ACCESS  then						-- out/in_out SCALAIRE lu en expression :
			----------------------								-- le slot contient l'ADRESSE, dereferencer
			SCALAR_REF_PARAMETER:								-- (meme geste que la re-passe out->in de
        declare											-- CODE_PROCEDURE_CALL). Piege n° 80.
	SIZ_CHAR  : CHARACTER	:= OPER_SIZ_CHAR( D( SM_OBJ_TYPE, DEFN ) );

        begin
	PUT( tab & "LI" & SIZ_CHAR & ' ' & INTEGER'IMAGE( DI( CD_LEVEL, DEFN ) ) & ',' &	tab );
	PUT( '-' & PRINT_NAME( D( LX_SYMREP, DEFN ) ) );
	PUT_LINE( "_ofs" );
        end	SCALAR_REF_PARAMETER;
		----------------------

      else											-- pas scalaire ou out in/out
        PUT( tab & "La " & INTEGER'IMAGE( DI( CD_LEVEL, DEFN ) ) & ',' & tab );
        PUT( '-' & PRINT_NAME( D( LX_SYMREP, DEFN ) ) );							-- ATTENTION signe offset de params opposé aux vars
        PUT_LINE( "_ofs" );										-- offset de parametre adresse

      end if;

    else
      declare
        OBJ_TYPE	:TREE	:= D( SM_OBJ_TYPE, DEFN );
      begin
        while  OBJ_TYPE.TY = DN_PRIVATE  or  OBJ_TYPE.TY = DN_L_PRIVATE  loop
	OBJ_TYPE := D( SM_TYPE_SPEC, OBJ_TYPE );
        end loop;

        if DEFN.TY in CLASS_VC_NAME  and then  DB( SM_RENAMES_OBJ, DEFN )  then
			---------------
			MANAGE_RENAMING:
	declare
	  OBJ_LEVEL	: LEVEL_NUM	:= DI( CD_LEVEL, DEFN );
	  OBJ_STR		: constant STRING	:= PRINT_NAME( D( LX_SYMREP, DEFN ) );
	begin

	  if  OBJ_TYPE.TY in CLASS_SCALAR  or else OBJ_TYPE.TY = DN_ACCESS  then
	    PUT_LINE( tab & "LI" & OPER_SIZ_CHAR( OBJ_TYPE ) & tab & IMAGE( OBJ_LEVEL ) & ", "
			& OBJ_STR & "_disp, 0" );
	  else
	    PUT_LINE( tab & "LVA" & tab & IMAGE( OBJ_LEVEL ) & ", " & OBJ_STR & "_disp" );
	  end if;

	  return;
	end	MANAGE_RENAMING;
		---------------
        end if;

        if  OBJ_TYPE.TY in CLASS_SCALAR  or else OBJ_TYPE.TY = DN_ACCESS  then
        declare
	SIZ_CHAR  : CHARACTER	:= OPER_SIZ_CHAR( OBJ_TYPE );
	DEFN_LVL  : INTEGER		:= DI( CD_LEVEL, DEFN );

        begin
	PUT( tab & "L" & SIZ_CHAR & ' ' & IMAGE( DEFN_LVL ) & ',' & tab );
	if  DEFN_LVL /= INTEGER( CUR_LEVEL )
	or else	D( XD_REGION, DEFN ).TY = DN_PACKAGE_ID
	then
	  REGIONS_PATH( DEFN );
	end if;
	PUT_LINE( PRINT_NAME( D( LX_SYMREP, DEFN ) ) & "_disp" );
        end;

     else												-- variable non scalaire
        declare
	DEFN_LVL  : INTEGER		:= DI( CD_LEVEL, DEFN );
        begin
	PUT( tab & "LVA " & IMAGE( DEFN_LVL ) & ',' & tab );
	if  DEFN_LVL /= INTEGER( CUR_LEVEL )
	or else	D( XD_REGION, DEFN ).TY = DN_PACKAGE_ID
	then
	  REGIONS_PATH( DEFN );
	end if;
	PUT_LINE( PRINT_NAME( D( LX_SYMREP, DEFN ) )  & "_disp" );
        end;

     end if;
      end;
    end if;

  end	  LOAD_MEM;
	--========--


			--^^^^^--
  procedure		  STORE			( DEST_DEFN	:TREE )
  is			---------
    TYPE_SPEC	: TREE		:= D( SM_OBJ_TYPE, DEST_DEFN );
    SIZ_CHAR	: CHARACTER;
    STORE_LEVEL	: INTEGER;
    DEST_DEFN_STR	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, DEST_DEFN ) );

  begin

    while  TYPE_SPEC.TY = DN_L_PRIVATE  or  TYPE_SPEC.TY = DN_PRIVATE  loop
      TYPE_SPEC := D( SM_TYPE_SPEC, TYPE_SPEC );
    end loop;

    SIZ_CHAR := OPER_SIZ_CHAR( TYPE_SPEC );

    if  DEST_DEFN.TY = DN_COMPONENT_ID  then
      declare
        PARENT_TYPE : TREE	:= D( SM_TYPE_SPEC, D( XD_REGION, DEST_DEFN ) );
      begin
        STORE_LEVEL := DI( CD_LEVEL, PARENT_TYPE );
      end;
    else
      STORE_LEVEL := DI( CD_LEVEL, DEST_DEFN );
    end if;

    if  DEST_DEFN.TY = DN_OUT_ID  or  DEST_DEFN.TY = DN_IN_OUT_ID  then
      PUT_LINE( tab & "SI" & SIZ_CHAR & ' ' & INTEGER'IMAGE( STORE_LEVEL )
	& ',' & tab & '-' & DEST_DEFN_STR & "_ofs" );

    else
      PUT_LINE( tab & "S" & SIZ_CHAR & ' ' & INTEGER'IMAGE( STORE_LEVEL )
	& ',' & tab & DEST_DEFN_STR & "_disp" );
    end if;

  end	STORE;
	-----


		--^^^^^^^^^^^^^^^^^--
  function	  SUBPROGRAM_ORIGIN		( DEFN :TREE )	return TREE
  is		---------------------
		-- LRM 8.5 : un renames de sous-programme ne declare pas un
		-- nouveau corps -- l'appel vise l'ORIGINE.  On suit la chaine
		-- SM_UNIT_DESC = DN_RENAMES_UNIT jusqu'au premier id porteur
		-- d'un vrai corps.  Meme prudence que EXCEPTION_ID_OF : la
		-- representation reelle est a confirmer au dump.
    RESULT	: TREE	:= DEFN;

  begin
    loop
      declare
        UD	: TREE	:= D( SM_UNIT_DESC, RESULT );
      begin
        exit when  UD = TREE_VOID  or else  UD = TREE_NIL
	or else  UD.TY /= DN_RENAMES_UNIT;

        declare
	NAME	: TREE	:= D( AS_NAME, UD );
        begin
	while  NAME.TY = DN_SELECTED  loop
	  NAME := D( AS_DESIGNATOR, NAME );
	end loop;
	RESULT := D( SM_DEFN, NAME );
        end;
      end;
    end loop;
    return  RESULT;

end	SUBPROGRAM_ORIGIN;
	-----------------

			--^^^--
  procedure		EXC_POP
  is			-------									-- PILIER 11 : EXC_TOP := EXC_TOP.PREV_CTX
  begin
    PUT_LINE( tab & "La 0," & tab & "STANDARD.EXCEPTIONS_TOP_CTX_disp" );
    PUT_LINE( tab & "La , 0" );									-- PREV_CTX (offset 0)
    PUT_LINE( tab & "Sa 0," & tab & "STANDARD.EXCEPTIONS_TOP_CTX_disp" );

  end	EXC_POP;
	-------


			--^^^^^^^^^^^^^^^--
  function		  EXCEPTION_ID_OF	( NAME :TREE )	return TREE
  is			-------------------
		-- Descend un nom eventuellement qualifie (DN_SELECTED) jusqu'au
		-- USED_NAME_ID, prend son SM_DEFN, puis suit la chaine des
		-- renommages.  LRM 8.5 : un renames ne declare pas une nouvelle
		-- exception -- l'identite est celle de l'ORIGINE.
		-- REPRESENTATION REELLE (dump exc_ren0, 7/7, contra diana_NODES) :
		-- SM_RENAMES_EXC porte DIRECTEMENT l'EXCEPTION_ID cible, pas le
		-- nom.  On accepte les deux formes -- foi au dump, pas a la
		-- grammaire.
    N		: TREE	:= NAME;
    RESULT	: TREE	:= NAME;
  begin
    loop
      while  N.TY = DN_SELECTED  loop
        N := D( AS_DESIGNATOR, N );
      end loop;

      if	 N.TY = DN_USED_NAME_ID  then  RESULT := D( SM_DEFN, N );
      elsif  N.TY = DN_EXCEPTION_ID  then  RESULT := N;							-- forme constatee : l'ID directement
      else	 exit;										-- nom non modelise : rendre le dernier resolu
      end if;

      N := D( SM_RENAMES_EXC, RESULT );
      exit when  N.TY /= DN_USED_NAME_ID
        and then  N.TY /= DN_SELECTED
        and then  N.TY /= DN_EXCEPTION_ID;								-- vierge/void : pas (plus) un renommage
    end loop;
    return  RESULT;

  end	EXCEPTION_ID_OF;
	---------------


			--^^^^^--
  function		  TAB50			return STRING
  is			---------

    NTABS		: INTEGER		:= (50 - NATURAL(TEXT_IO.COL) ) / 10;

  begin
    if  NTABS < 0  then  NTABS := 1;  else  NTABS := NTABS + 1;  end if;
    declare
      ESPACEMENT	: STRING( 1.. NATURAL(NTABS) )	:= (others => tab );

    begin
      return ESPACEMENT;
    end;

  end	TAB50;
	-----


			--^--
  function		IMAGE			( I : NATURAL )	return STRING
  is			-----

    STR	:constant STRING	:= NATURAL'IMAGE( I );

  begin
    return STR( STR'FIRST+1 .. STR'LAST );

  end	  IMAGE;
	--=====--


			--^^^^^^^^^^^^--
  procedure		  REGIONS_PATH		( ID : TREE; WITH_DOT :BOOLEAN := TRUE )
  is			----------------

    REGION	: TREE		:= D( XD_REGION, ID );
    RGN_NAME	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, REGION ) );

  begin
    if  RGN_NAME = "STANDARD"  or  RGN_NAME = "_STANDRD" then
      PUT( "STANDARD." );

    else
      REGIONS_PATH( REGION );

      if  REGION.TY = DN_TYPE_ID
      or else REGION.TY = DN_SUBTYPE_ID
      or else REGION.TY = DN_PRIVATE_TYPE_ID
      or else REGION.TY = DN_L_PRIVATE_TYPE_ID
      then
        PUT( '_' );
      end if;

      PUT( RGN_NAME );

      if  REGION.TY = DN_PROCEDURE_ID  or  REGION.TY = DN_FUNCTION_ID  then
        PUT( '_' & LABEL_STR( LABEL_TYPE( DI( CD_LABEL, REGION ) ) ) );

      elsif  REGION.TY = DN_GENERIC_ID  and then
		( D( SM_SPEC, REGION ).TY = DN_PROCEDURE_SPEC  or  D( SM_SPEC, REGION ).TY = DN_FUNCTION_SPEC )
      then
		-- Region = generique de SOUS-PROGRAMME : le namespace physique
		-- est le PRO du corps, au nom etiquete, mais generic_id ne porte
		-- pas CD_LABEL (schema DIANA).  Le label est sur l'AS_SOURCE_NAME
		-- du corps -- pose par CODE_SUBPROGRAM_BODY.  Lien verifie au
		-- dump (MINIG) : XD_BODY, et non SM_BODY (absent du dump).
		-- Les generiques de PACKAGE gardent leur namespace NON etiquete.
        PUT( '_' & LABEL_STR( LABEL_TYPE( DI( CD_LABEL, D( AS_SOURCE_NAME, D( XD_BODY, REGION ) ) ) ) ) );

      end if;
      if  WITH_DOT  then PUT( '.' ); end if;

    end if;

  end	  REGIONS_PATH;
	--============--


			--^^^^^^^^^^^^^^^^--
  function		  LETTERED_SUBNAME			( SUB_NAME : STRING )	return STRING
  is			--------------------
  begin
    if  SUB_NAME( SUB_NAME'FIRST ) = '"'  then
      if SUB_NAME = """>="""  then return "_GE_";
      elsif SUB_NAME = """>"""  then return "_GT_";
      elsif SUB_NAME = """<="""  then return "_LE_";
      elsif SUB_NAME = """<"""  then return "_LT_";
      elsif SUB_NAME = """+"""  then return "_PLUS_";
      elsif SUB_NAME = """-"""  then return "_MINUS_";
      elsif SUB_NAME = """&"""  then return "_CONC_";
      end if;
      return  SUB_NAME;
    else
      return  SUB_NAME;
    end if;

  end	  LETTERED_SUBNAME;
	--================--


		--^^^^^^^^^^^^--
  function	LAST_OF_SELECTED	( NAME_ID :TREE )	return TREE
  is		----------------
    TEMP_NAME	: TREE	:= NAME_ID;

  begin
    while  TEMP_NAME.TY = DN_SELECTED  loop
      TEMP_NAME := D( AS_DESIGNATOR, TEMP_NAME );
    end loop;
    return  TEMP_NAME;

  end	LAST_OF_SELECTED;
	----------------


	-----
end	UTILS;
	-----

------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2
