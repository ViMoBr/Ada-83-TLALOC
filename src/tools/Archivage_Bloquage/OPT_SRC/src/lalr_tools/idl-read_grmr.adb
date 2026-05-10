------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT	MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

with UNCHECKED_DEALLOCATION;
with LEX,	GRMR_OPS;
separate(	IDL )
--|-------------------------------------------------------------------------------------------------
--|		READ_GRMR
--|
procedure	READ_GRMR	( NOM_TEXTE :STRING	) is

  IFILE, OFILE		: FILE_TYPE;						--| FICHIER GRAMMAIRE ET TEXTE D'INITIALISATIONS SYMBOLES OPERATEURS

  TER_COUNT		: NATURAL	:= 0;
  ALT_COUNT		: NATURAL	:= 0;

  SEMAN_COUNT		: INTEGER	:= 0;						--| NOMBRE DE SYLLABES SEMANTIQUES
  SEMAN_ALT_COUNT		: INTEGER	:= 0;						--| NOMBRE D'ALTS AVEC SEMANTIQUE

  SOURCE_LIST		: SEQ_TYPE;						--| LISTE	DES SOURCELINES
  SOURCEPOS		: TREE;							--| LA SOURCE_POSITION

  ARITY_TABLE		: array( 0 .. 300 )	of INTEGER	:= (others => -1);

  --|-----------------------------------------------------------------------------------------------
  --|
  package	LALR_LEX is
  --|-----------------------------------------------------------------------------------------------

    procedure AVANCER;
    function  TOKEN	return STRING;

  --|-----------------------------------------------------------------------------------------------
  end LALR_LEX;


  --|-----------------------------------------------------------------------------------------------
  --|
  package	body LALR_LEX is
  --|-----------------------------------------------------------------------------------------------

    SLINE		: STRING(	1 .. 256 );						--| LIGNE	COURANTE
    LINE_COUNT	: NATURAL	:= 0;							--| NOMBRE DE LIGNES VUES
    LINE_TAKEN	: NATURAL	:= 0;							--| N° DE	LA DERNIERE LIGNE PRISE DANS UN SOURCE_LINE
    COL		: NATURAL	:= 1;							--| PROCHAINE COLONNE À BALAYER
    LAST		: NATURAL	:= 0;							--| NB DE	CARACTERES DANS LA LIGNE
    TS, TE	: NATURAL;							--| BORNES DU LEXEME

    --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    --|	PROCEDURE	AVANCER
    procedure AVANCER is
      SOURCE_LINE		: TREE;							--| LE SOURCELINE COURANT
    begin

<<START_GET>>

      if COL > LAST	then
        if END_OF_FILE( IFILE	) then
	TS := SLINE'FIRST;
	TE := SLINE'FIRST +	3;
	SLINE( SLINE'FIRST..SLINE'FIRST+3 ) := "%end";
        else
	GET_LINE(	IFILE, SLINE, LAST );
	LINE_COUNT := LINE_COUNT + 1;
	COL := 1;
        end if;
      end	if;

      while COL <= LAST and then (SLINE( COL ) = ' ' or else SLINE( COL ) = ASCII.HT) loop
        COL := COL + 1;
      end	loop;

      if COL < LAST	then
        if SLINE( COL..COL+1 ) = "--" or SLINE( COL..COL+1 ) = "//" or SLINE( COL..COL+1 ) = "##" then
	COL := LAST + 1;
	goto START_GET;
        end if;
      elsif COL > LAST then				--| LIGNE	BLANCHE
        goto START_GET;
      end	if;

      TS := COL;
      while COL <= LAST loop
        exit when SLINE( COL ) = ' ' or	else SLINE( COL ) =	ASCII.HT;
        if COL < LAST and then SLINE( COL..COL+1 ) = "--" then
	COL := LAST + 1;
	goto START_GET;
        end if;
        COL := COL + 1;
      end	loop;
      TE := COL - 1;

      if LINE_COUNT	/= LINE_TAKEN then
        SOURCE_LINE	:= MAKE( DN_SOURCELINE );
        DI  ( XD_NUMBER, SOURCE_LINE, LINE_COUNT );
        LIST( SOURCE_LINE, (TREE_NIL,TREE_NIL) );
        SOURCE_LIST	:= APPEND( SOURCE_LIST, SOURCE_LINE );
      end	if;

      SOURCEPOS := MAKE_SOURCE_POSITION( SOURCE_LINE,SRCCOL_IDX( TS )	);
    end AVANCER;
    --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    --|	FUNCTION TOKEN
    function TOKEN return STRING is
    begin
      return SLINE(	TS..TE );
    end;

  --|-----------------------------------------------------------------------------------------------
  end LALR_LEX;
  use LALR_LEX;




  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE	LOAD_DIANA
  procedure LOAD_DIANA is
    OP		: TREE;
    SYM		: TREE;
    NODE_POS	: NATURAL;
    DIANATBL_FILE	: TEXT_IO.FILE_TYPE;
    BUFFER	: STRING(	1..127 );
    LAST		: NATURAL	range 0..127;
    COL		: NATURAL	range 0..127;

    procedure SKIP_BLANKS is
    begin
      while COL <= LAST and then (BUFFER( COL ) =	' ' or BUFFER( COL ) = ASCII.HT) loop
        COL := COL + 1;
      end	loop;
    end;

    procedure FIND_BLANK is
    begin
      while COL <= LAST and then BUFFER( COL ) /=	' ' and then BUFFER( COL ) /=	ASCII.HT loop
        COL := COL + 1;
      end	loop;
    end;

  begin

    TEXT_IO.OPEN( DIANATBL_FILE, TEXT_IO.IN_FILE,	"../idl_tools/diana.tbl" );

