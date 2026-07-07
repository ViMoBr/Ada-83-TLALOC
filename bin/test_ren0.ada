package REN0_PACK is
   ORIGINE : exception;
end REN0_PACK;

with REN0_PACK;
procedure EXC_REN0 is
   ALIAS : exception renames REN0_PACK.ORIGINE;
begin
   raise ALIAS;
exception
   when REN0_PACK.ORIGINE => null;		-- appariement croise rename/origine
end EXC_REN0;
