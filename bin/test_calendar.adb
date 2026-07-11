with TEXT_IO; use TEXT_IO;
with CALENDAR;
use  CALENDAR;
		-------------
procedure		TEST_CALENDAR
is		-------------

  package INT_IO is new INTEGER_IO( INTEGER );
  package DUR_IO is new FLOAT_IO( LONG_FLOAT );

  T	: TIME;
  T2	: TIME;
  Y	: YEAR_NUMBER;
  M	: MONTH_NUMBER;
  D	: DAY_NUMBER;
  S	: DAY_DURATION;
  DELTA_T	: DURATION;

		------------
  procedure	AFFICHE_DATE
  is		------------
  begin
    PUT( " Y M D S = " );
    INT_IO.PUT( INTEGER( Y ), WIDTH=> 5 );
    INT_IO.PUT( INTEGER( M ), WIDTH=> 3 );
    INT_IO.PUT( INTEGER( D ), WIDTH=> 3 );
    PUT( ' ' ); DUR_IO.PUT( LONG_FLOAT( S ), FORE => 1, AFT => 6, EXP => 2 );
    NEW_LINE;

  end	AFFICHE_DATE;
	------------

begin
  PUT_LINE( "----- TIME_OF / SPLIT -----" );

  T := TIME_OF( 2000, 2, 29, 86399.75 );

  SPLIT( T, Y, M, D, S );
  AFFICHE_DATE;

  PUT_LINE( "----- SELECTORS -----" );

  INT_IO.PUT( INTEGER( YEAR( T ) ) ); NEW_LINE;
  INT_IO.PUT( INTEGER( MONTH( T ) ) ); NEW_LINE;
  INT_IO.PUT( INTEGER( DAY( T ) ) ); NEW_LINE;
  DUR_IO.PUT( LONG_FLOAT( SECONDS( T ) ), FORE => 1, AFT => 6, EXP => 2 );
  NEW_LINE;

  T2 := T + 0.25;

  PUT_LINE( "----- MIDNIGHT ROLLOVER -----" );

  SPLIT( T2, Y, M, D, S );
  AFFICHE_DATE;

  PUT_LINE( "----- OPERATORS -----" );
  DELTA_T := T2 - T;

  PUT( "T2 = " ); DUR_IO.PUT( LONG_FLOAT( SECONDS( T2 ) ), FORE => 1, AFT => 6, EXP => 2 );
  NEW_LINE;

  PUT( "DELTA_T = " ); DUR_IO.PUT( LONG_FLOAT( DELTA_T ), FORE => 1, AFT => 6, EXP => 2 );
  NEW_LINE;

  if T2 > T then
    PUT_LINE( "GT OK" );
  else
    PUT_LINE( "GT ERROR" );
  end if;

  PUT_LINE( "----- JOURNEE ORDINAIRE (30/4/2001 86399.75sec + 0.25 -----" );

  T  := TIME_OF( 2001, 4, 30, 86399.75 );
  T2 := T + 0.25;
  SPLIT( T2, Y, M, D, S );
  AFFICHE_DATE;

  PUT_LINE( "----- PASSAGE ANNEE (31/12/1999 86399.75sec + 0.25 -----" );

  T  := TIME_OF( 1999, 12, 31, 86399.75 );
  T2 := T + 0.25;
  SPLIT( T2, Y, M, D, S );
  AFFICHE_DATE;

--  PUT_LINE( "----- ANNEE NON BISEXTILE (28/2/1900 86399.75sec + 0.25 -----" );

--  T  := TIME_OF( 1900, 2, 28, 86399.75 );
--  T2 := T + 0.25;
--  SPLIT( T2, Y, M, D, S );
--  AFFICHE_DATE;

--  PUT_LINE( "----- ANNEE NON BISEXTILE (28/2/2100 86399.75sec + 0.25 -----" );

--  T  := TIME_OF( 2100, 2, 28, 86399.75 );
--  T2 := T + 0.25;
--  SPLIT( T2, Y, M, D, S );
--  AFFICHE_DATE;

  PUT_LINE( "----- HORS GAMME YEAR_NUMBER (1900 et 2100 exclus par le LRM) -----" );

  begin
    T := TIME_OF( 1900, 2, 28, 86399.75 );
    PUT_LINE( "1900 : ERREUR, pas d'exception" );
  exception
    when CONSTRAINT_ERROR => PUT_LINE( "1900 -> CONSTRAINT_ERROR OK" );
  end;

  begin
    T := TIME_OF( 2100, 2, 28, 86399.75 );
    PUT_LINE( "2100 : ERREUR, pas d'exception" );
  exception
    when CONSTRAINT_ERROR => PUT_LINE( "2100 -> CONSTRAINT_ERROR OK" );
  end;

  PUT_LINE( "----- ANNEE NON BISEXTILE (28/2/2001 86399.75sec + 0.25 -----" );

  T  := TIME_OF( 2001, 2, 28, 86399.75 );
  T2 := T + 0.25;
  SPLIT( T2, Y, M, D, S );
  AFFICHE_DATE;

  PUT_LINE( "----- PASSAGE ARRIERE (1/3/2000 0.25sec - 0.5 -----" );

  T  := TIME_OF( 2000, 3, 1, 0.25 );
  T2 := T - 0.50;
  SPLIT( T2, Y, M, D, S );
  AFFICHE_DATE;

  PUT_LINE( "----- CLOCK -----" );

  T := CLOCK;
  SPLIT( T, Y, M, D, S );
  PUT( " Y M D S = " );
  INT_IO.PUT( INTEGER( Y ), WIDTH=> 5 );
  INT_IO.PUT( INTEGER( M ), WIDTH=> 3 );
  INT_IO.PUT( INTEGER( D ), WIDTH=> 3 );
  PUT( ' ' ); DUR_IO.PUT( LONG_FLOAT( S ), FORE => 1, AFT => 13, EXP => 2 );
  NEW_LINE;

  PUT_LINE( "----- TEST COHERENCE -----" );

  declare
    T1, T2	: TIME;
    DT		: DURATION;

  begin
    T1 := CLOCK;

    for I in 1 .. 1_000_000 loop
      null;
    end loop;

    T2 := CLOCK;
    DT := T2 - T1;

    PUT_LINE( "----- CLOCK DELTA -----" );
    DUR_IO.PUT( LONG_FLOAT( DT ), FORE => 1, AFT => 9, EXP => 2 );
    NEW_LINE;

    if T2 >= T1 then
      PUT_LINE( "CLOCK ORDER OK" );
    else
      PUT_LINE( "CLOCK ORDER ERROR" );
    end if;
  end;

end	TEST_CALENDAR;
	-------------
