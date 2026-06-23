-- C34005F.ADA

-- OBJECTIVE:
--     FOR DERIVED ONE-DIMENSIONAL ARRAY TYPES WHOSE COMPONENT TYPE IS A
--     DISCRETE TYPE:
--     CHECK THAT ALL VALUES OF THE PARENT (BASE) TYPE ARE PRESENT FOR
--     THE DERIVED (BASE) TYPE WHEN THE DERIVED TYPE DEFINITION IS
--     CONSTRAINED.
--     CHECK THAT ANY CONSTRAINT IMPOSED ON THE PARENT SUBTYPE IS ALSO
--     IMPOSED ON THE DERIVED SUBTYPE.

-- HISTORY:
--     JRK 9/12/86  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C34005F IS

     SUBTYPE COMPONENT IS INTEGER;

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

     X : T := (OTHERS => 2);
     Y : S := (OTHERS => 2);

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
                    B := B + 1;
               END LOOP;
               RETURN A;
          END CREATE;

     END PKG;

BEGIN
     TEST ("C34005F", "CHECK THAT ALL VALUES OF THE PARENT (BASE) " &
                      "TYPE ARE PRESENT FOR THE DERIVED (BASE) TYPE " &
                      "WHEN THE DERIVED TYPE DEFINITION IS " &
                      "CONSTRAINED.  ALSO CHECK THAT ANY CONSTRAINT " &
                      "IMPOSED ON THE PARENT SUBTYPE IS ALSO IMPOSED " &
                      "ON THE DERIVED SUBTYPE.  CHECK FOR DERIVED " &
                      "ONE-DIMENSIONAL ARRAY TYPES WHOSE COMPONENT " &
                      "TYPE IS A DISCRETE TYPE");

     -- CHECK THAT BASE TYPE VALUES NOT IN THE SUBTYPE ARE PRESENT.

     BEGIN
          IF CREATE (2, 3, 4, X) /= (4, 5) OR
             CREATE (2, 3, 4, Y) /= (4, 5) THEN
               FAILED ("CAN'T CREATE BASE TYPE VALUES OUTSIDE THE " &
                       "SUBTYPE");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               FAILED ("CALL TO CREATE RAISED CONSTRAINT_ERROR");
          WHEN OTHERS =>
               FAILED ("CALL TO CREATE RAISED EXCEPTION");
     END;

     IF X & (3, 4) /= (2, 2, 2, 3, 4) OR
        Y & (3, 4) /= (2, 2, 2, 3, 4) THEN
          FAILED ("INCORRECT &");
     END IF;

     -- CHECK THE DERIVED SUBTYPE CONSTRAINT.

     IF T'FIRST /= 5 OR T'LAST /= 7 OR
        S'FIRST /= 5 OR S'LAST /= 7 THEN
          FAILED ("INCORRECT 'FIRST OR 'LAST");
     END IF;

     BEGIN
          X := (1, 2, 3);
          Y := (1, 2, 3);
          IF PARENT (X) /= PARENT (Y) THEN  -- USE X AND Y.
               FAILED ("INCORRECT CONVERSION TO PARENT");
          END IF;
     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED BY OK ASSIGNMENT");
     END;

     BEGIN
          X := (1, 2);
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- X := (1, 2)");
          IF X = (1, 2) THEN  -- USE X.
               COMMENT ("X ALTERED -- X := (1, 2)");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- X := (1, 2)");
     END;

     BEGIN
          X := (1, 2, 3, 4);
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- " &
                  "X := (1, 2, 3, 4)");
          IF X = (1, 2, 3, 4) THEN  -- USE X.
               COMMENT ("X ALTERED -- X := (1, 2, 3, 4)");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- " &
                       "X := (1, 2, 3, 4)");
     END;

     BEGIN
          Y := (1, 2);
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- Y := (1, 2)");
          IF Y = (1, 2) THEN  -- USE Y.
               COMMENT ("Y ALTERED -- Y := (1, 2)");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- Y := (1, 2)");
     END;

     BEGIN
          Y := (1, 2, 3, 4);
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- " &
                  "Y := (1, 2, 3, 4)");
          IF Y = (1, 2, 3, 4) THEN  -- USE Y.
               COMMENT ("Y ALTERED -- Y := (1, 2, 3, 4)");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- " &
                       "Y := (1, 2, 3, 4)");
     END;

     RESULT;
END C34005F;
