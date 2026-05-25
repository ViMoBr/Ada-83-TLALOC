with TEXT_IO; use TEXT_IO;
with CALENDAR;
use  CALENDAR;
		-------------
procedure		TEST_CALENDAR
is		-------------

  package INT_IO	is new INTEGER_IO( INTEGER );
  package DUR_IO	is new FIXED_IO( DURATION );

  T	: TIME;
  Y	: YEAR_NUMBER;
  M	: MONTH_NUMBER;
  D	: DAY_NUMBER;
  S	: DAY_DURATION;
  L	: LONG_INTEGER;

begin
  T := CALENDAR.CLOCK;
  Y := YEAR( T );
  PUT( " ANNEE : " ); INT_IO.PUT( Y ); NEW_LINE;
  M := MONTH( T );
  PUT( " MOIS : " ); INT_IO.PUT( M ); NEW_LINE;
  D := DAY( T );
  PUT( " JOUR " ); INT_IO.PUT( D ); NEW_LINE;
  S := SECONDS( T );
  PUT( " SECONDES " ); DUR_IO.PUT( S ); NEW_LINE;

--  SPLIT( T, Y, M, D, S );

end	TEST_CALENDAR;
	-------------
