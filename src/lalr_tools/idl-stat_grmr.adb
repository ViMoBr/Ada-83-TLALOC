------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

separate(	IDL )
--|-------------------------------------------------------------------------------------------------
--|		PROCEDURE	STAT_GRMR
--|-------------------------------------------------------------------------------------------------
procedure	STAT_GRMR	( NOM_TEXTE :STRING	) is

begin
  OPEN_IDL_TREE_FILE( NOM_TEXTE & ".lar" );						--| COMMENCER PAR OUVRIR CELA	POUR POUVOIR TRAVAILLER !

  declare										--| PUIS DECLARER/INITIALISER	CE DONT ON A BESOIN
    USER_ROOT		: TREE		:= D( XD_USER_ROOT,	TREE_ROOT);
    GRAMMAR		: TREE		:= D( XD_GRAMMAR, USER_ROOT);
    GR_RULE_S		: SEQ_TYPE	:= LIST( GRAMMAR);

    STATE_SEQ		: SEQ_TYPE	:= (TREE_NIL,TREE_NIL);			--| LISTE	DE TOUS LES ETATS ENGENDRES
    WORK_LIST		: SEQ_TYPE	:= STATE_SEQ;				--| ETATS	RESTANT À	TRAITER
    STATE_COUNT		: INTEGER		:= 0;					--| NOMBRE D'ETATS
    DUMMY_FOLLOW		: TREE		:= MAKE( DN_TERMINAL_S );			--| LISTE	DE SUIVI VIDE POUR PRNTSTAT

    HASH_SIZE		: constant INTEGER	:= 2999;				-- A PRIME
    HASH			: array (0 .. HASH_SIZE-1) of	TREE	:= (others=> TREE_VOID);
        -- DEFINED STATES

        -- DATA FOR	TABLES TO	SPEED UP NEW STATE CALCULATION
        -- FOR EACH	SYMBOL, INDEX POINTS TO A CHAIN OF ITEMS WITH THE
        -- GIVEN SYMBOL FOLLOWING THE POSITION MARKER (I.E., THOSE ITEMS
        -- WHICH, AFTER SHIFTING, FORM THE CORE OF A NEW STATE).
    type INDEX_TYPE	is record								-- ONE FOR EACH SYMBOL (- TER, + NONTER)
		  TIME		: INTEGER	:= 0;					--| PASS (FROM STATE) AT WHICH USED
		  F, L		: INTEGER;					--| PREMIER ET DERNIER ITEMS (N°)
		end record;
    type CHAIN_TYPE	is record
		  N		: INTEGER;					--| ITEM SUIVANT (0	POUR LA FIN DE CHAÎNE)
		  T		: TREE;						--| UN ITEM
		  FIRST		: BOOLEAN;					--| PREMIER ITEM POUR LE SYMBOLE
		end record;

    INDEX		: array( -INTEGER( 170 ) .. 400 ) of INDEX_TYPE;
    CHAIN		: array( 1 .. 100 )	of CHAIN_TYPE;
    CHAIN_LAST	: INTEGER;

    --|---------------------------------------------------------------------------------------------
    --|		PROCEDURE	MAKE_ITEM
    function MAKE_ITEM ( ALTERNATIVE :TREE; SYLLABE_S :SEQ_TYPE; SYLLABE_NBR :INTEGER ) return TREE	is
      ITEM	: TREE	:= MAKE( DN_ITEM );						--| FABRIQUER UN NOEUD ITEM
    begin
      D	( XD_ALTERNATIVE, ITEM, ALTERNATIVE );						--| Y MENTIONNER L'ALTERNATIVE DONT IL VIENT
      LIST( ITEM, SYLLABE_S );							--| Y METTRE LA LISTE DES SYLLABES DE L'ALTERNATIVE
      DI	( XD_SYL_NBR, ITEM,	SYLLABE_NBR );						--| PORTER UN N° DE	SYLLABE INITIAL
      D	( XD_GOTO, ITEM, TREE_VOID );							--| CHAMP	INITIALISE À VIDE
      D	( XD_FOLLOW, ITEM, DUMMY_FOLLOW );						--| CHAMP	INITIALISE À LISTE VIDE
      return ITEM;
    end;
    --|---------------------------------------------------------------------------------------------
    --|		PROCEDURE	MAKE_STATE
    function MAKE_STATE return TREE is
      STATE	: TREE	:= MAKE( DN_STATE );
    begin
      STATE_COUNT := STATE_COUNT + 1;							--| UN ETAT DE PLUS
      DI(	XD_STATE_NBR, STATE, STATE_COUNT );						--| METTRE LE N° D'ETAT
      STATE_SEQ := APPEND( STATE_SEQ, STATE );						--| AJOUTER À LA LISTE D'ETATS

      if WORK_LIST.FIRST.TY /= DN_LIST then						--| SI LA	LISTE N'EST PAS INITIALISEE OU VIDE
        if WORK_LIST.FIRST.TY	= DN_NIL then						--| SI ELLE EST VIDE
	WORK_LIST.FIRST := STATE;							--| POINTER L'ETAT CREÉ
        else									--| LA LISTE DE TRAVAIL EST NON VIDE
	WORK_LIST.FIRST := STATE_SEQ.NEXT;						--| LA LISTE DE TRAVAIL POINTE LE RESTE	DE LA LISTE DES ETATS
        end if;
      end	if;
      return STATE;
    end;
    --|---------------------------------------------------------------------------------------------
    --|		PROCEDURE	FORM_CLOSURE
    procedure FORM_CLOSURE ( ITEM_SEQ :in out SEQ_TYPE ) is
      INIT_NONTER_S		: SEQ_TYPE	:= (TREE_NIL,TREE_NIL);			--| LISTE	DES RÈGLES DE NON TERMINAUX QUI FORME LA FERMETURE
    begin

