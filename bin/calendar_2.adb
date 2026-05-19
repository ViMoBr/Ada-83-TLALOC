					--------
package body				CALENDAR
is					--------


			-----
  function		CLOCK		return TIME
  is			-----
  begin
    return 0;

  end	CLOCK;
	-----


			----
  function		YEAR		( DATE: TIME )		return YEAR_NUMBER
  is			----
  begin
    return 0;

  end	YEAR;
	----


			-----
  function		MONTH		( DATE: TIME )		return MONTH_NUMBER
  is			-----
  begin
    return 0;

  end	MONTH;
	-----


			---
  function		DAY		( DATE: TIME )		return DAY_NUMBER
  is			---
  begin
    return 0;

  end	DAY;
	---


			-------
  function		SECONDS		( DATE: TIME )		return DAY_DURATION
  is			-------
  begin
    return 0.0;

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
  begin
    null;

  end	SPLIT;
	-----


			-------
  function		TIME_OF		( YEAR	: YEAR_NUMBER;
					  MONTH	: MONTH_NUMBER;
					  DAY	: DAY_NUMBER;
					  SECONDS	: DAY_DURATION := 0.0 )	return TIME
  is			-------
  begin
    null;

  end	TIME_OF;
	-------


			---
  function		"+"		( LEFT : TIME;	RIGHT : DURATION )	return TIME
  is			---
  begin
    return 0;

  end	"+";
	---


			---
  function		"+"		( LEFT : DURATION; RIGHT : TIME )	return TIME
  is			---
  begin
    return 0;

  end	"+";
	---


			---
  function		"-"		( LEFT : TIME; RIGHT : DURATION )	return TIME
  is			---
  begin
    return 0;

  end	"-";
	---


			---
  function		"-"		( LEFT : TIME; RIGHT : TIME )		return DURATION
  is			---
  begin
    return 0.0;

  end	"-";
	---


			---
  function		"<"		( LEFT, RIGHT : TIME )		return BOOLEAN
  is			---
  begin
    return TRUE;

  end	"<";
	---


			----
  function		"<="		( LEFT, RIGHT : TIME )		return BOOLEAN
  is			----
  begin
    return TRUE;

  end	"<=";
	---


			---
  function		">"		( LEFT, RIGHT : TIME )		return BOOLEAN
  is			---
  begin
    return TRUE;

  end	">";
	---


			----
  function		">="		( LEFT, RIGHT : TIME )		return BOOLEAN
  is			----
  begin
    return TRUE;

  end	">=";
	----


	--------
end	CALENDAR;
	--------
