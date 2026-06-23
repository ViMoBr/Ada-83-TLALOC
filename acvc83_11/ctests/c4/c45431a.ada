-- C45431A.ADA

-- CHECK THAT FOR FIXED POINT TYPES +A = A AND THAT, FOR MODEL NUMBERS,
-- -(-A) = A.

-- CASE A: BASIC TYPES THAT FIT THE CHARACTERISTICS OF DURATION'BASE.

-- WRG 8/28/86

WITH REPORT; USE REPORT;
PROCEDURE C45431A IS

BEGIN

     TEST ("C45431A", "CHECK THAT FOR FIXED POINT TYPES +A = A AND " &
                      "THAT, FOR MODEL NUMBERS, -(-A) = A " &
                      "-- BASIC TYPES");

     -------------------------------------------------------------------

A:   DECLARE
          TYPE LIKE_DURATION IS DELTA 0.020 RANGE -86_400.0 .. 86_400.0;

          NON_MODEL_CONST : CONSTANT      := 2.0 / 3;
          NON_MODEL_VAR   : LIKE_DURATION := 0.0;

          SMALL, MAX, MIN, ZERO : LIKE_DURATION := 0.5;
          X                     : LIKE_DURATION := 0.0;
     BEGIN
          -- INITIALIZE "CONSTANTS":
          IF EQUAL (3, 3) THEN
               NON_MODEL_VAR := NON_MODEL_CONST;
               SMALL         := LIKE_DURATION'SMALL;
               MAX           := LIKE_DURATION'LAST;
               MIN           := LIKE_DURATION'FIRST;
               ZERO          := 0.0;
          END IF;

          -- CHECK + OR - ZERO = ZERO:
          IF "+"(RIGHT => ZERO) /= 0.0 OR
             +LIKE_DURATION'(0.0) /= ZERO THEN
               FAILED ("+0.0 /= 0.0");
          END IF;
          IF "-"(RIGHT => ZERO) /= 0.0 OR
             -LIKE_DURATION'(0.0) /= ZERO THEN
               FAILED ("-0.0 /= 0.0");
          END IF;
          IF -(-ZERO) /= 0.0 THEN
               FAILED ("-(-0.0) /= 0.0");
          END IF;

          -- CHECK + AND - MAX:
          IF EQUAL (3, 3) THEN
               X := MAX;
          END IF;
          IF +X /= MAX OR +LIKE_DURATION'LAST /= MAX THEN
               FAILED ("+LIKE_DURATION'LAST /= LIKE_DURATION'LAST");
          END IF;
          IF -(-X) /= MAX OR -(-LIKE_DURATION'LAST) /= MAX THEN
               FAILED ("-(-LIKE_DURATION'LAST) /= LIKE_DURATION'LAST");
          END IF;

          -- CHECK + AND - MIN:
          IF EQUAL (3, 3) THEN
               X := MIN;
          END IF;
          IF +X /= MIN OR +LIKE_DURATION'FIRST /= MIN THEN
               FAILED ("+LIKE_DURATION'FIRST /= LIKE_DURATION'FIRST");
          END IF;
          IF -(-X) /= MIN OR -(-LIKE_DURATION'FIRST) /= MIN THEN
               FAILED("-(-LIKE_DURATION'FIRST) /= LIKE_DURATION'FIRST");
          END IF;

          -- CHECK + AND - SMALL:
          IF EQUAL (3, 3) THEN
               X := SMALL;
          END IF;
          IF +X /= SMALL OR +LIKE_DURATION'SMALL /= SMALL THEN
               FAILED ("+LIKE_DURATION'SMALL /= LIKE_DURATION'SMALL");
          END IF;
          IF -(-X) /= SMALL OR -(-LIKE_DURATION'SMALL) /= SMALL THEN
               FAILED("-(-LIKE_DURATION'SMALL) /= LIKE_DURATION'SMALL");
          END IF;

          -- CHECK ARBITRARY MID-RANGE NUMBERS:
          IF EQUAL (3, 3) THEN
               X := 1000.984_375;
          END IF;
          IF +X /= 1000.984_375 OR +1000.984_375 /= X THEN
               FAILED ("+1000.984_375 /= 1000.984_375");
          END IF;
          IF -(-X) /= 1000.984_375 OR -(-1000.984_375) /= X THEN
               FAILED ("-(-1000.984_375) /= 1000.984_375");
          END IF;

          -- CHECK "+" AND "-" FOR NON-MODEL NUMBER:
          IF +LIKE_DURATION'(NON_MODEL_CONST) NOT IN 0.656_25 ..
                                                     0.671_875 OR
             +NON_MODEL_VAR NOT IN 0.656_25 .. 0.671_875 THEN
               FAILED ("+LIKE_DURATION'(2.0 / 3) NOT IN 0.656_25 .. " &
                       "0.671_875");
          END IF;
          IF -LIKE_DURATION'(NON_MODEL_CONST) NOT IN -0.671_875 ..
                                                     -0.656_25 OR
             -NON_MODEL_VAR NOT IN -0.671_875 .. -0.656_25 THEN
               FAILED ("-LIKE_DURATION'(2.0 / 3) NOT IN -0.671_875 " &
                       ".. -0.656_25");
          END IF;

     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED -- A");
     END A;

     -------------------------------------------------------------------

B:   DECLARE
          TYPE DECIMAL_M4 IS DELTA 100.0 RANGE -1000.0 .. 1000.0;

          NON_MODEL_CONST : CONSTANT   := 2.0 / 3;
          NON_MODEL_VAR   : DECIMAL_M4 := 0.0;

          SMALL, MAX, MIN, ZERO : DECIMAL_M4 := -128.0;
          X                     : DECIMAL_M4 :=    0.0;
     BEGIN
          -- INITIALIZE "CONSTANTS":
          IF EQUAL (3, 3) THEN
               NON_MODEL_VAR :=  NON_MODEL_CONST;
               SMALL         :=  DECIMAL_M4'SMALL;
               MAX           :=  DECIMAL_M4'LARGE;
               MIN           := -DECIMAL_M4'LARGE;
               ZERO          :=  0.0;
          END IF;

          -- CHECK + OR - ZERO = ZERO:
          IF +ZERO /= 0.0 OR +DECIMAL_M4'(0.0) /= ZERO THEN
               FAILED ("+0.0 /= 0.0");
          END IF;
          IF -ZERO /= 0.0 OR -DECIMAL_M4'(0.0) /= ZERO THEN
               FAILED ("-0.0 /= 0.0");
          END IF;
          IF -(-ZERO) /= 0.0 THEN
               FAILED ("-(-0.0) /= 0.0");
          END IF;

          -- CHECK + AND - MAX:
          IF EQUAL (3, 3) THEN
               X := MAX;
          END IF;
          IF +X /= MAX OR +DECIMAL_M4'LARGE /= MAX THEN
               FAILED ("+DECIMAL_M4'LARGE /= DECIMAL_M4'LARGE");
          END IF;
          IF -(-X) /= MAX OR -(-DECIMAL_M4'LARGE) /= MAX THEN
               FAILED ("-(-DECIMAL_M4'LARGE) /= DECIMAL_M4'LARGE");
          END IF;

          -- CHECK + AND - MIN:
          IF EQUAL (3, 3) THEN
               X := MIN;
          END IF;
          IF +X /= MIN OR +(-DECIMAL_M4'LARGE) /= MIN THEN
               FAILED ("+(-DECIMAL_M4'LARGE) /= (-DECIMAL_M4'LARGE)");
          END IF;
          IF -(-X) /= MIN OR -(-(-DECIMAL_M4'LARGE)) /= MIN THEN
               FAILED("-(-(-DECIMAL_M4'LARGE)) /= (-DECIMAL_M4'LARGE)");
          END IF;

          -- CHECK + AND - SMALL:
          IF EQUAL (3, 3) THEN
               X := SMALL;
          END IF;
          IF +X /= SMALL OR +DECIMAL_M4'SMALL /= SMALL THEN
               FAILED ("+DECIMAL_M4'SMALL /= DECIMAL_M4'SMALL");
          END IF;
          IF -(-X) /= SMALL OR -(-DECIMAL_M4'SMALL) /= SMALL THEN
               FAILED ("-(-DECIMAL_M4'SMALL) /= DECIMAL_M4'SMALL");
          END IF;

          -- CHECK ARBITRARY MID-RANGE NUMBERS:
          IF EQUAL (3, 3) THEN
               X := 256.0;
          END IF;
          IF +X /= 256.0 OR +256.0 /= X THEN
               FAILED ("+256.0 /= 256.0");
          END IF;
          IF -(-X) /= 256.0 OR -(-256.0) /= X THEN
               FAILED ("-(-256.0) /= 256.0");
          END IF;

          -- CHECK "+" AND "-" FOR NON-MODEL NUMBER:
          IF +DECIMAL_M4'(NON_MODEL_CONST) NOT IN 0.0 .. 64.0 OR
             +NON_MODEL_VAR NOT IN 0.0 .. 64.0 THEN
               FAILED ("+DECIMAL_M4'(2.0 / 3) NOT IN 0.0 .. 64.0");
          END IF;
          IF -DECIMAL_M4'(NON_MODEL_CONST) NOT IN -64.0 .. 0.0 OR
             -NON_MODEL_VAR NOT IN -64.0 .. 0.0 THEN
               FAILED ("-DECIMAL_M4'(2.0 / 3) NOT IN -64.0 .. 0.0");
          END IF;

     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED -- B");
     END B;

     -------------------------------------------------------------------

     RESULT;

END C45431A;