FIND_RULES_FOR_CLOSURE:								--| CHERCHER LES RÈGLES QUI VONT ALLER DANS LA FERMETURE DE	L'ITEM
      declare
        ITEM_S	: SEQ_TYPE	:= ITEM_SEQ;
        ITEM	: TREE;
      begin
        while not IS_EMPTY( ITEM_S ) loop						--| TANT QU'IL Y A DES ITEMS
	POP( ITEM_S, ITEM );							--| EN EXTRAIRE UN
	declare
	  SYLLABE_S	: SEQ_TYPE	:= LIST( ITEM );				--| PRENDRE SA LISTE DE SYLLABES
	  SYLLABE		: TREE;
	begin
	  if not IS_EMPTY( SYLLABE_S ) then						--| S'IL Y A DES SYLLABES
	    SYLLABE:= HEAD(	SYLLABE_S	);						--| PRENDRE LA PREMIÈRE
	    if SYLLABE.TY =	DN_NONTERMINAL then						--| SI C'EST UN NON	TERMINAL
	      declare
	        RULE : TREE	:= D( XD_RULE, SYLLABE );					--| PRENDRE SA RÈGLE DE DEFINITION
	      begin
	        if RULE.TY /= DN_VOID	then						--| S'IL Y EN A UNE
		 INIT_NONTER_S := TERM_LIST.R_UNION( INIT_NONTER_S,			--| MENTIONNER DANS	LA LISTE DES NON TERMINAUX
			LIST( D( XD_INIT_NONTER_S, D(	XD_RULEINFO, RULE )	) )
			      );
	         end if;
	       end;
	     end if;
	   end if;
	 end;
         end loop;
       end FIND_RULES_FOR_CLOSURE;

