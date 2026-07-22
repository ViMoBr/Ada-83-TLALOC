procedure GOTO_DUMP is

  A : INTEGER := 0;
  N : INTEGER := 0;

begin
				-- 1. goto AVANT, meme niveau (motif ADA_COMP)
  A := 1;
  goto SAUT_AVANT;
  A := 2;			-- jamais execute
<<SAUT_AVANT>>
  A := 3;

				-- 2. goto ARRIERE, meme niveau, garde de terminaison
<<REBOUCLE>>
  N := N + 1;
  if N < 3 then
    goto REBOUCLE;
  end if;

				-- 3. goto ARRIERE sortant d'un bloc declare
<<AVANT_BLOC>>
  A := A + 1;
  declare
    B : INTEGER := 10;
  begin
    B := B + A;
    if A < 6 then
      goto AVANT_BLOC;		-- sort du bloc : deniveler
    end if;
    A := B;
  end;

end GOTO_DUMP;
