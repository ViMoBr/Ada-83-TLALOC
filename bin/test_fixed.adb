		----------
procedure		TEST_FIXED
is		----------

  type SUPPLY_VOLTAGE	is delta 0.001	range -12.0 .. +12.0;
  type SCOPE_SIZES		is delta 0.000_015	range 0.0 .. 0.1;
  type DUREE		is delta 2.0**(-29)	range -(2.0**34 - 1.0) .. 2.0**34;

begin
  null;

end	TEST_FIXED;
	----------
