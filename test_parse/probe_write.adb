with GRMR_TBL;

procedure PROBE_WRITE
is
  use GRMR_TBL;
begin
  for I in ST_TBL_TYPE'RANGE loop
    GRMR.ST_TBL( I ) := I * 1009 - 500_000;			-- negatifs ET positifs
  end loop;
  GRMR.ST_TBL_LAST := 16#5EED1#;

  for I in AC_SYM_TYPE'RANGE loop
    GRMR.AC_SYM( I ) := AC_BYTE( (I*7) mod 256 );		-- couvre >= 128 (test ULb)
  end loop;

  for I in AC_TBL_TYPE'RANGE loop
    GRMR.AC_TBL( I ) := AC_SHORT( ((I*13) mod 60_001) - 30_000 );	-- couvre tout le short signe
  end loop;

  GRMR.AC_SYM_LAST := 16#5EED2#;				-- magies DISTINCTES :
  GRMR.AC_TBL_LAST := 16#5EED3#;				-- tout glissement d'offset
								-- entre LAST est visible
  for I in NTER_PG_TYPE'RANGE loop
    GRMR.NTER_PG( I ) := AC_BYTE( (I*3) mod 251 );
    GRMR.NTER_LN( I ) := AC_BYTE( (I*5) mod 253 );
  end loop;
  GRMR.NTER_LAST := 16#5EED4#;

  declare
    use GRMR_TBL_IO;
    F	: GRMR_TBL_IO.FILE_TYPE;
  begin
    CREATE( F, OUT_FILE, "parse_probe.bin" );
    WRITE( F, GRMR );
    CLOSE( F );
  end;
end PROBE_WRITE;