INSERT_RULES_IN_CLOSURE:								--| PORTER LES ALTERNATIVES DES RÈGLES TROUVEES DANS DES ITEMS CONSTITUANT LA FERMETURE
       declare
         RULE		: TREE;
       begin
         while not IS_EMPTY( INIT_NONTER_S ) loop						--| TANT QU'IL Y A DES RÈGLES
	 POP( INIT_NONTER_S, RULE );							--| EN EXTRAIRE UNE
	 declare
	   ALTERNATIVE_S	: SEQ_TYPE := LIST(	RULE );					--| PRENDRE LA LISTE DE SES ALTERNATIVES
	   ALTERNATIVE	: TREE;
	 begin
	   while not IS_EMPTY( ALTERNATIVE_S ) loop					--| TANT QU'IL Y A DES ALTERNATIVES
	     POP(	ALTERNATIVE_S, ALTERNATIVE );						--| EN EXTRAIRE UNE
	     ITEM_SEQ := APPEND( ITEM_SEQ,						--| PEFIXER À LA LISTE D'ITEMS
			MAKE_ITEM( ALTERNATIVE, LIST(	ALTERNATIVE ), 0 )			--| UN NOUVEL ITEM POUR CETTE	ALTERNATIVE
			);
	   end loop;
	 end;
         end loop;
       end INSERT_RULES_IN_CLOSURE;

     end FORM_CLOSURE;
     --|--------------------------------------------------------------------------------------------
     --|		PROCEDURE	MAKE_NEW_STATE
     function MAKE_NEW_STATE ( FROM_INDEX :INTEGER ) return	TREE is
       II			: INTEGER		:= INDEX(	FROM_INDEX ).F;
       STATE		: TREE		:= MAKE_STATE;				--| FABRIQUER UN ETAT
       NEW_ITEM_SEQ		: SEQ_TYPE	:= (TREE_NIL,TREE_NIL);			--| LISTE	D'ITEMS VIDE
     begin
       while II /= 0 loop
         declare
	 OLD_ITEM		: TREE		:= CHAIN(	II ).T;
	 OLD_TAIL		: SEQ_TYPE	:= LIST( OLD_ITEM );
	 NEW_ITEM		: TREE		:= MAKE_ITEM(
				D( XD_ALTERNATIVE, OLD_ITEM ),			--| POUR L'ALTERNATIVE DE L'ITEM PÈRE
				TAIL( OLD_TAIL ),					--| AVEC LE RESTE DE LA LISTE	DE SYLLABES
				DI( XD_SYL_NBR, OLD_ITEM) + 1				--| UN N°	DE SYLLABE INCREMENTE DE 1
				);
         begin
	 NEW_ITEM_SEQ := APPEND( NEW_ITEM_SEQ, NEW_ITEM );				--| PREFIXER L'ITEM	À LA LISTE
	 II := CHAIN( II ).N;							--| INDICE D'ITEM SUIVANT
         end;
       end loop;

       FORM_CLOSURE( NEW_ITEM_SEQ );							--| CALCULER LA FERMETURE DES	ITEMS MIS	EN LISTE
       LIST( STATE,	NEW_ITEM_SEQ );							--| AJOUTER L'ETAT À LA LISTE	D'ETATS
       return STATE;
     end;
    --|---------------------------------------------------------------------------------------------
    --|		PROCEDURE	MAKE_STATES
    procedure MAKE_STATES is
      FROM_STATE		: TREE;
      FROM_NBR		: INTEGER;
      FROM_ITEM_SEQ		: SEQ_TYPE;
      FROM_ITEM		: TREE;
      FROM_INDEX		: INTEGER;

      --|-------------------------------------------------------------------------------------------
      --|		PROCEDURE	ITEM_INDEX
      function ITEM_INDEX ( IT :TREE ) return INTEGER is
        SYLLABE_S		: SEQ_TYPE	:= LIST( IT );
      begin
        if IS_EMPTY( SYLLABE_S ) then
	return 0;
        else
	declare
	  SYLLABE		: TREE	:= HEAD( SYLLABE_S );
	begin
	  if SYLLABE.TY = DN_TERMINAL	then						--| SYLLABE TERMINALE
	    return - DI( XD_TER_NBR, SYLLABE );						--| OPPOSE DU N° DE	TERMINAL
	  else									--| NON TERMINALE
	    declare
	      RULE : TREE	:= D( XD_RULE, SYLLABE );					--| RÈGLE	DE DEFINITION
	    begin
	      if RULE.TY = DN_VOID then						--| PAS DE RÈGLE DE	DEFINITION
	        return 0;								--| N° 0
	      else								--| RÈGLE	PRESENTE
	        return DI( XD_RULE_NBR, D( XD_RULEINFO, RULE ) );				--| LE N°	DE RÈGLE
	      end	if;
	    end;
	  end if;
	end;
        end if;
      end	ITEM_INDEX;
      --|-------------------------------------------------------------------------------------------
      --|		PROCEDURE	CALCULATE_GOTO
      procedure CALCULATE_GOTO is
        TO_STATE		: TREE		:= TREE_VOID;
        FROM_ALT		: TREE		:= D( XD_ALTERNATIVE, FROM_ITEM );
        POSSIBLE_TO		: TREE;
        TEMP_ITEM		: TREE;
        HASH_CODE		: INTEGER		:= 0;
        HASH_DELTA		: INTEGER		:= 1;
        ELEMENT_COUNT	: INTEGER		:= 0;
        II		: INTEGER;						-- ITEM CHAIN NUMBER

        --|-----------------------------------------------------------------------------------------
        --|	PROCEDURE	CHECK_POSSIBLE_TO
        function CHECK_POSSIBLE_TO ( FROM_INDEX :INTEGER; POSSIBLE_TO	:TREE ) return BOOLEAN is
	II		: INTEGER		:= INDEX(	FROM_INDEX ).F;
	NEW_ITEM_SEQ	: SEQ_TYPE	:= LIST (	POSSIBLE_TO );
	OLD_ITEM		: TREE;
	NEW_ITEM		: TREE;
        begin
	loop
	  if IS_EMPTY( NEW_ITEM_SEQ )							--| PLUS D'ITEM
	     or else DI( XD_SYL_NBR, ( HEAD( NEW_ITEM_SEQ	) ) ) = 0				--| OU PLUS DE SYLLABE
	  then
	    return II = 0;
	  end if;
	  if II =	0 then
	    return FALSE;
	  end if;
	  OLD_ITEM := CHAIN( II ).T;
	  NEW_ITEM := HEAD ( NEW_ITEM_SEQ );
	  if D( XD_ALTERNATIVE, OLD_ITEM ) /= D( XD_ALTERNATIVE, NEW_ITEM )
	     or else DI( XD_SYL_NBR,OLD_ITEM) +1 /= DI( XD_SYL_NBR,	NEW_ITEM )
	  then
	    return FALSE;
	  end if;
	  II := CHAIN( II ).N;
	  NEW_ITEM_SEQ := TAIL( NEW_ITEM_SEQ );
	end loop;
        end CHECK_POSSIBLE_TO;

      begin
        II := INDEX( FROM_INDEX ).F;
        while II /=	0 loop
	ELEMENT_COUNT := ELEMENT_COUNT + 1;
	TEMP_ITEM	:= CHAIN(	II ).T;
	HASH_CODE	:= abs(
			HASH_CODE
		 - 28 * DI( XD_ALT_NBR, D( XD_ALTERNATIVE, TEMP_ITEM ) )
		 - 3  * DI( XD_SYL_NBR, TEMP_ITEM )
		 - 11 * ELEMENT_COUNT
		 );
	 II := CHAIN( II ).N;
        end loop;
        HASH_CODE := HASH_CODE mod HASH_SIZE;

        while HASH(	HASH_CODE	) /= TREE_VOID loop
	POSSIBLE_TO := HASH( HASH_CODE );
	if CHECK_POSSIBLE_TO( FROM_INDEX, POSSIBLE_TO ) then
	  TO_STATE := POSSIBLE_TO;
	  exit;
	end if;
	if HASH_DELTA >= HASH_SIZE then
	  PUT_LINE( "HASH TABLE OVERFLOW." );
	  raise PROGRAM_ERROR;
	end if;
	HASH_CODE	:= (HASH_CODE + HASH_DELTA) mod HASH_SIZE;
	HASH_DELTA := HASH_DELTA + 2;						-- SO HASH_CODE INCREASES BY N ** 2
        end loop;

        if TO_STATE	= TREE_VOID then			-- DIDN'T	FIND ONE
	TO_STATE := MAKE_NEW_STATE ( FROM_INDEX	);
	HASH( HASH_CODE ) := TO_STATE;
        end if;
		    -- INSERT NEW STATE AS GOTO FOR ALL	RULES WITH GIVEN NEXT SYMBOL
        II := INDEX( FROM_INDEX ).F;
        while II /=	0 loop
	FROM_ITEM	:= CHAIN(	II ).T;
	D( XD_GOTO, FROM_ITEM, TO_STATE );
	II := CHAIN( II ).N;
        end loop;
      end	CALCULATE_GOTO;

    begin
      while not IS_EMPTY( WORK_LIST ) loop
        POP( WORK_LIST, FROM_STATE );
        FROM_NBR :=	DI( XD_STATE_NBR, FROM_STATE );
        if STATE_COUNT mod 20	= 0 then
	PUT( '*');
        end if;
		    -- CONSTRUCT CHAIN STRUCTURE FOR THIS STATE
        CHAIN_LAST := 0;
        FROM_ITEM_SEQ := LIST( FROM_STATE );
        while not IS_EMPTY( FROM_ITEM_SEQ ) loop
	POP( FROM_ITEM_SEQ,	FROM_ITEM	);

	FROM_INDEX := ITEM_INDEX( FROM_ITEM );
	if FROM_INDEX /= 0 then
	  CHAIN_LAST := CHAIN_LAST + 1;
	  declare
	    CHAIN_I	: CHAIN_TYPE renames CHAIN(CHAIN_LAST);
	    INDEX_I	: INDEX_TYPE renames INDEX(FROM_INDEX);
	  begin
	    if INDEX_I.TIME	/= FROM_NBR then
	      INDEX_I := (TIME=> FROM_NBR, F=> CHAIN_LAST, L=> CHAIN_LAST);
	      CHAIN_I := (N=> 0, T=> FROM_ITEM,	FIRST=> TRUE);
	    else
	      CHAIN( INDEX_I.L ).N :=	CHAIN_LAST;
	      CHAIN_I := (N=> 0, T=> FROM_ITEM,	FIRST=> FALSE);
	    end if;
	    INDEX_I.L := CHAIN_LAST;
	  end;
	end if;
        end loop;

        for CH in 1	.. CHAIN_LAST loop
	if CHAIN(	CH ).FIRST then
	  FROM_ITEM := CHAIN( CH ).T;
	  FROM_INDEX := ITEM_INDEX( FROM_ITEM );
	  CALCULATE_GOTO;
	end if;
        end loop;

      end	loop;
    end MAKE_STATES;

  begin

    declare
      RULE_S		: SEQ_TYPE	:= GR_RULE_S;
      RULE		: TREE		:= HEAD( GR_RULE_S );			--| PREMIÈRE RÈGLE
      ALTERNATIVE_S		: SEQ_TYPE	:= LIST( RULE );				--| SA LISTE D'ALTERNATIVES
      ALTERNATIVE		: TREE		:= HEAD( ALTERNATIVE_S );			--| LA PREMIÈRE ALTERNATIVE
      SYLLABE_S		: SEQ_TYPE	:= LIST( ALTERNATIVE );			--| SA LISTE DE SYLLABES
      ITEM_SEQ		: SEQ_TYPE	:= APPEND( (TREE_NIL,TREE_NIL),		--| METTRE EN LISTE
					     MAKE_ITEM( ALTERNATIVE, SYLLABE_S,	0 )	--| LE PREMIER ITEM
						);
    begin
      LIST( DUMMY_FOLLOW, (TREE_NIL,TREE_NIL) );						--| METTRE UNE LISTE VIDE DANS LE SUIVI
      FORM_CLOSURE(	ITEM_SEQ );							--| CALCULER LA FERMETURE DU PREMIER ITEM
      LIST( MAKE_STATE, ITEM_SEQ );							--| FABRIQUER UN PREMIER ETAT	AVEC L'ITEM INTERESSANT L'ALTERNATIVE 1	DE LA RÈGLE 1
    end;

    MAKE_STATES;

    declare
      STATE_S	: TREE	:= MAKE( DN_STATE_S	);					--| FABRIQUER UN ACCÈS POUR LA LISTE D'ETAT
    begin
      LIST( STATE_S, STATE_SEQ );							--| Y PORTER LA LISTE CONSTITUEE
      D( XD_STATELIST, USER_ROOT, STATE_S );						--| METTRE DANS LA LISTE DE LA STRUCTURE DE DONNEES
    end;
  end;

  CLOSE_IDL_TREE_FILE;
end STAT_GRMR;
