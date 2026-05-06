------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

separate(	IDL )
--|--------------------------------------------------------------------------------------------------
--|		INIT_GRMR
--|--------------------------------------------------------------------------------------------------
procedure	INIT_GRMR	( NOM_TEXTE :STRING	) is
  use  TERM_LIST;

  GRAMMAR		: TREE;
  GR_RULE_SEQ	: SEQ_TYPE;

  MORE_PASSES	: BOOLEAN;							--| INDIQUE DES CHANGEMENTS DANS LA FERMETURE TRANSITIVE
  PASS		: INTEGER		:= 0;

  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE	INITIALIZE
  procedure INITIALIZE is
    RULE_SEQ		: SEQ_TYPE	:= GR_RULE_SEQ;
    RULE			: TREE;
    RULE_INIT_LIST		: SEQ_TYPE;
    RULEINFO		: TREE;
    ALT_SEQ		: SEQ_TYPE;
    ALT			: TREE;
    SYL_SEQ		: SEQ_TYPE;
    SYL			: TREE;
    IS_NULLABLE		: BOOLEAN;						-- CURRENT RULE HAS	NULLABLE ALT
    GENS_TER_STR		: BOOLEAN;						-- CURRENT RULE HAS	TERMINAL ALT
    NONTER_NAME		: TREE;							-- SYMBOL_REP OF NON-TERMINAL
    NONTER_DEF_LIST		: SEQ_TYPE;
    RULE_COUNT		: INTEGER	:= 0;
    INIT_NONTER_S		: TREE;
  begin
    while	not IS_EMPTY( RULE_SEQ ) loop							--| TANT QU'IL Y A DES RÈGLES
      POP( RULE_SEQ, RULE );								--| EN EXTRAIRE UNE
      RULE_COUNT :=	RULE_COUNT + 1;							--| UNE DE PLUS VUE

      RULE_INIT_LIST := (TREE_NIL, TREE_NIL);
      RULEINFO	:= MAKE( DN_RULEINFO );						--| FABRIQUER SON INFO
      INIT_NONTER_S	:= MAKE( DN_RULE_S );						--| FABRIQUER UNE LISTE DE RÈGLES
      LIST( INIT_NONTER_S, INSERT ( (TREE_NIL, TREE_NIL), RULE ) );				--| Y METTRE LA RÈGLE
      D  ( XD_INIT_NONTER_S, RULEINFO, INIT_NONTER_S );					--| PORTER CELA DANS L'INFO
      DB ( XD_IS_REACHABLE,  RULEINFO, FALSE );						--| METTRE REACHABLE À FAUX
      DI ( XD_RULE_NBR,      RULEINFO, RULE_COUNT	);					--| Y PORTER LE N° DE RÈGLE
      DI ( XD_TIMECHANGED,   RULEINFO, 0 );						--| METTRE À 0 TIMECHANGED
      DI ( XD_TIMECHECKED,   RULEINFO, 0 );						--| ET TIMECHECKED
      D  ( XD_RULEINFO, RULE,	RULEINFO );						--| POINTER L'INFO DANS LA RÈGLE
      IS_NULLABLE := FALSE;
      GENS_TER_STR := FALSE;

      ALT_SEQ := LIST( RULE );							--| PRENDRE LA LISTE D'ALTERNATIVES
      while not IS_EMPTY( ALT_SEQ ) loop						--| TANT QU'IL Y A DES ALTERNATIVES
        POP( ALT_SEQ, ALT );								--| EN EXTRAIRE UNE
        D	 ( XD_RULE, ALT, RULE );							--| MENTIONNER LA RÈGLE QUI LA CONTIENT
        declare
	ALT_NOT_NULLABLE	: BOOLEAN	:= FALSE;
	ALT_NOT_GEN_TER_STR	: BOOLEAN	:= FALSE;
        begin
	SYL_SEQ := LIST( ALT );							--| PRENDRE LA LISTE DE SYLLABES DE L'ALTERNATIVE
	if not IS_EMPTY( SYL_SEQ ) then						--| S'IL Y A DES SYLLABES
	  SYL := HEAD( SYL_SEQ );							--| PRENDRE LA TÊTE
	  if SYL.TY = DN_TERMINAL then						--| SI C'EST UN TERMINAL
	    RULE_INIT_LIST := UNION( RULE_INIT_LIST, SYL );				--| L'AJOUTER À LA LISTE DES TÊTES TERMINALES D'ALTERNATIVES
	  end if;
	  while not IS_EMPTY( SYL_SEQ	) loop						--| TANT QU'IL Y A DES SYLLABES
	    POP( SYL_SEQ, SYL );							--| EN EXTRAIRE UNE
	    if SYL.TY = DN_TERMINAL then						--| SI C'EST UN TERMINAL
	      ALT_NOT_NULLABLE := TRUE;						--| INDIQUER NON ANNULABLE
	    else									--| C'EST	UN NON TERMINAL
	      NONTER_NAME := D( XD_SYMREP, SYL );
	      NONTER_DEF_LIST := LIST( NONTER_NAME );
	      while not IS_EMPTY( NONTER_DEF_LIST ) and then HEAD( NONTER_DEF_LIST).TY /= DN_RULE	loop
	        NONTER_DEF_LIST := TAIL( NONTER_DEF_LIST );
	      end	loop;
	      if IS_EMPTY( NONTER_DEF_LIST ) then
	        ERROR( D( LX_SRCPOS, SYL ), "NON-TERMINAL NOT DEFINED - " & PRINT_NAME(	NONTER_NAME ) );
	        D( XD_RULE,	SYL, TREE_VOID );
	        ALT_NOT_NULLABLE := TRUE;
	      else
	        D( XD_RULE,	SYL, HEAD( NONTER_DEF_LIST ) );				-- ASSUME	THE WORST	ABOUT THE	NON-TERMINAL FOR NOW
	        ALT_NOT_NULLABLE    := TRUE;
	        ALT_NOT_GEN_TER_STR := TRUE;
	      end	if;
	    end if;
	  end loop;
	end if;
	if not ALT_NOT_NULLABLE then
	  IS_NULLABLE := TRUE;
	end if;
	if not ALT_NOT_GEN_TER_STR then
	  GENS_TER_STR := TRUE;
	end if;
        end;
      end	loop;

      LIST( RULEINFO,RULE_INIT_LIST );
      DB	( XD_GENS_TER_STR, RULEINFO, GENS_TER_STR );
      DB	( XD_IS_NULLABLE, RULE, IS_NULLABLE );
    end loop;
	      -- FIRST RULE	IS ALWAYS	REACHABLE
    DB( XD_IS_REACHABLE, D( XD_RULEINFO, HEAD( GR_RULE_SEQ ) ), TRUE );
  end INITIALIZE;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE	TRANS_CLOSE
  procedure TRANS_CLOSE is
    RULE_SEQ		: SEQ_TYPE	:= GR_RULE_SEQ;
    RULE			: TREE;
    RULE_INIT_LIST		: SEQ_TYPE;
    RULEINFO		: TREE;
    ALT_SEQ		: SEQ_TYPE;
    ALT			: TREE;
    SYL_SEQ		: SEQ_TYPE;
    SYL			: TREE;
    IS_NULLABLE		: BOOLEAN;						-- CURRENT RULE HAS	NULLABLE ALT
    IS_REACHABLE		: BOOLEAN;						-- CURRENT RULE IS REACHABLE
    GENS_TER_STR		: BOOLEAN;						-- CURRENT RULE HAS	TERMINAL ALT
    ALT_NOT_NULLABLE	: BOOLEAN;						-- ALT FOUND TO BE NOT NULLABLE
    ALT_NOT_GEN_TER_STR	: BOOLEAN;
	      -- ALT FOUND TO BE NOT TERMINALN
    NONTER_RULE		: TREE;
    NONTER_INFO		: TREE;
    TIMECHANGED		: INTEGER;
    TIMECHECKED		: INTEGER;
    NONTER_CHANGED		: INTEGER;
    CHANGE_FLAG		: BOOLEAN;						-- RULE CHANGED IN THIS PASS
    INIT_NONTER_S		: TREE;
    INIT_NONTER_SEQ		: SEQ_TYPE;

  begin
    while	not IS_EMPTY( RULE_SEQ ) loop
      RULE     := HEAD( RULE_SEQ );
      RULE_SEQ := TAIL( RULE_SEQ );

      RULEINFO := D( XD_RULEINFO, RULE );
      TIMECHANGED := DI( XD_TIMECHANGED, RULEINFO	);
      TIMECHECKED := DI( XD_TIMECHECKED, RULEINFO	);
      DI(	XD_TIMECHECKED, RULEINFO, PASS );

      RULE_INIT_LIST := LIST(	RULEINFO );
      IS_REACHABLE	 := DB( XD_IS_REACHABLE, RULEINFO );
      IS_NULLABLE	 := FALSE;							-- WE'LL SEE IF IT CHANGES
      GENS_TER_STR	 := DB( XD_GENS_TER_STR, RULEINFO );
      INIT_NONTER_S	 := D( XD_INIT_NONTER_S, RULEINFO );
      INIT_NONTER_SEQ:= LIST(	INIT_NONTER_S );
      CHANGE_FLAG := FALSE;

      ALT_SEQ := LIST( RULE );
      while not IS_EMPTY( ALT_SEQ ) loop
        POP( ALT_SEQ, ALT );

        ALT_NOT_NULLABLE   :=	FALSE;
        ALT_NOT_GEN_TER_STR:=	FALSE;
        SYL_SEQ	       :=	LIST ( ALT);
        if not IS_EMPTY( SYL_SEQ ) then
	SYL := HEAD( SYL_SEQ );
	if SYL.TY	= DN_NONTERMINAL then
	  NONTER_RULE := D(	XD_RULE, SYL );
	  if NONTER_RULE.TY	/= DN_VOID then
	    INIT_NONTER_SEQ	:= R_UNION( INIT_NONTER_SEQ, LIST( D( XD_INIT_NONTER_S, D( XD_RULEINFO, NONTER_RULE ) ) )	);
	  end if;
	end if;
        end if;
        while not IS_EMPTY( SYL_SEQ ) loop
	POP( SYL_SEQ, SYL );
	if SYL.TY	= DN_TERMINAL then
	  if not ALT_NOT_NULLABLE then
	    ALT_NOT_NULLABLE := TRUE;
	    if TIMECHANGED >= TIMECHECKED then
						-- OTHERWISE ALREADY DONE
	      RULE_INIT_LIST := UNION( RULE_INIT_LIST, SYL );
	    end if;
	  end if;
	else -- SINCE IT'S DN_NONTERMINAL
	  NONTER_RULE := D(	XD_RULE, SYL );
	  if NONTER_RULE.TY	= DN_VOID	then
	    ALT_NOT_NULLABLE := TRUE;
	  else
	    NONTER_INFO := D( XD_RULEINFO, NONTER_RULE );
	    NONTER_CHANGED := DI( XD_TIMECHANGED, NONTER_INFO );
	    if TIMECHANGED >= TIMECHECKED and then IS_REACHABLE and	then not DB( XD_IS_REACHABLE,	NONTER_INFO ) then
	      MORE_PASSES := TRUE;
	      DB(	XD_IS_REACHABLE, NONTER_INFO,	TRUE);
	      DI(	XD_TIMECHANGED, NONTER_INFO, PASS );
	    end if;
	    if not ALT_NOT_NULLABLE then
	      if not DB( XD_IS_NULLABLE, NONTER_RULE ) then
	        ALT_NOT_NULLABLE := TRUE;
	      else
	        if NONTER_CHANGED > TIMECHANGED	then
								-- KEEP LOOKING IF NONTER BECAME NULLABLE
		TIMECHANGED := NONTER_CHANGED;
	        end if;
	      end	if;
	      if NONTER_CHANGED >= TIMECHECKED then
	        RULE_INIT_LIST := UNION ( RULE_INIT_LIST,	LIST ( NONTER_INFO ) );
	      end	if;
	    end if;
	    if not ALT_NOT_GEN_TER_STR and then	not GENS_TER_STR and then not	DB ( XD_GENS_TER_STR, NONTER_INFO ) then
	      ALT_NOT_GEN_TER_STR := TRUE;
	    end if;
	  end if;
	end if;
	exit when	ALT_NOT_NULLABLE and then GENS_TER_STR and then TIMECHANGED	< TIMECHECKED;
        end loop;
        if not ALT_NOT_NULLABLE then
	IS_NULLABLE := TRUE;
        end if;
        if not ALT_NOT_GEN_TER_STR then
	GENS_TER_STR := TRUE;
        end if;
      end	loop;

      if not SAME (	LIST ( RULEINFO ), RULE_INIT_LIST ) then
        LIST ( RULEINFO, RULE_INIT_LIST	);
        CHANGE_FLAG	:= TRUE;
      end	if;
      if not SAME (	LIST ( INIT_NONTER_S), INIT_NONTER_SEQ ) then
        LIST ( INIT_NONTER_S,	INIT_NONTER_SEQ );
        CHANGE_FLAG	:= TRUE;
      end	if;
      if GENS_TER_STR and then not DB (	XD_GENS_TER_STR, RULEINFO ) then
        DB ( XD_GENS_TER_STR,	RULEINFO,	TRUE );
        CHANGE_FLAG	:= TRUE;
      end	if;
      if IS_NULLABLE and then	not DB ( XD_IS_NULLABLE, RULE	) then
        DB ( XD_IS_NULLABLE, RULE, TRUE	);
        CHANGE_FLAG	:= TRUE;
      end	if;
      if CHANGE_FLAG then
        DI ( XD_TIMECHANGED, RULEINFO, PASS );
        MORE_PASSES	:= TRUE;
      end	if;
    end loop;
  end TRANS_CLOSE;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE	CHECK_GRAMMAR
  procedure CHECK_GRAMMAR is
    RULE_SEQ	: SEQ_TYPE	:= GR_RULE_SEQ;
    RULE		: TREE;
    RULEINFO	: TREE;
  begin
    while	not IS_EMPTY( RULE_SEQ ) loop
      POP( RULE_SEQ, RULE );
      RULEINFO := D( XD_RULEINFO, RULE );
      if not DB( XD_IS_REACHABLE, RULEINFO ) then
        ERROR( D( LX_SRCPOS,RULE ), "RULE CANNOT BE REACHED - " & PRINT_NAME( D( XD_NAME,	RULE ) ) );
      end	if;
      if not DB( XD_GENS_TER_STR, RULEINFO ) then
        ERROR( D( LX_SRCPOS,RULE ), "DOES NOT GEN TERMINAL STRING - "	& PRINT_NAME( D( XD_NAME, RULE ) ) );
      end	if;
    end loop;
  end CHECK_GRAMMAR;

begin

  PUT_LINE( "INITIALIZE.");
  declare
    USER_ROOT	: TREE;
  begin
    OPEN_IDL_TREE_FILE( NOM_TEXTE & ".lar" );
    USER_ROOT := D(	XD_USER_ROOT, TREE_ROOT );
    GRAMMAR   := D(	XD_GRAMMAR, USER_ROOT );
  end;

  GR_RULE_SEQ := LIST( GRAMMAR );
  INITIALIZE;

  loop
    PASS := PASS + 1;
    PUT (	"BEGIN TRANS CLOSE PASS " );
    INT_IO.PUT ( PASS, 1 );
    PUT_LINE ( "." );
    MORE_PASSES := FALSE;
    TRANS_CLOSE;
    exit when not MORE_PASSES;
  end loop;

  PUT_LINE ( "CHECK GRAMMAR."	);
  CHECK_GRAMMAR;

  CLOSE_IDL_TREE_FILE;
--|--------------------------------------------------------------------------------------------------
end INIT_GRMR;
