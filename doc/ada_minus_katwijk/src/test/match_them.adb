package body match_them is
   function A_Match_Is_Made (l: string; f: integer; p: pattern) return boolean;
   function Element_Matches (l: string; f: integer;
                             t: integer; p: pattern) return boolean;
   function Is_Member (p: pattern; c: character) return boolean;

   function Matches (l: string; p: pattern) return boolean is
   begin
      own_io. put_line (l);
      for i in 1 .. own_io. MAX_STRING loop
         if A_Match_Is_Made (l, i, p)
         then
            return TRUE;
         elsif l (i) = character' val (0)
         then
            return FALSE;
         end if;
      end loop;
      -- hier mogen we niet komen
      own_io. put_line ("Hier gaat iets krakend mis");
      raise My_Error;
   end;


   function A_Match_Is_Made (l: string; f: integer; p: pattern) return boolean is
   begin
      if p = null
      then
         return TRUE;
      end if;
      for j in f - 1 .. own_io. MAX_STRING loop
         if Element_Matches (l, f, j, p) and then
            A_Match_Is_Made (l, j + 1, p. next)
         then
            return TRUE;
         elsif j > 0 and then l (j) = character' val (0)
         then
            return FALSE;
         end if;
      end loop;
      own_io. put_line ("Hier gaat iets krakend mis");
      -- Hier mogen we niet komen
      raise My_Error;
   end;


   function Element_Matches (l: string; f: integer;
                             t: integer; p: pattern) return boolean is
   begin
      case p. pattern_key is
         when bol_key     => return t = f - 1 and then f = 0;
         when eol_key     => return f = t and then l (f) = character' val (0);
         when any_key     => return l (f) /= character' val (0);
         when char_key    => return l (f) = p. pattern_char_value
                                    and then t = f;
         when ccl_key     => return t = f and then
                                    Is_Member (p. low_val, l (f));
         when clos_key    => if f = t + 1
                             then
                                return TRUE;
                             end if;
                             for j in f .. t loop
                                if Element_Matches (l, f, j, p. low_val) and then
                                   Element_Matches (l, j + 1, t, p)
                                then
                                   return TRUE;
                                end if;
                             end loop;
                             return FALSE;
         when others      => -- should not happen
                             raise My_Error;
      end case;
   end;

   function Is_Member (p: pattern; c: character) return boolean is
   begin
      if p = null
      then
         return FALSE;
      elsif p. pattern_char_value = c
      then
         return TRUE;
      else
         return Is_Member (p. next, c);
      end if;
   end;
end;
