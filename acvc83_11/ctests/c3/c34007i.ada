-- C34007I.ADA

-- FOR DERIVED ACCESS TYPES WHOSE DESIGNATED TYPE IS A MULTI-DIMENSIONAL
-- ARRAY TYPE:

--   CHECK THAT ALL VALUES OF THE PARENT (BASE) TYPE ARE PRESENT FOR THE
--   DERIVED (BASE) TYPE WHEN THE DERIVED TYPE DEFINITION IS
--   CONSTRAINED.

--   CHECK THAT ANY CONSTRAINT IMPOSED ON THE PARENT SUBTYPE IS ALSO
--   IMPOSED ON THE DERIVED SUBTYPE.

-- JRK 9/25/86

WITH REPORT; USE REPORT;

PROCEDURE C34007I IS

     SUBTYPE COMPONENT IS INTEGER;

     TYPE DESIGNATED IS ARRAY (NATURAL RANGE <>, NATURAL RANGE <>) OF
                              COMPONENT;

     SUBTYPE SUBDESIGNATED IS DESIGNATED (4 .. 5, 6 .. 8);

     PACKAGE PKG IS

          TYPE PARENT IS ACCESS DESIGNATED;

          FUNCTION CREATE ( F1, L1 : NATURAL;
                            F2, L2 : NATURAL;
                            C      : COMPONENT;
                            DUMMY  : PARENT   -- TO RESOLVE OVERLOADING.
                          ) RETURN PARENT;

     END PKG;

     USE PKG;

     TYPE T IS NEW PARENT (IDENT_INT (4) .. IDENT_INT (5),
                           IDENT_INT (6) .. IDENT_INT (8));

     SUBTYPE SUBPARENT IS PARENT (4 .. 5, 6 .. 8);

     TYPE S IS NEW SUBPARENT;

     X : T := NEW SUBDESIGNATED'(OTHERS => (OTHERS => 2));
     Y : S := NEW SUBDESIGNATED'(OTHERS => (OTHERS => 2));

     PACKAGE BODY PKG IS

          FUNCTION CREATE
             ( F1, L1 : NATURAL;
               F2, L2 : NATURAL;
               C      : COMPONENT;
               DUMMY  : PARENT
             ) RETURN PARENT
          IS
               A : PARENT    := NEW DESIGNATED (F1 .. L1, F2 .. L2);
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
     TEST ("C34007I", "CHECK THAT ALL VALUES OF THE PARENT (BASE) " &
                      "TYPE ARE PRESENT FOR THE DERIVED (BASE) TYPE " &
                      "WHEN THE DERIVED TYPE DEFINITION IS " &
                      "CONSTRAINED.  ALSO CHECK THAT ANY CONSTRAINT " &
                      "IMPOSED ON THE PARENT SUBTYPE IS ALSO IMPOSED " &
                      "ON THE DERIVED SUBTYPE.  CHECK FOR DERIVED " &
                      "ACCESS TYPES WHOSE DESIGNATED TYPE IS A " &
                      "MULTI-DIMENSIONAL ARRAY TYPE");

     -- CHECK THAT BASE TYPE VALUES NOT IN THE SUBTYPE ARE PRESENT.

     IF CREATE (6, 9, 2, 3, 1, X) . ALL /=
        ((1, 2), (3, 4), (5, 6), (7, 8)) OR
        CREATE (6, 9, 2, 3, 1, Y) . ALL /=
        ((1, 2), (3, 4), (5, 6), (7, 8)) THEN
          FAILED ("CAN'T CREATE BASE TYPE VALUES OUTSIDE THE SUBTYPE");
     END IF;

     IF CREATE (6, 9, 2, 3, 1, X) IN T OR
        CREATE (6, 9, 2, 3, 1, Y) IN S THEN
          FAILED ("INCORRECT ""IN""");
     END IF;

     -- CHECK THE DERIVED SUBTYPE CONSTRAINT.

     IF X'FIRST /= 4 OR X'LAST /= 5 OR
        Y'FIRST /= 4 OR Y'LAST /= 5 OR
        X'FIRST (2) /= 6 OR X'LAST (2) /= 8 OR
        Y'FIRST (2) /= 6 OR Y'LAST (2) /= 8 THEN
          FAILED ("INCORRECT 'FIRST OR 'LAST");
     END IF;

     BEGIN
          X := NEW SUBDESIGNATED'((1, 2, 3), (4, 5, 6));
          Y := NEW SUBDESIGNATED'((1, 2, 3), (4, 5, 6));
          IF PARENT (X) = PARENT (Y) OR  -- USE X AND Y.
             X.ALL /= Y.ALL THEN
               FAILED ("INCORRECT ALLOCATOR OR CONVERSION TO PARENT");
          END IF;
     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED BY OK ASSIGNMENT");
     END;

     BEGIN
          X := NEW DESIGNATED'(5 .. 6 => (6 .. 8 => 0));
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- " &
                  "X := NEW DESIGNATED'(5 .. 6 => (6 .. 8 => 0))");
          IF X = NULL OR ELSE
             X.ALL = ((0, 0, 0), (0, 0, 0)) THEN  -- USE X.
               COMMENT ("X ALTERED -- " &
                        "X := NEW DESIGNATED'(5 .. 6 => " &
                        "(6 .. 8 => 0))");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- " &
                       "X := NEW DESIGNATED'(5 .. 6 => (6 .. 8 => 0))");
     END;

     BEGIN
          X := NEW DESIGNATED'(4 .. 5 => (5 .. 7 => 0));
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- " &
                  "X := NEW DESIGNATED'(4 .. 5 => (5 .. 7 => 0))");
          IF X = NULL OR ELSE
             X.ALL = ((0, 0, 0), (0, 0, 0)) THEN  -- USE X.
               COMMENT ("X ALTERED -- " &
                        "X := NEW DESIGNATED'(4 .. 5 => " &
                        "(5 .. 7 => 0))");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- " &
                       "X := NEW DESIGNATED'(4 .. 5 => (5 .. 7 => 0))");
     END;

     BEGIN
          Y := NEW DESIGNATED'(5 .. 6 => (6 .. 8 => 0));
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- " &
                  "Y := NEW DESIGNATED'(5 .. 6 => (6 .. 8 => 0))");
          IF Y = NULL OR ELSE
             Y.ALL = ((0, 0, 0), (0, 0, 0)) THEN  -- USE Y.
               COMMENT ("Y ALTERED -- " &
                        "Y := NEW DESIGNATED'(5 .. 6 => " &
                        "(6 .. 8 => 0))");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- " &
                       "Y := NEW DESIGNATED'(5 .. 6 => (6 .. 8 => 0))");
     END;

     BEGIN
          Y := NEW DESIGNATED'(4 .. 5 => (5 .. 7 => 0));
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- " &
                  "Y := NEW DESIGNATED'(4 .. 5 => (5 .. 7 => 0))");
          IF Y = NULL OR ELSE
             Y.ALL = ((0, 0, 0), (0, 0, 0)) THEN  -- USE Y.
               COMMENT ("Y ALTERED -- " &
                        "Y := NEW DESIGNATED'(4 .. 5 => " &
                        "(5 .. 7 => 0))");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- " &
                       "Y := NEW DESIGNATED'(4 .. 5 => (5 .. 7 => 0))");
     END;

     RESULT;
END C34007I;
