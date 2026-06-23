-- C45331D.ADA

-- CHECK THAT FOR FIXED POINT TYPES THE OPERATORS "+" AND "-" PRODUCE
-- CORRECT RESULTS WHEN:
--      (A) A, B, A+B, AND A-B ARE ALL MODEL NUMBERS.
--      (B) A IS A MODEL NUMBER BUT B, A+B, AND A-B ARE NOT.
--      (C) A, B, A+B, AND A-B ARE ALL MODEL NUMBERS WITH DIFFERENT
--          SUBTYPES.

-- CASE D: TYPES TYPICAL OF APPLICATIONS USING FIXED POINT ARITHMETIC.

-- WRG 9/3/86

WITH REPORT; USE REPORT;
PROCEDURE C45331D IS

     TYPE TRACK_RANGE IS DELTA 0.125 RANGE -4096.0 .. 4096.0;
          -- 'MANTISSA = 15.
     SUBTYPE F     IS TRACK_RANGE DELTA 0.25 RANGE -1000.0 .. 1000.0;
     SUBTYPE ST_F1 IS F           DELTA 0.5  RANGE  -500.0 ..  500.0;
     SUBTYPE ST_F2 IS ST_F1       DELTA 1.0;

BEGIN

     TEST ("C45331D", "CHECK THAT FOR FIXED POINT TYPES THE " &
                      "OPERATORS ""+"" AND ""-"" PRODUCE CORRECT " &
                      "RESULTS - TYPICAL TYPES");

     COMMENT ("TRACK_RANGE'BASE'MANTISSA =" &
              INTEGER'IMAGE (TRACK_RANGE'BASE'MANTISSA));

     -------------------------------------------------------------------

A:   DECLARE
          SMALL, MAX, MIN, ZERO : F := 0.5;
          X                     : F := 0.0;
     BEGIN
          -- INITIALIZE "CONSTANTS":
          IF EQUAL (3, 3) THEN
               SMALL := F'SMALL;
               MAX   := F'LAST;  -- BECAUSE F'LAST < F'LARGE AND F'LAST
                                 -- IS A MODEL NUMBER.
               MIN   := F'FIRST; -- F'FIRST IS A MODEL NUMBER.
               ZERO  := 0.0;
          END IF;

          -- CHECK SMALL + OR - ZERO = SMALL:
          IF "+"(LEFT => SMALL, RIGHT => ZERO) /= SMALL OR
             0.0 + SMALL /= SMALL THEN
               FAILED ("F'SMALL + 0.0 /= F'SMALL");
          END IF;
          IF "-"(LEFT => SMALL, RIGHT => ZERO) /= SMALL OR
             SMALL - 0.0 /= SMALL THEN
               FAILED ("F'SMALL - 0.0 /= F'SMALL");
          END IF;

          -- CHECK MAX + OR - ZERO = MAX:
          IF MAX + ZERO /= MAX OR 0.0 + MAX /= MAX THEN
               FAILED ("F'LAST + 0.0 /= F'LAST");
          END IF;
          IF MAX - ZERO /= MAX OR MAX - 0.0 /= MAX THEN
               FAILED ("F'LAST - 0.0 /= F'LAST");
          END IF;

          -- CHECK SMALL - SMALL = 0.0:
          IF EQUAL (3, 3) THEN
               X := SMALL;
          END IF;
          IF SMALL - X /= 0.0 OR SMALL - SMALL /= 0.0 OR
             F'SMALL - F'SMALL /= 0.0 THEN
               FAILED ("F'SMALL - F'SMALL /= 0.0");
          END IF;

          -- CHECK MAX - MAX = 0.0:
          IF EQUAL (3, 3) THEN
               X := MAX;
          END IF;
          IF MAX - X /= 0.0 OR MAX - MAX /= 0.0 OR
             F'LAST - F'LAST /= 0.0 THEN
               FAILED ("F'LAST - F'LAST /= 0.0");
          END IF;

          -- CHECK ZERO - MAX = MIN, MIN - MIN = 0.0, AND MIN + MAX =
          -- 0.0:
          IF EQUAL (3, 3) THEN
               X := ZERO - MAX;
          END IF;
          IF X /= MIN THEN
               FAILED ("0.0 - 1000.0 /= -1000.0");
          END IF;
          IF EQUAL (3, 3) THEN
               X := MIN;
          END IF;
          IF MIN - X /= 0.0 OR MIN - MIN /= 0.0 OR
             F'FIRST - F'FIRST /= 0.0 THEN
               FAILED ("F'FIRST - F'FIRST /= 0.0");
          END IF;
          IF MIN + MAX /= 0.0 OR MAX + MIN /= 0.0 OR
             F'FIRST + F'LAST /= 0.0 THEN
               FAILED ("-1000.0 + 1000.0 /= 0.0");
          END IF;

          -- CHECK ADDITION AND SUBTRACTION FOR ARBITRARY MID-RANGE
          -- NUMBERS:
          IF EQUAL (3, 3) THEN
               X := 100.75;
          END IF;
          IF X + SMALL /= 101.0 OR SMALL + X /= 101.0 OR
             F'(100.75) + F'SMALL /= 101.0 THEN
               FAILED ("100.75 + 0.25 /= 101.0");
          END IF;
          IF 101.0 - X /= SMALL OR 101.0 - SMALL /= X OR
             101.0 - SMALL - X /= 0.0 THEN
               FAILED ("101.0 - 100.75 /= 0.25");
          END IF;

          -- CHECK (MAX - SMALL) + SMALL = MAX:
          IF EQUAL (3, 3) THEN
               X := MAX - SMALL;
          END IF;
          IF X /= 999.75 OR F'LAST - F'SMALL /= 999.75 THEN
               FAILED ("1000.0 - 0.25 /= 999.75");
               X := 999.75;
          END IF;
          IF X + SMALL /= MAX OR F'(999.75) + F'SMALL /= 1000.0 THEN
               FAILED ("999.75 + 0.25 /= 1000.0");
          END IF;

     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED - A");
     END A;

     -------------------------------------------------------------------

B:   DECLARE
          NON_MODEL_CONST : CONSTANT := 2.0 / 3;
          NON_MODEL_VAR   : F        := 0.0;

          SMALL, MAX, MIN, ZERO : F := 0.5;
          X                     : F := 0.0;
     BEGIN
          -- INITIALIZE "CONSTANTS":
          IF EQUAL (3, 3) THEN
               SMALL         := F'SMALL;
               MAX           := F'LAST;  -- BECAUSE F'LAST < F'LARGE AND
                                         -- F'LAST  IS A MODEL NUMBER.
               MIN           := F'FIRST; -- F'FIRST IS A MODEL NUMBER.
               ZERO          := 0.0;
               NON_MODEL_VAR := NON_MODEL_CONST;
          END IF;

          -- CHECK VALUE OF NON_MODEL_VAR:
          IF NON_MODEL_VAR NOT IN 0.5 .. 0.75 THEN
               FAILED ("VALUE OF NON_MODEL_VAR NOT IN CORRECT RANGE");
          END IF;

          -- CHECK NON-MODEL VALUE + OR - ZERO:
          IF NON_MODEL_VAR + ZERO NOT IN 0.5 .. 0.75 OR
             F'(0.0) + NON_MODEL_CONST NOT IN 0.5 .. 0.75 THEN
               FAILED ("(2.0 / 3) + 0.0 NOT IN 0.5 .. 0.75");
          END IF;
          IF NON_MODEL_VAR  - ZERO NOT IN 0.5 .. 0.75 OR
             NON_MODEL_CONST - F'(0.0) NOT IN 0.5 .. 0.75 THEN
               FAILED ("(2.0 / 3) - 0.0 NOT IN 0.5 .. 0.75");
          END IF;

          -- CHECK ZERO - NON-MODEL:
          IF F'(0.0) - NON_MODEL_CONST NOT IN -0.75 .. -0.5 THEN
               FAILED ("0.0 - (2.0 / 3) NOT IN -0.75 .. -0.5");
          END IF;

          -- CHECK MODEL + OR - NON-MODEL NEAR F'SMALL:
          IF SMALL + NON_MODEL_VAR NOT IN 0.75 .. 1.0 OR
             NON_MODEL_CONST + F'SMALL NOT IN 0.75 .. 1.0 THEN
               FAILED ("(2.0 / 3) + 0.25 NOT IN 0.75 .. 1.0");
          END IF;
          IF NON_MODEL_VAR - SMALL NOT IN 0.25 .. 0.5 THEN
               FAILED ("(2.0 / 3) - 0.25 NOT IN 0.25 .. 0.5");
          END IF;
          IF F'(1.0) - NON_MODEL_CONST NOT IN 0.25 .. 0.5 THEN
               FAILED ("1.0 - (2.0 / 3) NOT IN 0.25 .. 0.5");
          END IF;

          -- CHECK ADDITION AND SUBTRACTION OF NON-MODEL NEAR MIN AND
          -- MAX:
          IF MIN + NON_MODEL_VAR NOT IN -999.5 .. -999.25 OR
             NON_MODEL_CONST + F'FIRST NOT IN -999.5 .. -999.25 THEN
               FAILED ("-1000.0 + (2.0 / 3) NOT IN -999.5 .. -999.25");
          END IF;
          IF MAX - NON_MODEL_VAR NOT IN 999.25 .. 999.5 OR
             F'LAST - NON_MODEL_CONST NOT IN 999.25 .. 999.5 THEN
               FAILED ("1000.0 - (2.0 / 3) NOT IN 999.25 .. 999.5");
          END IF;

          -- CHECK ADDITION AND SUBTRACTION FOR ARBITRARY MID-RANGE
          -- MODEL NUMBER WITH NON-MODEL:
          IF EQUAL (3, 3) THEN
               X := -213.25;
          END IF;
          IF X + NON_MODEL_CONST NOT IN -212.75 .. -212.5 THEN
               FAILED ("-213.25 + (2.0 / 3) NOT IN -212.75 .. -212.5");
          END IF;
          IF NON_MODEL_VAR - X NOT IN 213.75 .. 214.0 THEN
               FAILED ("(2.0 / 3) - (-213.25) NOT IN 213.75 .. 214.0");
          END IF;

     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED - B");
     END B;

     -------------------------------------------------------------------

C:   DECLARE
          A_SMALL, A_MAX, A_MIN : ST_F1 := 0.0;
          B_SMALL, B_MAX, B_MIN : ST_F2 := 0.0;
          X                     : F;
     BEGIN
          -- INITIALIZE "CONSTANTS":
          IF EQUAL (3, 3) THEN
               A_SMALL := ST_F1'SMALL;
               A_MAX   := ST_F1'LAST;  -- BECAUSE 'LAST < 'LARGE AND
                                       -- 'LAST  IS A MODEL NUMBER.
               A_MIN   := ST_F1'FIRST; -- 'FIRST IS A MODEL NUMBER.

               B_SMALL := ST_F2'SMALL;
               B_MAX   := ST_F2'LAST;  -- BECAUSE 'LAST <= 'LARGE AND
                                       -- 'LAST  IS A MODEL NUMBER.
               B_MIN   := ST_F2'FIRST; -- 'FIRST IS A MODEL NUMBER.
          END IF;

          IF A_MIN + B_MIN /= -1000.0 THEN
               FAILED ("-500.0 + (-500.0) /= -1000.0");
          END IF;

          IF A_MIN - B_MIN /= 0.0 THEN
               FAILED ("-500.0 - (-500.0) /= 0.0");
          END IF;

          IF A_MIN + B_SMALL /= -499.0 THEN
               FAILED ("-500.0 + 1.0 /= -499.0");
          END IF;

          IF A_MIN - B_SMALL /= -501.0 THEN
               FAILED ("-500.0 - 1.0 /= -501.0");
          END IF;

          IF A_MIN + B_MAX /= 0.0 THEN
               FAILED ("-500.0 + 500.0 /= 0.0");
          END IF;

          IF A_MIN - B_MAX /= -1000.0 THEN
               FAILED ("-500.0 - 500.0 /= -1000.0");
          END IF;

          IF A_SMALL + B_MIN /= -499.5 THEN
               FAILED ("0.5 + (-500.0) /= -499.5");
          END IF;

          IF A_SMALL - B_MIN /= 500.5 THEN
               FAILED ("0.5 - (-500.0) /= 500.5");
          END IF;

          IF A_SMALL + B_SMALL /= 1.5 THEN
               FAILED ("0.5 + 1.0 /= 1.5");
          END IF;

          IF A_SMALL - B_SMALL /= -0.5 THEN
               FAILED ("0.5 - 1.0 /= -0.5");
          END IF;

          IF A_SMALL + B_MAX /= 500.5 THEN
               FAILED ("0.5 + 500.0 /= 500.5");
          END IF;

          IF A_SMALL - B_MAX /= -499.5 THEN
               FAILED ("0.5 - 500.0 /= -499.5");
          END IF;

          IF A_MAX + B_MIN /= 0.0 THEN
               FAILED ("500.0 + (-500.0) /= 0.0");
          END IF;

          IF A_MAX - B_MIN /= 1000.0 THEN
               FAILED ("500.0 - (-500.0) /= 1000.0");
          END IF;

          IF A_MAX + B_SMALL /= 501.0 THEN
               FAILED ("500.0 + 1.0 /= 501.0");
          END IF;

          IF A_MAX - B_SMALL /= 499.0 THEN
               FAILED ("500.0 - 1.0 /= 499.0");
          END IF;

          IF A_MAX + B_MAX /= 1000.0 THEN
               FAILED ("500.0 + 500.0 /= 1000.0");
          END IF;

          IF A_MAX - B_MAX /= 0.0 THEN
               FAILED ("500.0 - 500.0 /= 0.0");
          END IF;

          X := B_MIN - A_MIN;
          IF X /= 0.0 THEN
               FAILED ("B_MIN - A_MIN /= 0.0");
          END IF;

          X := B_MIN - A_SMALL;
          IF X /= -500.5 THEN
               FAILED ("B_MIN - A_SMALL /= -500.5");
          END IF;

          X := B_MIN - A_MAX;
          IF X /= -1000.0 THEN
               FAILED ("B_MIN - A_MAX /= -1000.0");
          END IF;

          X := B_SMALL - A_MIN;
          IF X /= 501.0 THEN
               FAILED ("B_SMALL - A_MIN /= 501.0");
          END IF;

          X := B_SMALL - A_SMALL;
          IF X /= 0.5 THEN
               FAILED ("B_SMALL - A_SMALL /= 0.5");
          END IF;

          X := B_SMALL - A_MAX;
          IF X /= -499.0 THEN
               FAILED ("B_SMALL - A_MAX /= -499.0");
          END IF;

          X := B_MAX - A_MIN;
          IF X /= 1000.0 THEN
               FAILED ("B_MAX - A_MIN /= 1000.0");
          END IF;

          X := B_MAX - A_SMALL;
          IF X /= 499.5 THEN
               FAILED ("B_MAX - A_SMALL /= 499.5");
          END IF;

          X := B_MAX - A_MAX;
          IF X /= 0.0 THEN
               FAILED ("B_MAX - A_MAX /= 0.0");
          END IF;

     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED - C");
     END C;

     -------------------------------------------------------------------

     RESULT;

END C45331D;
