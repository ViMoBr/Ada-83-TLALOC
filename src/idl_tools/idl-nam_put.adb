------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

separate (IDL)
--|-------------------------------------------------------------------------------------------------
--|		PROCEDURE NAM_PUT
--|
procedure NAM_PUT ( NOM_TEXTE :STRING ) is						--| ECRIT DES PARTIES ADA POUR UN NOUVEL ENVIRONNEMENT IDL

  RESULT_FILE	: TEXT_IO.FILE_TYPE;

  ASSERTION_ERROR	: exception;

  --|-----------------------------------------------------------------------------------------------
  --|		PACKAGE TBL
  --|-----------------------------------------------------------------------------------------------
  package TBL is

    type AC_STRING		is access STRING;

    type NODE_IDX		is range 0 .. 255;						--| INDICE DES NOEUDS
    type ATTR_IDX		is range 0 .. 255;						--| INDICE DES ATTRIBUTS
    type CLASS_IDX		is range 0 .. 150;						--| INDICE DES CLASSES
    type FIELD_IDX		is range 0 .. 1500;						--| INDICE DES CHAMPS (CITATION D'UN ATTRIBUT DANS UN NOEUD)

    LAST_NODE		: NODE_IDX		:= 0;
    LAST_ATTR		: ATTR_IDX		:= 0;
    LAST_CLASS		: CLASS_IDX		:= 0;

    NODE_IMAGE		: array( NODE_IDX ) of AC_STRING;
    START_FIELD		: array( NODE_IDX ) of FIELD_IDX;
    END_FIELD		: array( NODE_IDX ) of FIELD_IDX;

    ATTR_IMAGE		: array( ATTR_IDX ) of AC_STRING;				--| NOMS DES ATTRIBUTS
    ATTR_KIND		: array( ATTR_IDX ) of CHARACTER;				--| 'A' 'B' 'I' ATTRIBUT TREE, BOOLEAN, INTEGER OR SEQUENCE

    CLASS_IMAGE		: array( CLASS_IDX ) of AC_STRING;				--| NOM DES CLASSES
    START_NODE		: array( CLASS_IDX ) of NODE_IDX;				--| PREMIER NOEUD DE CLASSE
    END_NODE		: array( CLASS_IDX ) of NODE_IDX;				--| DERNIER NOEUD DE CLASSE

    ATTR_IDX_OF_NODE	: array( FIELD_IDX ) of ATTR_IDX;


    function  UPPER_CASE	( A :STRING )		return STRING;
    function  LOWER_CASE	( A :STRING )		return STRING;
    procedure READ_TABLES	( NOM_TABLE :STRING );

    --|---------------------------------------------------------------------------------------------
  end TBL;

  use TBL;
  package body TBL is separate;


  --|-----------------------------------------------------------------------------------------------
  --|		PROCEDURE PUT_NODES_NAMES
  --|
  procedure PUT_NODES_NAMES is
    I		: NATURAL		:= 0;
  begin
    PUT_LINE( "  type NODE_NAME" & ASCII.HT & "is (" );
    for N in 0 .. TBL.LAST_NODE loop
      if I > 4 then
        NEW_LINE;
        I := 0;
      end if;
      declare
        STR	: STRING renames TBL.NODE_IMAGE( N ).all;
      begin
        PUT( ASCII.HT & "DN_" & UPPER_CASE( STR ) & "," );
        if STR'LENGTH+3 > 18 then
	I := I + 1;
        end if;
      end;
      I := I + 1;
    end loop;

    NEW_LINE;
    PUT_LINE( ASCII.HT & "DN_VIRGIN" );
    PUT_LINE( ASCII.HT & ");" );
    PUT_LINE( RESULT_FILE, ASCII.HT & "for NODE_NAME'SIZE use 8;" );
    NEW_LINE;
  end PUT_NODES_NAMES;
  --|-----------------------------------------------------------------------------------------------
  --|		PROCEDURE PUT_ATTRIBUTES_NAMES
  --|
  procedure PUT_ATTRIBUTES_NAMES is
    I		: NATURAL		:= 0;
  begin
    PUT_LINE( "  type ATTRIBUTE_NAME" & ASCII.HT & "is (" );
    for A in 0 .. TBL.LAST_ATTR-1 loop
      if I > 4 then
        NEW_LINE;
        I := 0;
      end if;
      declare
        STR		: STRING renames TBL.ATTR_IMAGE( A ).all;
      begin
        PUT( ASCII.HT & UPPER_CASE( STR( STR'FIRST .. STR'LAST ) ) & "," );
        if STR'LENGTH > 18 then
	I := I + 1;
        end if;
      end;
      I := I + 1;
    end loop;

    if TBL.LAST_ATTR mod 5 = 0 then
      NEW_LINE;
    end if;
    declare
      STR		: STRING renames TBL.ATTR_IMAGE(  TBL.LAST_ATTR ).all;
    begin
      PUT( ASCII.HT & UPPER_CASE( STR( STR'FIRST .. STR'LAST ) ) );
    end;
    NEW_LINE;
    PUT_LINE( ASCII.HT & ");" );
    NEW_LINE;
  end PUT_ATTRIBUTES_NAMES;
  --|-----------------------------------------------------------------------------------------------
  --|		PROCEDURE PUT_CLASSES
  --|
  procedure PUT_CLASSES is
  begin
    for C in 0 .. TBL.LAST_CLASS loop
      PUT_LINE( "  subtype CLASS_" & UPPER_CASE( CLASS_IMAGE( C ).all )
	       & ASCII.HT & "is NODE_NAME RANGE DN_" & UPPER_CASE( TBL.NODE_IMAGE( START_NODE( C ) ).all )
	       & ASCII.HT & ".. DN_" & UPPER_CASE( TBL.NODE_IMAGE( END_NODE( C ) ).all )
	       & ';'
	     );
    end loop;
    NEW_LINE;
  end;


begin
  TBL.READ_TABLES( NOM_TEXTE );

  CREATE( RESULT_FILE, OUT_FILE, LOWER_CASE( NOM_TEXTE ) & "_node_attr_class_names.ads" );
  SET_OUTPUT( RESULT_FILE );

  PUT_LINE( RESULT_FILE, "--|-------------------------------------------------------------------------------------------------");
  PUT_LINE( RESULT_FILE, "--|" & ASCII.HT & NOM_TEXTE & "_NODE_ATTR_CLASS_NAMES");
  PUT_LINE( RESULT_FILE, "--|-------------------------------------------------------------------------------------------------");
  PUT_LINE( "package " & NOM_TEXTE & "_NODE_ATTR_CLASS_NAMES is");
  NEW_LINE( RESULT_FILE );
  PUT_NODES_NAMES;
  PUT_ATTRIBUTES_NAMES;
  PUT_CLASSES;
  NEW_LINE( RESULT_FILE );
  PUT_LINE( RESULT_FILE, "--|-------------------------------------------------------------------------------------------------");
  PUT_LINE( RESULT_FILE, "end " & NOM_TEXTE & "_NODE_ATTR_CLASS_NAMES;");

  SET_OUTPUT( STANDARD_OUTPUT );
  CLOSE( RESULT_FILE );

--|-------------------------------------------------------------------------------------------------
end NAM_PUT;
