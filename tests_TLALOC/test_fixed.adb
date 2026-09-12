with TEXT_IO;
use  TEXT_IO;
		----------
procedure		TEST_FIXED
is		----------

--  type DURAT_ION		is delta 2.0**(-29) range -2.0**34 .. 2.0**34 - 1.0;

--  type SUPPLY_VOLTAGE	is delta 0.001	range -12.0 .. +12.0;
--  type SUPPLY_CURRENT	is delta 0.000_3	range 0.0 .. 2.0;
--  type SUPPLY_POWER		is delta 0.1	range -50.0 .. 70.0;

--  package INT_IO	is new INTEGER_IO( INTEGER );
--  package POWER_IO	is new FIXED_IO( SUPPLY_POWER );
--  package DUR_IO	is new FIXED_IO( DURATION );

--  type SCOPE_SIZES		is delta 0.000_015	range 0.0 .. 0.1;
--  type DUREE		is delta 2.0**(-29)	range -(2.0**34 - 1.0) .. 2.0**34;

--  V	: SUPPLY_VOLTAGE	:= 1.5;
--  I	: SUPPLY_CURRENT	:= 0.7;
--  P	: SUPPLY_POWER	:= 15.5;
--  ENT_P	: INTEGER;


  package LF_IO is new TEXT_IO.FLOAT_IO( LONG_FLOAT );

  D0	: DURATION	:= 0.0;
  D1	: DURATION	:= 1.0;
  D2	: DURATION	:= 0.5;
  D3	: DURATION	:= 86400.0;
  D4	: DURATION	:= -1.0;
  D5	: DURATION	:= -0.5;
  D6	: DURATION	:= -86400.0;
  D_MIN	: DURATION	:= -17179869184.0;

  I0	: LONG_INTEGER	:= 0;
  I1	: LONG_INTEGER	:= 1;
  I2	: LONG_INTEGER	:= -1;
  I3	: LONG_INTEGER	:= 86400;
  I4	: LONG_INTEGER	:= -86400;

  C0	: DURATION	:= DURATION( I0 );
  C1	: DURATION	:= DURATION( I1 );
  C2	: DURATION	:= DURATION( I2 );
  C3	: DURATION	:= DURATION( I3 );
  C4	: DURATION	:= DURATION( I4 );

