-- C34004C.ADA

-- OBJECTIVE:
--     FOR DERIVED FIXED POINT TYPES:

--     CHECK THAT ALL VALUES OF THE PARENT (BASE) TYPE ARE PRESENT FOR
--     THE DERIVED (BASE) TYPE WHEN THE DERIVED TYPE DEFINITION IS
--     CONSTRAINED.

--     CHECK THAT ANY CONSTRAINT IMPOSED ON THE PARENT SUBTYPE IS ALSO
--     IMPOSED ON THE DERIVED SUBTYPE.

-- HISTORY:
--     JRK 09/08/86
--     JLH 09/25/87  REFORMATTED HEADER.

WITH SYSTEM; USE SYSTEM;
WITH REPORT; USE REPORT;

PROCEDURE C34004C IS

     TYPE PARENT IS DELTA 0.01 RANGE -100.0 .. 100.0;

     TYPE T IS NEW PARENT DELTA 0.1 RANGE
               IDENT_INT (1) * (-30.0) ..
               IDENT_INT (1) * ( 30.0);

     SUBTYPE SUBPARENT IS PARENT DELTA 0.1 RANGE -30.0 .. 30.0;

     TYPE S IS NEW SUBPARENT;

     X : T;
     Y : S;

BEGIN
     TEST ("C34004C", "CHECK THAT ALL VALUES OF THE PARENT (BASE) " &
                      "TYPE ARE PRESENT FOR THE DERIVED (BASE) TYPE " &
                      "WHEN THE DERIVED TYPE DEFINITION IS " &
                      "CONSTRAINED.  ALSO CHECK THAT ANY CONSTRAINT " &
                      "IMPOSED ON THE PARENT SUBTYPE IS ALSO IMPOSED " &
                      "ON THE DERIVED SUBTYPE.  CHECK FOR DERIVED " &
                      "FIXED POINT TYPES");

     -- CHECK THAT BASE TYPE VALUES NOT IN THE SUBTYPE ARE PRESENT.

     DECLARE
          TBD : CONSTANT := BOOLEAN'POS (T'BASE'DELTA <= 0.01);
          SBD : CONSTANT := BOOLEAN'POS (S'BASE'DELTA <= 0.01);
     BEGIN
          IF TBD = 0 OR SBD = 0 THEN
               FAILED ("INCORRECT 'BASE'DELTA");
          END IF;
     END;

     IF T'BASE'FIRST > -PARENT'SAFE_LARGE OR
        S'BASE'FIRST > -PARENT'SAFE_LARGE OR
        T'BASE'LAST  <  PARENT'SAFE_LARGE OR
        S'BASE'LAST  <  PARENT'SAFE_LARGE THEN
          FAILED ("INCORRECT 'BASE'FIRST OR 'BASE'LAST");
     END IF;

     DECLARE
          N : INTEGER := IDENT_INT (8);
     BEGIN
          IF  98.0 + T'(1.0) + N * 0.0078125 /=  99.0625 OR
              98.0 + S'(1.0) + 8 * 0.0078125 /=  99.0625 OR
             -98.0 - T'(1.0) - N * 0.0078125 /= -99.0625 OR
             -98.0 - S'(1.0) - 8 * 0.0078125 /= -99.0625 THEN
               FAILED ("INCORRECT + OR -");
          END IF;
     END;

     -- CHECK THE DERIVED SUBTYPE CONSTRAINT.

     DECLARE
          TYPE MAX_FLOAT IS DIGITS MAX_DIGITS;
          SD : CONSTANT := BOOLEAN'POS (S'DELTA = 0.1);
     BEGIN
          IF 10.0 * ABS (T'DELTA - 0.1) > MAX_FLOAT'EPSILON OR
             SD = 0 THEN
               FAILED ("INCORRECT 'DELTA");
          END IF;
     END;

     IF T'FIRST /= -30.0 OR T'LAST /= 30.0 OR
        S'FIRST /= -30.0 OR S'LAST /= 30.0 THEN
          FAILED ("INCORRECT 'FIRST OR 'LAST");
     END IF;

     BEGIN
          X := -30.0;
          Y := -30.0;
          IF PARENT (X) /= PARENT (Y) THEN  -- USE X AND Y.
               FAILED ("INCORRECT CONVERSION TO PARENT - 1");
          END IF;
          X := 30.0;
          Y := 30.0;
          IF PARENT (X) /= PARENT (Y) THEN  -- USE X AND Y.
               FAILED ("INCORRECT CONVERSION TO PARENT - 2");
          END IF;
     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED BY OK ASSIGNMENT");
     END;

     BEGIN
          X := -30.0625;
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- X := -30.0625");
          IF X = -30.0625 THEN  -- USE X.
               COMMENT ("X ALTERED -- X := -30.0625");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- X := -30.0625");
     END;

     BEGIN
          X := 30.0625;
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- X := 30.0625");
          IF X = 30.0625 THEN  -- USE X.
               COMMENT ("X ALTERED -- X := 30.0625");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- X := 30.0625");
     END;

     BEGIN
          Y := -30.0625;
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- Y := -30.0625");
          IF Y = -30.0625 THEN  -- USE Y.
               COMMENT ("Y ALTERED -- Y := -30.0625");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- Y := -30.0625");
     END;

     BEGIN
          Y := 30.0625;
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- Y := 30.0625");
          IF Y = 30.0625 THEN  -- USE Y.
               COMMENT ("Y ALTERED -- Y := 30.0625");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- Y := 30.0625");
     END;

     RESULT;
END C34004C;
