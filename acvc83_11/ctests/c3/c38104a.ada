-- C38104A.ADA

-- OBJECTIVE:
--     CHECK THAT AN INCOMPLETE TYPE WITH DISCRIMINANTS CAN BE
--     USED IN AN ACCESS TYPE DEFINITION WITH A COMPATIBLE DISCRIMINANT
--     CONSTRAINT.

-- HISTORY:
--     PMW 09/01/88  CREATED ORIGINAL TEST BY RENAMING E38104A.ADA.

WITH REPORT;  USE REPORT;
PROCEDURE C38104A IS

BEGIN

     TEST ("C38104A","INCOMPLETELY DECLARED TYPE CAN BE USED AS TYPE " &
           "MARK IN ACCESS TYPE DEFINITION, AND CAN BE CONSTRAINED " &
           "THERE OR LATER IF INCOMPLETE TYPE HAD DISCRIMINANT(S)");

     DECLARE
          TYPE T1;
          TYPE T1_NAME IS ACCESS T1;

          TYPE T1 IS
               RECORD
                    COMP : INTEGER;
               END RECORD;

          TYPE T2(DISC : INTEGER := 5);
          TYPE T2_NAME1 IS ACCESS T2(5);
          TYPE T2_NAME2 IS ACCESS T2;

          SUBTYPE SUB_T2_NAME2 IS T2_NAME2(5);
          TYPE T2_NAME2_NAME IS ACCESS T2_NAME2(5);
          X : T2_NAME2(5);

          TYPE T2(DISC : INTEGER := 5) IS
               RECORD
                    COMP : T2_NAME2(DISC);
               END RECORD;

          X1N : T1_NAME;
          X2A,X2B : T2;
          X2N2 : T2_NAME2;

     BEGIN
          IF EQUAL(3,3) THEN
               X1N := NEW T1 '(COMP => 5);
          END IF;

          IF X1N.COMP /= 5 THEN
               FAILED ("ASSIGNMENT FAILED - 1");
          END IF;

          X2A := (DISC => IDENT_INT(7), COMP => NULL);
          X2N2 := NEW T2(IDENT_INT(7));
          X2N2.ALL := X2A;

          IF EQUAL(3,3) THEN
               X2B := (DISC => IDENT_INT(7), COMP => X2N2);
          END IF;

          IF X2B.COMP.COMP /= NULL
               OR X2B.COMP.DISC /= 7 THEN
               FAILED ("ASSIGNMENT FAILED - 2");
          END IF;

     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED");
     END;

     RESULT;

END C38104A;
