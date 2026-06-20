------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

separate ( EXPANDER )
				-----------------
package body			REPRESENTED_ITEMS
				-----------------
is

			--------------------
  function		STATIC_INTEGER_VALUE	( EXP :TREE )	return INTEGER
  is			--------------------
  begin
    -- Premier périmètre volontairement restreint :
    -- les positions de représentation doivent être statiques.
    --
    -- Dans les clauses :
    --   C at <exp> range <lo> .. <hi>
    -- <exp>, <lo>, <hi> arrivent normalement comme numeric_literal
    -- ou comme expression déjà évaluée avec SM_VALUE entier.

    if  EXP = TREE_VOID  or else  EXP = TREE_NIL  then
      PUT_LINE( "; REPRESENTED_ITEMS.STATIC_INTEGER_VALUE : expression absente" );
      raise PROGRAM_ERROR;

    elsif  EXP.TY = DN_NUMERIC_LITERAL  then
      return DI( SM_VALUE, EXP );

    elsif  EXP.TY in CLASS_EXP  then
      return DI( SM_VALUE, EXP );

    else
      PUT_LINE( "; REPRESENTED_ITEMS.STATIC_INTEGER_VALUE : EXP.TY inattendu "
	      & NODE_NAME'IMAGE( EXP.TY ) );
      raise PROGRAM_ERROR;
    end if;

  end	STATIC_INTEGER_VALUE;
	--------------------


			------------------------
  function		REPRESENTATION_SIZE_BITS	( TYPE_SPEC :TREE )	return INTEGER
  is			------------------------
  begin
      return  DI( SM_SIZE, TYPE_SPEC );

  end	REPRESENTATION_SIZE_BITS;
	------------------------


			-----------------
  procedure		GET_COMP_REP_ELEM	( REP_ELEM :TREE; COMP_ID :out TREE;
					  BYTE_OFFSET, FIRST_BIT, LAST_BIT, WIDTH :out INTEGER )
  is			-----------------
    RNG		: TREE	:= D( AS_RANGE, REP_ELEM );
    EXP_FIRST	: TREE	:= D( AS_EXP1, RNG );
    EXP_LAST	: TREE	:= D( AS_EXP2, RNG );
    BIT_DEPART	: INTEGER	:= STATIC_INTEGER_VALUE( EXP_FIRST );
    BIT_FIN	: INTEGER	:= STATIC_INTEGER_VALUE( EXP_LAST );

  begin
    COMP_ID   := D( SM_DEFN, D( AS_NAME, REP_ELEM ) );
    BYTE_OFFSET := STATIC_INTEGER_VALUE( D( AS_EXP, REP_ELEM ) );
    FIRST_BIT := BIT_DEPART;
    LAST_BIT := BIT_FIN;
    WIDTH := BIT_FIN - BIT_DEPART + 1;

  end	GET_COMP_REP_ELEM;
	-----------------


			--------------------
  function		REP_RECORD_USED_BITS	( TYPE_SPEC :TREE )	return INTEGER
  is			--------------------
    REP			: TREE;
    REP_S			: SEQ_TYPE;
    REP_ELEM		: TREE;
    COMP_ID		: TREE;
    BYTE_OFFSET		: INTEGER;
    FIRST_BIT		: INTEGER;
    LAST_BIT		: INTEGER;
    WIDTH			: INTEGER;
    END_BIT		: INTEGER;
    MAX_BIT		: INTEGER := 0;
  begin
    REP := D( SM_REPRESENTATION, TYPE_SPEC );

    if  REP = TREE_VOID  or else REP = TREE_NIL  then
      return 0;
    end if;

    REP_S := LIST( D( AS_COMP_REP_S, REP ) );

    while  not IS_EMPTY( REP_S )  loop
      POP( REP_S, REP_ELEM );

      if  REP_ELEM.TY = DN_COMP_REP  then
        GET_COMP_REP_ELEM( REP_ELEM, COMP_ID, BYTE_OFFSET, FIRST_BIT, LAST_BIT, WIDTH );
        END_BIT := BYTE_OFFSET * CODI.STORAGE_UNIT + LAST_BIT + 1;

        if  END_BIT > MAX_BIT  then
          MAX_BIT := END_BIT;
        end if;
      end if;
    end loop;

    return MAX_BIT;

  end	REP_RECORD_USED_BITS;
	--------------------


			----------------------------
  function		REPRESENTED_RECORD_SIZE_BITS	( TYPE_SPEC :TREE )	return INTEGER
  is			----------------------------
    TS		: TREE := TYPE_SPEC;
    SIZE_BITS	: INTEGER := 0;
    USED_BITS	: INTEGER := 0;
  begin
    if  TS.TY = DN_PRIVATE  or else TS.TY = DN_L_PRIVATE  then
      TS := D( SM_TYPE_SPEC, TS );
    elsif  TS.TY = DN_INCOMPLETE  then
      TS := D( XD_FULL_TYPE_SPEC, TS );
    end if;

    -- 1. Source prioritaire : clause "for T'SIZE use N".
    -- SM_SIZE est un attribut numérique / Value, donc lire par DI,
    -- pas par D.
    begin
      SIZE_BITS := DI( SM_SIZE, TS );
    exception
      when others =>
        SIZE_BITS := 0;
    end;

    if  SIZE_BITS > 0  then
      return SIZE_BITS;
    end if;

    -- 2. Calcul minimal à partir des comp_rep.
    USED_BITS := REP_RECORD_USED_BITS( TS );

    if  USED_BITS > 0  then
      return USED_BITS;
    end if;

    -- 3. Dernier recours : CD_IMPL_SIZE si déjà posé.
    begin
      SIZE_BITS := DI( CD_IMPL_SIZE, TS );
    exception
      when others =>
        SIZE_BITS := 0;
    end;

    return SIZE_BITS;

  end	REPRESENTED_RECORD_SIZE_BITS;




			--------------
  function		HAS_RECORD_REP		( TYPE_SPEC :TREE )		return BOOLEAN
  is			--------------

    TS	: TREE	:= TYPE_SPEC;

  begin
    if  TS = TREE_VOID  or else  TS = TREE_NIL  then
      return  FALSE;
    end if;

    if  TS.TY = DN_PRIVATE  or else  TS.TY = DN_L_PRIVATE  then
      TS := D( SM_TYPE_SPEC, TS );
    elsif  TS.TY = DN_INCOMPLETE  then
      TS := D( XD_FULL_TYPE_SPEC, TS );
    end if;

    if  TS.TY /= DN_RECORD  then
      return  FALSE;
    end if;

    return  D( SM_REPRESENTATION, TS ) /= TREE_VOID  and then  D( SM_REPRESENTATION, TS ) /= TREE_NIL;

  end	HAS_RECORD_REP;
	--------------


			-----------------
  function		HAS_COMPONENT_REP		( COMP_ID :TREE )		return BOOLEAN
  is			-----------------

    REP	: TREE;

  begin
    if  COMP_ID = TREE_VOID  or else  COMP_ID = TREE_NIL  then
      return  FALSE;
    end if;

    if  not ( COMP_ID.TY = DN_COMPONENT_ID  or else  COMP_ID.TY = DN_DISCRIMINANT_ID ) then
      return  FALSE;
    end if;

    REP := D( SM_COMP_REP, COMP_ID );

    return  REP /= TREE_VOID  and then  REP /= TREE_NIL  and then  REP.TY = DN_COMP_REP;

  end	HAS_COMPONENT_REP;
	-----------------


			-----------------
  procedure		GET_COMPONENT_REP		( COMP_ID :TREE; BYTE_OFFSET :out INTEGER;
						  FIRST_BIT, LAST_BIT, WIDTH :out INTEGER )
  is			-----------------
    REP		: TREE;
    DUMMY_ID	: TREE;
  begin
    if  not HAS_COMPONENT_REP( COMP_ID )  then
      PUT_LINE( "; REPRESENTED_ITEMS.GET_COMPONENT_REP : composant sans SM_COMP_REP "
	      & NODE_NAME'IMAGE( COMP_ID.TY ) );
      raise PROGRAM_ERROR;
    end if;

    REP := D( SM_COMP_REP, COMP_ID );

    GET_COMP_REP_ELEM( REP, DUMMY_ID, BYTE_OFFSET, FIRST_BIT, LAST_BIT, WIDTH );

  end	GET_COMPONENT_REP;
	-----------------


			-------------------
  function		IS_SMALL_REP_RECORD		( TYPE_SPEC :TREE )		return BOOLEAN
  is			-------------------

    TS		: TREE	:= TYPE_SPEC;
    REP		: TREE;
    REP_S		: SEQ_TYPE;
    REP_ELEM	: TREE;
    SIZE_BITS	: INTEGER;

  begin
    if  not HAS_RECORD_REP( TS )  then
      return  FALSE;
    end if;

    if  TS.TY = DN_PRIVATE  or else  TS.TY = DN_L_PRIVATE  then
      TS := D( SM_TYPE_SPEC, TS );
    elsif  TS.TY = DN_INCOMPLETE  then
      TS := D( XD_FULL_TYPE_SPEC, TS );
    end if;

    SIZE_BITS := REPRESENTED_RECORD_SIZE_BITS( TS );

    if  SIZE_BITS <= 0  or else  SIZE_BITS > 64  then
      return  FALSE;
    end if;

    -- Premier périmètre : modèle TREE-like.
    -- Tous les champs doivent être dans le même contenant logique
    -- commençant à byte_offset 0.
    REP   := D( SM_REPRESENTATION, TS );
    REP_S := LIST( D( AS_COMP_REP_S, REP ) );

    while  not IS_EMPTY( REP_S )  loop
      POP( REP_S, REP_ELEM );

      if  REP_ELEM.TY = DN_COMP_REP  then
        declare
	COMP_ID		: TREE;
	BYTE_OFFSET	: INTEGER;
	FIRST_BIT		: INTEGER;
	LAST_BIT		: INTEGER;
	WIDTH		: INTEGER;
	END_BIT		: INTEGER;
        begin
	GET_COMP_REP_ELEM( REP_ELEM, COMP_ID, BYTE_OFFSET, FIRST_BIT, LAST_BIT, WIDTH );
          END_BIT := BYTE_OFFSET * CODI.STORAGE_UNIT + LAST_BIT + 1;

	if  BYTE_OFFSET < 0  or else  FIRST_BIT < 0  or else  LAST_BIT < FIRST_BIT
	or else  WIDTH <= 0  or else  WIDTH > 64  or else  END_BIT > SIZE_BITS
	then
	  return  FALSE;
	end if;
        end;
      end if;
    end loop;

    return  TRUE;

  end	IS_SMALL_REP_RECORD;
	-------------------


			----------------------------
  procedure		CODE_REPRESENTED_RECORD_DECL		( TYPE_ID :TREE; TYPE_SPEC :TREE )
  is			----------------------------

    TYPE_ID_STR	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, TYPE_ID ) );
    LVL_STR	:constant STRING	:= IMAGE( CODI.CUR_LEVEL );
    SIZE_BITS	: INTEGER;

  begin
    if  not HAS_RECORD_REP( TYPE_SPEC )  then
      PUT_LINE( "; REPRESENTED_ITEMS.CODE_REPRESENTED_RECORD_DECL : record sans representation "
	      & TYPE_ID_STR );
      raise  PROGRAM_ERROR;
    end if;

    if  not IS_SMALL_REP_RECORD( TYPE_SPEC )  then
      PUT_LINE( "; REPRESENTED_ITEMS.CODE_REPRESENTED_RECORD_DECL : representation trop generale "
	      & TYPE_ID_STR );
      raise  PROGRAM_ERROR;
    end if;

    SIZE_BITS := REPRESENTATION_SIZE_BITS( TYPE_SPEC );
    DI( CD_LEVEL, TYPE_SPEC, INTEGER( CODI.CUR_LEVEL ) );
    DI( CD_IMPL_SIZE, TYPE_SPEC, SIZE_BITS );
    DB( CD_COMPILED, TYPE_SPEC, TRUE );

    if  CODI.DEBUG  then
      NEW_LINE;
      PUT_LINE( CODI.TAB50 & "; " & TYPE_ID_STR & " REPRESENTED RECORD TYPE INFO" );
    end if;

    PUT_LINE( TYPE_ID_STR & " = '" & TYPE_ID_STR & "'" );
    PUT_LINE( "namespace " & TYPE_ID_STR );

    -- Patron minimal compatible avec les records ordinaires :
    -- SIZ reste exprimé en bits, comme les autres patrons de type.
    PUT_LINE( "VAR use__info, q" );
    PUT_LINE( "VAR SIZ, d" );
    PUT_LINE( tab & "LVA" & CODI.tab & LVL_STR & ", SIZ" );
    PUT_LINE( tab & "Sa"  & CODI.tab & LVL_STR & ", use__info" );

    PUT_LINE( tab & "LI" & CODI.tab & IMAGE( SIZE_BITS ) );
    PUT_LINE( tab & "Sd" & CODI.tab & LVL_STR & ", SIZ" );

    declare
      SIZE_BYTES : INTEGER;
    begin
      SIZE_BYTES := ( SIZE_BITS + CODI.STORAGE_UNIT - 1 ) / CODI.STORAGE_UNIT;
      PUT_LINE( "size = " & IMAGE( SIZE_BYTES ) );
    end;

    if  CODI.DEBUG  then
      declare
        REP		: TREE		:= D( SM_REPRESENTATION, TYPE_SPEC );
        REP_S		: SEQ_TYPE	:= LIST( D( AS_COMP_REP_S, REP ) );
        REP_ELEM		: TREE;
      begin
        while  not IS_EMPTY( REP_S )  loop
	POP( REP_S, REP_ELEM );

	if  REP_ELEM.TY = DN_COMP_REP  then
	  declare
	    COMP_ID	: TREE;
	    BYTE_OFFSET	: INTEGER;
	    FIRST_BIT	: INTEGER;
	    LAST_BIT	: INTEGER;
	    WIDTH		: INTEGER;
	  begin
	    GET_COMP_REP_ELEM( REP_ELEM, COMP_ID, BYTE_OFFSET, FIRST_BIT, LAST_BIT, WIDTH );
	    PUT_LINE( ";   " & PRINT_NAME( D( LX_SYMREP, COMP_ID ) ) & " at" & INTEGER'IMAGE( BYTE_OFFSET )
		    & " range" & INTEGER'IMAGE( FIRST_BIT ) & " .." & INTEGER'IMAGE( LAST_BIT )
		    & " width" & INTEGER'IMAGE( WIDTH ) );
	  end;
	end if;
        end loop;
      end;
    end if;

    PUT_LINE( "end namespace" );

  end	CODE_REPRESENTED_RECORD_DECL;
	----------------------------


	-----------------
end	REPRESENTED_ITEMS;
	-----------------

------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2
