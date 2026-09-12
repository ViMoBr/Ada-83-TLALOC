-- EXC_TEST1 (auto-jugeant) -- pilier 11, lot E-B
-- Exerce ce que exc_test0 n'exerce pas : sorties anticipees traversant des
-- corps proteges (return depuis stms proteges, return depuis handler, exit
-- traversant DEUX blocs proteges -- temoin du bug UNLINK compte-vs-niveau
-- corrige en E-A2), recursion avec handler levant, handler dans handler,
-- propagation profonde, appariement croise rename/origine, predefinies,
-- choix multiple.  Verdict greppable : "EXC_TEST1 PASSE" / "EXC_TEST1 ECHOUE".
-- Apres chaque cas de sortie anticipee, un raise/catch de CONTROLE valide
-- l'integrite de la pile des contextes (un pop manque = saut dans un frame
-- mort, un pop de trop = la sentinelle).

with TEXT_IO;	use TEXT_IO;
with REN0_PACK;
procedure EXC_TEST1
is

  E1, E2	: exception;
  ALIAS		: exception renames REN0_PACK.ORIGINE;

  NB_OK		: INTEGER := 0;
  NB_ECHECS	: INTEGER := 0;

  V		: INTEGER := 0;			-- registre d'observation des sections
  CNT		: INTEGER := 0;			-- compteur d'incarnations (section 4)

  package IO_ENT is new INTEGER_IO( INTEGER );

  procedure CHECK ( OK : in BOOLEAN; SECTION : in INTEGER; NUMERO : in INTEGER )
  is
  begin
    if  OK  then
      NB_OK := NB_OK + 1;
    else
      NB_ECHECS := NB_ECHECS + 1;
      PUT( "* ECHEC section" );
      IO_ENT.PUT( SECTION, WIDTH => 3 );
      PUT( " test" );
      IO_ENT.PUT( NUMERO, WIDTH => 3 );
      NEW_LINE;
    end if;
  end CHECK;

  procedure CONTROLE ( SECTION : in INTEGER )	-- integrite de la pile des contextes
  is
    OK : BOOLEAN := FALSE;
  begin
    begin
      raise E1;
    exception
      when E1 => OK := TRUE;
    end;
    CHECK( OK, SECTION, 99 );
  end CONTROLE;

  -- === 1. return depuis les statements PROTEGES d'une procedure ===
  -- CODE_RETURN doit poper le contexte du corps protege (drapeau au niveau
  -- englobant) ; le handler ne doit jamais courir.
  procedure P_RET is
  begin
    V := 1;
    return;
  exception
    when others => V := 91;
  end P_RET;

  -- === 2. return depuis le HANDLER ===
  -- Le contexte est DEJA depile a l'entree du dispatch : CODE_RETURN ne doit
  -- PAS emettre de pop pour ce bloc (drapeau efface pendant les handlers).
  procedure P_RET_H is
  begin
    raise E1;
  exception
    when E1 =>
      V := 2;
      return;
  end P_RET_H;

  -- === 4. recursion + handler levant ===
  -- Un contexte PAR INCARNATION ; le raise dans le handler propage a
  -- l'incarnation appelante (pop avant dispatch, LRM 11.4.1).
  procedure R ( N : in INTEGER ) is
  begin
    if  N = 0  then
      raise E2;
    end if;
    R( N - 1 );
  exception
    when E2 =>
      CNT := CNT + 1;
      raise E2;					-- raise NOMME depuis le handler (le raise nu attend E-C)
  end R;

  -- === 6. propagation profonde : trois frames sans handler, meme niveau ===
  procedure P6C is
  begin
    raise E1;
  end P6C;

  procedure P6B is
  begin
    P6C;
    V := 96;					-- ne doit jamais courir
  end P6B;

  procedure P6A is
  begin
    P6B;
    V := 96;
  end P6A;

  function F_LEVE return INTEGER is begin raise E1; return 0; end;

  procedure P_TRAITE is
  begin
    raise E2;
  exception
    when E2 => null;
  end P_TRAITE;

