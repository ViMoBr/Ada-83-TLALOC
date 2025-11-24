package body own_io is
   procedure get_line (s: out string; cnt: in out integer) is
   begin
      get_line (s, cnt);
      s (cnt + 1) := character' val (0);  -- a c-string
      cnt := cnt + 1;
   end;
   procedure put_line (s: string) is
   begin
     for i in 1 .. s' last loop
        if s (i) = character' val (0)
        then
           put (character' val (10));
           return;
        else
           put (s (i));
        end if;
     end loop;
   end;
end;
