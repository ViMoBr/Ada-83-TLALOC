with text_io; use text_io;
with car;     use car;
with data_base;

package garage is
   auto_file	: text_io. file_type;
   package auto_data_base is new data_base (
      db_file	=> auto_file,
      elem	=> car. autorec,
      kind	=> car. componenten,
      in_order	=> car. relation,
      eof	=> text_io. end_of_file,
      write	=> car. write,
      read	=> car. read);

   use auto_data_base;

   procedure open_db_input;
   procedure open_db_output;
   procedure close_data_base;
   procedure show_unsold_cars (crit:	car. componenten);
   procedure buy_car;
   procedure sell_car (the_car : rec_key);
   procedure build_in_snuf (the_snuf:	snuf;
                            the_car:	rec_key;
                            snuf_sum:	florijn);
   procedure make_a_tour   (the_car:	rec_key);
end garage;

package body garage is

   package balance_actions is
      max_transaction:		constant := 100;
      type transaction_range is range 0 .. max_transaction;
      type kind_of_transaction is (NULL_ACTION,
                                   INKOOP,
                                   VERKOOP,
                                   ADDED_SNUF,
                                   LOST_ON_TOUR);
      type balance_rec is
      record
         auto:		rec_key;
         transaction:	kind_of_transaction;
         amount:	florijn;
      end record;

      type transaction_set is array (transaction_range) of balance_rec;
      current_transaction:	transaction_range := 1;
      transaction_data_base:	transaction_set := 
                                (others => (null_key, NULL_ACTION, 0));

      procedure add_trans       (auto:	autorec;
                                 trans:	kind_of_transaction;
                                 sum:	florijn);
      
      procedure make_balance;
   end balance_actions;

   package body balance_actions is
      procedure add_trans (auto:	autorec;
                           trans:	kind_of_transaction;
                           sum:		florijn) is
      begin
         null;
      end;

      procedure make_balance is
      begin
         null;
      end;
   end balance_actions;

   use balance_actions;

   procedure open_db_input is
   begin
      open (file   => auto_file,
            mode   => in_file,
            name   => "auto_db");
      load_data_base;

      order_db (automerk);

      car. write_head;
      show_data_base;
   end open_db_input;

   procedure open_db_output is
   begin
      open (file   => auto_file,
            mode   => out_file,
            name   => "auto_db");
   end open_db_output;

   procedure clean_data_base is
      current_car : car. autorec := first_data_object;
   begin
      loop
         case get_status (current_car) is
            when VERKOCHT |
                 VERLOREN_GEGAAN =>
                    delete (get_key (current_car));
            when others =>
                    null;
         end case;

         current_car := next_data_object;
      end loop;
   exception
      when no_more_objects =>
                   return;
      when others          =>
                   raise;
   end clean_data_base;

   procedure close_data_base is
   begin
      balance_actions. make_balance;
      clean_data_base;
      open_db_output;
      store_data_base;
   end close_data_base;

   procedure show_unsold_cars (crit:	car. componenten) is
      current_car : car. autorec := first_data_object;
   begin
      car. write_head;
      order_db (crit);
      loop
         case get_status (current_car) is
            when TE_KOOP =>
                 car. write (current_car);
            when others =>
                 null;
         end case;

         current_car := next_data_object;
      end loop;

   exception
      when no_more_objects =>
                     return;
      when others          =>
                     raise;
   end show_unsold_cars;

   procedure buy_car is
      current_car : car. autorec;
   begin
      put_line ("Enter data from bought car: ");
      car. read_tty (current_car);
--      car. read (current_car, from => standard_input);
      insert (current_car);
      add_trans (current_car, INKOOP, get_inkoopprijs (current_car));
   end buy_car;

   procedure sell_car (the_car: rec_key) is
      current_car : car. autorec;
   begin
      current_car := select_object (the_car);
      delete (the_car);
      set_status (current_car, VERKOCHT);
      insert (current_car);
      add_trans (current_car, VERKOOP, get_verkoopprijs (current_car));
   end sell_car;

   procedure build_in_snuf (the_snuf:	snuf;
                            the_car:	rec_key;
                            snuf_sum:	florijn) is
      current_car:	car. autorec;
      current_snufs:	car. snufset;
--    use car. snuf_instant;
      package bla renames car. snuf_instant;
      use bla;
   begin
      current_car := select_object (the_car);
      delete (the_car);
      current_snufs := get_snufs (current_car);
      if not is_member (current_snufs, the_snuf) then
         current_snufs := current_snufs + the_snuf;
         set_snufs (current_car, current_snufs);
      end if;

      insert (current_car);
      add_trans (current_car, ADDED_SNUF, snuf_sum);
   end build_in_snuf;

   procedure make_a_tour (the_car:	rec_key) is
      current_car : car. autorec;
   begin
      current_car := select_object (the_car);
      --
      -- do_the_tour (current_car)
      --
   end make_a_tour;
end garage;

      
      

