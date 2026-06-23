-- C45651A.ADA

-- FOR FIXED POINT TYPES, CHECK:
--      (A) FOR MODEL NUMBERS A >= 0.0, THAT ABS A = A.
--      (B) FOR MODEL NUMBERS A <= 0.0. THAT ABS A = -A.
--      (C) FOR NON-MODEL NUMBERS A > 0.0, THAT ABS A VALUES ARE WITHIN
--          THE APPROPRIATE MODEL INTERVAL.
--      (D) FOR NON-MODEL NUMBERS A < 0.0, THAT ABS A VALUES ARE WITHIN
--          THE APPROPRIATE MODEL INTERVAL.

-- CASE A: BASIC TYPES THAT FIT THE CHARACTERISTICS OF DURATION'BASE.

-- WRG 9/11/86
-- PWB 3/31/88  CHANGED RANGE FOR MEMBERSHIP TEST INVOLVING
--              ABS (DECIMAL_M4'FIRST + DECIMAL_M4'SMALL / 2).


WITH REPORT; USE REPORT;
PROCEDURE C45651A IS

     -- THE NAME OF EACH TYPE OR SUBTYPE ENDS WITH THAT TYPE'S
     -- 'MANTISSA VALUE.

BEGIN

     TEST ("C45651A", "CHECK THAT, FOR FIXED POINT TYPES, THE ABS " &
                      "OPERATOR PRODUCES CORRECT RESULTS - BASIC " &
                      "TYPES");

     -------------------------------------------------------------------

