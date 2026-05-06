------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

separate (IDL)
--|-------------------------------------------------------------------------------------------------
--|		PROCEDURE	IDL_READ
--|-------------------------------------------------------------------------------------------------
procedure	IDL_READ ( NOM_TEXTE :STRING ) is						--| LIT UNE DESCRIPTION IDL EN MEMOIRE VIRTUELLE

  IFILE			: FILE_TYPE;						--| FICHIER IDL
  SLINE			: STRING ( 1..256 );					--| LIGNE	TEXTE COURANTE
  COL			: NATURAL		:= 1;					--| PROCHAINE COLONNE À LIRE
  F_COL			: NATURAL;						--| PREMIERE COLONNE DU LEXEME
  TOKEN_LENGTH		: NATURAL;						--| LONGUEUR DU LEXEME
  LAST			: NATURAL		:= 0;					--| NOMBRE DE CARACTERE DE LA	LIGNE
  TOKEN_IS_NAME		: BOOLEAN;
  LINE_COUNT		: NATURAL		:= 0;

  ATTR_COUNT		: INTEGER		:= -1;
  SOURCE_LIST		: SEQ_TYPE;						--| LISTE	 DES LIGNES SOURCES
  SOURCEPOS		: TREE;							--| LA POSITION SOURCE DU LEXEME COURANT
  SOURCELINE		: TREE;							--| LE NOEUD LIGNE SOURCE

  USER_ROOT		: TREE;							--| RACINE DE L'ARBRE

  type CONTEXT_TYPE		is (NIL, IN_NODE, IN_CLASS);
  CONTEXT			: CONTEXT_TYPE	:= NIL;

  procedure PROCESS_IDL;
  procedure CHECK_IDL;
  procedure PRINT_IDL;

  --|-----------------------------------------------------------------------------------------------
  --|		PROCEDURE	GET_TOKEN
  procedure GET_TOKEN is
  begin
    while	 COL <= LAST  and then  ( SLINE(	COL ) = ' ' or else	SLINE( COL ) = ASCII.HT )  loop	--| PASSER LES ESPACES
      COL	:= COL + 1;
    end loop;

    if COL < LAST and then SLINE( COL )	= '-' and	then SLINE( COL+1 )	= '-' then		--| SAUTER EN FIN DE LIGNE SUR COMMENTAIRE
      COL	:= LAST +	1;
    end if;

    if COL > LAST then								--| SI ON	EST POST FIN DE LIGNE
      loop
        if END_OF_FILE ( IFILE ) then return; end	if;

        if END_OF_LINE ( IFILE ) then
	SKIP_LINE	( IFILE );
	LINE_COUNT := LINE_COUNT + 1;
	LAST := 0;
        else
	SLINE( 1..2 ) := "??";							--| FORCER À AUTRE CHOSE QUE // EN CAS DE LIGNE VIDE
	GET_LINE(	IFILE, SLINE, LAST );						--| LIRE UNE LIGNE
	if SLINE(	1..2 ) = "//" then							--| NE S'OCCUPER QUE DES LIGNES COMMENÇANT PAR //
	  COL := 3;								--| SE METTRE EN COL 3 POST "//"
	else
	  COL := LAST + 1;								--| POST FIN DE LIGNE POUR NEGLIGER LA LIGNE
	end if;
        end if;

        while COL <= LAST and	then ( SLINE(COL) =	' ' or else SLINE(COL) = ASCII.HT ) loop	--| PASSER LES BLANCS
	COL := COL + 1;
        end loop;

        if COL <= LAST then
	if SLINE(	COL ) = '-' and then COL < LAST and then SLINE( COL+1 ) = '-' then
	  COL := LAST + 1;
	else									--| LIGNE	NON VIDE
	  SOURCELINE := MAKE ( DN_SOURCELINE );						--| CREER	UN NOEUD LIGNE SOURCE
	  DI  ( XD_NUMBER, SOURCELINE, LINE_COUNT );					--| Y METTRE LE NUMERO DE LIGNE
	  LIST( SOURCELINE,	(TREE_NIL,TREE_NIL)	);					--| INITIALISER LA XD_ERROR_LIST
	  SOURCE_LIST := APPEND ( SOURCE_LIST, SOURCELINE	);				--| METTRE LA LIGNE	EN FILE
	  exit;
	end if;
        end if;
      end	loop;
    end if;

    F_COL	:= COL;
    TOKEN_LENGTH :=	1;
    TOKEN_IS_NAME := FALSE;

    case SLINE(COL)	is
    when 'A'..'Z' |	'a'..'z' =>
      TOKEN_IS_NAME	:= TRUE;
      COL	:= COL +1;
      while COL <= LAST
	  and then ( SLINE(	COL ) in 'A'..'Z'
		   or else SLINE( COL ) in 'a'..'z'
		   or else SLINE( COL ) = '_'
		   or else SLINE( COL ) in '0'..'9'
			)
      loop
        TOKEN_LENGTH := TOKEN_LENGTH + 1;
        COL := COL + 1;
      end	loop;

    when ':' =>									--| PEUT ETRE ::=
      if COL + 2 <=	LAST
	        and then SLINE (COL +	1) = ':' and then SLINE( COL + 2 ) = '=' then		--| OUI UN ::=
        TOKEN_LENGTH := 3;								--| LONGUEUR 3
        COL := COL + 3;
      else
        COL := COL + 1;
      end	if;

    when '=' =>									--| PEUT ETRE =>
      if COL + 1 <=	LAST and then SLINE( COL + 1 ) = '>' then				--| OUI "=>"
        TOKEN_LENGTH := 2;
        COL := COL + 2;
      else
        COL := COL + 1;
      end	if;

    when '|' | ';' | ',' =>
      COL	:= COL + 1;

    when others =>
      COL	:= COL + 1;

    end case;

    SOURCEPOS := MAKE_SOURCE_POSITION( SOURCELINE, SRCCOL_IDX( F_COL ) );

  end GET_TOKEN;
  --|-----------------------------------------------------------------------------------------------
  --|		PROCEDURE	PROCESS_IDL
  procedure PROCESS_IDL is

    RULE_NODE		: TREE;
    NODE_LIST		: SEQ_TYPE	:= (TREE_NIL,TREE_NIL);
    PRIOR_F_COL		: POSITIVE	:= 1;
    PRIOR_TOKEN_LENGTH	: NATURAL		:= 0;
    type ATTR_TYPE		is (NORMAL, SEQ);

    --|---------------------------------------------------------------------------------------------
    --|		PROCEDURE	MAKE_RULE_OR_CLASS_NODE
    procedure MAKE_RULE_OR_CLASS_NODE (	NODE_NAME	:STRING )	is
      SYMBOL		: TREE		:= STORE_SYM ( NODE_NAME );			--| STOCKER/RETIRER	LE NOM DE	NOEUD REGLE (NOM EN	PARTIE GAUCHE AVANT	LE => )
      R_LIST		: SEQ_TYPE	:= LIST (	SYMBOL );				--| LISTE	CONTENANT	LE NOEUD REGLE ASSOCIEES AU SYMBOLE (REFERENCE COMME GAUCHE	DE REGLE OU TYPAGE)
    begin
      if IS_EMPTY (	R_LIST ) then							--| LA LISTE EST VIDE, C'EST LA PREMIERE DEFINITION DE REGLE/CLASSE
        RULE_NODE := MAKE ( DN_CLASS_NODE );						--| FABRIQUER UN NOEUD POUR LA REGLE/CLASSE
        D	( XD_SYMREP, RULE_NODE, SYMBOL );						--| METTRE LE SYMBOLE DU NOM DE REGLE (NOM GAUCHE) DANS LE XD_NAME DU	NOEUD REGLE
        LIST ( RULE_NODE, (TREE_NIL,TREE_NIL) );						--| INITIALISER À VIDE LA LISTE DES ELEMENTS DU CÔTE DROIT
        if CONTEXT = IN_NODE then							--| DANS UN NOEUD REGLE SIMPLE
	DB ( XD_IS_CLASS, RULE_NODE, FALSE );						--| MARQUER UNE REGLE DE STRUCTURE D'ATTRIBUTS
        else									--| DANS UNE CLASSE
	DB ( XD_IS_CLASS, RULE_NODE, TRUE );						--| MARQUER UNE REGLE DE DEFINITION DE CLASSE
        end if;
        D	( LX_SRCPOS, RULE_NODE, SOURCEPOS );						--| METTRE LA POSITION SOURCE	DONNEE PAR GET_TOKEN
        D	( XD_PARENT, RULE_NODE, TREE_VOID );
        LIST ( SYMBOL, APPEND	( (TREE_NIL,TREE_NIL), RULE_NODE ) );				--| METTRE LE NOEUD	REGLE COMME ELEMENT	UNIQUE DE	LISTE DU SYMBOLE DE	NOM GAUCHE (XD_DEFLIST)
        NODE_LIST := APPEND (	NODE_LIST, RULE_NODE );					--| METTRE EN LISTE	LA REGLE

      else									--| UNE REGLE AVEC MEME PARTIE GAUCHE A	DEJÀ ETE VUE
        declare
	DEF		: TREE		:= HEAD (	R_LIST );				--| PRENDRE LE NOEUD DE TETE,	LE NOEUD REGLE
        begin
	if DEF.TY	= DN_CLASS_NODE then						--| VERIFIER QUE C'EST UNE REGLE
	  RULE_NODE := DEF;								--| PRENDRE CE NOEUD COMME COURANT
	  if CONTEXT = IN_CLASS then							--| ON A UN NOM CITE EN CLASSE (PEUT AVOIR ETE TROUVE AUPARAVANT CITE	COMME TYPAGE EN DROITE DE REGLE D'ATTRIBUTION )
	    DB ( XD_IS_CLASS, RULE_NODE, TRUE );					--| MARQUER COMME CLASSE
	  end if;

	else									--| ANOMALIE LE NOEUD N'EST PAS UNE REGLE
	  ERROR (	SOURCEPOS, "HOLA ! " & NODE_NAME & " N EST PAS UN NOM EN PARTIE GAUCHE (REGLE) !" );
	end if;
        end;
      end	if;

    end MAKE_RULE_OR_CLASS_NODE;
    --|---------------------------------------------------------------------------------------------
    --|		PROCEDURE	MAKE_ATTR
    procedure MAKE_ATTR ( ATTR_NAME :STRING; ATYPE :ATTR_TYPE; NOM_TYPE :STRING	) is
      SYMBOL		: TREE		:= STORE_SYM ( ATTR_NAME );			--| STOCKER/RETIRER	LE SYMBOLE (SYMREP)	DE L'ATTRIBUT
      A_LIST		: SEQ_TYPE	:= LIST (	SYMBOL );				--| LISTE	CONTENANT	LA DEFINITION DE L'ATTRIBUT
      TYPAGE		: TREE		:= STORE_SYM ( NOM_TYPE );			--| STOCKER/REPRENDRE LE SYMBOLE DU TYPE DE L'ATTRIBUT (UN NOM DE REGLE OU DE CLASSE)
      ATTR		: TREE;
    begin

      if IS_EMPTY (	A_LIST ) then							--| AUCUNE APPARITION DE CET ATTRIBUT
        ATTR_COUNT := ATTR_COUNT + 1;							--| UN ATTRIBUT DE PLUS
        ATTR := MAKE ( DN_ATTR );							--| CREER	UN NOEUD DE TYPE ATTRIBUT/TERMINAL
        D	( XD_SYMREP, ATTR, SYMBOL );							--| POINTER LE SYMBOLE DANS LE CHAMP XD_SYMREP DU	TERMINAL

        case ATYPE is								--| SUIVANT QUE L'ON A UN ATTRIBUT SIMPLE OU UNE SEQUENCE
        when NORMAL	=>								--| UN ATTRIBUT SIMPLE
	DI ( XD_ATTR_ID, ATTR, ATTR_COUNT );						--| PORTER LE N° D'ATTRIBUT EN POSITIF
        when others	=>								--| UN ATTRIBUT SEQUENCE, PORTER LE N° D'ATTRIBUT	EN NEGATIF
	DI (XD_ATTR_ID, ATTR, - ATTR_COUNT );
        end case;
        D	( XD_ATTR_TYPE, ATTR, TYPAGE );						--| METTRE LE TYPAGE
        LIST ( SYMBOL, APPEND	( (TREE_NIL,TREE_NIL), ATTR )	);				--| PORTER L'ATTRIBUT CREÉ EN	LISTE DANS LE XD_DEFLIST DU SYMREP

      else									--| IL Y A DEJÀ EU UNE APPARITION
        ATTR := HEAD ( A_LIST	);							--| PRENDRE LA DEFINITION EXISTANTE
      end	if;

      if ATTR.TY = DN_ATTR then							--| CE DOIT ETRE UN	ATTRIBUT/TERMINAL
        case ATYPE is
        when NORMAL	=>								--| ATTRIBUT SIMPLE	(NON SEQUENCE)
	if DI ( XD_ATTR_ID,	ATTR ) < 0  then						--| IL Y A UNE ANOMALIE (LE N° D'ATTRIBUT DOIT ETRE POSITIF	DANS CE CAS)
	  ERROR (	SOURCEPOS, "ATTR IS SEQ" & ATTR_NAME);

	elsif TYPAGE /= D (	XD_ATTR_TYPE, ATTR ) then					--| ANOMALIE SI LE TYPAGE NE CORRESPOND	PAS À CE QUI EST DANS L'ATTRIBUT (VOIR LA LIGNE (**) UN PEU	PLUS HAUT)
	  declare
	    OLD_TYPAGE	: TREE		:= D ( XD_ATTR_TYPE, ATTR );
	  begin
	    ERROR	( SOURCEPOS, "VALUE OF " & ATTR_NAME
			& " IS "	 & PRINT_NAME ( TYPAGE )
			& " [" & PAGE_IDX'IMAGE ( TYPAGE.PG )
			& "." & LINE_IDX'IMAGE ( TYPAGE.LN )
			& "." & NODE_NAME'IMAGE ( TYPAGE.TY ) &	"] CALLED " & PRINT_NAME ( TYPAGE )

			& ", NOT " & PRINT_NAME ( OLD_TYPAGE )
			& " [" & PAGE_IDX'IMAGE ( OLD_TYPAGE.PG	)
			& "." & LINE_IDX'IMAGE ( OLD_TYPAGE.LN )
			& "." & NODE_NAME'IMAGE ( OLD_TYPAGE.TY	) & "] CALLED " & PRINT_NAME ( OLD_TYPAGE )
			);
	  end;
	end if;
        when others	=>								--| ATTRIBUT SEQUENCE
	if DI ( XD_ATTR_ID,	ATTR) >= 0 then						--| ANOMALIE SI LE N° D'ATTRIBUT EST POSITIF (IL DOIT ETRE NEGATIF POUR UNE SEQUENCE)
	  ERROR (	SOURCEPOS, "ATTR IS NOT SEQ" & ATTR_NAME );

	elsif TYPAGE /= D (	XD_ATTR_TYPE, ATTR)	then					--| SI LE	TYPAGE DE	SEQUENCE DIFFERE DE	L'ANTERIEUR
	  declare
	    TEMP		: TREE		:= ATTR;					--| GARER	L'ATTRIBUT ANCIENNEMENT TYPE
	  begin
	    ATTR := MAKE ( DN_ATTR );							--| REFAIRE UN TERMINAL QUI EST PRIS COMME ATTRIBUT
	    D  ( XD_SYMREP,	ATTR, D (	XD_SYMREP, TEMP ) );				--| DANS LE SYMREP DU NOUVEAU, RECOPIER	LE SYMREP	DE L'ANCIEN
	    DI ( XD_ATTR_ID, ATTR, DI	( XD_ATTR_ID, TEMP ) );				--| REPORTER AUSSI LE N° D'ATTRIBUT
	    D  ( XD_ATTR_TYPE, ATTR, TYPAGE );						--| METTRE LE TYPAGE DANS CE NOUVEAU NOEUD ATTRIBUT QUI DIFERE PAR LE	TYPAGE
	  end;
	end if;
        end case;
        declare
	ASEQ		: SEQ_TYPE	 := LIST ( RULE_NODE );			--| REPRENDRE LA XD_LIST DU NOEUD REGLE	EN COURS
        begin
	LIST ( RULE_NODE, APPEND ( ASEQ, ATTR )	);					--| AJOUTER AU NOEUD REGLE EN	COURS LA LISTE DES ATTRIBUTS AUGMENTEE
        end;
      else									--| LA DEFINITION (TROUVEE) N'EST PAS UN TERMINAL	!
        ERROR ( SOURCEPOS, "NOT DEFINED AS AN ATTRIBUTE -" & ATTR_NAME );

      end	if;

    end MAKE_ATTR;
    --|---------------------------------------------------------------------------------------------
    --|		PROCEDURE	MAKE_MEMBER
    procedure MAKE_MEMBER ( MEMBER_NAME	:STRING )	is

      SYMBOL		: TREE		:= STORE_SYM ( MEMBER_NAME );			--| STOCKER/REPRENDRE LE SYMREP CORRESPONDANT AU NOM D'ELEMENT DE CLASSE
      MEMBER		: TREE		:= MAKE (	DN_MEMBER	);			--| FABRIQUER UN NON TERMINAL	POUR UN ELEMENT APPARTENANT À	UNE CLASSE
      M_LIST		: SEQ_TYPE	:= LIST (	SYMBOL );				--| LA LISTE CONTENANT LA REGLE DEFINISSANT LE SYMBOLE
    begin
      D (	XD_SYMREP, MEMBER, SYMBOL );							--| METTRE LE SYMREP DANS LE CHAMP XD_SYMREP DU MEMBRE DE CLASSE
      D (	LX_SRCPOS, MEMBER, SOURCEPOS );						--| METTRE LA POSITION SOURCE	DU MEMBRE	CREÉ PAR GET_TOKEN
      LIST ( RULE_NODE, APPEND ( LIST (	RULE_NODE	), MEMBER	) );				--| AJOUTER LE MEMBRE À LA LISTE DES MEMBRES DU NOEUD
    end ;
    --|---------------------------------------------------------------------------------------------

  begin
    LAST := 0;
    COL := 1;
    GET_TOKEN;
    loop

      exit when END_OF_FILE (IFILE) or else SLINE( F_COL..F_COL + TOKEN_LENGTH - 1) = "end";	--| FINIR	AVEC LE FICHIER OU LE LEXEME %%% QUI INDIQUE LA FIN

      if TOKEN_IS_NAME then								--| LEXEME IDENTIFICATEUR
        PRIOR_F_COL	:= F_COL;								--| GARDER SA POSITION
        PRIOR_TOKEN_LENGTH :=	TOKEN_LENGTH;						--| ET SA	LONGUEUR
        GET_TOKEN;									--| ET PASSER AU SUIVANT (QUI	VA PERMETTRE DE SAVOIR CE QUE	L'ON VA FAIRE)

      elsif SLINE( F_COL..F_COL + TOKEN_LENGTH - 1) = "=>" then				--| INDIQUE UNE REGLE DEFINISSANT DES ATTRIBUTS
        CONTEXT := IN_NODE;								--| GARDER UNE TRACE DE CE FAIT : DEFINITION D'UNE ASSOCIATION D'ATTRIBUTS
        MAKE_RULE_OR_CLASS_NODE ( SLINE( PRIOR_F_COL..PRIOR_F_COL +PRIOR_TOKEN_LENGTH -1 ) );	--| TENTER LA CREATION D'UN NOEUD REGLE	(OU LE RAMENER S'IL	EXISTE DEJÀ)
        GET_TOKEN;									--| ALLER	CHERCHER LE PREMIER	NOM D'ATTRIBUT OU LE ;

      elsif SLINE( F_COL..F_COL + TOKEN_LENGTH - 1) = "::="	then				--| LEXEME MARQUANT	UNE DEFINITION DE CLASSE
        CONTEXT := IN_CLASS;								--| GARDER UNE TRACE DE CE FAIT : DEFINITION D'UNE CLASSE
        MAKE_RULE_OR_CLASS_NODE ( SLINE( PRIOR_F_COL..PRIOR_F_COL +PRIOR_TOKEN_LENGTH -1 ) );	--| TENTER LA CREATION D'UN NOEUD REGLE	(OU LE RAMENER S'IL	EXISTE DEJÀ)
        GET_TOKEN;									--| ALLER	CHERCHER UN COMPOSANT DE CLASSE
        while SLINE( F_COL..F_COL + TOKEN_LENGTH - 1) /= ";" loop				--| JUSQU'À LA FIN DE LA DEFINITION DE CLASSE
	if TOKEN_IS_NAME then							--| SI L'ON A UN NOM (PAS UNE	',' SEPARATRICE)
	  MAKE_MEMBER ( SLINE( F_COL..F_COL + TOKEN_LENGTH - 1) );				--| CREER	UN MEMBRE	DE CLASSE
	end if;
	GET_TOKEN;								--| AVANCER AU LEXEME SUIVANT
        end loop;

      elsif SLINE( F_COL..F_COL + TOKEN_LENGTH - 1) = ":" then				--| SEPARATEUR DU TYPAGE
        GET_TOKEN;									--| AMENER UN SEQ OU LE NOM DU TYPE
        if SLINE( F_COL..F_COL + TOKEN_LENGTH - 1) = "Seq" then				--| C'EST	UN SEQ
	GET_TOKEN;								--| PRENDRE LE OF OU LE NOM DE TYPE
	if SLINE(	F_COL..F_COL + TOKEN_LENGTH -	1) = "Of"	then				--| ON A LE OF
	  GET_TOKEN;								--| PRENDRE LE NOM DE TYPE
	end if;
	MAKE_ATTR	( SLINE( PRIOR_F_COL..PRIOR_F_COL +PRIOR_TOKEN_LENGTH -1 ),	SEQ,		--| AJOUTER UN ATTRIBUT SEQUENCE
		  SLINE( F_COL..F_COL + TOKEN_LENGTH - 1 )				--| AVEC SON TYPAGE
		 );

        elsif SLINE( PRIOR_F_COL..PRIOR_F_COL +PRIOR_TOKEN_LENGTH -1 ) /= "lx_comments" then	--| SI CE	N'EST PAS	UN ATTRIBUT LX_COMMENTS
	MAKE_ATTR	( SLINE( PRIOR_F_COL..PRIOR_F_COL + PRIOR_TOKEN_LENGTH - 1), NORMAL,		--| AJOUTER UN ATTRIBUT SIMPLE (NON SEQUENCE)
		  SLINE( F_COL..F_COL + TOKEN_LENGTH - 1 )				--| AVEC SON TYPAGE
		 );
        end if;

      else
        GET_TOKEN;									--| LEXEME NON RECONNU, PASSER AU SUIVANT
      end	if;
    end loop;

    USER_ROOT := MAKE ( DN_USER_ROOT );							--| FABRIQUER LE NOEUD RACINE	ARBRE
    D ( XD_SOURCENAME, USER_ROOT, STORE_TEXT ( NOM_TEXTE ) );				--| Y METTRE LE NOM	DE FICHIER ANS XD_SOURCENAME
    LIST ( USER_ROOT, NODE_LIST );							--| PORTER DANS LE NOEUD SEQUENCE LA LISTE DES NOEUDS
    D ( XD_USER_ROOT, TREE_ROOT, USER_ROOT );						--| METTRE LE NOEUD	RACINE ARBRE DANS LA RACINE SYSTEME
  end PROCESS_IDL;
  --|-----------------------------------------------------------------------------------------------
  --|		PROCEDURE	CHECK_IDL
  procedure CHECK_IDL is
    NODE_LIST		: SEQ_TYPE		:= LIST (	USER_ROOT	);		--| REPRENDRE LA LISTE DES REGLES DU CHAMP XD_LIST
    RULE_NODE		: TREE;
    ITEM_LIST		: SEQ_TYPE;
    ITEM			: TREE;
  begin
    PUT_LINE ( "**** VERIFICATION ...");
    while	not IS_EMPTY ( NODE_LIST ) loop
      POP	( NODE_LIST, RULE_NODE );							--| RETIRER UN NOEUD REGLE
      ITEM_LIST := LIST ( RULE_NODE );							--| LISTE	DES ATTRIBUTS OU DES MEMBRES
      while not IS_EMPTY ( ITEM_LIST ) loop						--| TANT QUE LISTE NON VIDE
        POP ( ITEM_LIST, ITEM	);							--| RETIRER UN ELEMENT DE LA XD_LIST (ATTRIBUT OU	MEMBRE DE	CLASSE)

        if ITEM.TY = DN_ATTR then							--| TERMINAL (OU ATTRIBUT)
	declare
	  TYPAGE		: TREE		:= D ( XD_ATTR_TYPE, ITEM );			--| LE TYPE DE L'ATTRIBUT
	begin
	  if TYPAGE.TY /= DN_SYMBOL_REP then
	    ERROR	( D ( LX_SRCPOS, RULE_NODE ),	"TYPAGE INEXISTANT: " );
	  end if;
	end;

        else									--| NON TERMINAL (OU MEMBRE DE CLASSE)
	declare
	  DEFINING_RULE_LIST	: SEQ_TYPE	:= LIST (	D ( XD_SYMREP, ITEM	) );
	begin

	  if IS_EMPTY ( DEFINING_RULE_LIST ) then
	    ERROR	( D ( LX_SRCPOS, RULE_NODE ),	"!! CLASSE VIDE : "	& PRINT_NAME ( D ( XD_SYMREP,	ITEM ) ) );
	  elsif HEAD ( DEFINING_RULE_LIST ).TY /= DN_CLASS_NODE then
	    ERROR	( D ( LX_SRCPOS, RULE_NODE ),	"!! PAS UN NOEUD CLASSE : " &	PRINT_NAME ( D ( XD_SYMREP, ITEM ) ) );
	  else
	    declare
	      DEFINING_RULE		: constant TREE	:= HEAD (	DEFINING_RULE_LIST );
	      OWNER		: constant TREE	:= RULE_NODE;
	      PARENT		: TREE		:= D ( XD_PARENT, DEFINING_RULE );
	    begin
	      D (	XD_CLASS_NODE, ITEM, DEFINING_RULE );
	      if PARENT = TREE_VOID then
	        D	( XD_PARENT, DEFINING_RULE, OWNER );

	      elsif DEFINING_RULE = TREE_VOID then
	        null;
	      elsif PARENT /= OWNER then
	        ERROR ( D (	LX_SRCPOS, OWNER ),	"NOEUD/CLASSE "
			   & PRINT_NAME ( D	( XD_SYMREP, DEFINING_RULE ) )
			   & " A LA FOIS DANS " & PRINT_NAME ( D ( XD_SYMREP, OWNER	) )
			   & " ET " & PRINT_NAME ( D ( XD_SYMREP, PARENT ) )
			   );
	      end	if;
	    end;
	  end if;
	end;
        end if;
      end	loop;
    end loop;
  end CHECK_IDL;
  --|-----------------------------------------------------------------------------------------------
  --|		PROCEDURE	PRINT_IDL
  procedure PRINT_IDL is
    NODE_LIST		: SEQ_TYPE		:= LIST (	USER_ROOT	);
    RULE_NODE		: TREE;
    ITEM_LIST		: SEQ_TYPE;
    ITEM			: TREE;
    DEFLIST		: SEQ_TYPE;
    NFILE, CFILE		: TEXT_IO.FILE_TYPE;					--| FICHIERS NOEUDS	ET HIERARCHIE
    --|---------------------------------------------------------------------------------------------
    --|		PROCEDURE	CLASS_PATH
    procedure CLASS_PATH ( NODE :TREE; IS_CLASS :BOOLEAN ) is
      PARENT		: constant TREE		:= D( XD_PARENT, NODE );
    begin
      if PARENT = NODE then
        ERROR( D( LX_SRCPOS, NODE ), "AUTO PARENT ! " & PRINT_NAME( D( XD_SYMREP, NODE ) ) );
        PUT_LINE ( "ERREUR PARTITION" );
      end	if;

      if PARENT = TREE_VOID then							--| CLASSE DE BASE
        if DB( XD_IS_CLASS, NODE ) then							--| UN NOEUD CLASSE
	declare
	  THE_NAME	: constant STRING		:= PRINT_NAME( D ( XD_SYMREP,	NODE ) );
	begin
	  if THE_NAME /= "NON_DIANA"
	    and then THE_NAME /= "ALL_SOURCE"
	    and then THE_NAME /= "TYPE_SPEC"
	    and then THE_NAME /= "STANDARD_IDL"
	  then
	    PUT_LINE ( "**** PARTITION INATTENDUE = " & THE_NAME );
	  end if;
	  PUT( THE_NAME );
	  if not IS_CLASS then
	    PUT( CFILE, THE_NAME );
	  end if;
	end;

        else									--| UN NOEUD DE REGLE D'ATTRIBUTION
	PUT( "..." );
        end if;

      else									--| PAS CLASSE DE BASE
        CLASS_PATH(	PARENT, IS_CLASS );							--| REMONTER VERS LA CLASSE DE BASE
        PUT( " > " & PRINT_NAME( D( XD_SYMREP, NODE ) ) );
        if not IS_CLASS then
	PUT ( CFILE, " > " & PRINT_NAME ( D ( XD_SYMREP, NODE ) ) );			--| REPETER
        end if;
      end	if;
    end CLASS_PATH;


  begin
    CREATE ( NFILE,	OUT_FILE,	NOM_TEXTE	& "_NODES_.txt" );					--| FICHIER INFORMATION TEXTE	DES NOEUDS
    CREATE ( CFILE,	OUT_FILE,	NOM_TEXTE	& "_CLASS_.txt" );					--| FICHIER INFORMATION TEXTE	HIERARCHIE DES CLASSES
    SET_OUTPUT ( NFILE );
    PUT_LINE ( "----- ARBORESCENCE IDL -----");
    while	not IS_EMPTY ( NODE_LIST ) loop
      POP	( NODE_LIST, RULE_NODE );

      declare
        IS_A_CLASS		: constant BOOLEAN		:= DB ( XD_IS_CLASS, RULE_NODE );
      begin
        declare
	RULE_CLASS_NAME	: constant STRING		:= PRINT_NAME ( D (	XD_SYMREP, RULE_NODE ) );
        begin

	if IS_A_CLASS then								--| DEFINIT UNE CLASSE
	  PUT ( "{" & RULE_CLASS_NAME	& "}" );
	else
	  PUT ( RULE_CLASS_NAME );
	end if;
        end;

        PUT ( ASCII.HT & "PATH " );
        CLASS_PATH ( RULE_NODE, IS_CLASS=> DB ( XD_IS_CLASS, RULE_NODE ) );
        if not IS_A_CLASS then							--| PAS UNE CLASSE
	NEW_LINE ( CFILE );
        end if;

        ITEM_LIST := LIST ( RULE_NODE );						--| LISTE	DES ATTRIBUTS OU DES MEMBRES
        if not IS_EMPTY ( ITEM_LIST ) then
	if IS_A_CLASS then								--| DEFINIT UNE CLASSE
	  PUT ( " ::= " );
	end if;
        end if;
        NEW_LINE;
      end;

      while not IS_EMPTY ( ITEM_LIST ) loop
        POP ( ITEM_LIST, ITEM	);

        if ITEM.TY = DN_ATTR then							--| ATTRIBUT
	PUT ( ASCII.HT & "=> " & PRINT_NAME ( D	( XD_SYMREP, ITEM )	) & ASCII.HT & ": ");
	if DI ( XD_ATTR_ID,	ITEM ) < 0 then						--| ATTRIBUT SEQUENCE
	  PUT ( "SEQ OF ");
	end if;
	PUT_LINE ( PRINT_NAME ( D ( XD_ATTR_TYPE, ITEM ) ) );				--| TYPAGE

        else									--| MEMBRE DE CLASSE
	PUT ( ASCII.HT & PRINT_NAME (	D ( XD_SYMREP, ITEM	) ) );				--| NOM DU MEMBRE
	DEFLIST := LIST ( D	( XD_SYMREP, ITEM )	);
	if IS_EMPTY ( DEFLIST ) or else HEAD ( DEFLIST ).TY /= DN_CLASS_NODE then
	  PUT ( " ?????" );
	end if;
	NEW_LINE;
        end if;
      end	loop;
      NEW_LINE;

    end loop;
    SET_OUTPUT ( STANDARD_OUTPUT );
    CLOSE	( NFILE );
    CLOSE	( CFILE );

  exception
    when others =>
      CLOSE ( NFILE	);
      CLOSE ( CFILE	);
      PUT_LINE ( "ERREUR A L IMPRESSION" );
  end PRINT_IDL;

begin

  OPEN ( IFILE, IN_FILE, "../../idl/" &	NOM_TEXTE	& ".idl" );						--| FICHIER SOURCE IDL
  PUT_LINE ( "LE FICHIER : " & NOM_TEXTE & ".IDL EST OUVERT " );
  CREATE_IDL_TREE_FILE ( NOM_TEXTE & ".lar");								--| FICHIER D'ARBRE	IDL
  PUT_LINE ( "LE FICHIER : " & NOM_TEXTE & ".lar  EST CREE"	);
  SOURCE_LIST := (TREE_NIL,TREE_NIL);

  PUT_LINE ( "PROCESS IDL ..." ); PROCESS_IDL; PUT_LINE ( " OK" );
  LIST ( TREE_ROOT,	SOURCE_LIST );
  CLOSE (	IFILE );

  CHECK_IDL;
  PRINT_IDL;

  CLOSE_IDL_TREE_FILE;

exception
  when NAME_ERROR =>
    PUT_LINE ( "LE FICHIER DESCRIPTION : " & "../../idl/" &	NOM_TEXTE	& ".idl  EST INTROUVABLE" );

--|-------------------------------------------------------------------------------------------------
end IDL_READ;