begin
  PUT_LINE( "     ----- FIXED -> FLOAT -----" );

  LF_IO.PUT( LONG_FLOAT( D0 ),    FORE=> 1, AFT=> 6, EXP=> 2 ); NEW_LINE;
  LF_IO.PUT( LONG_FLOAT( D1 ),    FORE=> 1, AFT=> 6, EXP=> 2 ); NEW_LINE;
  LF_IO.PUT( LONG_FLOAT( D2 ),    FORE=> 1, AFT=> 6, EXP=> 2 ); NEW_LINE;
  LF_IO.PUT( LONG_FLOAT( D3 ),    FORE=> 1, AFT=> 6, EXP=> 2 ); NEW_LINE;
  LF_IO.PUT( LONG_FLOAT( D4 ),    FORE=> 1, AFT=> 6, EXP=> 2 ); NEW_LINE;
  LF_IO.PUT( LONG_FLOAT( D5 ),    FORE=> 1, AFT=> 6, EXP=> 2 ); NEW_LINE;
  LF_IO.PUT( LONG_FLOAT( D6 ),    FORE=> 1, AFT=> 6, EXP=> 2 ); NEW_LINE;
  LF_IO.PUT( LONG_FLOAT( D_MIN ), FORE=> 1, AFT=> 6, EXP=> 2 ); NEW_LINE;

  PUT_LINE( "     ----- INTEGER -> FIXED -----" );

  LF_IO.PUT( LONG_FLOAT( C0 ), FORE => 1, AFT => 6, EXP => 2 );
  TEXT_IO.NEW_LINE;

  LF_IO.PUT( LONG_FLOAT( C1 ), FORE => 1, AFT => 6, EXP => 2 );
  TEXT_IO.NEW_LINE;

  LF_IO.PUT( LONG_FLOAT( C2 ), FORE => 1, AFT => 6, EXP => 2 );
  TEXT_IO.NEW_LINE;

  LF_IO.PUT( LONG_FLOAT( C3 ), FORE => 1, AFT => 6, EXP => 2 );
  TEXT_IO.NEW_LINE;

  LF_IO.PUT( LONG_FLOAT( C4 ), FORE => 1, AFT => 6, EXP => 2 );
  TEXT_IO.NEW_LINE;

  PUT_LINE( "     ----- FIXED -> INTEGER -----" );

  declare
    D0    : DURATION := 0.0;
    D1    : DURATION := 1.0;
    D2    : DURATION := 0.4;
    D3    : DURATION := 0.5;
    D4    : DURATION := 0.6;
    D5    : DURATION := 1.4;
    D6    : DURATION := 1.5;
    D7    : DURATION := 1.6;

    D8    : DURATION := -0.4;
    D9    : DURATION := -0.5;
    D10   : DURATION := -0.6;
    D11   : DURATION := -1.4;
    D12   : DURATION := -1.5;
    D13   : DURATION := -1.6;

    D_MIN : DURATION := -17179869184.0;
    D_MAX : DURATION :=  17179869183.0;

    package LONGINT_IO is new TEXT_IO.INTEGER_IO( LONG_INTEGER );
    use LONGINT_IO;
  begin
    LONGINT_IO.PUT( LONG_INTEGER( D0 ) ); NEW_LINE;
    LONGINT_IO.PUT( LONG_INTEGER( D1 ) ); NEW_LINE;

    LONGINT_IO.PUT( LONG_INTEGER( D2 ) ); NEW_LINE;
    LONGINT_IO.PUT( LONG_INTEGER( D3 ) ); NEW_LINE;
    LONGINT_IO.PUT( LONG_INTEGER( D4 ) ); NEW_LINE;
    LONGINT_IO.PUT( LONG_INTEGER( D5 ) ); NEW_LINE;
    LONGINT_IO.PUT( LONG_INTEGER( D6 ) ); NEW_LINE;
    LONGINT_IO.PUT( LONG_INTEGER( D7 ) ); NEW_LINE;

    LONGINT_IO.PUT( LONG_INTEGER( D8 ) ); NEW_LINE;
    LONGINT_IO.PUT( LONG_INTEGER( D9 ) ); NEW_LINE;
    LONGINT_IO.PUT( LONG_INTEGER( D10 ) ); NEW_LINE;
    LONGINT_IO.PUT( LONG_INTEGER( D11 ) ); NEW_LINE;
    LONGINT_IO.PUT( LONG_INTEGER( D12 ) ); NEW_LINE;
    LONGINT_IO.PUT( LONG_INTEGER( D13 ) ); NEW_LINE;

    LONGINT_IO.PUT( LONG_INTEGER( D_MIN ) ); NEW_LINE;
    LONGINT_IO.PUT( LONG_INTEGER( D_MAX ) ); NEW_LINE;
  end;

  PUT_LINE( "     ----- FIXED -> FIXED (SMALL IDENTIQUES) -----" );

  declare
    A	: DURATION	:= 10.5;
    B	: DURATION	:= 2.25;

    C	: DURATION;
    D	: DURATION;

  begin
    C := A + B;
    D := A - B;

    LF_IO.PUT( LONG_FLOAT( C ), FORE => 1, AFT => 6, EXP => 2 ); NEW_LINE;
    LF_IO.PUT( LONG_FLOAT( D ), FORE => 1, AFT => 6, EXP => 2 ); NEW_LINE;

    if A > B then
      LF_IO.PUT( 1.0, FORE => 1, AFT => 1, EXP => 2 );
    else
      LF_IO.PUT( 0.0, FORE => 1, AFT => 1, EXP => 2 );
    end if;
    NEW_LINE;

    if A = B then
      LF_IO.PUT( 0.0, FORE => 1, AFT => 1, EXP => 2 );
    else
      LF_IO.PUT( 1.0, FORE => 1, AFT => 1, EXP => 2 );
    end if;
    NEW_LINE;
  end;

  PUT_LINE( "     ----- FLOAT -> FIXED -----" );

  declare
    F0 : LONG_FLOAT := 0.0;
    F1 : LONG_FLOAT := 1.0;
    F2 : LONG_FLOAT := 0.5;
    F3 : LONG_FLOAT := 86400.0;
    F4 : LONG_FLOAT := -1.0;
    F5 : LONG_FLOAT := -0.5;
    F6 : LONG_FLOAT := -86400.0;
    F7	: LONG_FLOAT	:= 0.123456789;
    F8	: LONG_FLOAT	:= 0.999999999;

    X0	: DURATION	:= DURATION( F0 );
    X1	: DURATION	:= DURATION( F1 );
    X2	: DURATION	:= DURATION( F2 );
    X3	: DURATION	:= DURATION( F3 );
    X4	: DURATION	:= DURATION( F4 );
    X5	: DURATION	:= DURATION( F5 );
    X6	: DURATION	:= DURATION( F6 );
    X7	: DURATION	:= DURATION( F7 );
    X8	: DURATION	:= DURATION( F8 );
  begin
    LF_IO.PUT( LONG_FLOAT( X0 ), FORE=> 1, AFT=> 6, EXP=> 2 ); NEW_LINE;
    LF_IO.PUT( LONG_FLOAT( X1 ), FORE=> 1, AFT=> 6, EXP=> 2 ); NEW_LINE;
    LF_IO.PUT( LONG_FLOAT( X2 ), FORE=> 1, AFT=> 6, EXP=> 2 ); NEW_LINE;
    LF_IO.PUT( LONG_FLOAT( X3 ), FORE=> 1, AFT=> 6, EXP=> 2 ); NEW_LINE;
    LF_IO.PUT( LONG_FLOAT( X4 ), FORE=> 1, AFT=> 6, EXP=> 2 ); NEW_LINE;
    LF_IO.PUT( LONG_FLOAT( X5 ), FORE=> 1, AFT=> 6, EXP=> 2 ); NEW_LINE;
    LF_IO.PUT( LONG_FLOAT( X6 ), FORE=> 1, AFT=> 6, EXP=> 2 ); NEW_LINE;
    LF_IO.PUT( LONG_FLOAT( X7 ), FORE=> 1, AFT=> 6, EXP=> 2 ); NEW_LINE;
    LF_IO.PUT( LONG_FLOAT( X8 ), FORE=> 1, AFT=> 6, EXP=> 2 ); NEW_LINE;

  end;

  PUT_LINE( "END FIXED TEST" );

end	TEST_FIXED;
	----------
