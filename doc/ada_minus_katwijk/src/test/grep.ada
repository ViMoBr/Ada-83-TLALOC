with c_lib; use c_lib;
with own_io; use own_io;
with text_io; use text_io;
-- with text_handler; use text_handler;
with pattern_making; use pattern_making;
with match_them; use match_them;
procedure grep is
   pattern_string,
   arg2,
   arg : string (1 .. 127);
   p   : pattern;
   l   : string (1 .. 255);
   cnt : long;
   show_flag : Boolean := FALSE;
begin
   if num_args  < 2
   then
      own_io.put_line ("Usage: grep pattern [-s]");
   else
      if num_args >= 3
      then
         get_args (3, arg, cnt);
         if arg (1) = '-' and then arg (2) = 's'
         then
            show_flag := TRUE;
         end if;
      end if;
      get_args (4, arg, cnt);
      p := Make_Pattern (arg, show_flag);
      cnt := 1;
      loop
         own_io. get_line (l, integer (cnt));
         exit when cnt = 0;
         if Matches (l, p)
         then
            own_io. put_line (l);
         end if;
      end loop;
   end if;
end;

