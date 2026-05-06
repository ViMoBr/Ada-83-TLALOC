------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

separate(	IDL )
--|--------------------------------------------------------------------------------------------------
--|		OPTR_GRMR
--|--------------------------------------------------------------------------------------------------
procedure	OPTR_GRMR	( NOM_TEXTE :STRING	) is
  GRAMMAR		: TREE;
  GR_RULE_S	: SEQ_TYPE;

  type RTBL_TYPE	is record
		  RULE		: TREE;						--| ACCÈS	À UNE RÈGLE
		  REPLACEMENT	: TREE;						--| RÈGLE	REMPLAÇANTE
		  USE_COUNT	: INTEGER;					--| NOMBRE D'USAGES	DE LA RÈGLE
		  IS_ONE_ALT	: BOOLEAN;					--| RÈGLE	À UNE SEULE ALTERNATIVE
		end record;
  RTBL		: array( 1 .. 350) of RTBL_TYPE;					--| TABLE	D'ACCÈS AUX RÈGLES ET INFORMATIONS
  LAST_RULE_NBR	: INTEGER	:= 0;							--| NOMBRE DE RÈGLES

  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE	FIRST_PASS
  procedure FIRST_PASS is								--| REMPLACE LES RÈGLES MONO-ALTERNATIVE ET MONO-SYLLABES PAR LA RÈGLE ÉVENTUELLE DE LA SYLLABE
    RULE_S	: SEQ_TYPE	:= GR_RULE_S;
    RULE		: TREE;

    --|----------------------------------------------------------------------------------------
    --|	PROCEDURE	PROPAGATE_REPLACEMENT
    procedure PROPAGATE_REPLACEMENT ( I, LIM :INTEGER ) is
    begin
      if LIM <= 0 then								--| SI L'ON A CELA C'EST QUE L'ON A PLUS DE REMPLAÇANTES DE	REMPLAÇANTE QUE DE RÈGLES !
        ERROR( D( LX_SRCPOS, RTBL( I ).RULE ), "CIRCULAR REPLACEMENT"	);			--| DONC ON TOURNE EN ROND
      else
        if RTBL( I ).REPLACEMENT.TY = DN_RULE then
	declare
	  J : INTEGER	 := DI( XD_RULEINFO, RTBL( I ).REPLACEMENT );			--| NUMÉRO DE LA RÈGLE REMPLAÇANTE
	begin
	  if RTBL( J ).REPLACEMENT.TY	= DN_RULE	then					--| SI LA	REMPLAÇANTE A AUSSI	UNE REMPLAÇANTE
	    PROPAGATE_REPLACEMENT( J,	LIM - 1 );					--| ALLER	CHERCHER PLUS LOIN (EN INDIQUANT LE NOMBRE DE FOIS MAX OÙ L'ON PEUT FAIRE CELA)
	    RTBL(	I ).REPLACEMENT := RTBL( J ).REPLACEMENT;				--| METTRE LA REMPLAÇANTE DE LA REMPLAÇANTE COMME	REMPLAÇANTE (!)
	  end if;
	end;
        end if;
      end	if;
    end;

  begin
    while	not IS_EMPTY( RULE_S ) loop							--| TANT QU'IL Y A DES RÈGLES
      POP( RULE_S, RULE );								--| EN EXTRAIRE UNE
      LAST_RULE_NBR	:= LAST_RULE_NBR + 1;						--| UNE RÈGLE DE PLUS
      DI(	XD_RULEINFO, RULE, LAST_RULE_NBR );						--| STOCKER LE NUMÉRO DE RÈGLE

      declare
        ALTERNATIVE_S	: SEQ_TYPE	:=  LIST(	RULE );
        IS_ONE_ALT		: BOOLEAN	:= IS_EMPTY( TAIL( ALTERNATIVE_S ) );			--| INDIQUE SI NE CONTIENT QU'UNE ALTERNATIVE (QUEUE DE LA LISTE D'ALTERNATIVES	VIDE)
      begin
        RTBL( LAST_RULE_NBR )	:= (
			RULE		=> RULE,					--| STOCKER L'ACCÈS	À CETTE RÈGLE DANS LA TABLE DES RÈGLES
			REPLACEMENT	=> TREE_VOID,				--| PAS DE REMPLAÇANTE
			USE_COUNT		=> 0,					--| PAS D'USAGE
			IS_ONE_ALT	=> IS_ONE_ALT				--| INDIQUE SI NE CONTIENT QU'UNE ALTERNATIVE
			);

        if IS_ONE_ALT then								--| ON NE	CONSIDÈRE	QUE LA CAS MONO ALTERNATIVE
	declare
	  SYLLABE_S	: SEQ_TYPE	:= LIST( HEAD( ALTERNATIVE_S ) );		--| LISTE	DES SYLLABES DE L'UNIQUE ALTERNATIVE
	begin
	  if not IS_EMPTY( SYLLABE_S )						--| S'IL Y A DES SYLLABES
	     and then IS_EMPTY( TAIL(	SYLLABE_S	) )					--| ET S'IL N'Y EN A QU'UNE
	     and then IS_EMPTY( LIST(	D( XD_SEMANTICS, HEAD( ALTERNATIVE_S ) ) ) )		--| ET ELLE N'A PAS	D'ACTION SÉMANTIQUE
	  then
	    declare
	      SYLLABE	: TREE	:= HEAD( SYLLABE_S );
	    begin
	      if SYLLABE.TY	/= DN_TERMINAL then						--| LA SYLLABE EST TERMINALE
	        declare
		DEF_LIST : SEQ_TYPE	:= LIST( D( XD_SYMREP, SYLLABE ) );			--| LISTE	DES UTILISATIONS DU	SYMBOLE DE SYLLABE
	        begin
		while not	IS_EMPTY(	DEF_LIST )					--| TANT QU'IL Y A DES UTIISATIONS
		      and	then HEAD( DEF_LIST	).TY /= DN_RULE loop			--| ET QUE CE N'EST	PAS LA RÈGLE DE DÉFINITION
		  DEF_LIST := TAIL(	DEF_LIST );					--| AVANCER SUR LA LISTE DES UTILISATIONS
		end loop;
		if not IS_EMPTY( DEF_LIST ) then					--| SI L'ON A TROUVÉ UNE RÈGLE DE DÉFINITION
		  RTBL( LAST_RULE_NBR ).REPLACEMENT := HEAD( DEF_LIST );			--| METTRE CETTE RÈGLE COMME REMPLAÇANTE DE LA RÈGLE MONO-ALTERNATIVE	MONO-SYLLABE
		  D( XD_RULE, SYLLABE, HEAD( DEF_LIST )	);				--| MENTIONNER AUSSI DANS LA SYLLABE
		else
		  D( XD_RULE, SYLLABE, TREE_VOID );					--| S'IL N'Y A PAS DE RÈGLE DE DÉFINITION, METTRE	UN ACCÈS VIDE
		end if;
	        end;
	      end	if;
	    end;
	  end if;
	end;
        end if;
      end;
    end loop;

    for I	in 1 .. LAST_RULE_NBR loop							--| BALAYER TOUTES LES RÈGLES
      PROPAGATE_REPLACEMENT( I, LAST_RULE_NBR );						--| POUR PRENDRE LES REMPLAÇANTES DE REMPLAÇANTES
    end loop;
  end FIRST_PASS;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE	SECOND_PASS
  procedure SECOND_PASS is								--| CHANGE LA DÉFINITION D'UNE SYLLABE SI CELLE-CI EST REMPLACÉE
  begin
    for I	in 1 .. LAST_RULE_NBR loop							--| PASSER EN REVUE	TOUTES LES RÈGLES
      declare
        RTBL_I	: RTBL_TYPE renames	RTBL( I );
      begin
        if RTBL_I.REPLACEMENT.TY /= DN_RULE then						--| LA RÈGLE N'A PAS DE REMPLAÇANTE (PAS TRAITÉE À LA PASSE	1)
	declare
	  ALTERNATIVE_S	: SEQ_TYPE	:= LIST( RTBL_I.RULE );			--| PRENDRE SA LISTE D'ALTERNATIVES
	  ALTERNATIVE	: TREE;
	  SYLLABE_S	: SEQ_TYPE;
	  SYLLABE	: TREE;
	begin
	  while not IS_EMPTY( ALTERNATIVE_S ) loop					--| S'IL Y A DES ALTERNATIVES
	    POP( ALTERNATIVE_S, ALTERNATIVE );						--| EXTRAIRE LA LISTE DE SES SYLLABES
	    SYLLABE_S := LIST( ALTERNATIVE );

	    while	not IS_EMPTY( SYLLABE_S ) loop					--| TANT QU'IL Y A DES SYLLABES
	      POP( SYLLABE_S, SYLLABE	);						--| EN EXTRAIRE UNE
	      if SYLLABE.TY	= DN_NONTERMINAL then					--| SI C'EST UNE NON TERMINALE
	        declare
		RULE	: TREE	:= TREE_VOID;
	        begin
		declare
		  DEFLIST	: SEQ_TYPE  := LIST( D( XD_SYMREP, SYLLABE ) );			--| PRENDRE LA LISTE DES UTILISATIONS DE SON SYMBOLE
		begin
		  while not IS_EMPTY( DEFLIST	)					--| TANT QU'IL Y A DES UTILISATIONS
		    and then HEAD( DEFLIST).TY /= DN_RULE loop				--| ET QUE CE N'EST	PAS UNE RÈGLE DE DÉFINITION
		    DEFLIST := TAIL( DEFLIST );					--| AVANCER SUR LA LISTE DES UTILISATIONS
		  end loop;

		  if not IS_EMPTY( DEFLIST ) then					--| SI L'ON A TROUVÉ UNE RÈGLE DE DÉFINITION
		    RULE := HEAD( DEFLIST );						--| PRENDRE CETTE RÈGLE DE DÉFINITION
		  end if;
		end;
		D( XD_RULE, SYLLABE, RULE );						--| MENTIONNER LA RÈGLE (OU LE VIDE) DE	DÉFINITION DE LA SYLLABE
		if RULE.TY /= DN_VOID then						--| S'IL Y A EFFECTIVEMENT UNE RÈGLE DE	DÉFINITION
		  declare
		    J	 : INTEGER	:= DI( XD_RULEINFO,	RULE );			--| PRENDRE SON NUMÉRO
		    RTBL_J : RTBL_TYPE	renames RTBL( J );
		  begin
		    if RTBL_J.REPLACEMENT.TY /= DN_VOID	then				--| SI LA	RÈGLE DE DÉFINITION	A UNE REMPLAÇANTE
		      D( XD_SYMREP,	SYLLABE, D( XD_NAME, RTBL_J.REPLACEMENT	) );		--| METTRE LE SYMBOLE DE CETTE REMPLAÇANTE COMME SYMBOLE DE	LA SYLLABE
		      D( XD_RULE, SYLLABE, RTBL_J.REPLACEMENT );				--| METTRE LA RÈGLE	REMPLAÇANTE COMME DÉFINITION DE LA SYLLABE
		      declare
		        K	: INTEGER	:= DI( XD_RULEINFO,	RTBL_J.REPLACEMENT );
		      begin
		        RTBL( K ).USE_COUNT := RTBL( K ).USE_COUNT + 1;			--| INDIQUER QUE LA	REMPLAÇANTE EST UTILISÉE UNE FOIS DE PLUS
		      end;
		    else
		      RTBL_J.USE_COUNT := RTBL_J.USE_COUNT + 1;
		    end if;
		  end;
		end if;
	        end;
	      end	if;
	    end loop;

	  end loop;
	end;
        end if;
      end;
    end loop;
  end SECOND_PASS;
  --|-----------------------------------------------------------------------------------------------
  --|		PROCEDURE	THIRD_PASS
  procedure THIRD_PASS is

    --|---------------------------------------------------------------------------------------------
    --|		PROCEDURE	REPLACE_ALTS
    procedure REPLACE_ALTS ( ALTERNATIVE_S :in out SEQ_TYPE	) is
      ALTERNATIVE		: TREE;
      SYLLABE_S		: SEQ_TYPE;
      SYLLABE		: TREE;
      RULE		: TREE;

      --|-------------------------------------------------------------------------------------------
      --|		FUNCTION CATENATE
      function CATENATE ( A,B: SEQ_TYPE) return SEQ_TYPE is
      begin
        if IS_EMPTY( B ) then
	return A;
        elsif IS_EMPTY( A ) then
	return B;
        else
	return INSERT( CATENATE( TAIL( A ), B ), HEAD( A ) );
        end if;
    end CATENATE;

  begin
    if IS_EMPTY ( ALTERNATIVE_S ) then
      return;
    end if;
    ALTERNATIVE := HEAD ( ALTERNATIVE_S	);					--| EXTRAIRE UNE ALTERNATIVE
    SYLLABE_S := LIST ( ALTERNATIVE);						--| EXTRAIRE LA ISTE DE SES SYLLABES
    if not IS_EMPTY	( SYLLABE_S )						--| S'IL Y A DES SYLLABES
       and then IS_EMPTY( TAIL( SYLLABE_S ) )					--| ET UNE SEULE
       and then IS_EMPTY( LIST( D( XD_SEMANTICS, ALTERNATIVE ) ) )			--| ET SANS ACTION SÉMANTIQUE
    then
      SYLLABE := HEAD( SYLLABE_S);
      if SYLLABE.TY	= DN_NONTERMINAL then
        RULE := D( XD_RULE, SYLLABE);
        if RULE /= TREE_VOID then
				-- IT IS DEFINED (ELSE ERR IN	INITGRMR)
				--@	PUT("CHECKING: "); PUT_LINE(PRINTNAME(D	( XD_NAME,RULE)));
	declare
	  RTBL_I	: RTBL_TYPE renames	RTBL( DI(	XD_RULEINFO, RULE )	);
	begin
	  if RTBL_I.USE_COUNT = 1 then
					      -- IT IS USED	ONCE
	    RTBL_I.REPLACEMENT := TREE_FALSE;
					      -- MARK REPLACED
	    ALTERNATIVE_S := CATENATE( LIST( RTBL_I.RULE ), TAIL( ALTERNATIVE_S ) );
	    REPLACE_ALTS( ALTERNATIVE_S);
	    return;
	  end if;
	end;
        end if;
      end	if;
    end if;
	      -- DID NOT REPLACE; CHECK TAIL
    declare
      ALTERNATIVE_S_TAIL	: SEQ_TYPE	:= TAIL( ALTERNATIVE_S );
      NEW_ALTERNATIVE_S_TAIL	: SEQ_TYPE	:= ALTERNATIVE_S_TAIL;
    begin
      REPLACE_ALTS(	NEW_ALTERNATIVE_S_TAIL );
      if ALTERNATIVE_S_TAIL =	NEW_ALTERNATIVE_S_TAIL then
        return;
      end	if;
      ALTERNATIVE_S	:= INSERT( NEW_ALTERNATIVE_S_TAIL, HEAD( ALTERNATIVE_S ) );
    end;
  end REPLACE_ALTS;


  begin
    for I	in 1 .. LAST_RULE_NBR loop							--| POUR TOUTES LES	RÈGLES
      declare
        RTBL_I		: RTBL_TYPE renames	RTBL( I );
        ALTERNATIVE_S	: SEQ_TYPE;
      begin
        if RTBL_I.REPLACEMENT.TY /= DN_RULE then						--| SI LA	RÈGLE N'A	PAS DE REMPLAÇANTE
	ALTERNATIVE_S := LIST( RTBL_I.RULE );						--| PRENDRE SA LISTE D'ALTERNATIVES
	REPLACE_ALTS( ALTERNATIVE_S );						--| MODIFIER CETTE LISTE D'ALTERNATIVES
	LIST( RTBL_I.RULE, ALTERNATIVE_S );						--| REPLACER LA LISTE MODIFIÉE
        end if;
      end;
    end loop;
  end THIRD_PASS;
  --|-----------------------------------------------------------------------------------------------
  --|		PROCEDURE	REWRITE
  procedure REWRITE	is
    NEW_RULE_COUNT		: INTEGER	:= 0;
    ONE_USE_COUNT		: INTEGER	:= 0;
    RULE_S		: SEQ_TYPE	:= (TREE_NIL,TREE_NIL);
  begin
    for I	in 1 .. LAST_RULE_NBR loop
      declare
        RTBL_I : RTBL_TYPE renames RTBL( I );
      begin
        if RTBL_I.REPLACEMENT	= TREE_VOID then
	NEW_RULE_COUNT := NEW_RULE_COUNT + 1;
	RULE_S :=	APPEND( RULE_S, RTBL_I.RULE );
	if RTBL_I.USE_COUNT	= 1 then
	  ONE_USE_COUNT := ONE_USE_COUNT + 1;
	end if;
        end if;
      end;
    end loop;
    LIST(	GRAMMAR, RULE_S );							--| REMPLACE LA LISTE DE REGLES
    PUT (	"RULES:" );
    INT_IO.PUT( LAST_RULE_NBR	);
    INT_IO.PUT( NEW_RULE_COUNT );
    NEW_LINE;
    INT_IO.PUT( ONE_USE_COUNT, 1 );
    PUT_LINE  ( " RULES WITH ONE USE." );
  end REWRITE;


begin
  PUT_LINE ( "OPTR_GRMR" );
  declare
    USER_ROOT	: TREE;
  begin
    OPEN_IDL_TREE_FILE( NOM_TEXTE & ".lar" );
    USER_ROOT := D(	XD_USER_ROOT, TREE_ROOT );
    GRAMMAR   := D(	XD_GRAMMAR, USER_ROOT );
  end;
  GR_RULE_S := LIST( GRAMMAR );							--| LA LISTE DES RÈGLES DE GRAMMAIRE
  PUT_LINE ( "FIRST PASS." );
  FIRST_PASS;
  PUT_LINE ( "SECOND PASS." );
  SECOND_PASS;
  PUT_LINE ( "THIRD PASS." );
  THIRD_PASS;
  PUT_LINE ( "REWRITE." );
  REWRITE;

  CLOSE_IDL_TREE_FILE;
--|--------------------------------------------------------------------------------------------------
end OPTR_GRMR;
