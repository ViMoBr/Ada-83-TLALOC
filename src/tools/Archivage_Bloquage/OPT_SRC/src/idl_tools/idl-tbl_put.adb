------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT	MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

separate (IDL)
--|-------------------------------------------------------------------------------------------------
--|	PROCEDURE	TBL_PUT
--|
procedure	TBL_PUT (	NOM_TEXTE	:STRING )	is

  RESULT_FILE, NFILE	: TEXT_IO.FILE_TYPE;
  RULE_LIST		: SEQ_TYPE;
  RULE_NBR		: NATURAL	:= 0;
  VOID_WAS_SEEN		: BOOLEAN	:= FALSE;
  use INT_IO;

  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE	PROCESS_RULES
  --|
  procedure PROCESS_RULES ( CLASS_RULE :TREE ) is

    ITEM_LIST	: SEQ_TYPE	:= LIST (	CLASS_RULE );				--| LISTE	DES REGLES DEFINISSANT LES MEMBRES DE LA CLASSE
    ITEM		: TREE;
    RULE_NODE	: TREE;

    VOID_SYM	: TREE		:= STORE_SYM ( "VOID");

    --|---------------------------------------------------------------------------------------------
    --|	PROCEDURE	PUT_RULE
    --|
    procedure PUT_RULE ( RULE	:TREE ) is
      subtype STR3	is STRING( 1..3 );
      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE	PUT_PROPER_ATTRS
      --|
      procedure PUT_PROPER_ATTRS ( TER_LIST_ARG :SEQ_TYPE; PREFIX :STR3 ) is
        TER_LIST	: SEQ_TYPE	:= TER_LIST_ARG;
        TER		: TREE;
        --|-----------------------------------------------------------------------------------------
        --|	PROCEDURE	PUT_ATTR
        --|
        procedure PUT_ATTR ( TER :TREE ) is
	TER_PREFIX	: STRING(	1..3 ) :=	"???";
	TER_NAME	: constant STRING	:= PRINT_NAME ( D (	XD_SYMREP, TER ) );
        begin

	if TER_NAME'LENGTH >= 3 then							--| SI LE	NOM EST ASSEZ LONG
	  TER_PREFIX( 1..3 ) := TER_NAME( TER_NAME'FIRST..TER_NAME'FIRST+2 );			--| EXTRAIRE LA TRANCHE DU PREFIXE
	end if;

	if TER_PREFIX = PREFIX							--| SI C'EST LE PREFIXE COURANT
	   or else (	PREFIX = "   " and TER_PREFIX	/= "as_"				--| OU SI	ON A MIS "   " MAIS	QUE CE N'EST PAS UN	CONNU "AS_", "LX_",	"SM_"
			and TER_PREFIX /= "lx_" and TER_PREFIX /= "sm_")
	then
	  if DI (	XD_ATTR_ID, TER ) <	0 then						--| ATTRIBUT DE TYPE SEQUENCE
	    PUT (	'A');								--| METTRE A EN DEBUT DE LIGNE

	  elsif PRINT_NAME ( D ( XD_ATTR_TYPE, TER ) ) = "INTEGER" then			--| TYPAGE "INTEGER"
	    PUT (	'I');								--| METTRE I EN DEBUT DE LIGNE

	  elsif PRINT_NAME ( D ( XD_ATTR_TYPE, TER ) ) = "BOOLEAN" then			--| TYPAGE "BOOLEAN"
	    PUT (	'B');								--| METTRE B EN DEBUT DE LIGNE

	  else									--| TOUT AUTRE ATTRIBUT
	    PUT (	'A');								--| METTRE A EN DEBUT DE LIGNE

	  end if;
	  PUT ("   ");
	  PUT ( DI ( XD_ATTR_ID, TER ), 4 );						--| METTRE LE N° D'ATTRIBUT (POUR LE RETROUVER DANS LA LISTE DES ATTRIBUTS)
	  PUT ( "   ");
	  PUT_LINE ( PRINT_NAME (D (XD_SYMREP, TER ) ) );					--| METTRE LE NOM DE L'ATTRIBUT
	  PUT_LINE ( NFILE,	ASCII.HT & "=> " & PRINT_NAME	(D (XD_SYMREP, TER ) )		--| ATTRIBUT
			& ASCII.HT & ":" & PRINT_NAME	(D (XD_ATTR_TYPE, TER ) )		--| ET TYPE AU FICHIER NOEUDS	COMPLETS
		    );
	end if;
        end PUT_ATTR;

      begin
        while not IS_EMPTY ( TER_LIST )	loop						--| TANT QU'IL Y A DES ATTRIBUTS PROPRES
	POP ( TER_LIST, TER	);							--| PRENDRE UN ATTRIBUT
	if TER.TY	= DN_ATTR	then							--| EN PRINCIPE L'ATTRIBUT DOIT ÊTRE DE	CE TYPE
	  PUT_ATTR ( TER );								--| L'IMPRIMER
	end if;
        end loop;
      end	PUT_PROPER_ATTRS;
      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE	PUT_INHERITED_ATTRS
      --|
      procedure PUT_INHERITED_ATTRS ( CLASS_NODE :TREE; PREFIX :STR3 ) is
      begin
        if CLASS_NODE /= TREE_VOID then
	PUT_INHERITED_ATTRS	( D ( XD_PARENT, CLASS_NODE ), PREFIX );			--| RECURSION AU NIVEAU SUPERIEUR
	PUT_PROPER_ATTRS ( LIST ( CLASS_NODE ),	PREFIX );					--| PUIS PLACER LES	ATTRIBUTS	PROPRES HERITES À CE NIVEAU
        end if;
      end;
      --|-------------------------------------------------------------------------------------------

    begin
      PUT	( "N ");									--| LIGNE	NOEUD (PARTIE GAUCHE DE LA REGLE)
      INT_IO.PUT ( RULE_NBR, 3 );							--| D'ABORD LE N° DE REGLE
      DI ( XD_NODE_ID, RULE, RULE_NBR );						--| LE MEMORISER DANS LA REGLE
      PUT_LINE ( ' ' & PRINT_NAME ( D (	XD_SYMREP, RULE ) )	);				--| PUIS LE NOM DE LA REGLE (DU NOEUD)
      PUT_LINE ( NFILE, PRINT_NAME ( D ( XD_SYMREP, RULE ) ) & ASCII.HT & "=>" );		--| NOM DU NOEUD AU	FICHIER NOEUDS
      declare
        PARENT	: TREE	:= D ( XD_PARENT, RULE );					--| CLASSE DANS LAQUELLE EST COMPRIS LE	NOEUD DE LA REGLE
      begin
        PUT_INHERITED_ATTRS (	PARENT, "as_" );						--| METTRE LES ATTRIBUTS HERITES DU GENRE "AS_" (SYNTAXIQUES)
        PUT_PROPER_ATTRS ( LIST ( RULE ), "as_" );					--| IMPRIMER LA LISTE DES ATTRIBUTS PROPRES DE LA	REGLE (LES CHAMPS DU NOEUD)

        PUT_INHERITED_ATTRS (	PARENT,"lx_" );						--| REFAIRE ENSUITE	POUR LES "LX_" (LEXICAUX)
        PUT_PROPER_ATTRS ( LIST ( RULE ),"lx_" );

        PUT_INHERITED_ATTRS (	PARENT, "sm_" );						--| REFAIRE ENSUITE	POUR LES "SM_" (SEMANTIQUES)
        PUT_PROPER_ATTRS ( LIST ( RULE ), "sm_" );

        PUT_INHERITED_ATTRS (PARENT, "   " );
        PUT_PROPER_ATTRS ( LIST ( RULE ), "   " );
      end;
      RULE_NBR := RULE_NBR + 1;
      PUT_LINE ( NFILE, ASCII.HT & ';' );
    end PUT_RULE;

  begin

    PUT_LINE ( "C "	& PRINT_NAME ( D ( XD_SYMREP,	CLASS_RULE ) ) );				--| LIGNE	DEBUT DE CLASSE

    while	not IS_EMPTY ( ITEM_LIST ) loop
      POP	( ITEM_LIST, ITEM );							--| PRENDRE UN MEMBRE DE LA CLASSE TRAITEE

      if ITEM.TY /=	DN_ATTR then							--| SI CE	N'EST PAS	UN ATTRIBUT (UN MEMBRE)
        RULE_NODE := D ( XD_CLASS_NODE,	ITEM );						--| PRENDRE SA REGLE DE DEFINITION
        if DB ( XD_IS_CLASS, RULE_NODE ) then						--| LA REGLE DEFINIT UN MEMBRE CLASSE
	PROCESS_RULES ( D (	XD_CLASS_NODE, ITEM	) );
        else									--| LA REGLE DEFINIT DES ATTRIBUTS
	if D ( XD_SYMREP, RULE_NODE) /= VOID_SYM then					--| PAS LA REGLE DEFINISSANT "VOID"
	  PUT_RULE ( D ( XD_CLASS_NODE, ITEM ) );					--| IMPRIMER LA REGLE NAAA

	elsif not	VOID_WAS_SEEN then							--| SI C'EST LA REGLE POUR "VOID" ET QU'ON NE L'A	PAS ENCORE VUE
	  VOID_WAS_SEEN := TRUE;							--| INDIQUER QUE L'ON A VU CELLE-CI
	  PUT_RULE ( D ( XD_CLASS_NODE, ITEM ) );					--| IMPRIMER LA REGLE
	end if;
        end if;

      else									--| S'IL Y A UN TERMINAL C'EST UNE PROPRIETE DE CLASSE
        null;									--| NE RIEN IMPRIMER : LA PROPRIETE SERA COLLECTEE PAR PUT_INHERITED_ATTRS COMME ATTRIBUT	HERITE
      end	if;

    end loop;

    PUT_LINE ( "E "	& PRINT_NAME ( D ( XD_SYMREP,	CLASS_RULE ) ) );				--| LIGNE	FIN DE CLASSE
  end PROCESS_RULES;

