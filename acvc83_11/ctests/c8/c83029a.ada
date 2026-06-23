-- C83029A.ADA

-- OBJECTIVE:
--     CHECK THAT A LOOP PARAMETER HIDES AN OUTER DECLARATION OF A
--     HOMOGRAPH. ALSO CHECK THAT THE OUTER DECLARATION IS DIRECTLY
--     VISIBLE IN BOTH DECLARATIVE REGIONS BEFORE THE DECLARATION OF
--     THE INNER HOMOGRAPH AND THE OUTER DECLARATION IS VISIBLE BY
--     SELECTION AFTER THE INNER HOMOGRAPH DECLARATION.

-- HISTORY:
--     BCB 09/06/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE C83029A IS

     GENERIC
          TYPE T IS PRIVATE;
          X : T;
     FUNCTION GEN_FUN RETURN T;

     FUNCTION GEN_FUN RETURN T IS
     BEGIN
          RETURN X;
     END GEN_FUN;

BEGIN
     TEST ("C83029A", "CHECK THAT A LOOP PARAMETER HIDES AN OUTER " &
                      "DECLARATION OF A HOMOGRAPH");

     ONE:
     DECLARE
          A : INTEGER := IDENT_INT(2);
          B : INTEGER := A;
          C : INTEGER;

     BEGIN  -- ONE

          FOR A IN 1 .. 1 LOOP
               C := A;

               IF A /= IDENT_INT(1) THEN
                    FAILED ("INCORRECT VALUE FOR INNER HOMOGRAPH - 1");
               END IF;

               IF ONE.A /= IDENT_INT(2) THEN
                    FAILED ("INCORRECT VALUE FOR OUTER HOMOGRAPH - 2");
               END IF;

               IF ONE.B /= IDENT_INT(2) THEN
                    FAILED ("INCORRECT VALUE FOR OUTER VARIABLE - 3");
               END IF;

               IF C /= IDENT_INT(1) THEN
                    FAILED ("INCORRECT VALUE FOR INNER VARIABLE - 4");
               END IF;

               IF EQUAL(1,1) THEN
                    ONE.A := A;
               END IF;
          END LOOP;

          IF A /= IDENT_INT(1) THEN
               FAILED ("INCORRECT VALUE PASSED OUT - 6");
          END IF;
     END ONE;

     TWO:
     DECLARE                 --  OVERLOADING OF FUNCTIONS.

          OBJ : INTEGER := 1;
          FLO : FLOAT := 5.0;

          FUNCTION F IS NEW GEN_FUN (INTEGER, OBJ);

          FUNCTION F IS NEW GEN_FUN (FLOAT, FLO);

     BEGIN
          FOR F IN 1 .. 1 LOOP
               OBJ := INTEGER(F);
          END LOOP;

          IF OBJ /= IDENT_INT(1) THEN
               FAILED ("INCORRECT VALUE RETURNED - 10");
          END IF;
     END TWO;

     RESULT;
END C83029A;
