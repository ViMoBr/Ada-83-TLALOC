-- C34005O.ADA

-- OBJECTIVE:
--     FOR DERIVED MULTI-DIMENSIONAL ARRAY TYPES WHOSE COMPONENT TYPE
--     IS A NON-LIMITED TYPE:
--     CHECK THAT ALL VALUES OF THE PARENT (BASE) TYPE ARE PRESENT FOR
--     THE DERIVED (BASE) TYPE WHEN THE DERIVED TYPE DEFINITION IS
--     CONSTRAINED.
--     CHECK THAT ANY CONSTRAINT IMPOSED ON THE PARENT SUBTYPE IS ALSO
--     IMPOSED ON THE DERIVED SUBTYPE.

-- HISTORY:
--     JRK 9/17/86  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C34005O IS

     SUBTYPE COMPONENT IS INTEGER;

     PACKAGE PKG IS

          FIRST : CONSTANT := 0;
          LAST  : CONSTANT := 10;

          SUBTYPE INDEX IS INTEGER RANGE FIRST .. LAST;

          TYPE PARENT IS ARRAY (INDEX RANGE <>, INDEX RANGE <>) OF
                               COMPONENT;

          FUNCTION CREATE ( F1, L1 : INDEX;
                            F2, L2 : INDEX;
                            C      : COMPONENT;
                            DUMMY  : PARENT   -- TO RESOLVE OVERLOADING.
                          ) RETURN PARENT;

     END PKG;

     USE PKG;

     TYPE T IS NEW PARENT (IDENT_INT (4) .. IDENT_INT (5),
                           IDENT_INT (6) .. IDENT_INT (8));

     SUBTYPE SUBPARENT IS PARENT (4 .. 5, 6 .. 8);

     TYPE S IS NEW SUBPARENT;

     X : T := (OTHERS => (OTHERS => 2));
     Y : S := (OTHERS => (OTHERS => 2));

     PACKAGE BODY PKG IS

          FUNCTION CREATE
             ( F1, L1 : INDEX;
               F2, L2 : INDEX;
               C      : COMPONENT;
               DUMMY  : PARENT
             ) RETURN PARENT
          IS
               A : PARENT (F1 .. L1, F2 .. L2);
               B : COMPONENT := C;
          BEGIN
               FOR I IN F1 .. L1 LOOP
                    FOR J IN F2 .. L2 LOOP
                         A (I, J) := B;
                         B := B + 1;
                    END LOOP;
               END LOOP;
               RETURN A;
          END CREATE;

     END PKG;

