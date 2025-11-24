with car;     use car;
with dyn_car; use dyn_car;

package auto_control is

   subtype	stat_type is autorec;

   procedure	init_statics (car_stat: stat_type);
   procedure	reset_dynamics;
   procedure	get_dynamics;
   function	car_dynamics return dyn_type;
   procedure	helling (h: percentage);
   procedure	stop;
   procedure	gas_rem (g: gas_rem_stand);

end auto_control;



