-- C34003C.ADA

-- FOR DERIVED FLOATING POINT TYPES:

--   CHECK THAT ALL VALUES OF THE PARENT (BASE) TYPE ARE PRESENT FOR THE
--   DERIVED (BASE) TYPE WHEN THE DERIVED TYPE DEFINITION IS
--   CONSTRAINED.

--   CHECK THAT ANY CONSTRAINT IMPOSED ON THE PARENT SUBTYPE IS ALSO
--   IMPOSED ON THE DERIVED SUBTYPE.

-- JRK 9/4/86

WITH REPORT; USE REPORT;

PROCEDURE C34003C IS

     TYPE PARENT IS DIGITS 5;

     TYPE T IS NEW PARENT DIGITS 4 RANGE
               PARENT (IDENT_INT (-30)) ..
               PARENT (IDENT_INT ( 30));

     SUBTYPE SUBPARENT IS PARENT DIGITS 4 RANGE -30.0 .. 30.0;

     TYPE S IS NEW SUBPARENT;

     X : T;
     Y : S;

BEGIN
     TEST ("C34003C", "CHECK THAT ALL VALUES OF THE PARENT (BASE) " &
                      "TYPE ARE PRESENT FOR THE DERIVED (BASE) TYPE " &
                      "WHEN THE DERIVED TYPE DEFINITION IS " &
                      "CONSTRAINED.  ALSO CHECK THAT ANY CONSTRAINT " &
                      "IMPOSED ON THE PARENT SUBTYPE IS ALSO IMPOSED " &
                      "ON THE DERIVED SUBTYPE.  CHECK FOR DERIVED " &
                      "FLOATING POINT TYPES");

     -- CHECK THAT BASE TYPE VALUES NOT IN THE SUBTYPE ARE PRESENT.

     IF T'BASE'DIGITS < 5 OR S'BASE'DIGITS < 5 THEN
          FAILED ("INCORRECT 'BASE'DIGITS");
     END IF;

     IF T'BASE'FIRST > -PARENT'SAFE_LARGE OR
        S'BASE'FIRST > -PARENT'SAFE_LARGE OR
        T'BASE'LAST  <  PARENT'SAFE_LARGE OR
        S'BASE'LAST  <  PARENT'SAFE_LARGE THEN
          FAILED ("INCORRECT 'BASE'FIRST OR 'BASE'LAST");
     END IF;

     IF  12344.0 + T'(1.0) + 1.0 /=  12346.0 OR
         12344.0 + S'(1.0) + 1.0 /=  12346.0 OR
        -12344.0 - T'(1.0) - 1.0 /= -12346.0 OR
        -12344.0 - S'(1.0) - 1.0 /= -12346.0 THEN
          FAILED ("INCORRECT + OR -");
     END IF;

     -- CHECK THE DERIVED SUBTYPE CONSTRAINT.

     IF T'DIGITS /= 4 OR S'DIGITS /= 4 THEN
          FAILED ("INCORRECT 'DIGITS");
     END IF;

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
          X := -31.0;
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- X := -31.0");
          IF X = -31.0 THEN  -- USE X.
               COMMENT ("X ALTERED -- X := -31.0");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- X := -31.0");
     END;

     BEGIN
          X := 31.0;
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- X := 31.0");
          IF X = 31.0 THEN  -- USE X.
               COMMENT ("X ALTERED -- X := 31.0");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- X := 31.0");
     END;

     BEGIN
          Y := -31.0;
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- Y := -31.0");
          IF Y = -31.0 THEN  -- USE Y.
               COMMENT ("Y ALTERED -- Y := -31.0");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- Y := -31.0");
     END;

     BEGIN
          Y := 31.0;
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- Y := 31.0");
          IF Y = 31.0 THEN  -- USE Y.
               COMMENT ("Y ALTERED -- Y := 31.0");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- Y := 31.0");
     END;

     RESULT;
END C34003C;