BEGIN
     TEST ("C34005O", "CHECK THAT ALL VALUES OF THE PARENT (BASE) " &
                      "TYPE ARE PRESENT FOR THE DERIVED (BASE) TYPE " &
                      "WHEN THE DERIVED TYPE DEFINITION IS " &
                      "CONSTRAINED.  ALSO CHECK THAT ANY CONSTRAINT " &
                      "IMPOSED ON THE PARENT SUBTYPE IS ALSO IMPOSED " &
                      "ON THE DERIVED SUBTYPE.  CHECK FOR DERIVED " &
                      "MULTI-DIMENSIONAL ARRAY TYPES WHOSE COMPONENT " &
                      "TYPE IS A NON-LIMITED TYPE");

     -- CHECK THAT BASE TYPE VALUES NOT IN THE SUBTYPE ARE PRESENT.

     BEGIN
          IF CREATE (6, 9, 2, 3, 1, X) /=
             ((1, 2), (3, 4), (5, 6), (7, 8)) OR
             CREATE (6, 9, 2, 3, 1, Y) /=
             ((1, 2), (3, 4), (5, 6), (7, 8)) THEN
               FAILED ("CAN'T CREATE BASE TYPE VALUES OUTSIDE THE " &
                       "SUBTYPE");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               FAILED ("CALL TO CREATE RAISED CONSTRAINT_ERROR");
          WHEN OTHERS =>
               FAILED ("CALL TO CREATE RAISED EXCEPTION");
     END;

     IF ((1, 2), (3, 4), (5, 6), (7, 8)) IN T OR
        ((1, 2), (3, 4), (5, 6), (7, 8)) IN S THEN
          FAILED ("INCORRECT ""IN""");
     END IF;

     -- CHECK THE DERIVED SUBTYPE CONSTRAINT.

     IF T'FIRST /= 4 OR T'LAST /= 5 OR
        S'FIRST /= 4 OR S'LAST /= 5 OR
        T'FIRST (2) /= 6 OR T'LAST (2) /= 8 OR
        S'FIRST (2) /= 6 OR S'LAST (2) /= 8 THEN
          FAILED ("INCORRECT 'FIRST OR 'LAST");
     END IF;

     BEGIN
          X := ((1, 2, 3), (4, 5, 6));
          Y := ((1, 2, 3), (4, 5, 6));
          IF PARENT (X) /= PARENT (Y) THEN  -- USE X AND Y.
               FAILED ("INCORRECT CONVERSION TO PARENT");
          END IF;
     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED BY OK ASSIGNMENT");
     END;

     BEGIN
          X := (4 => (6 .. 8 => 0));
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- " &
                  "X := (4 => (6 .. 8 => 0))");
          IF X = (4 => (6 .. 8 => 0)) THEN  -- USE X.
               COMMENT ("X ALTERED -- " &
                        "X := (4 => (6 .. 8 => 0))");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- " &
                       "X := (4 => (6 .. 8 => 0))");
     END;

     BEGIN
          X := (4 .. 6 => (6 .. 8 => 0));
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- " &
                  "X := (4 .. 6 => (6 .. 8 => 0))");
          IF X = (4 .. 6 => (6 .. 8 => 0)) THEN  -- USE X.
               COMMENT ("X ALTERED -- " &
                        "X := (4 .. 6 => (6 .. 8 => 0))");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- " &
                       "X := (4 .. 6 => (6 .. 8 => 0))");
     END;

     BEGIN
          X := (4 .. 5 => (6 .. 7 => 0));
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- " &
                  "X := (4 .. 5 => (6 .. 7 => 0))");
          IF X = (4 .. 5 => (6 .. 7 => 0)) THEN  -- USE X.
               COMMENT ("X ALTERED -- " &
                        "X := (4 .. 5 => (6 .. 7 => 0))");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- " &
                       "X := (4 .. 5 => (6 .. 7 => 0))");
     END;

     BEGIN
          X := (4 .. 5 => (6 .. 9 => 0));
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- " &
                  "X := (4 .. 5 => (6 .. 9 => 0))");
          IF X = (4 .. 5 => (6 .. 9 => 0)) THEN  -- USE X.
               COMMENT ("X ALTERED -- " &
                        "X := (4 .. 5 => (6 .. 9 => 0))");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- " &
                       "X := (4 .. 5 => (6 .. 9 => 0))");
     END;

     BEGIN
          Y := (4 => (6 .. 8 => 0));
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- " &
                  "Y := (4 => (6 .. 8 => 0))");
          IF Y = (4 => (6 .. 8 => 0)) THEN  -- USE Y.
               COMMENT ("Y ALTERED -- " &
                        "Y := (4 => (6 .. 8 => 0))");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- " &
                       "Y := (4 => (6 .. 8 => 0))");
     END;

     BEGIN
          Y := (4 .. 6 => (6 .. 8 => 0));
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- " &
                  "Y := (4 .. 6 => (6 .. 8 => 0))");
          IF Y = (4 .. 6 => (6 .. 8 => 0)) THEN  -- USE Y.
               COMMENT ("Y ALTERED -- " &
                        "Y := (4 .. 6 => (6 .. 8 => 0))");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- " &
                       "Y := (4 .. 6 => (6 .. 8 => 0))");
     END;

     BEGIN
          Y := (4 .. 5 => (6 .. 7 => 0));
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- " &
                  "Y := (4 .. 5 => (6 .. 7 => 0))");
          IF Y = (4 .. 5 => (6 .. 7 => 0)) THEN  -- USE Y.
               COMMENT ("Y ALTERED -- " &
                        "Y := (4 .. 5 => (6 .. 7 => 0))");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- " &
                       "Y := (4 .. 5 => (6 .. 7 => 0))");
     END;

     BEGIN
          Y := (4 .. 5 => (6 .. 9 => 0));
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- " &
                  "Y := (4 .. 5 => (6 .. 9 => 0))");
          IF Y = (4 .. 5 => (6 .. 9 => 0)) THEN  -- USE Y.
               COMMENT ("Y ALTERED -- " &
                        "Y := (4 .. 5 => (6 .. 9 => 0))");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- " &
                       "Y := (4 .. 5 => (6 .. 9 => 0))");
     END;

     RESULT;
END C34005O;
