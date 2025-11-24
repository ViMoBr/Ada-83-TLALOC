with text_io; use text_io;
with calendar; use calendar;
with car;     use car;
package dyn_car is
   --
   -- dynamische gegevens van de auto
   --

   type speed is range 0 .. 300;
   subtype percentage		is integer range -100 .. 100;
   
   type indicator		is (AAN, UIT);

   subtype gas_rem_stand	is integer;

   type dyn_type		is record
				   snelheid	: speed := 0;
				   helling	: percentage := 0;
				   gas_stand	: gas_rem_stand := 0;
				   max_gas	: indicator := UIT;
			           max_rem	: indicator := UIT;
				   crash	: indicator := UIT;
				   neg_v	: indicator := UIT;

				   message	: vstring;
				   tijdstip	: calendar. time;
				end record;
   crash:			exception;
end dyn_car;


