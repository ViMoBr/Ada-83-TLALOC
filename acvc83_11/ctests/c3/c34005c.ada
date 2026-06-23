-- C34005C.ADA

-- OBJECTIVE:
--     FOR DERIVED ONE-DIMENSIONAL ARRAY TYPES WHOSE COMPONENT TYPE IS A
--     NON-LIMITED, NON-DISCRETE TYPE:
--     CHECK THAT ALL VALUES OF THE PARENT (BASE) TYPE ARE PRESENT FOR
--     THE DERIVED (BASE) TYPE WHEN THE DERIVED TYPE DEFINITION IS
--     CONSTRAINED.
--     CHECK THAT ANY CONSTRAINT IMPOSED ON THE PARENT SUBTYPE IS ALSO
--     IMPOSED ON THE DERIVED SUBTYPE.

-- HISTORY:
--     JRK 9/10/86  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C34005C IS

     SUBTYPE COMPONENT IS FLOAT;

     PACKAGE PKG IS

          FIRST : CONSTANT := 0;
          LAST  : CONSTANT := 100;

          SUBTYPE INDEX IS INTEGER RANGE FIRST .. LAST;

          TYPE PARENT IS ARRAY (INDEX RANGE <>) OF COMPONENT;

          FUNCTION CREATE ( F, L  : INDEX;
                            C     : COMPONENT;
                            DUMMY : PARENT   -- TO RESOLVE OVERLOADING.
                          ) RETURN PARENT;

     END PKG;

     USE PKG;

     TYPE T IS NEW PARENT (IDENT_INT (5) .. IDENT_INT (7));

     SUBTYPE SUBPARENT IS PARENT (5 .. 7);

     TYPE S IS NEW SUBPARENT;

     X : T := (OTHERS => 2.0);
     Y : S := (OTHERS => 2.0);

     PACKAGE BODY PKG IS

          FUNCTION CREATE
             ( F, L  : INDEX;
               C     : COMPONENT;
               DUMMY : PARENT
             ) RETURN PARENT
          IS
               A : PARENT (F .. L);
               B : COMPONENT := C;
          BEGIN
               FOR I IN F .. L LOOP
                    A (I) := B;
                    B := B + 1.0;
               END LOOP;
               RETURN A;
          END CREATE;

     END PKG;

BEGIN
     TEST ("C34005C", "CHECK THAT ALL VALUES OF THE PARENT (BASE) " &
                      "TYPE ARE PRESENT FOR THE DERIVED (BASE) TYPE " &
                      "WHEN THE DERIVED TYPE DEFINITION IS " &
                      "CONSTRAINED.  ALSO CHECK THAT ANY CONSTRAINT " &
                      "IMPOSED ON THE PARENT SUBTYPE IS ALSO IMPOSED " &
                      "ON THE DERIVED SUBTYPE.  CHECK FOR DERIVED " &
                      "ONE-DIMENSIONAL ARRAY TYPES WHOSE COMPONENT " &
                      "TYPE IS A NON-LIMITED, NON-DISCRETE TYPE");

     -- CHECK THAT BASE TYPE VALUES NOT IN THE SUBTYPE ARE PRESENT.

     BEGIN
          IF CREATE (2, 3, 4.0, X) /= (4.0, 5.0) OR
             CREATE (2, 3, 4.0, Y) /= (4.0, 5.0) THEN
               FAILED ("CAN'T CREATE BASE TYPE VALUES OUTSIDE THE " &
                       "SUBTYPE");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               FAILED ("CALL TO CREATE RAISED CONSTRAINT_ERROR");
          WHEN OTHERS =>
               FAILED ("CALL TO CREATE RAISED EXCEPTION");
     END;

     IF X & (3.0, 4.0) /= (2.0, 2.0, 2.0, 3.0, 4.0) OR
        Y & (3.0, 4.0) /= (2.0, 2.0, 2.0, 3.0, 4.0) THEN
          FAILED ("INCORRECT &");
     END IF;

     -- CHECK THE DERIVED SUBTYPE CONSTRAINT.

     IF T'FIRST /= 5 OR T'LAST /= 7 OR
        S'FIRST /= 5 OR S'LAST /= 7 THEN
          FAILED ("INCORRECT 'FIRST OR 'LAST");
     END IF;

     BEGIN
          X := (1.0, 2.0, 3.0);
          Y := (1.0, 2.0, 3.0);
          IF PARENT (X) /= PARENT (Y) THEN  -- USE X AND Y.
               FAILED ("INCORRECT CONVERSION TO PARENT");
          END IF;
     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED BY OK ASSIGNMENT");
     END;

     BEGIN
          X := (1.0, 2.0);
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- X := (1.0, 2.0)");
          IF X = (1.0, 2.0) THEN  -- USE X.
               COMMENT ("X ALTERED -- X := (1.0, 2.0)");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- X := (1.0, 2.0)");
     END;

     BEGIN
          X := (1.0, 2.0, 3.0, 4.0);
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- " &
                  "X := (1.0, 2.0, 3.0, 4.0)");
          IF X = (1.0, 2.0, 3.0, 4.0) THEN  -- USE X.
               COMMENT ("X ALTERED -- X := (1.0, 2.0, 3.0, 4.0)");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- " &
                       "X := (1.0, 2.0, 3.0, 4.0)");
     END;

     BEGIN
          Y := (1.0, 2.0);
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- Y := (1.0, 2.0)");
          IF Y = (1.0, 2.0) THEN  -- USE Y.
               COMMENT ("Y ALTERED -- Y := (1.0, 2.0)");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- Y := (1.0, 2.0)");
     END;

     BEGIN
          Y := (1.0, 2.0, 3.0, 4.0);
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- " &
                  "Y := (1.0, 2.0, 3.0, 4.0)");
          IF Y = (1.0, 2.0, 3.0, 4.0) THEN  -- USE Y.
               COMMENT ("Y ALTERED -- Y := (1.0, 2.0, 3.0, 4.0)");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- " &
                       "Y := (1.0, 2.0, 3.0, 4.0)");
     END;

     RESULT;
END C34005C;
