-- C34007F.ADA

-- FOR DERIVED ACCESS TYPES WHOSE DESIGNATED TYPE IS A ONE-DIMENSIONAL
-- ARRAY TYPE:

--   CHECK THAT ALL VALUES OF THE PARENT (BASE) TYPE ARE PRESENT FOR THE
--   DERIVED (BASE) TYPE WHEN THE DERIVED TYPE DEFINITION IS
--   CONSTRAINED.

--   CHECK THAT ANY CONSTRAINT IMPOSED ON THE PARENT SUBTYPE IS ALSO
--   IMPOSED ON THE DERIVED SUBTYPE.

-- JRK 9/25/86

WITH REPORT; USE REPORT;

PROCEDURE C34007F IS

     SUBTYPE COMPONENT IS INTEGER;

     TYPE DESIGNATED IS ARRAY (NATURAL RANGE <>) OF COMPONENT;

     SUBTYPE SUBDESIGNATED IS DESIGNATED (5 .. 7);

     PACKAGE PKG IS

          TYPE PARENT IS ACCESS DESIGNATED;

          FUNCTION CREATE ( F, L  : NATURAL;
                            C     : COMPONENT;
                            DUMMY : PARENT   -- TO RESOLVE OVERLOADING.
                          ) RETURN PARENT;

     END PKG;

     USE PKG;

     TYPE T IS NEW PARENT (IDENT_INT (5) .. IDENT_INT (7));

     SUBTYPE SUBPARENT IS PARENT (5 .. 7);

     TYPE S IS NEW SUBPARENT;

     X : T := NEW SUBDESIGNATED'(OTHERS => 2);
     Y : S := NEW SUBDESIGNATED'(OTHERS => 2);

     PACKAGE BODY PKG IS

          FUNCTION CREATE
             ( F, L  : NATURAL;
               C     : COMPONENT;
               DUMMY : PARENT
             ) RETURN PARENT
          IS
               A : PARENT    := NEW DESIGNATED (F .. L);
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
     TEST ("C34007F", "CHECK THAT ALL VALUES OF THE PARENT (BASE) " &
                      "TYPE ARE PRESENT FOR THE DERIVED (BASE) TYPE " &
                      "WHEN THE DERIVED TYPE DEFINITION IS " &
                      "CONSTRAINED.  ALSO CHECK THAT ANY CONSTRAINT " &
                      "IMPOSED ON THE PARENT SUBTYPE IS ALSO IMPOSED " &
                      "ON THE DERIVED SUBTYPE.  CHECK FOR DERIVED " &
                      "ACCESS TYPES WHOSE DESIGNATED TYPE IS A " &
                      "ONE-DIMENSIONAL ARRAY TYPE");

     -- CHECK THAT BASE TYPE VALUES NOT IN THE SUBTYPE ARE PRESENT.

     IF CREATE (2, 3, 4, X) . ALL /= (4, 5) OR
        CREATE (2, 3, 4, Y) . ALL /= (4, 5) THEN
          FAILED ("CAN'T CREATE BASE TYPE VALUES OUTSIDE THE SUBTYPE");
     END IF;

     IF CREATE (2, 3, 4, X) IN T OR
        CREATE (2, 3, 4, Y) IN S THEN
          FAILED ("INCORRECT ""IN""");
     END IF;

     -- CHECK THE DERIVED SUBTYPE CONSTRAINT.

     IF X'FIRST /= 5 OR X'LAST /= 7 OR
        Y'FIRST /= 5 OR Y'LAST /= 7 THEN
          FAILED ("INCORRECT 'FIRST OR 'LAST");
     END IF;

     BEGIN
          X := NEW SUBDESIGNATED'(1, 2, 3);
          Y := NEW SUBDESIGNATED'(1, 2, 3);
          IF PARENT (X) = PARENT (Y) OR  -- USE X AND Y.
             X.ALL /= Y.ALL THEN
               FAILED ("INCORRECT ALLOCATOR OR CONVERSION TO PARENT");
          END IF;
     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED BY OK ASSIGNMENT");
     END;

     BEGIN
          X := NEW DESIGNATED'(6 .. 8 => 0);
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- " &
                  "X := NEW DESIGNATED'(6 .. 8 => 0)");
          IF X = NULL OR ELSE X.ALL = (0, 0, 0) THEN  -- USE X.
               COMMENT ("X ALTERED -- " &
                        "X := NEW DESIGNATED'(6 .. 8 => 0)");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- " &
                       "X := NEW DESIGNATED'(6 .. 8 => 0)");
     END;

     BEGIN
          Y := NEW DESIGNATED'(6 .. 8 => 0);
          FAILED ("CONSTRAINT_ERROR NOT RAISED -- " &
                  "Y := NEW DESIGNATED'(6 .. 8 => 0)");
          IF Y = NULL OR ELSE Y.ALL = (0, 0, 0) THEN  -- USE Y.
               COMMENT ("Y ALTERED -- " &
                        "Y := NEW DESIGNATED'(6 .. 8 => 0)");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- " &
                       "Y := NEW DESIGNATED'(6 .. 8 => 0)");
     END;

     RESULT;
END C34007F;
