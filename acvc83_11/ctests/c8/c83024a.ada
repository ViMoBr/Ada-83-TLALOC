-- C83024A.ADA

-- OBJECTIVE:
--     CHECK THAT A DECLARATION IN A DECLARATIVE REGION FOR A GENERIC
--     PACKAGE HIDES AN OUTER DECLARATION OF A HOMOGRAPH. ALSO CHECK
--     THAT THE OUTER DECLARATION IS DIRECTLY VISIBLE IN BOTH
--     DECLARATIVE REGIONS BEFORE THE DECLARATION OF THE INNER HOMOGRAPH
--     AND THE OUTER DECLARATION IS VISIBLE BY SELECTION AFTER THE INNER
--     HOMOGRAH DECLARATION.

-- HISTORY:
--     BCB 08/30/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C83024A IS

     GENERIC
          TYPE T IS PRIVATE;
          X : T;
     FUNCTION GEN_FUN RETURN T;

     FUNCTION GEN_FUN RETURN T IS
     BEGIN
          RETURN X;
     END GEN_FUN;

BEGIN
     TEST ("C83024A", "CHECK THAT A DECLARATION IN A DECLARATIVE " &
                      "REGION FOR A GENERIC PACKAGE HIDES AN OUTER " &
                      "DECLARATION OF A HOMOGRAPH");

     ONE:
     DECLARE
          A : INTEGER := IDENT_INT(2);
          B : INTEGER := A;
          OBJ : INTEGER := IDENT_INT(3);

          GENERIC
               X : IN INTEGER := A;
               A : IN OUT INTEGER;
          PACKAGE INNER IS
               C : INTEGER := A;
          END INNER;

          PACKAGE BODY INNER IS
          BEGIN
               IF A /= IDENT_INT(3) THEN
                    FAILED ("INCORRECT VALUE FOR INNER HOMOGRAPH - 10");
               END IF;

               IF ONE.A /= IDENT_INT(2) THEN
                    FAILED ("INCORRECT VALUE FOR OUTER HOMOGRAPH - 11");
               END IF;

               IF ONE.B /= IDENT_INT(2) THEN
                    FAILED ("INCORRECT VALUE FOR OUTER VARIABLE - 12");
               END IF;

               IF C /= IDENT_INT(3) THEN
                    FAILED ("INCORRECT VALUE FOR INNER VARIABLE - 13");
               END IF;

               IF X /= IDENT_INT(2) THEN
                    FAILED ("INCORRECT VALUE PASSED IN - 14");
               END IF;

               IF EQUAL(1,1) THEN
                    A := IDENT_INT(4);
               ELSE
                    A := 1;
               END IF;
          END INNER;

          PACKAGE NEW_INNER IS NEW INNER (A => OBJ);

     BEGIN  -- ONE
          IF OBJ /= IDENT_INT(4) THEN
               FAILED ("INCORRECT VALUE PASSED OUT - 15");
          END IF;
     END ONE;

     TWO:
     DECLARE            -- AFTER THE SPECIFICATION OF PACKAGE.
          A : INTEGER := IDENT_INT(2);

          GENERIC
               X : IN OUT INTEGER;
          PACKAGE INNER IS
               A : INTEGER := IDENT_INT(3);
          END INNER;

          B : INTEGER := A;

          PACKAGE BODY INNER IS
               C : INTEGER := TWO.A;
          BEGIN
               IF A /= IDENT_INT(3) THEN
                    FAILED ("INCORRECT VALUE FOR INNER HOMOGRAPH - 20");
               END IF;

               IF TWO.A /= IDENT_INT(2) THEN
                    FAILED ("INCORRECT VALUE FOR OUTER HOMOGRAPH - 21");
               END IF;

               IF TWO.B /= IDENT_INT(2) THEN
                    FAILED ("INCORRECT VALUE FOR OUTER VARIABLE - 22");
               END IF;

               IF C /= IDENT_INT(2) THEN
                    FAILED ("INCORRECT VALUE FOR INNER VARIABLE - 23");
               END IF;

               IF X /= IDENT_INT(2) THEN
                    FAILED ("INCORRECT VALUE PASSED IN - 24");
               END IF;

               IF EQUAL(1,1) THEN
                    X := A;
               ELSE
                    NULL;
               END IF;
          END INNER;

          PACKAGE NEW_INNER IS NEW INNER (A);

     BEGIN  -- TWO
          IF A /= IDENT_INT(3) THEN
               FAILED ("INCORRECT VALUE PASSED OUT - 25");
          END IF;
     END TWO;

     THREE:
     DECLARE                 --  OVERLOADING OF FUNCTIONS.

          OBJ : INTEGER := 1;
          FLO : FLOAT := 6.25;

          FUNCTION F IS NEW GEN_FUN (INTEGER, OBJ);

          GENERIC
               X : IN OUT INTEGER;
               F : IN FLOAT;
          PACKAGE INNER IS
          END INNER;

          FUNCTION F IS NEW GEN_FUN (FLOAT, FLO);

          PACKAGE BODY INNER IS
          BEGIN
               X := INTEGER(F);
          END INNER;

          PACKAGE NEW_INNER IS NEW INNER (OBJ, FLO);

     BEGIN
          IF OBJ /= IDENT_INT(6) THEN
               FAILED ("INCORRECT VALUE RETURNED FROM FUNCTION - 60");
          END IF;
     END THREE;

     RESULT;
END C83024A;
