-- C83027A.ADA

-- OBJECTIVE:
--     CHECK THAT A DECLARATION IN A RECORD DECLARATION HIDES AN OUTER
--     DECLARATION OF A HOMOGRAPH. ALSO CHECK THAT THE OUTER DECLARATION
--     IS DIRECTLY VISIBLE IN BOTH DECLARATIVE REGIONS BEFORE THE
--     DECLARATION OF THE INNER HOMOGRAPH AND THE OUTER DECLARATION IS
--     VISIBLE BY SELECTION AFTER THE INNER HOMOGRAPH DECLARATION.

-- HISTORY:
--     BCB 09/02/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE C83027A IS

     GENERIC
          TYPE T IS PRIVATE;
          X : T;
     FUNCTION GEN_FUN RETURN T;

     FUNCTION GEN_FUN RETURN T IS
     BEGIN
          RETURN X;
     END GEN_FUN;

BEGIN
     TEST ("C83027A", "CHECK THAT A DECLARATION IN A RECORD " &
                      "DECLARATION HIDES AN OUTER DECLARATION OF " &
                      "A HOMOGRAPH");

     ONE:
     DECLARE
          A : INTEGER := IDENT_INT(2);
          OBJ : INTEGER := IDENT_INT(3);

          TYPE INNER2 (A : INTEGER := IDENT_INT(3)) IS RECORD
               C : INTEGER := ONE.A;
               D : INTEGER := A;
          END RECORD;

          E : INTEGER := A;

          RECVAR : INNER2;

     BEGIN  -- ONE
          IF A /= IDENT_INT(2) THEN
               FAILED ("INCORRECT VALUE FOR OUTER HOMOGRAPH - 1");
          END IF;

          IF RECVAR.A /= IDENT_INT(3) THEN
               FAILED ("INCORRECT VALUE FOR INNER HOMOGRAPH - 2");
          END IF;

          IF E /= IDENT_INT(2) THEN
               FAILED ("INCORRECT VALUE FOR OUTER VARIABLE - 3");
          END IF;

          IF RECVAR.C /= IDENT_INT(2) THEN
               FAILED ("INCORRECT VALUE FOR INNER VARIABLE - 4");
          END IF;

          IF RECVAR.D /= IDENT_INT(3) THEN
               FAILED ("INCORRECT VALUE FOR INNER VARIABLE - 5");
          END IF;

          IF EQUAL(1,1) THEN
               OBJ := RECVAR.A;
          ELSE
               OBJ := 1;
          END IF;

          IF OBJ /= IDENT_INT(3) THEN
               FAILED ("INCORRECT VALUE PASSED OUT - 6");
          END IF;
     END ONE;

     TWO:
     DECLARE

          GENERIC
               A : INTEGER := IDENT_INT(2);
               B : INTEGER := A;
          PACKAGE P IS
               TYPE INNER (C : INTEGER := A;
                           A : INTEGER := IDENT_INT(3)) IS RECORD
                    D : INTEGER := A;
               END RECORD;
          END P;

          PACKAGE BODY P IS
               RECVAR : INNER;
          BEGIN
               IF RECVAR.A /= IDENT_INT(3) THEN
                    FAILED ("INCORRECT VALUE FOR INNER HOMOGRAPH - 10");
               END IF;

               IF A /= IDENT_INT(2) THEN
                    FAILED ("INCORRECT VALUE FOR OUTER HOMOGRAPH - 11");
               END IF;

               IF B /= IDENT_INT(2) THEN
                    FAILED ("INCORRECT VALUE FOR OUTER VARIABLE - 12");
               END IF;

               IF RECVAR.C /= IDENT_INT(2) THEN
                    FAILED ("INCORRECT VALUE FOR INNER VARIABLE - 13");
               END IF;

               IF RECVAR.D /= IDENT_INT(3) THEN
                    FAILED ("INCORRECT VALUE FOR INNER VARIABLE - 14");
               END IF;
          END P;

          PACKAGE PACK IS NEW P;

     BEGIN  -- TWO
          NULL;
     END TWO;

     THREE:
     DECLARE
          A : INTEGER := IDENT_INT(2);
          OBJ : INTEGER := IDENT_INT(3);

          TYPE INNER4 (C : INTEGER := A;
                       A : INTEGER := IDENT_INT(3);
                       X : INTEGER := THREE.A) IS RECORD
               D : INTEGER := A;
          END RECORD;

          RECVAR : INNER4;

     BEGIN  -- THREE
          IF A /= IDENT_INT(2) THEN
               FAILED ("INCORRECT VALUE FOR OUTER HOMOGRAPH - 20");
          END IF;

          IF RECVAR.A /= IDENT_INT(3) THEN
               FAILED ("INCORRECT VALUE FOR INNER HOMOGRAPH - 21");
          END IF;

          IF RECVAR.C /= IDENT_INT(2) THEN
               FAILED ("INCORRECT VALUE FOR INNER VARIABLE - 22");
          END IF;

          IF RECVAR.D /= IDENT_INT(3) THEN
               FAILED ("INCORRECT VALUE FOR INNER VARIABLE - 23");
          END IF;

          IF RECVAR.X /= IDENT_INT(2) THEN
               FAILED ("INCORRECT VALUE FOR INNER VARIABLE - 24");
          END IF;

          IF EQUAL(1,1) THEN
               OBJ := RECVAR.A;
          ELSE
               OBJ := 1;
          END IF;

          IF OBJ /= IDENT_INT(3) THEN
               FAILED ("INCORRECT VALUE PASSED OUT - 25");
          END IF;
     END THREE;

     RESULT;
END C83027A;
