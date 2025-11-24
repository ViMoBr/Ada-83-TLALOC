with text_io; use text_io;
package io_hulp is
   type reply is (yes, no);
   function get_yes_or_no return reply;
end io_hulp;

package body io_hulp is
   function is_yes_or_no (x: string) return boolean is
   begin
     return x = "yes" or else x = "noo";
   end;

   function get_yes_or_no return reply is
      answer: string (1 .. 3);
      procedure get_reasonable_answer (s: in out string) is
         l: integer;
      begin
         put_line ("asking: "); 
         get_line (s, l);
         if l = 2
         then
            s (3) := 'o';
         end if;
      end;
   begin
      get_reasonable_answer (answer);
      while not is_yes_or_no (answer)
      loop
         put ("Invalid input: try again ");
         get_reasonable_answer (answer);
      end loop;
      if answer = "yes"
      then
         return yes;
      else
         return no;
      end if;
   end;
end;

