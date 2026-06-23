-- C34005I.ADA

-- OBJECTIVE:
--     FOR DERIVED ONE-DIMENSIONAL ARRAY TYPES WHOSE COMPONENT TYPE IS A
--     CHARACTER TYPE:
--     CHECK THAT ALL VALUES OF THE PARENT (BASE) TYPE ARE PRESENT FOR
--     THE DERIVED (BASE) TYPE WHEN THE DERIVED TYPE DEFINITION IS
--     CONSTRAINED.
--     CHECK THAT ANY CONSTRAINT IMPOSED ON THE PARENT SUBTYPE IS ALSO
--     IMPOSED ON THE DERIVED SUBTYPE.

-- HISTORY:
--     JRK 9/15/86  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C34005I IS

     TYPE COMPONENT IS NEW CHARACTER;

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

     X : T := (OTHERS => 'B');
     Y : S := (OTHERS => 'B');

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
                    B := COMPONENT'SUCC (B);
               END LOOP;
               RETURN A;
          END CREATE;

     END PKG;

BEGIN
     TEST ("C34005I", "CHECK THAT ALL VALUES OF THE PARENT (BASE) " &
                      "TYPE ARE PRESENT FOR THE DERIVED (BASE) TYPE " &
                      "WHEN THE DERIVED TYPE DEFINITION IS " &
                      "CONSTRAINED.  ALSO CHECK THAT ANY CONSTRAINT " &
                      "IMPOSED ON THE PARENT SUBTYPE IS ALSO IMPOSED " &
                      "ON THE DERIVED SUBTYPE.  CHECK FOR DERIVED " &
                      "ONE-DIMENSIONAL ARRAY TYPES WHOSE COMPONENT " &
                      "TYPE IS A CHARACTER TYPE");

     -- CHECK THAT BASE TYPE VALUES NOT IN THE SUBTYPE ARE PRESENT.

     BEGIN
          IF CREATE (2, 3, 'D', X) /= "DE" OR
             CREATE (2, 3, 'D', Y) /= "DE" THEN
               FAILED ("CAN'T CREATE BASE TYPE VALUES OUTSIDE THE " &
                       "SUBTYPE");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               FAILED ("CALL TO CREATE RAISED CONSTRAINT_ERROR");
          WHEN OTHERS =>
               FAILED ("CALL TO CREATE RAISED EXCEPTION");
     END;

     IF X & "CD" /= "BBBCD" OR
        Y & "CD" /= "BBBCD" THEN
          FAILED ("INCORRECT &");
     END IF;

     -- CHECK THE DERIVED SUBTYPE CONSTRAINT.

     IF T'FIRST /= 5 OR T'LAST /= 7 OR
        S'FIRST /= 5 OR S'LAST /= 7 THEN
          FAILED ("INCORRECT 'FIRST OR 'LAST");
     END IF;

     BEGIN
          X := "ABC";
          Y := "ABC";
          IF PARENT (X) /= PARENT (Y) THEN  -- USE X AND Y.
               FAILED ("INCORRECT CONVERSION TO PARENT");
          END IF;
     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED BY OK ASSIGNMENT");
     END;

     BEGIN
          X := "AB";
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- X := ""AB""");
          IF X = "AB" THEN  -- USE X.
               COMMENT ("X ALTERED -- X := ""AB""");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- X := ""AB""");
     END;

     BEGIN
          X := "ABCD";
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- " &
                  "X := ""ABCD""");
          IF X = "ABCD" THEN  -- USE X.
               COMMENT ("X ALTERED -- X := ""ABCD""");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- " &
                       "X := ""ABCD""");
     END;

     BEGIN
          Y := "AB";
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- Y := ""AB""");
          IF Y = "AB" THEN  -- USE Y.
               COMMENT ("Y ALTERED -- Y := ""AB""");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- Y := ""AB""");
     END;

     BEGIN
          Y := "ABCD";
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- " &
                  "Y := ""ABCD""");
          IF Y = "ABCD" THEN  -- USE Y.
               COMMENT ("Y ALTERED -- Y := ""ABCD""");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- " &
                       "Y := ""ABCD""");
     END;

     RESULT;
END C34005I;
