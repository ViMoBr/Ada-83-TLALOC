------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2
with TEXT_IO; use TEXT_IO;

with MACHINE_CODE;	use MACHINE_CODE;
					--------
package body				CALENDAR
is					--------

package LONGINT_IO is new INTEGER_IO( LONG_INTEGER );

	------------------------------------------------------------------
	-- Représentation interne :
	--   TIME = Q35.29 signé, epoch 1900-01-01 00:00:00 UTC
	--   Unité = 1 / 2**29 s  (≈ 1.86 ns par tick, correspond au 'SMALL)
	--   Plage = ±2**34 s ≈ ±544 ans autour de 1900
	--
	--   DURATION (dans STANDARD) = même 'SMALL = 2**(-29)
	--   defini danz STANDARD : type _duration is delta 2.0**(-29) range -(2.0**34 - 1.0) .. 2.0**34;
	--   donc TIME - TIME donne DURATION et TIME + DURATION donne TIME
	--   sont de simples soustractions/additions d'entiers 64 bits.
	------------------------------------------------------------------

  EPOCH_DIFF_S	:constant LONG_INTEGER	:= 2_208_988_800;						-- Décalage entre l'epoch Unix (1970) et notre epoch (1900), en secondes
  SCALE		:constant LONG_INTEGER	:= 16#2000_0000#;						-- 2**29 (échelle de la fraction Q35.29)
  DAYS_1900	:constant LONG_INTEGER	:= 693_901;						-- Décalage en jours : 1900-01-01 depuis l'epoch Hinnant (0000-03-01)
  SECONDS_PER_DAY	:constant LONG_INTEGER	:= 86_400;
  NS_PER_SEC	:constant LONG_INTEGER	:= 1_000_000_000;


			--------------
  function		DAYS_FROM_CIVIL	( Y_IN, M_IN, D_IN :LONG_INTEGER )	return LONG_INTEGER		-- Algorithme Hinnant DAYS_FROM_CIVIL : (Y, M, D) → jours depuis 0000-03-01.
  is			---------------								-- Domaine de validité : toutes dates grégoriennes proleptiques.
    Y, M_ADJ, ERA, YOE, DOY, DOE	: LONG_INTEGER;							-- Arithmétique entière pure, sans branche significative.

  begin
    if  M_IN <= 2  then
      Y     := Y_IN - 1;
      M_ADJ := M_IN + 9;										-- janvier=10, février=11 (de l'année précédente)
    else
      Y     := Y_IN;
      M_ADJ := M_IN - 3;										-- mars=0, avril=1, ..., décembre=9
    end if;

    if  Y >= 0  then
      ERA := Y / 400;
    else
      ERA := (Y - 399) / 400;
    end if;
    YOE := Y - ERA * 400;										-- [7FFD907EF1F00..399]
    DOY := (153 * M_ADJ + 2) / 5 + D_IN - 1;								-- [0..365]
    DOE := YOE * 365 + YOE / 4 - YOE / 100 + DOY;								-- [0..146096]
    return  ERA * 146_097 + DOE;

  end	DAYS_FROM_CIVIL;
	---------------


			---------------
  procedure		CIVIL_FROM_DAYS	( DAYS	:in LONG_INTEGER;					-- Algorithme Hinnant CIVIL_FROM_DAYS : jours depuis 0000-03-01 → (Y, M, D).
					  Y, M, D	:out LONG_INTEGER )
  is			---------------
    ERA, DOE, YOE, Y_OUT, DOY, MP, M_OUT, D_OUT	: LONG_INTEGER;
    TMP					: LONG_INTEGER;

  begin

--PUT( "CIVIL_FROM_DAYS DAYS : " ); LONGINT_IO.PUT( DAYS ); NEW_LINE;

    if  DAYS >= 0  then
      TMP := DAYS;
    else
      TMP := DAYS - 146_096;
    end if;
    ERA := TMP / 146_097;
    DOE := DAYS - ERA * 146_097;									-- [0..146096]
    YOE := (DOE - DOE/1460 + DOE/36524 - DOE/146096) / 365;							-- [0..399]
    Y_OUT := YOE + ERA * 400;
    DOY := DOE - (365 * YOE + YOE/4 - YOE/100);								-- [0..365]
    MP  := (5 * DOY + 2) / 153;									-- [0..11]
    D_OUT := DOY - (153 * MP + 2) / 5 + 1;								-- [1..31]
    if  MP < 10  then
      M_OUT := MP + 3;
    else
      M_OUT := MP - 9;
      Y_OUT := Y_OUT + 1;
    end if;
    Y := Y_OUT;
    M := M_OUT;
    D := D_OUT;

--PUT( "CIVIL_FROM_DAYS Y : " ); LONGINT_IO.PUT( Y ); NEW_LINE;
--PUT( "CIVIL_FROM_DAYS M : " ); LONGINT_IO.PUT( M ); NEW_LINE;
--PUT( "CIVIL_FROM_DAYS D : " ); LONGINT_IO.PUT( D ); NEW_LINE;

  end	CIVIL_FROM_DAYS;
	---------------


			-----
  function		CLOCK		return TIME
  is			-----

    type LINUX_TIMEVAL	is record
			  SEC, NANOSEC	: LONG_INTEGER;
			end record;
    LTV		: LINUX_TIMEVAL;
    T		: LONG_INTEGER;

		---------------
    procedure	GETTIME_SYSCALL	( TV :out LINUX_TIMEVAL )
    is		---------------
    begin
        ASM_OP_2'( OPCODE=> LIa, LVL=> 2, OFS=> -8 );
        ASM_OP_0'( OPCODE=> SYS_CLOCK_GETTIME );

    end	GETTIME_SYSCALL;
	---------------

  begin
    GETTIME_SYSCALL( LTV );
    T := (LTV.SEC + EPOCH_DIFF_S) * SCALE + (LTV.NANOSEC * SCALE) / NS_PER_SEC;

--PUT( "CLOCK : " ); LONGINT_IO.PUT( LONG_INTEGER( T ), 25, 16 ); NEW_LINE;
--PUT( "SECONDES : " ); LONGINT_IO.PUT( LTV.SEC ); NEW_LINE;
--PUT( "NANO-SECONDES : " ); LONGINT_IO.PUT( LTV.NANOSEC ); NEW_LINE;
--PUT( "ANNEES (depuis 1970) : " ); LONGINT_IO.PUT( LTV.SEC / 86400 / 365 ); NEW_LINE;

    return TIME( T );

  end	CLOCK;
	-----


			----
  function		YEAR		( DATE :TIME )		return YEAR_NUMBER
  is			----
    Y, M, D, S	: LONG_INTEGER;
  begin
    declare
      SECONDS_TOTAL, FRAC, DAYS_FROM_1900	: LONG_INTEGER;
    begin
--PUT( "YEAR DATE : " ); LONGINT_IO.PUT( LONG_INTEGER( DATE ), 25, 16 ); NEW_LINE;
      SECONDS_TOTAL   := LONG_INTEGER( DATE ) / SCALE;
--PUT( "YEAR SECONDS_TOTAL : " ); LONGINT_IO.PUT( SECONDS_TOTAL ); NEW_LINE;
      DAYS_FROM_1900  := SECONDS_TOTAL / SECONDS_PER_DAY;
--PUT( "YEAR DAYS_FROM_1900 : " ); LONGINT_IO.PUT( DAYS_FROM_1900 ); NEW_LINE;

      CIVIL_FROM_DAYS( DAYS_FROM_1900 + DAYS_1900, Y, M, D );
    end;
    return YEAR_NUMBER( Y );

  end	YEAR;
	----


			-----
  function		MONTH		( DATE :TIME )		return MONTH_NUMBER
  is			-----
    Y, M, D			: LONG_INTEGER;
    SECONDS_TOTAL, DAYS_FROM_1900	: LONG_INTEGER;
  begin
    SECONDS_TOTAL  := LONG_INTEGER( DATE ) / SCALE;
    DAYS_FROM_1900 := SECONDS_TOTAL / SECONDS_PER_DAY;
    CIVIL_FROM_DAYS( DAYS_FROM_1900 + DAYS_1900, Y, M, D );
    return MONTH_NUMBER( M );

  end	MONTH;
	-----


			---
  function		DAY		( DATE :TIME )		return DAY_NUMBER
  is			---
    Y, M, D			: LONG_INTEGER;
    SECONDS_TOTAL, DAYS_FROM_1900	: LONG_INTEGER;
  begin
    SECONDS_TOTAL  := LONG_INTEGER( DATE ) / SCALE;
    DAYS_FROM_1900 := SECONDS_TOTAL / SECONDS_PER_DAY;
    CIVIL_FROM_DAYS( DAYS_FROM_1900 + DAYS_1900, Y, M, D );
    return DAY_NUMBER( D );

  end	DAY;
	---


			-------
  function		SECONDS		( DATE :TIME )		return DAY_DURATION
  is			-------
    -- Renvoie le nombre de secondes écoulées depuis minuit du jour de DATE.
    -- Le résultat est exprimé en DURATION (Q35.29) :
    --   sec_in_day * 2**29 + (frac dans la seconde courante)
    T, SEC_TOTAL, FRAC_PART, SEC_OF_DAY, RESULT	: LONG_INTEGER;
  begin
    T          := LONG_INTEGER( DATE );
    SEC_TOTAL  := T / SCALE;
    FRAC_PART  := T - SEC_TOTAL * SCALE;								-- Dans [0..2**29-1]

PUT( "T : " ); LONGINT_IO.PUT( T ); NEW_LINE;
PUT( "SEC_TOTAL : " ); LONGINT_IO.PUT( SEC_TOTAL ); NEW_LINE;
PUT( "FRAC_PART : " ); LONGINT_IO.PUT( FRAC_PART ); NEW_LINE;


    SEC_OF_DAY := SEC_TOTAL rem SECONDS_PER_DAY;

PUT( "SEC_OF_DAY : " ); LONGINT_IO.PUT( SEC_OF_DAY ); NEW_LINE;

    if  SEC_OF_DAY < 0  then										-- normaliser pour DATE < 1900
      SEC_OF_DAY := SEC_OF_DAY + SECONDS_PER_DAY;
    end if;
    RESULT := SEC_OF_DAY; -- * SCALE + FRAC_PART;

PUT( "RESULT : " ); LONGINT_IO.PUT( RESULT ); NEW_LINE;

    return  DAY_DURATION( DURATION( RESULT ) );

  end	SECONDS;
	-------


			-----
  procedure		SPLIT		( DATE	:in TIME;
					  YEAR	:out YEAR_NUMBER;
					  MONTH	:out MONTH_NUMBER;
					  DAY	:out DAY_NUMBER;
					  SECONDS	:out DAY_DURATION
					)
  is			-----
    Y, M, D				: LONG_INTEGER;
    T, SEC_TOTAL, FRAC_PART, DAYS_FROM_1900,
    SEC_OF_DAY, DUR_INTERNAL			: LONG_INTEGER;

  begin
    T              := LONG_INTEGER( DATE );
    SEC_TOTAL      := T / SCALE;
    FRAC_PART      := T - SEC_TOTAL * SCALE;
    DAYS_FROM_1900 := SEC_TOTAL / SECONDS_PER_DAY;
    SEC_OF_DAY     := SEC_TOTAL - DAYS_FROM_1900 * SECONDS_PER_DAY;


    if  SEC_OF_DAY < 0  then		   								-- Si DATE < 1900-01-01 (T négatif), normaliser pour avoir
      SEC_OF_DAY     := SEC_OF_DAY + SECONDS_PER_DAY;	 						-- SEC_OF_DAY dans [0..86400) et DAYS_FROM_1900 entier correct.
      DAYS_FROM_1900 := DAYS_FROM_1900 - 1;
    end if;
    if  FRAC_PART < 0  then										-- ne devrait pas arriver
      FRAC_PART      := FRAC_PART + SCALE;
      SEC_OF_DAY     := SEC_OF_DAY - 1;
      if  SEC_OF_DAY < 0  then
        SEC_OF_DAY     := SEC_OF_DAY + SECONDS_PER_DAY;
        DAYS_FROM_1900 := DAYS_FROM_1900 - 1;
      end if;
    end if;

    CIVIL_FROM_DAYS( DAYS_FROM_1900 + DAYS_1900, Y, M, D );

    DUR_INTERNAL := SEC_OF_DAY * SCALE + FRAC_PART;
    YEAR := YEAR_NUMBER( Y );
    MONTH	:= MONTH_NUMBER( M );
    DAY := DAY_NUMBER( D );
    SECONDS := DAY_DURATION( DURATION( DURATION'SMALL ) * DURATION( DUR_INTERNAL ) );

  end	SPLIT;
	-----


			-------
  function		TIME_OF		( YEAR	: YEAR_NUMBER;
					  MONTH	: MONTH_NUMBER;
					  DAY	: DAY_NUMBER;
					  SECONDS	: DAY_DURATION := 0.0 )	return TIME
  is			-------
    DAYS_FROM_HINNANT, DAYS_FROM_1900_LOCAL,
    DUR_INTERNAL, T				: LONG_INTEGER;

  begin

    DAYS_FROM_HINNANT := DAYS_FROM_CIVIL( LONG_INTEGER( YEAR ), LONG_INTEGER( MONTH ), LONG_INTEGER( DAY ) );		-- Calcul des jours depuis 0000-03-01 puis depuis 1900-01-01.
    DAYS_FROM_1900_LOCAL := DAYS_FROM_HINNANT - DAYS_1900;

    -- Conversion SECONDS (DAY_DURATION) en représentation Q35.29 entière.
    -- Comme DURATION'SMALL = 2**(-29), la valeur interne est SECONDS / 2**(-29)
    -- = SECONDS * 2**29, qu'on obtient par division par 'SMALL.
    DUR_INTERNAL := LONG_INTEGER( SECONDS / DAY_DURATION( DURATION'SMALL ) );

    T := DAYS_FROM_1900_LOCAL * SECONDS_PER_DAY * SCALE + DUR_INTERNAL;
    return TIME( T );

  exception
    when others =>
      raise TIME_ERROR;

  end	TIME_OF;
	-------


			---
  function		"+"		( LEFT : TIME;	RIGHT : DURATION )	return TIME
  is			---
    -- LEFT et RIGHT ont la même échelle binaire (Q35.29).
    -- Addition = simple add 64 bits. Conversion via 'SMALL identique.
    DUR_INTERNAL	: LONG_INTEGER;
  begin
    DUR_INTERNAL := LONG_INTEGER( RIGHT / DURATION( DURATION'SMALL ) );
    return TIME( LONG_INTEGER( LEFT ) + DUR_INTERNAL );
  exception
    when others =>
      raise TIME_ERROR;

  end	"+";
	---


			---
  function		"+"		( LEFT : DURATION; RIGHT : TIME )	return TIME
  is			---
  begin
    return RIGHT + LEFT;
  end	"+";
	---


			---
  function		"-"		( LEFT : TIME; RIGHT : DURATION )	return TIME
  is			---
    DUR_INTERNAL	: LONG_INTEGER;

  begin
    DUR_INTERNAL := LONG_INTEGER( RIGHT / DURATION( DURATION'SMALL ) );
    return  TIME( LONG_INTEGER( LEFT ) - DUR_INTERNAL );
  exception
    when others =>
      raise TIME_ERROR;

  end	"-";
	---


			---
  function		"-"		( LEFT : TIME; RIGHT : TIME )		return DURATION
  is			---
    DELTA_INTERNAL	: LONG_INTEGER;

  begin
    DELTA_INTERNAL := LONG_INTEGER( LEFT ) - LONG_INTEGER( RIGHT );
    return  DURATION( DURATION( DURATION'SMALL ) * DURATION( DELTA_INTERNAL ) );
  exception
    when others =>
      raise TIME_ERROR;

  end	"-";
	---


			---
  function		"<"		( LEFT, RIGHT : TIME )		return BOOLEAN
  is			---
  begin
    return LONG_INTEGER( LEFT ) < LONG_INTEGER( RIGHT );
  end	"<";
	---


			----
  function		"<="		( LEFT, RIGHT : TIME )		return BOOLEAN
  is			----
  begin
    return LONG_INTEGER( LEFT ) <= LONG_INTEGER( RIGHT );
  end	"<=";
	----


			---
  function		">"		( LEFT, RIGHT : TIME )		return BOOLEAN
  is			---
  begin
    return LONG_INTEGER( LEFT ) > LONG_INTEGER( RIGHT );
  end	">";
	---


			----
  function		">="		( LEFT, RIGHT : TIME )		return BOOLEAN
  is			----
  begin
    return LONG_INTEGER( LEFT ) >= LONG_INTEGER( RIGHT );
  end	">=";
	----


	--------
end	CALENDAR;
	--------

