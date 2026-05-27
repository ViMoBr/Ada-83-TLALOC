with TEXT_IO;
use  TEXT_IO;
		----------
procedure		TEST_FIXED
is		----------

  type DURAT_ION		is delta 2.0**(-29) range -2.0**34 .. 2.0**34 - 1.0;

--  type SUPPLY_VOLTAGE	is delta 0.001	range -12.0 .. +12.0;
--  type SUPPLY_CURRENT	is delta 0.000_3	range 0.0 .. 2.0;
  type SUPPLY_POWER		is delta 0.1	range -50.0 .. 70.0;

  package INT_IO	is new INTEGER_IO( INTEGER );
  package POWER_IO	is new FIXED_IO( SUPPLY_POWER );
  package DUR_IO	is new FIXED_IO( DURATION );

--  type SCOPE_SIZES		is delta 0.000_015	range 0.0 .. 0.1;
--  type DUREE		is delta 2.0**(-29)	range -(2.0**34 - 1.0) .. 2.0**34;

--  V	: SUPPLY_VOLTAGE	:= 1.5;
--  I	: SUPPLY_CURRENT	:= 0.7;
  P	: SUPPLY_POWER	:= 15.5;
  ENT_P	: INTEGER;
begin
  ENT_P := INTEGER( P );
  PUT( "ENT_P = " ); INT_IO.PUT( ENT_P ); NEW_LINE;
--  P := SUPPLY_POWER( I * V );
  PUT( "P = " ); POWER_IO.PUT( P ); NEW_LINE;
end	TEST_FIXED;
	----------