TROUVER_CLASSE_ALL_SOURCE:
    loop
      GET_LINE( DIANATBL_FILE, BUFFER, LAST );
      if LAST > 0 then
        if BUFFER( 1 ) = 'C' then
	COL := 2;
	SKIP_BLANKS;
	exit when	BUFFER( COL..LAST )	= "ALL_SOURCE";
        end if;
      end	if;
    end loop TROUVER_CLASSE_ALL_SOURCE;

TRAITER_TOUTE_CLASSE_ALL_SOURCE:
    loop
      GET_LINE( DIANATBL_FILE, BUFFER, LAST);
      if LAST > 0 then
        if BUFFER( 1 ) = 'E' then							--| FIN DE CLASSE
	COL := 2;
	SKIP_BLANKS;
	exit when	BUFFER( COL..LAST )	= "ALL_SOURCE";					--| FIN DE CLASSE SOURCE_NAME	: FIN DE TRAITEMENT

        elsif BUFFER( 1 ) = 'N' then							--| POUR UN NOEUD
	COL := 2;
	SKIP_BLANKS;
	FIND_BLANK;								--| POUR PASSER SUR	LE NUMERO	DE NOEUD
	SKIP_BLANKS;

	OP := MAKE( DN_SEM_OP );							--| CREER	UN NOEUD SEM_OP
	NODE_POS := INTEGER'VALUE( BUFFER( 2..COL-1 ) );					--| NUMERO DE NOEUD
	DI( XD_SEM_OP, OP, NODE_POS );						--| OP.XD_SEM_OP :=	POS
	SYM := STORE_SYM( BUFFER( COL..LAST ) );					--| NOM DU NOEUD
	LIST( SYM, INSERT( LIST( SYM ), OP ) );
	ARITY_TABLE( NODE_POS ) := 0;

        elsif BUFFER( 1 ) = 'A' or else	BUFFER( 1	) = 'B' or else BUFFER( 1 ) =	'I' then
	COL := 2;
	SKIP_BLANKS;
	FIND_BLANK;
	SKIP_BLANKS;

	if COL + 2 <= LAST and then BUFFER( COL	.. COL+2 ) = "as_" then			--| ATTRIBUT as_xxx
	  COL := 2;								--| RECULER AU DEVANT DU NUMERO D ATTRIBUT
	  SKIP_BLANKS;
	  if BUFFER( COL ) = '-' then							--| NUMERO NEGATIF INDIQUE SEQUENCE
	    ARITY_TABLE( NODE_POS ) := 4;
	  else
	    ARITY_TABLE( NODE_POS ) := ARITY_TABLE( NODE_POS ) + 1;
	  end if;
	end if;
        end if;
      end	if;
    end loop TRAITER_TOUTE_CLASSE_ALL_SOURCE;

    TEXT_IO.CLOSE( DIANATBL_FILE );

  exception
    when END_ERROR =>
      TEXT_IO.CLOSE( DIANATBL_FILE );
  end LOAD_DIANA;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE	LOAD_TERMINALS
  procedure LOAD_TERMINALS is
    TER		: TREE;
    SYM		: TREE;
    DEFLIST	: SEQ_TYPE;
    use LEX;
  begin
    for T	in LEX_TYPE loop
      TER	:= MAKE( DN_TERMINAL );
      SYM	:= STORE_SYM( LEX.LEX_IMAGE (	T ) );
      DEFLIST := LIST( SYM );
      while not IS_EMPTY( DEFLIST ) and	then HEAD( DEFLIST ).TY /= DN_TERMINAL loop
        DEFLIST := TAIL( DEFLIST );
      end	loop;
      if not IS_EMPTY( DEFLIST ) then
        PUT ( "***DUPLICATE TERMINAL IMAGE - " );
        PUT_LINE( LEX_IMAGE (	T ) );
      end	if;
      LIST( SYM, INSERT( LIST( SYM ), TER ) );
      D( XD_SYMREP,	TER, SYM );
      DI(	XD_TER_NBR, TER, LEX_TYPE'POS( T ) );
    end loop;
  end LOAD_TERMINALS;
  --|----------------------------------------------------------------------------------------------
  --|	PROCEDURE	PROCESS_GRAMMAR
  procedure PROCESS_GRAMMAR is
    USER_ROOT	: TREE;
    GRAMMAR	: TREE;
    RULE		: TREE;
    ALTERNATIVE	: TREE;
    SYLLABLE	: TREE;
    SYMBOL	: TREE;
    SEQ		: SEQ_TYPE;
    RULE_LIST	: SEQ_TYPE	:= (TREE_NIL,TREE_NIL);
    ALT_LIST	: SEQ_TYPE;
    SYL_LIST	: SEQ_TYPE;
    SEMAN_LIST	: SEQ_TYPE;
    SEM_S		: TREE;
    --|---------------------------------------------------------------------------------------------
    --|	PROCEDURE	MAKE_RULE
    procedure MAKE_RULE ( TEXT :STRING ) is
      DEFLIST	: SEQ_TYPE;
    begin

      if TEXT = "%%" or TEXT = "::=" then raise PROGRAM_ERROR; end if;

      SYMBOL := STORE_SYM( TEXT );
      PUT_LINE( "RULE = " & TEXT );
      RULE := MAKE(	DN_RULE );
      D( XD_NAME, RULE, SYMBOL);
      D( LX_SRCPOS,	RULE, SOURCEPOS );
      RULE_LIST := APPEND( RULE_LIST, RULE );

      SEQ	:= LIST( SYMBOL );
      DEFLIST := SEQ;
      while not IS_EMPTY( DEFLIST )
	  and then HEAD( DEFLIST).TY /= DN_RULE
	  and then HEAD( DEFLIST).TY /= DN_TERMINAL
      loop
        DEFLIST := TAIL( DEFLIST );
      end	loop;
      if not IS_EMPTY( DEFLIST ) then
        ERROR( SOURCEPOS, "DUPLICATE RULE - " & TEXT );
      end	if;
      LIST( SYMBOL,	APPEND( SEQ, RULE )	);

      ALT_LIST := (TREE_NIL,TREE_NIL);
    end MAKE_RULE;
    --|--------------------------------------------------------------------------------------------
    --|	PROCEDURE	MAKE_ALTERNATIVE
    procedure MAKE_ALTERNATIVE is
    begin
      ALTERNATIVE := MAKE( DN_ALT );
      D( LX_SRCPOS,	ALTERNATIVE, SOURCEPOS);
      ALT_COUNT   := ALT_COUNT + 1;
      DI(	XD_ALT_NBR, ALTERNATIVE, ALT_COUNT );
      ALT_LIST    := APPEND( ALT_LIST, ALTERNATIVE );

      SYL_LIST   :=	(TREE_NIL,TREE_NIL);
      SEMAN_LIST :=	(TREE_NIL,TREE_NIL);
    end MAKE_ALTERNATIVE;
    --|---------------------------------------------------------------------------------------------
    --|	PROCEDURE	MAKE_SYLLABE
    procedure MAKE_SYLLABE ( TEXT :STRING ) is
    begin

      if TEXT = "%%" or TEXT = "::=" then raise PROGRAM_ERROR; end if;

      if TEXT = "'|'" then
        SYMBOL := STORE_SYM( "|" );
      else
        SYMBOL := STORE_SYM( TEXT );
      end	if;

      SEQ	:= LIST( SYMBOL );
      while not IS_EMPTY( SEQ	)
	  and then HEAD( SEQ ).TY /= DN_TERMINAL
	  and then HEAD( SEQ ).TY /= DN_RULE
      loop
        SEQ := TAIL( SEQ );
      end	loop;
      if IS_EMPTY( SEQ ) or else HEAD( SEQ ).TY /= DN_TERMINAL then
        SYLLABLE :=	MAKE( DN_NONTERMINAL);
      else
        SYLLABLE :=	MAKE( DN_TERMINAL );
        DI( XD_TER_NBR, SYLLABLE, DI( XD_TER_NBR,	HEAD( SEQ	) ) );
      end	if;

      D( XD_SYMREP,	SYLLABLE,	SYMBOL );
      D( LX_SRCPOS,	SYLLABLE,	SOURCEPOS	);

      SYL_LIST := APPEND( SYL_LIST, SYLLABLE );
    end MAKE_SYLLABE;
    --|---------------------------------------------------------------------------------------------
    --|	PROCEDURE	MAKE_SEMANTICS_GET_TOKEN
    procedure MAKE_SEMANTICS_GET_TOKEN ( IN_TEXT :STRING ) is
      TEXT		: constant STRING	:= IN_TEXT;				-- COPY OF THE ARGUMENT
      use	GRMR_OPS;
      SEM_OP		: GRMR_OP;
      SEMAN_SYM		: TREE;
      NODE_NAME_POS		: INTEGER;
      DEFLIST		: SEQ_TYPE;
      SEMAN		: TREE;
      NODE_NAME_ARITY	: ARITIES;
    begin

      SEM_OP := GRMR_OP_VALUE( TEXT );
      AVANCER;
      case SEM_OP is
      when G_ERROR =>
        ERROR ( SOURCEPOS, "INVALID SEMANTIC OP - " & TEXT );
      when N_0 .. N_L =>
        SEMAN_SYM := FIND_SYM( TOKEN );
        if SEMAN_SYM.TY = DN_VOID then
	DEFLIST := (TREE_NIL,TREE_NIL);
        else
	DEFLIST := LIST( SEMAN_SYM );
	while not	IS_EMPTY(	DEFLIST )	and then HEAD( DEFLIST ).TY /= DN_SEM_OP loop
	  DEFLIST	:= TAIL( DEFLIST );
	end loop;
        end if;
        if IS_EMPTY( DEFLIST)	then
	ERROR( SOURCEPOS, "NODE NAME NOT FOUND AFTER - " & TEXT );
        else
	NODE_NAME_POS := DI( XD_SEM_OP, HEAD( DEFLIST ) );
	AVANCER;
	SEMAN := MAKE( DN_SEM_NODE );
	DI( XD_SEM_OP, SEMAN, GRMR_OP'POS( SEM_OP ) );
	DI( XD_KIND,   SEMAN, NODE_NAME_POS );
	SEMAN_LIST := APPEND( SEMAN_LIST, SEMAN	);
	SEMAN_COUNT := SEMAN_COUNT + 1;

	NODE_NAME_ARITY := ARITIES'VAL( ARITY_TABLE( NODE_NAME_POS ) );
	case SEM_OP is
	when N_0 .. N_DEF =>
	  if NODE_NAME_ARITY /= NULLARY then
	    ERROR( SOURCEPOS, "NODE MUST BE NULLARY - " &	TEXT & " " & PRINT_NAME( SEMAN_SYM ) );
	  end if;
	when N_1 =>
	  if NODE_NAME_ARITY /= UNARY	then
	    ERROR( SOURCEPOS, "NODE MUST BE UNARY - " & TEXT & " " & PRINT_NAME( SEMAN_SYM ) );
	  end if;
	when N_2 .. N_V2 =>
	  if NODE_NAME_ARITY /= BINARY then
	    ERROR( SOURCEPOS, "NODE MUST BE BINARY - " & TEXT & " "	& PRINT_NAME( SEMAN_SYM ) );
	  end if;
	when N_3 .. N_V3 =>
	  if NODE_NAME_ARITY /= TERNARY then
	    ERROR( SOURCEPOS, "NODE MUST BE TERNARY - " &	TEXT & " " & PRINT_NAME( SEMAN_SYM ) );
	  end if;
	when N_L =>
	  if NODE_NAME_ARITY /= ARBITRARY then
	    ERROR	( SOURCEPOS, "NODE MUST BE ARBITRARY - " & TEXT &	" " & PRINT_NAME( SEMAN_SYM )	);
	  end if;
	when others =>
	  raise PROGRAM_ERROR;
	end case;
        end if;
      when G_INFIX | G_UNARY =>
        if TOKEN( TOKEN'FIRST	) /= '"' then
	ERROR( SOURCEPOS, "QUOTED STRING REQUIRED AFTER - " & TEXT & "( TOKEN = " & TOKEN & ")" );
        else
	SEMAN := MAKE( DN_SEM_NODE );
	DI( XD_SEM_OP, SEMAN, GRMR_OP'POS( SEM_OP ) );
	declare
	  SYM	: TREE	:= STORE_SYM( TOKEN	);
	begin
	  D( XD_KIND, SEMAN, SYM );

	  PUT_LINE( OFILE, "STORE_SYM ( " &  TOKEN & " );" );
	  SET_OUTPUT( OFILE	); PRINT_TREE( SYM ); SET_OUTPUT( STANDARD_OUTPUT	);

	end;
	SEMAN_LIST := APPEND( SEMAN_LIST, SEMAN	);
	SEMAN_COUNT := SEMAN_COUNT + 1;
	AVANCER;
        end if;
      when others =>
        SEMAN := MAKE( DN_SEM_OP );
        DI( XD_SEM_OP, SEMAN,	GRMR_OP'POS( SEM_OP	) );
        SEMAN_LIST := APPEND(	SEMAN_LIST, SEMAN );
        SEMAN_COUNT	:= SEMAN_COUNT + 1;
      end	case;
    end MAKE_SEMANTICS_GET_TOKEN;
    --|---------------------------------------------------------------------------------------------
    --|	PROCEDURE	MAKE_TERMINAL
    procedure MAKE_TERMINAL (	TEXT :STRING ) is
      SYMBOL		: TREE;
      DEFLIST		: SEQ_TYPE;
    begin
      if TEXT = "'|'" then
        SYMBOL := FIND_SYM( "|");
      else
        SYMBOL := FIND_SYM( TEXT );
      end	if;

      if SYMBOL.TY = DN_VOID then
        DEFLIST := (TREE_NIL,TREE_NIL);
      else
        DEFLIST := LIST( SYMBOL );
        while not IS_EMPTY( DEFLIST ) and then HEAD( DEFLIST).TY /= DN_TERMINAL	loop
	DEFLIST := TAIL( DEFLIST );
        end loop;
      end	if;
      if IS_EMPTY( DEFLIST ) then
        ERROR( SOURCEPOS, "UNDEFINED TERMINAL - "	& TEXT );
      else
        D( LX_SRCPOS, HEAD( DEFLIST ), SOURCEPOS );
      end	if;
    end MAKE_TERMINAL;

  begin

    if TOKEN /= "%terminals" then
      ERROR( SOURCEPOS, "EXPECTING %terminals" );
      return;
    end if;
    AVANCER;

    MAKE_TERMINAL( "*end*" );

    while	TOKEN /= "%start" loop
      MAKE_TERMINAL	( TOKEN );
      AVANCER;
    end loop;

    if TOKEN /="%start" then
      ERROR( SOURCEPOS, "EXPECTING %start" );
      return;
    end if;
    AVANCER;									--| SAUTER %start
	      -- GENERATE RULE:
	      --	 *SENTENCE* ::= <START_SYMBOL> *END*
    MAKE_RULE( "*SENTENCE*" );
    MAKE_ALTERNATIVE;
    MAKE_SYLLABE( TOKEN );
    if SYLLABLE.TY = DN_TERMINAL then
      ERROR( SOURCEPOS, "START SYMBOL CANNOT BE TERMINAL - " & TOKEN );
    end if;
    MAKE_SYLLABE( "*end*" );
    SEM_S	:= MAKE( DN_SEM_S );
    DI  (	XD_SEM_INDEX, SEM_S, 0);
    LIST(	SEM_S, (TREE_NIL,TREE_NIL) );
    LIST(	ALTERNATIVE, SYL_LIST);
    D   (	XD_SEMANTICS, ALTERNATIVE, SEM_S );
    LIST(	RULE, ALT_LIST );

    AVANCER;									--| LIT LE %rules
    if TOKEN /= "%rules" then
      ERROR( SOURCEPOS, "EXPECTING %RULES INSTEAD OF " & TOKEN );
      return;
    end if;
    AVANCER;									--| SAUTER %rules

    while	TOKEN /= "%end" loop
      MAKE_RULE( TOKEN );
      AVANCER;
      if TOKEN = "::=" then
        AVANCER;
      else
        ERROR( SOURCEPOS, "EXPECTING ::= INSTEAD OF " & TOKEN );
      end	if;

      while TOKEN /= "%%" loop
        MAKE_ALTERNATIVE;
        while TOKEN	/= "|" and then TOKEN /= "====>" and then TOKEN /= "%%" loop
	if TOKEN /= "empty"	then
	  MAKE_SYLLABE( TOKEN );
	end if;
	AVANCER;
        end loop;

        if TOKEN = "====>" then							--| UNE LISTE D'OPERATIONS SEMANTIQUES
	AVANCER;
	while TOKEN /= "|" and TOKEN /= "%%" loop					--| ARRET	DE LA LISTE SUR NOUVELLE ALTERNATIVE OU	FIN DE REGLE
	  MAKE_SEMANTICS_GET_TOKEN( TOKEN );						--| INTEGRER L'OPERATION SEMANTIQUE
	end loop;
        end if;

        SEM_S := MAKE( DN_SEM_S );
        DI  ( XD_SEM_INDEX, SEM_S, 0 );
        LIST( SEM_S, SEMAN_LIST );
        if not IS_EMPTY( SEMAN_LIST ) then
	SEMAN_ALT_COUNT := SEMAN_ALT_COUNT + 1;
        end if;
        D	  ( XD_SEMANTICS, ALTERNATIVE, SEM_S );
        LIST( ALTERNATIVE, SYL_LIST );

        if TOKEN = "|" then								--| ENCORE UNE ALTERNATIVE, PASSER LE '|'
	AVANCER;
        end if;
      end	loop;

      LIST( RULE, ALT_LIST );								--| LISTER LA REGLE
      AVANCER;									--| PASSER LE %%

    end loop;

    GRAMMAR := MAKE( DN_RULE_S );
    LIST(	GRAMMAR, RULE_LIST );

    USER_ROOT := MAKE( DN_USER_ROOT );
    D( XD_SOURCENAME, USER_ROOT, STORE_TEXT( NOM_TEXTE ) );
    D( XD_GRAMMAR, USER_ROOT,	GRAMMAR );

    D( XD_USER_ROOT, TREE_ROOT, USER_ROOT );
  end PROCESS_GRAMMAR;


begin
  OPEN  (	IFILE, IN_FILE, "../../idl/" & "diana.idl" );					--| CONTIENT LA DESCRIPTION IDL DE LA GRAMMAIRE ADA83
  CREATE(	OFILE, OUT_FILE, NOM_TEXTE & "_INITS.txt" );
  CREATE_IDL_TREE_FILE( NOM_TEXTE & ".lar" );						--| FICHIER DES PAGES CONTENANT L ARBRE	GRAMMAIRE	ADA83
  SOURCE_LIST := (TREE_NIL, TREE_NIL );
  LOAD_DIANA;
  LOAD_TERMINALS;

  AVANCER;
  PUT_LINE( "PROCESS_GRAMMAR");
  PROCESS_GRAMMAR;

  LIST ( TREE_ROOT,	SOURCE_LIST );
  CLOSE( OFILE);
  CLOSE( IFILE);
  CLOSE_IDL_TREE_FILE;

  INT_IO.PUT( SEMAN_COUNT, 0 );
  PUT( " SEM SYLS FOR " );
  INT_IO.PUT( SEMAN_ALT_COUNT, 0 );
  PUT_LINE( " ALTS." );
--|-------------------------------------------------------------------------------------------------
end READ_GRMR;
