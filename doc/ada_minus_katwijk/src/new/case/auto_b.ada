--
with calendar; use calendar;
with display_handler;
use display_handler;

package body auto_control is

   --
   -- local declarations and subtypes
   --
   subtype duration is long;

   subtype gas_rem_percentage is gas_rem_stand range -100 .. 100;
   gasmin: constant gas_rem_percentage := gas_rem_percentage' FIRST;
   gasmax: constant gas_rem_percentage := gas_rem_percentage' LAST;

   max_helling: constant percentage := percentage' LAST;
   min_helling: constant percentage := percentage' FIRST;

   new_stand  : gas_rem_percentage;
   comp_intval: constant duration := 1;
   stat_obj   : stat_type;          -- static data of driving car
   kracht     : power;
   gewicht    : zwaarte;

   dyn_obj,
   new_dyn_obj: dyn_type;           -- toestandsvectoren voor rijdende auto
   initial_dyn_obj : constant dyn_type := dyn_obj;

   -- renames for dyn_obj-componenten

   snelheid:   speed	renames dyn_obj. snelheid;
   tijdstip:   time	renames dyn_obj. tijdstip;
   curr_helling:
	       percentage renames dyn_obj. helling;
   gas:        gas_rem_stand renames dyn_obj. gas_stand;


   -- renames for new_dyn_obj-componenten

   new_snelheid:	speed renames new_dyn_obj. snelheid;
   new_tijdstip:	time  renames new_dyn_obj. tijdstip;
   new_helling:		percentage renames new_dyn_obj. helling;
   new_gas:		gas_rem_stand renames new_dyn_obj. gas_stand;
   new_neg_v:		indicator  renames new_dyn_obj. neg_v;
   new_max_gas:		indicator  renames new_dyn_obj. max_gas;
   new_max_rem:		indicator  renames new_dyn_obj. max_rem;
   new_crash:		indicator  renames new_dyn_obj. crash;

   -- variables and constants for new_speed function

   C_m:			speed;  -- max. pushing power, starting from
				-- linear increase of delivered vermogen
				-- up to 40 m/s
   C_m_m:		speed;	-- acceleration per unit "gaspedaal"
   C_r:			speed;	-- break deceleration per unit break
   C_w:			constant speed := 78;

   G:			constant speed := 98;

   STOPPED:		exception;	--


   function updated_speed (event_time:	time) return speed;
   function car_dynamics return dyn_type is
   begin
      return dyn_obj;
   end car_dynamics;

   function checked (unchecked_v:	speed) return speed is
      -- check speed being < 0, or negative and now 0
      --
   begin
      if unchecked_v >= 0 and then snelheid < 0
      then
         new_neg_v := UIT;
      elsif unchecked_v < 0 and then snelheid >= 0
      then
         new_neg_v := AAN;
      end if;

      return unchecked_v;
   end checked;

   function new_speed (delta_t:	duration) return speed is separate;


   procedure update_dynamics is separate;

   procedure init_statics (car_stat:	stat_type) is
   begin
      stat_obj	:= car_stat;
      kracht	:= get_kracht (stat_obj);
      gewicht	:= get_gewicht (stat_obj);

      C_m	:= speed (kracht) * 10000 / 400;

      C_m_m	:= (C_m / speed (gewicht)) / speed (gasmax);

      C_r	:= (60 / speed (-gasmin));

--      C_w	:= C_w / speed (gewicht);

      reset_dynamics;
   end init_statics;

   procedure gas_rem (g:	gas_rem_stand) is
   begin
      -- the next statement is embedded in a block to allow
      -- catching exceptions
      begin
         put_message (mk_string ("                      "));
         new_stand := g;

         if new_stand = gasmax
         then
            new_max_gas := AAN;
         else
            new_max_gas := UIT;
         end if;

         if new_stand = gasmin
         then
            new_max_rem := AAN;
         else
            new_max_rem := UIT;
         end if;

      exception
         when constraint_error =>
            if g > gasmax
            then
               new_gas := gasmax;
	       new_max_gas := AAN;
	    elsif g < gasmin
            then
               new_gas := gasmin;
               new_max_rem := AAN;
            end if;
         when others => raise;
      end;

      new_gas := new_stand;
      update_dynamics;

   exception
      when STOPPED =>
         put_message (mk_string ("                  "));
      when others  =>
         raise;
   end gas_rem;

   procedure stop is
   begin
      new_max_gas	:= UIT;
      new_max_rem	:= AAN;
      new_gas		:= gasmin;

      loop
         update_dynamics;
         put_speed (snelheid);
         delay 2;
      end loop;

   exception
      when STOPPED =>
         put_message (mk_string ("AUTO STAAT STIL !!!!"));
      when others  =>
         raise;
   end stop;

   procedure reset_dynamics is separate;

   procedure helling (h:	percentage) is separate;

   procedure get_dynamics is
   begin
      update_dynamics;
      put_speed (snelheid);
   exception
      when STOPPED =>
         put_message (mk_string ("AUTO STAAT STIL !!!!!"));
         put_speed   (snelheid);
      when others  =>
         raise;
   end get_dynamics;

   function updated_speed (event_time: time) return speed is
      temp_delta : duration := event_time - tijdstip;
   begin
      while temp_delta > comp_intval
      loop
         snelheid := checked (new_speed (comp_intval));

         temp_delta := temp_delta - comp_intval;
      end loop;
      return checked (new_speed (temp_delta));
   end updated_speed;

end auto_control;

              