begin
  OPEN_IDL_TREE_FILE ( NOM_TEXTE & ".lar" );						--| FICHIER D'ARBRE	IDL
  CREATE	 ( RESULT_FILE, OUT_FILE, NOM_TEXTE & ".tbl" );					--| FICHIER DE SORTIE .TBL
  CREATE	 ( NFILE,	OUT_FILE,	NOM_TEXTE	& "_NODES.txt" );					--| FICHIER DES NOEUDS COMPLETS

  TEXT_IO.SET_OUTPUT ( RESULT_FILE );

  RULE_LIST := LIST	( STORE_SYM ( "STANDARD_IDL" ) );					--| LISTE	DES REGLES DONT LA PARTIE GAUCHE EST DANS LA CATEGORIE STANDARD_IDL
  if not IS_EMPTY (	RULE_LIST) then							--| SI NON VIDE
    PROCESS_RULES (	HEAD ( RULE_LIST ) );						--| TRAITER
  end if;

  RULE_LIST := LIST	( STORE_SYM ( "ALL_SOURCE" ) );					--| PAREIL POUR LA CATEGORIE ALL_SOURCE
  if not IS_EMPTY (	RULE_LIST) then
    PROCESS_RULES (	HEAD ( RULE_LIST ) );
  end if;

  RULE_LIST := LIST	( STORE_SYM ( "TYPE_SPEC" ) );					--| PAREIL POUR LA CATEGORIE TYPE_SPEC
  if not IS_EMPTY (	RULE_LIST) then
    PROCESS_RULES (	HEAD ( RULE_LIST ) );
  end if;

  RULE_LIST := LIST	( STORE_SYM ( "NON_DIANA") );						--| PAREIL POUR LA CATEGORIE NON_DIANA
  if not IS_EMPTY (	RULE_LIST) then
    PROCESS_RULES (	HEAD ( RULE_LIST ) );
  end if;

  TEXT_IO.SET_OUTPUT ( TEXT_IO.STANDARD_OUTPUT );
  CLOSE (	NFILE );
  CLOSE (	RESULT_FILE );
  CLOSE_IDL_TREE_FILE;

  PUT_LINE ( "OK" );
  NEW_LINE;

exception

  when NAME_ERROR =>
    PUT_LINE ( "LE FICHIER : " & NOM_TEXTE & ".lar  EST INTROUVABLE" );

  when others =>
    CLOSE	( RESULT_FILE );
    CLOSE_IDL_TREE_FILE;
    PUT_LINE ( "ERREUR TBL_PUT" );

--|-------------------------------------------------------------------------------------------------
end TBL_PUT;
