-- C34002C.ADA

-- FOR DERIVED INTEGER TYPES:

--   CHECK THAT ALL VALUES OF THE PARENT (BASE) TYPE ARE PRESENT FOR THE
--   DERIVED (BASE) TYPE WHEN THE DERIVED TYPE DEFINITION IS
--   CONSTRAINED.

--   CHECK THAT ANY CONSTRAINT IMPOSED ON THE PARENT SUBTYPE IS ALSO
--   IMPOSED ON THE DERIVED SUBTYPE.

-- JRK 8/21/86

WITH REPORT; USE REPORT;

PROCEDURE C34002C IS

     TYPE PARENT IS RANGE -100 .. 100;

     TYPE T IS NEW PARENT RANGE
               PARENT'VAL (IDENT_INT (-30)) ..
               PARENT'VAL (IDENT_INT ( 30));

     SUBTYPE SUBPARENT IS PARENT RANGE -30 .. 30;

     TYPE S IS NEW SUBPARENT;

     X : T;
     Y : S;

BEGIN
     TEST ("C34002C", "CHECK THAT ALL VALUES OF THE PARENT (BASE) " &
                      "TYPE ARE PRESENT FOR THE DERIVED (BASE) TYPE " &
                      "WHEN THE DERIVED TYPE DEFINITION IS " &
                      "CONSTRAINED.  ALSO CHECK THAT ANY CONSTRAINT " &
                      "IMPOSED ON THE PARENT SUBTYPE IS ALSO IMPOSED " &
                      "ON THE DERIVED SUBTYPE.  CHECK FOR DERIVED " &
                      "INTEGER TYPES");

     -- CHECK THAT BASE TYPE VALUES NOT IN THE SUBTYPE ARE PRESENT.

     IF T'POS (T'BASE'FIRST) /= PARENT'POS (PARENT'BASE'FIRST) OR
        S'POS (S'BASE'FIRST) /= PARENT'POS (PARENT'BASE'FIRST) OR
        T'POS (T'BASE'LAST)  /= PARENT'POS (PARENT'BASE'LAST)  OR
        S'POS (S'BASE'LAST)  /= PARENT'POS (PARENT'BASE'LAST)  THEN
          FAILED ("INCORRECT 'BASE'FIRST OR 'BASE'LAST");
     END IF;

     IF T'PRED (100) /= 99 OR T'SUCC (99) /= 100 OR
        S'PRED (100) /= 99 OR S'SUCC (99) /= 100 THEN
          FAILED ("INCORRECT 'PRED OR 'SUCC");
     END IF;

     -- CHECK THE DERIVED SUBTYPE CONSTRAINT.

     IF T'FIRST /= -30 OR T'LAST /= 30 OR
        S'FIRST /= -30 OR S'LAST /= 30 THEN
          FAILED ("INCORRECT 'FIRST OR 'LAST");
     END IF;

     BEGIN
          X := -30;
          Y := -30;
          IF PARENT (X) /= PARENT (Y) THEN  -- USE X AND Y.
               FAILED ("INCORRECT CONVERSION TO PARENT - 1");
          END IF;
          X := 30;
          Y := 30;
          IF PARENT (X) /= PARENT (Y) THEN  -- USE X AND Y.
               FAILED ("INCORRECT CONVERSION TO PARENT - 2");
          END IF;
     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED BY OK ASSIGNMENT");
     END;

     BEGIN
          X := -31;
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- X := -31");
          IF X = -31 THEN  -- USE X.
               COMMENT ("X ALTERED -- X := -31");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- X := -31");
     END;

     BEGIN
          X := 31;
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- X := 31");
          IF X = 31 THEN  -- USE X.
               COMMENT ("X ALTERED -- X := 31");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- X := 31");
     END;

     BEGIN
          Y := -31;
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- Y := -31");
          IF Y = -31 THEN -- USE Y.
               COMMENT ("Y ALTERED -- Y := -31");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- Y := -31");
     END;

     BEGIN
          Y := 31;
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- Y := 31");
          IF Y = 31 THEN  -- USE Y.
               COMMENT ("Y ALTERED -- Y := 31");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- Y := 31");
     END;

     RESULT;
END C34002C;
