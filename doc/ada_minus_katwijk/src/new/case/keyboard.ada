
package keyboard is
   procedure do_read;
end keyboard;

with text_io; use text_io;
with car;     use car;
with dyn_car; use dyn_car;
with display_handler; use display_handler;
with auto_control; use auto_control;

package body keyboard is

   esc_char : character := '\033';

   subtype strlen0	is integer range 0 .. 20;
   subtype strlen	is integer range strlen0' first + 1 .. strlen0' last;
   subtype astring	is standard. string (strlen);

   a:		astring;
   last:	strlen0 := strlen0' last;
   h:		percentage := 5;		-- for the time being
   max_h:	constant percentage := 100;
   xstring:	vstring;

   function convert (i: strlen) return gas_rem_stand is
      number:	gas_rem_stand := 0;
      j:	strlen := i;
   begin
      while (a (j) >= '0') and (a (j) <= '9') loop
         number := character' pos (a (j)) -
                   character' pos ('0') + number * 10;
         j := j + 1;
      end loop;

      return number;
   end convert;

   procedure do_read is
   begin
      set_line_length (0);
      loop
         a := (others => ' ');
         for i in 1 .. last loop
            put (' ');
         end loop;

         loop
            move_prompt;
            get_line (a, last);
            exit when last > 0;
         end loop;

         case a (1) is
            when 'i'	=> auto_control. reset_dynamics;
            when 's'	=> auto_control. stop;
                           exit;
            when '+'	=> auto_control. gas_rem (convert (2));
            when '-'	=> auto_control. gas_rem (- convert (2));
            when '0' .. '9' =>
                           auto_control. gas_rem (convert (1));
            when 'l'	=> auto_control. helling ( -h);
            when 'h'	=> auto_control. helling (  h);
            when 'r'	=> move_prompt;	-- non tasking only
	                   auto_control. get_dynamics;
            when 'x'	=> move_prompt;
                           auto_control. helling (max_h);
            when others => move_prompt;
                           null;
         end case;
      end loop;

      xstring := mk_string ("einde van de rit");
      display_handler. put_message (xstring);

      -- abort auto control

      for i in long range 1 .. 1_000_000 loop null; end loop;

      clear_screen;

   exception
      when CRASH =>
         xstring := mk_string ("CRASH CRASH CRASH");
         display_handler.put_message (xstring);
   end do_read;
end keyboard;