A:   DECLARE
          TYPE LIKE_DURATION_M23 IS DELTA 0.020
               RANGE -86_400.0 .. 86_400.0;

          NON_MODEL_CONST : CONSTANT          := 2.0 / 3;
          NON_MODEL_VAR   : LIKE_DURATION_M23 := 0.0;

          SMALL, MAX, MIN, ZERO : LIKE_DURATION_M23 := 0.5;
          X                     : LIKE_DURATION_M23 := 1.0;
     BEGIN
          -- INITIALIZE "CONSTANTS":
          IF EQUAL (3, 3) THEN
               SMALL         := LIKE_DURATION_M23'SMALL;
               MAX           := LIKE_DURATION_M23'LAST;
               MIN           := LIKE_DURATION_M23'FIRST;
               ZERO          := 0.0;
               NON_MODEL_VAR := NON_MODEL_CONST;
          END IF;

          -- (A)
          IF EQUAL (3, 3) THEN
               X := SMALL;
          END IF;
          IF ABS X /= SMALL OR X /= ABS LIKE_DURATION_M23'SMALL THEN
               FAILED ("ABS (1.0 / 64) /= (1.0 / 64)");
          END IF;
          IF EQUAL (3, 3) THEN
               X := MAX;
          END IF;
          IF ABS X /= MAX OR X /= ABS LIKE_DURATION_M23'LAST THEN
               FAILED ("ABS 86_400.0 /= 86_400.0");
          END IF;

          -- (B)
          IF EQUAL (3, 3) THEN
               X := -SMALL;
          END IF;
          IF ABS X /= SMALL OR
             ABS (-LIKE_DURATION_M23'SMALL) /= SMALL THEN
               FAILED ("ABS -(1.0 / 64) /= (1.0 / 64)");
          END IF;
          IF EQUAL (3, 3) THEN
               X := MIN;
          END IF;
          IF ABS X /= MAX OR ABS LIKE_DURATION_M23'FIRST /= MAX THEN
               FAILED ("ABS -86_400.0 /= 86_400.0");
          END IF;

          -- (A) AND (B)
          IF EQUAL (3, 3) THEN
               X := 0.0;
          END IF;
          IF "ABS" (RIGHT => X) /= ZERO OR X /= ABS 0.0 THEN
               FAILED ("ABS 0.0 /= 0.0 -- (LIKE_DURATION_M23)");
          END IF;

          -- CHECK THAT VALUE OF NON_MODEL_VAR IS IN THE RANGE
          -- 42 * 'SMALL .. 43 * 'SMALL:
          IF NON_MODEL_VAR NOT IN 0.65625 .. 0.671875 THEN
               FAILED ("VALUE OF NON_MODEL_VAR NOT IN CORRECT RANGE " &
                       "- A");
          END IF;

          -- (C)
          IF ABS NON_MODEL_VAR NOT IN 0.65625 .. 0.671875 OR
             ABS LIKE_DURATION_M23'(NON_MODEL_CONST) NOT IN
                 0.65625 .. 0.671875 THEN
               FAILED ("ABS (2.0 / 3) NOT IN CORRECT RANGE - A");
          END IF;
          IF EQUAL (3, 3) THEN
               X := 0.01;  -- INTERVAL IS 0.0 .. SMALL.
          END IF;
          IF ABS X NOT IN 0.0 .. LIKE_DURATION_M23'SMALL OR
             ABS LIKE_DURATION_M23'(0.01) NOT IN
                 0.0 .. LIKE_DURATION_M23'SMALL THEN
               FAILED ("ABS 0.01 NOT IN CORRECT RANGE");
          END IF;
          IF EQUAL (3, 3) THEN
               X := 86_399.992_187_5;  -- LIKE_DURATION_M23'LAST -
                                       -- 1.0 / 128.
          END IF;
          IF ABS X NOT IN 86_399.984_375 .. 86_400.0 OR
             ABS (LIKE_DURATION_M23'LAST - LIKE_DURATION_M23'SMALL / 2)
                 NOT IN 86_399.984_375 .. 86_400.0 THEN
               FAILED ("ABS (LIKE_DURATION_M23'LAST - " &
                       "LIKE_DURATION_M23'SMALL / 2) NOT IN CORRECT " &
                       "RANGE");
          END IF;

          -- (D)
          IF EQUAL (3, 3) THEN
               X := -NON_MODEL_CONST;
          END IF;
          IF ABS X NOT IN 0.65625 .. 0.671875 OR
             ABS (-LIKE_DURATION_M23'(NON_MODEL_CONST)) NOT IN
                 0.65625 .. 0.671875 THEN
               FAILED ("ABS (-2.0 / 3) NOT IN CORRECT RANGE - A");
          END IF;
          IF EQUAL (3, 3) THEN
               X := -0.01;  -- INTERVAL IS -SMALL..0.0.
          END IF;
          IF ABS X NOT IN 0.0 .. LIKE_DURATION_M23'SMALL OR
             ABS (-LIKE_DURATION_M23'(0.01)) NOT IN
                 0.0 .. LIKE_DURATION_M23'SMALL THEN
               FAILED ("ABS (-0.01) NOT IN CORRECT RANGE");
          END IF;
          IF EQUAL (3, 3) THEN
               X := -86_399.992_187_5;  -- LIKE_DURATION_M23'FIRST +
                                        -- 1.0 / 128.
          END IF;
          IF ABS X NOT IN 86_399.984_375 .. 86_400.0 OR
             ABS (LIKE_DURATION_M23'FIRST + LIKE_DURATION_M23'SMALL / 2)
                 NOT IN 86_399.984_375 .. 86_400.0 THEN
               FAILED ("ABS (LIKE_DURATION_M23'FIRST +" &
                       "LIKE_DURATION_M23'SMALL / 2) NOT IN CORRECT " &
                       "RANGE");
          END IF;
     END A;

     -------------------------------------------------------------------

B:   DECLARE
          TYPE DECIMAL_M4 IS DELTA 100.0 RANGE -1000.0 .. 1000.0;

          NON_MODEL_CONST : CONSTANT   := 2.0 / 3;
          NON_MODEL_VAR   : DECIMAL_M4 := 0.0;

          SMALL, MAX, MIN, ZERO : DECIMAL_M4 := 128.0;
          X                     : DECIMAL_M4 :=   0.0;
     BEGIN
          -- INITIALIZE "CONSTANTS":
          IF EQUAL (3, 3) THEN
               SMALL         :=  DECIMAL_M4'SMALL;
               MAX           :=  DECIMAL_M4'LARGE;
               MIN           := -DECIMAL_M4'LARGE;
               ZERO          :=  0.0;
               NON_MODEL_VAR := NON_MODEL_CONST;
          END IF;

          -- (A)
          IF EQUAL (3, 3) THEN
               X := SMALL;
          END IF;
          IF ABS X /= SMALL OR X /= ABS DECIMAL_M4'SMALL THEN
               FAILED ("ABS 64.0 /= 64.0");
          END IF;
          IF EQUAL (3, 3) THEN
               X := MAX;
          END IF;
          IF ABS X /= MAX OR X /= ABS DECIMAL_M4'LARGE THEN
               FAILED ("ABS 960.0 /= 960.0");
          END IF;

          -- (B)
          IF EQUAL (3, 3) THEN
               X := -SMALL;
          END IF;
          IF ABS X /= SMALL OR ABS (-DECIMAL_M4'SMALL) /= SMALL THEN
               FAILED ("ABS -64.0 /= 64.0");
          END IF;
          IF EQUAL (3, 3) THEN
               X := MIN;
          END IF;
          IF ABS X /= MAX OR ABS (-DECIMAL_M4'LARGE) /= MAX THEN
               FAILED ("ABS -960.0 /= 960.0");
          END IF;

          -- (A) AND (B)
          IF EQUAL (3, 3) THEN
               X := 0.0;
          END IF;
          IF ABS X /= ZERO OR X /= ABS 0.0 THEN
               FAILED ("ABS 0.0 /= 0.0 -- (DECIMAL_M4)");
          END IF;

          -- CHECK THE VALUE OF NON_MODEL_VAR:
          IF NON_MODEL_VAR NOT IN 0.0 .. 64.0 OR
             NON_MODEL_VAR NOT IN ZERO .. SMALL THEN
               FAILED ("VALUE OF NON_MODEL_VAR NOT IN CORRECT RANGE " &
                       "- B");
          END IF;

          -- (C)
          IF ABS NON_MODEL_VAR NOT IN 0.0 .. 64.0 OR
             ABS DECIMAL_M4'(NON_MODEL_CONST) NOT IN 0.0 .. 64.0 THEN
               FAILED ("ABS (2.0 / 3) NOT IN CORRECT RANGE - B");
          END IF;
          IF EQUAL (3, 3) THEN
               X := 37.0;  -- INTERVAL IS 0.0 .. 64.0.
          END IF;
          IF ABS X NOT IN 0.0 .. DECIMAL_M4'SMALL OR
             ABS DECIMAL_M4'(37.0) NOT IN 0.0 .. DECIMAL_M4'SMALL THEN
               FAILED ("ABS 37.0 NOT IN CORRECT RANGE");
          END IF;
          IF EQUAL (3, 3) THEN
               X := 928.0;
          END IF;
          IF ABS X NOT IN 896.0 .. 960.0 OR
             ABS (DECIMAL_M4'LAST - DECIMAL_M4'SMALL / 2) NOT IN
                 896.0 .. 960.0 THEN
               FAILED ("ABS 928.0 NOT IN CORRECT RANGE");
          END IF;

          -- (D)
          IF EQUAL (3, 3) THEN
               X := -NON_MODEL_CONST;
          END IF;
          IF ABS X NOT IN 0.0 .. 64.0 OR
             ABS (-DECIMAL_M4'(NON_MODEL_CONST)) NOT IN 0.0 .. 64.0 THEN
               FAILED ("ABS -(2.0 / 3) NOT IN CORRECT RANGE - B");
          END IF;
          IF EQUAL (3, 3) THEN
               X := -37.0;  -- INTERVAL IS -SMALL .. 0.0.
          END IF;
          IF ABS X NOT IN 0.0 .. DECIMAL_M4'SMALL OR
             ABS (-DECIMAL_M4'(37.0)) NOT IN 0.0 .. DECIMAL_M4'SMALL
             THEN
               FAILED ("ABS (-37.0) NOT IN CORRECT RANGE");
          END IF;
          IF EQUAL (3, 3) THEN
               X := -928.0;
          END IF;
          IF ABS X NOT IN 896.0 .. 960.0 OR
             ABS (DECIMAL_M4'FIRST + DECIMAL_M4'SMALL / 2) NOT IN
                 896.0 .. 1024.0 THEN
               FAILED ("ABS (-928.0) NOT IN CORRECT RANGE");
          END IF;
     END B;

     -------------------------------------------------------------------

     RESULT;

END C45651A;