begin

  -- === 1 ===
  PUT_LINE( "=== 1. return depuis corps protege ===" );
  V := 0;  P_RET;
  CHECK( V = 1, 1, 1 );
  CONTROLE( 1 );

  -- === 2 ===
  PUT_LINE( "=== 2. return depuis handler ===" );
  V := 0;  P_RET_H;
  CHECK( V = 2, 2, 1 );
  CONTROLE( 2 );

  -- === 3. exit traversant DEUX blocs proteges (bug UNLINK E-A2) ===
  PUT_LINE( "=== 3. exit a travers deux blocs proteges ===" );
  V := 0;
  loop
    begin
      begin
        V := 3;
        exit;
      exception
        when others => V := 93;
      end;
    exception
      when others => V := 94;
    end;
  end loop;
  CHECK( V = 3, 3, 1 );
  CONTROLE( 3 );				-- deux pops + deux UNLINK par niveau : l'etat doit etre sain

  -- === 4 ===
  PUT_LINE( "=== 4. recursion, handler levant ===" );
  CNT := 0;  V := 0;
  begin
    R( 3 );
  exception
    when E2 => V := 4;
  end;
  CHECK( V = 4,   4, 1 );
  CHECK( CNT = 4, 4, 2 );			-- incarnations N = 0,1,2,3

  -- === 5. handler dans handler ===
  PUT_LINE( "=== 5. handler dans handler ===" );
  V := 0;
  begin
    raise E1;
  exception
    when E1 =>
      begin
        raise E2;
      exception
        when E2 => V := 1;
      end;
      V := V + 10;
  end;
  CHECK( V = 11, 5, 1 );

  -- === 6 ===
  PUT_LINE( "=== 6. propagation profonde ===" );
  V := 0;
  begin
    P6A;
  exception
    when E1 => V := 6;
  end;
  CHECK( V = 6, 6, 1 );
  CONTROLE( 6 );

  -- === 7. appariement croise rename / origine (LRM 8.5) ===
  PUT_LINE( "=== 7. renames croises ===" );
  V := 0;
  begin
    raise ALIAS;
  exception
    when REN0_PACK.ORIGINE => V := 1;
  end;
  begin
    raise REN0_PACK.ORIGINE;
  exception
    when ALIAS => V := V + 10;
  end;
  CHECK( V = 11, 7, 1 );

  -- === 8. predefinies levees a la main ===
  PUT_LINE( "=== 8. predefinies ===" );
  V := 0;
  begin
    raise CONSTRAINT_ERROR;
  exception
    when CONSTRAINT_ERROR => V := 1;
  end;
  begin
    raise NUMERIC_ERROR;
  exception
    when others => V := V + 10;
  end;
  CHECK( V = 11, 8, 1 );

  -- === 9. choix multiple ===
  PUT_LINE( "=== 9. choix multiple ===" );
  V := 0;
  begin
    raise E2;
  exception
    when E1 | E2 => V := 9;
  end;
  CHECK( V = 9, 9, 1 );

 -- === 10. raise nu (LRM 11.3) ===
  PUT_LINE( "=== 10. raise nu ===" );				-- 10.1 re-raise simple : propage au bloc englobant
  V := 0;
  begin
    begin
      raise E1;
    exception
      when E1 => V := 1;  raise;
    end;
  exception
    when E1 => V := V + 10;
  end;
  CHECK( V = 11, 10, 1 );

  -- 10.2 ADVERSARIAL : une exception TRAITEE dans le handler ne doit pas
  -- corrompre le re-raise (c'est le cas qui invalide le design naif).
  V := 0;
  begin
    begin
      raise E1;
    exception
      when E1 =>
        begin
          raise E2;
        exception
          when E2 => V := 1;
        end;
        raise;				-- DOIT re-lever E1
    end;
  exception
    when E1 => V := V + 10;
    when E2 => V := V + 100;
  end;
  CHECK( V = 11, 10, 2 );

  -- 10.3 idem via APPEL : la procedure traite E2 en interne
  V := 0;
  begin
    begin
      raise E1;
    exception
      when E1 =>
        P_TRAITE;			-- leve et rattrape E2 chez elle
        raise;			-- DOIT re-lever E1
    end;
  exception
    when E1 => V := V + 10;
    when E2 => V := V + 100;
  end;
  CHECK( V = 10, 10, 3 );

-- === 11. exception pendant l'ELABORATION d'un bloc a handler (LRM 11.4.2) ===
  PUT_LINE( "=== 11. exception en elaboration ===" );
  V := 0;
  begin
    declare
      X : INTEGER := F_LEVE;		-- leve E1 PENDANT l'elaboration
    begin
      V := 91;				-- jamais atteint
    exception
      when E1 => V := 92;		-- le handler du bloc NE DOIT PAS capter sa propre elaboration
    end;
  exception
    when E1 => V := 11;		-- capte par le contexte ENGLOBANT
  end;
  CHECK( V = 11, 11, 1 );

-- === 12. bloc protege en boucle longue (stabilite / anti-fuite) ===
  PUT_LINE( "=== 12. bloc protege en boucle longue ===" );
  V := 0;
  for I in 1 .. 100_000 loop
    begin
      V := V + 1;
    exception
      when others => V := 0;
    end;
  end loop;
  CHECK( V = 100_000, 12, 1 );

  -- === VERDICT ===
  NEW_LINE;
  PUT( "RESULTAT :" );
  IO_ENT.PUT( NB_OK, WIDTH => 4 );
  PUT( " OK," );
  IO_ENT.PUT( NB_ECHECS, WIDTH => 4 );
  PUT_LINE( " ECHECS" );

  if  NB_ECHECS = 0  then
    PUT_LINE( "EXC_TEST1 PASSE" );
  else
    PUT_LINE( "EXC_TEST1 ECHOUE" );
  end if;

end	EXC_TEST1;
