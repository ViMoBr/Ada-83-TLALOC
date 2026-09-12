------------------------------------------------------------------------
--  GOTO_TEST v2 -- temoin auto-jugeant du pilier GOTO (LRM 5.9)
--  S1 : goto AVANT meme niveau (motif ADA_COMP)
--  S2 : goto ARRIERE meme niveau (reboucle, garde de terminaison)
--  S3 : goto ARRIERE sortant d'un bloc declare (UNLINK)
--  S4 : goto ARRIERE sortant d'un bloc PROTEGE (UNLINK + EXC_POP)
--  S6 : goto AVANT sortant d'un bloc declare (RACCORD : UNLINK)
--       -- l'ex-cas refuse v1, motif LIB_PHASE
--  S7 : goto AVANT sortant d'un bloc PROTEGE (RACCORD : photo CTX
--       + EXC_POP) -- si le contexte fantome restait empile, le
--       raise apres l'etiquette serait deroule vers le bloc mort
--  Oracle : « RESULTAT :  10 OK,  0 ECHECS » puis « GOTO_TEST PASSE »
------------------------------------------------------------------------
with TEXT_IO;	use TEXT_IO;

procedure		GOTO_TEST
is			---------

  OK_COUNT	: INTEGER := 0;
  KO_COUNT	: INTEGER := 0;

  A		: INTEGER := 0;
  N		: INTEGER := 0;
  S3_TOURS	: INTEGER := 0;

		-------
  procedure	VERIFIE		( COND :BOOLEAN; NUM :INTEGER )
  is		-------
  begin
    if  COND  then
      OK_COUNT := OK_COUNT + 1;
    else
      KO_COUNT := KO_COUNT + 1;
      PUT_LINE( "ECHEC ASSERTION" & INTEGER'IMAGE( NUM ) );
    end if;
  end	VERIFIE;

begin
			-- S1 : goto AVANT, meme niveau
  A := 1;
  goto S1_SUITE;
  A := 2;					-- ne doit jamais s'executer
<<S1_SUITE>>
  VERIFIE( A = 1, 101 );

			-- S2 : goto ARRIERE, meme niveau
  N := 0;
<<S2_RETOUR>>
  N := N + 1;
  if  N < 3  then
    goto S2_RETOUR;
  end if;
  VERIFIE( N = 3, 201 );

			-- S3 : goto ARRIERE sortant d'un bloc declare
  A := 0;
<<S3_RETOUR>>
  S3_TOURS := S3_TOURS + 1;
  declare
    B	: INTEGER := 10;
  begin
    B := B + A;
    if  S3_TOURS < 3  then
      A := A + 1;
      goto S3_RETOUR;				-- sort du bloc : UNLINK attendu
    end if;
    A := B;					-- 3e tour : A = 10 + 2 = 12
  end;
  VERIFIE( A = 12,       301 );
  VERIFIE( S3_TOURS = 3, 302 );

			-- S4 : goto ARRIERE sortant d'un bloc PROTEGE
  declare
    PASSES	: INTEGER := 0;
    TRACE	: INTEGER := 0;
  begin
<<S4_RETOUR>>
    PASSES := PASSES + 1;
    if  PASSES = 2  then
      raise CONSTRAINT_ERROR;			-- hors du bloc protege quitte
    end if;
    declare
      DUMMY	: INTEGER := 1;
    begin
      if  PASSES = 1  then
        goto S4_RETOUR;				-- sort du bloc protege : UNLINK + EXC_POP
      end if;
      DUMMY := DUMMY + 1;
    exception
      when others =>
        TRACE := 999;				-- contexte fantome : ne doit JAMAIS s'executer
    end;
    VERIFIE( FALSE, 401 );			-- flux normal impossible ici
  exception
    when CONSTRAINT_ERROR =>
      VERIFIE( TRACE  = 0, 402 );
      VERIFIE( PASSES = 2, 403 );
    when others =>
      VERIFIE( FALSE, 404 );
  end;

			-- S5 : sequel apres S4 -- l'etat des niveaux est sain
  N := 0;
  for I in 1 .. 4 loop
    N := N + I;
  end loop;
  VERIFIE( N = 10, 501 );

			-- S6 : goto AVANT sortant d'un bloc declare (raccord UNLINK)
  A := 0;
  declare
    B	: INTEGER := 5;
  begin
    A := B;
    goto S6_SORTIE;				-- AVANT, sort du bloc : raccord UNLINK
    A := 99;					-- ne doit jamais s'executer
  end;
<<S6_SORTIE>>
  VERIFIE( A = 5, 601 );

			-- S7 : goto AVANT sortant d'un bloc PROTEGE (raccord
			--      photo CTX + EXC_POP)
  declare
    TRACE	: INTEGER := 0;
  begin
    declare
      DUMMY	: INTEGER := 1;
    begin
      goto S7_SORTIE;				-- AVANT, sort du bloc protege :
      DUMMY := 2;				-- raccord EXC_POP + UNLINK
    exception
      when others =>
        TRACE := 999;				-- contexte fantome : jamais
    end;
    TRACE := TRACE + 500;			-- chute normale : jamais (goto pris)
<<S7_SORTIE>>
    raise CONSTRAINT_ERROR;
  exception
    when CONSTRAINT_ERROR =>
      VERIFIE( TRACE = 0, 702 );
    when others =>
      VERIFIE( FALSE, 703 );
  end;

  VERIFIE( KO_COUNT = 0, 901 );

  PUT( "RESULTAT : " );  PUT( INTEGER'IMAGE( OK_COUNT ) );
  PUT( " OK, " );        PUT( INTEGER'IMAGE( KO_COUNT ) );
  PUT_LINE( " ECHECS" );
  if  KO_COUNT = 0  then
    PUT_LINE( "GOTO_TEST PASSE" );
  else
    PUT_LINE( "GOTO_TEST ECHOUE" );
  end if;

end	GOTO_TEST;
	---------
