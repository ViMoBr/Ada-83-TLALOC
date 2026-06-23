-- CC3236A.ADA

-- OBJECTIVE:
--      CHECK THAT A FORMAL PRIVATE AND LIMITED PRIVATE TYPE DENOTES ITS
--      ACTUAL PARAMETER, AND OPERATIONS OF THE FORMAL TYPE ARE
--      IDENTIFIED WITH CORRESPONDING OPERATIONS OF THE ACTUAL TYPE
--      WHEN THE ACTUAL PARAMETER IS A TYPE WITH DISCRIMINANTS.

-- HISTORY:
--      DHH 10/24/88 CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE CC3236A IS

     GENERIC
          TYPE T IS PRIVATE;
     PACKAGE P IS
          SUBTYPE SUB_T IS T;
          PAC_VAR : T;
     END P;

     GENERIC
          TYPE T IS LIMITED PRIVATE;
     PACKAGE LP IS
          SUBTYPE SUB_T IS T;
          PAC_VAR : T;
     END LP;

BEGIN
     TEST ("CC3236A", "CHECK THAT A FORMAL PRIVATE OR LIMITED " &
                      "PRIVATE TYPE DENOTES ITS ACTUAL PARAMETER AND " &
                      "OPERATIONS OF THE FORMAL TYPE ARE IDENTIFIED " &
                      "WITH CORRESPONDING OPERATIONS OF THE ACTUAL " &
                      "TYPE, WHEN THE ACTUAL PARAMETER IS A TYPE " &
                      "WITH DISCRIMINANTS");

     DECLARE
          TYPE REC(X : INTEGER := 5) IS
               RECORD
                    NULL;
               END RECORD;
          OBJ_REC : REC(4);

          PACKAGE P2 IS NEW P (REC);
          USE P2;

          TYPE NEW_T IS NEW SUB_T;
          OBJ_NEWT : NEW_T(4);
     BEGIN
          PAC_VAR := SUB_T'((X => 4));
          IF PAC_VAR /= OBJ_REC THEN
               FAILED ("INCORRECT RESULTS - 1");
          END IF;
          IF PAC_VAR NOT IN REC THEN
               FAILED ("INCORRECT RESULTS - 2");
          END IF;
          IF OBJ_REC NOT IN SUB_T THEN
               FAILED ("INCORRECT RESULTS - 3");
          END IF;
          IF PAC_VAR.X /= OBJ_NEWT.X THEN
               FAILED ("INCORRECT RESULTS - 4");
          END IF;
          IF SUB_T'BASE'SIZE /= REC'SIZE THEN
               FAILED ("INCORRECT RESULTS - 5");
          END IF;
     END;

     DECLARE
          TYPE REC(X : INTEGER := 5) IS
               RECORD
                    NULL;
               END RECORD;
          OBJ_REC : REC(4);

          PACKAGE P2 IS NEW LP (REC);
          USE P2;

          TYPE NEW_T IS NEW SUB_T;
          OBJ_NEWT : NEW_T(4);
     BEGIN
          PAC_VAR := SUB_T'(X => 4);
          IF PAC_VAR /= OBJ_REC THEN
               FAILED ("INCORRECT RESULTS - 7");
          END IF;
          IF PAC_VAR NOT IN REC THEN
               FAILED ("INCORRECT RESULTS - 8");
          END IF;
          IF OBJ_REC NOT IN SUB_T THEN
               FAILED ("INCORRECT RESULTS - 9");
          END IF;
          IF PAC_VAR.X /= OBJ_NEWT.X THEN
               FAILED ("INCORRECT RESULTS - 10");
          END IF;
          IF SUB_T'BASE'SIZE /= REC'SIZE THEN
               FAILED ("INCORRECT RESULTS - 11");
          END IF;
     END;

     RESULT;
END CC3236A;
