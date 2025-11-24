with calendar; use calendar;
with text_io;  use text_io;
with integer_io;
with dyn_car;  use dyn_car;
with car;      use car;

package display_handler is
   --
   -- this package can display an object of type dyn_type or some part of it;
   -- a call to put_all (dyn) redraws the data on the screen
   --
   -- the package retains a copy of all data
   --
   -- a call to redraw redraws the static part of the screen and
   -- the dynamic part of the screen using old data
   --

   -- a call to init redraws the static part of the screen

   procedure put_all	(dyn:	dyn_type);
   procedure redraw;
   procedure init;

   -- parts of the screen can be updated calling

   procedure put_speed	 (v:	speed);		-- -100 < v < 100
   procedure put_helling (h:	percentage);
   procedure put_gas_rem (g:	gas_rem_stand);
   procedure put_message (s:	car. vstring);
   procedure put_max_gas (b:	indicator);
   procedure put_max_rem (b:	indicator);
   procedure put_crash	 (b:	indicator);
   procedure put_neg_v	 (b:	indicator);
   procedure put_tijdstip(t:	calendar. time);

   --
   -- to move the cursor to the prompt position
   --
   procedure move_prompt;

   --
   -- and of course:
   --

   procedure clear_screen;
end display_handler;

package body display_handler is
   esc_char: character := '\033';	-- aii

   package int_io is new integer_io (integer);
   use int_io;

   type row is range 1 .. 24;
   type col is range 1 .. 80;

   old_dyn:	dyn_type;	-- central object of this package body
   --
   -- interface with calendar
   --
   jaar:	year_number;
   maand:	month_number;
   dag:		day_number;
   duur:	day_duration;

   procedure clear_screen is
   begin
      put (esc_char);
      put ("[2J");
   end;

   procedure move_rc (r: row; c: col) is
   begin
      put (esc_char); put ('['); put (integer (r), 0, 10);
      put (';');
      put (integer (c), 0, 10); put ('H');
   end;

   procedure mk_vis is
   begin
      put (esc_char); put ("[0v");
   end mk_vis;

   procedure mk_invis is
   begin
      put (esc_char); put ("[1v");
   end;

   procedure move_prompt is
   begin
      move_rc (22, 7);
   end;

   procedure put_bar (c1, c2:	character;
	              amount:	percentage) is
      j : percentage;
   begin
      j := amount / 4 + 25;
      if amount < 0
      then
         for i in 1 .. j loop put (c2); end loop;
         for i in j + 1 .. 25 loop put (c1); end loop;
         for i in 26 .. 50 loop put (c2); end loop;
      else
         for i in 1 .. 25 loop put (c2); end loop;
         for i in 26 .. j loop put (c1); end loop;
         for i in j + 1 .. 50 loop put (c2); end loop;
      end if;
   end put_bar;

   procedure put_max_gas (b:	indicator) is
   begin
      mk_invis;
      move_rc (18, 22);
      if b = AAN
      then
         put ('X');
      else
         put (' ');
      end if;

      old_dyn. max_gas := b;
      move_prompt;
      mk_vis;
   end put_max_gas;

   procedure put_max_rem (b:	indicator) is
   begin
      mk_invis;
      move_rc (18, 32);
      if b = AAN
      then
         put ('X');
      else
         put (' ');
      end if;

      old_dyn. max_rem := b;
      move_prompt;
      mk_vis;
   end put_max_rem;

   procedure put_crash (b:	indicator) is
   begin
      mk_invis;
      move_rc (18, 42);
      if b = AAN
      then
         put ('X');
      else
         put (' ');
      end if;

      old_dyn. crash := b;
      move_prompt;
      mk_vis;
   end;

   procedure put_neg_v (b:	indicator) is
   begin
      mk_invis;
      move_rc (18, 52);
      if b = AAN
      then
         put ('X');
      else
         put (' ');
      end if;

      old_dyn. neg_v := b;
      move_prompt;
      mk_vis;
   end;


   procedure put_speed (v:	speed) is separate;

   procedure put_helling (h:	percentage) is
   begin
      mk_invis;
      move_rc (7, 10);
      put (percentage (h));
      move_rc (7, 28);
      put_bar ('|', '.', percentage (h));
      old_dyn. helling := h;
      move_prompt;
      mk_vis;
   end put_helling;

   procedure put_gas_rem (g:	gas_rem_stand) is
      gg : gas_rem_stand := g;
   begin
      mk_invis;
      if gg > 100 then gg := 100; end if;
      if gg < -100 then gg := -100; end if;
      move_rc (10, 10);
      put (integer (gg));
      move_rc (10, 28);
      put_bar ('|', '.', percentage (gg));
      old_dyn. gas_stand := gg;
      move_prompt;
      mk_vis;
   end put_gas_rem;

   procedure put_message (s:	car.vstring) is
   begin
      mk_invis;
      move_rc (13, 8);
      for i in 1 .. old_dyn. message. all' last
      loop
         put (' ');
      end loop;

      move_rc (13, 8);
      put (s. all);
      old_dyn. message := s;
      move_prompt;
      mk_vis;
   end put_message;

   procedure put_all (dyn:	dyn_type) is
   begin
      mk_invis;
      put_speed		(dyn. snelheid);
      put_helling	(dyn. helling);
      put_gas_rem	(dyn. gas_stand);
      put_max_gas	(dyn. max_gas);
      put_max_rem	(dyn. max_rem);
      put_crash		(dyn. crash);
      put_neg_v		(dyn. neg_v);
      put_tijdstip	(dyn. tijdstip);
      put_message	(dyn. message);
      move_prompt;
      old_dyn := dyn;
      mk_vis;
   end put_all;

   procedure put_tijdstip (t:	calendar. time) is
   begin
      mk_invis;
      move_rc (1, 10);
      split   (t, jaar, maand, dag, duur);
      put     (jaar);
      put     (maand);
      put     (dag);
      put     (integer (duur));
      old_dyn. tijdstip := t;
      move_prompt;
      mk_vis;
   end put_tijdstip;

   procedure static_disp is
   begin
      move_rc ( 1, 1); put ("tijd");
      move_rc ( 4, 1); put ("snelheid");
      move_rc ( 7, 1); put ("helling");
      move_rc (10, 1); put ("gas_rem");
      move_rc (13, 1); put ("message");

      move_rc (16,20); put ("max_gas");
      move_rc (16,30); put ("max_rem");
      move_rc (16,40); put ("crash");
      move_rc (16,50); put ("neg_v");

      move_rc ( 3,24); put ("-100");
      move_rc ( 3,53); put ('0');
      move_rc ( 3,76); put ("+100");
      move_rc (22, 1); put ('>');
   end static_disp;

   procedure redraw is
   begin
      mk_invis;
      static_disp;
      put_all (old_dyn);
      move_prompt;
      mk_vis;
   end redraw;

   procedure init is
   begin
      clear_screen;
      mk_invis;
      static_disp;
      move_prompt;
      mk_vis;
   end init;
end display_handler;


      


