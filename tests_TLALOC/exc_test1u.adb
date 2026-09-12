-- EXC_TEST1U -- pilier 11, lot E-B : temoin PERMANENT de la sentinelle.
-- (Remplace la mutation "commenter le when others" d'exc_test0, qui ne vit
-- pas dans le depot.)  Oracle du filet :
--     stdout    = "EXCEPTION NON RATTRAPEE : PERDUE"
--     code $?   = 1
procedure EXC_TEST1U
is
  PERDUE	: exception;

  procedure LEVE is
  begin
    raise PERDUE;
  end LEVE;

begin
  LEVE;
end	EXC_TEST1U;
