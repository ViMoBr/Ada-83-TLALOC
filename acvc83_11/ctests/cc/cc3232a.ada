-- CC3232A.ADA

-- OBJECTIVE:
--     CHECK THAT A PRIVATE OR LIMITED PRIVATE FORMAL TYPE DENOTES ITS
--     ACTUAL PARAMETER A FLOATING POINT TYPE, AND OPERATIONS OF THE
--     FORMAL TYPE ARE IDENTIFIED WITH CORRESPONDING OPERATIONS OF THE
--     ACTUAL TYPE.

-- HISTORY:
--     TBN 09/15/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE CC3232A IS

     TYPE FLOAT IS DIGITS 5 RANGE 0.0 .. 10.0;

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

     FUNCTION IDENT_FLO (X : FLOAT) RETURN FLOAT IS
     BEGIN
          IF EQUAL (3, 3) THEN
               RETURN X;
          ELSE
               RETURN (0.0);
          END IF;
     END IDENT_FLO;

BEGIN
     TEST ("CC3232A", "CHECK THAT A PRIVATE OR LIMITED PRIVATE " &
                      "FORMAL TYPE DENOTES ITS ACTUAL PARAMETER A " &
                      "FLOATING POINT TYPE, AND OPERATIONS OF THE " &
                      "FORMAL TYPE ARE IDENTIFIED WITH CORRESPONDING " &
                      "OPERATIONS OF THE ACTUAL TYPE");

     DECLARE  -- PRIVATE TYPE.
          OBJ_INT : INTEGER := 1;
          OBJ_FLO : FLOAT := 1.0;

          PACKAGE P1 IS NEW P (FLOAT);
          USE P1;

          TYPE NEW_T IS NEW SUB_T;
          OBJ_NEWT : NEW_T;
     BEGIN
          PAC_VAR := SUB_T'(1.0);
          IF PAC_VAR /= OBJ_FLO THEN
               FAILED ("INCORRECT RESULTS - 1");
          END IF;
          OBJ_FLO := IDENT_FLO (PAC_VAR) + IDENT_FLO (OBJ_FLO);
          IF OBJ_FLO <= PAC_VAR THEN
               FAILED ("INCORRECT RESULTS - 2");
          END IF;
          PAC_VAR := PAC_VAR * OBJ_FLO;
          IF PAC_VAR NOT IN FLOAT THEN
               FAILED ("INCORRECT RESULTS - 3");
          END IF;
          IF OBJ_FLO NOT IN SUB_T THEN
               FAILED ("INCORRECT RESULTS - 4");
          END IF;
          PAC_VAR := 1.0;
          OBJ_FLO := 1.0;
          OBJ_FLO := PAC_VAR * OBJ_FLO;
          IF OBJ_FLO /= 1.0 THEN
               FAILED ("INCORRECT RESULTS - 5");
          END IF;
          OBJ_FLO := 1.0;
          OBJ_FLO := OBJ_FLO / OBJ_FLO;
          IF OBJ_FLO /= 1.0 THEN
               FAILED ("INCORRECT RESULTS - 6");
          END IF;
          PAC_VAR := 1.0;
          OBJ_FLO := PAC_VAR ** OBJ_INT;
          IF OBJ_FLO /= 1.0 THEN
               FAILED ("INCORRECT RESULTS - 7");
          END IF;
          IF SUB_T'DIGITS /= 5 THEN
               FAILED ("INCORRECT RESULTS - 8");
          END IF;
          OBJ_NEWT := 1.0;
          OBJ_NEWT := OBJ_NEWT - 1.0;
          IF OBJ_NEWT NOT IN NEW_T THEN
               FAILED ("INCORRECT RESULTS - 9");
          END IF;
          IF NEW_T'DIGITS /= 5 THEN
               FAILED ("INCORRECT RESULTS - 10");
          END IF;
          OBJ_NEWT := NEW_T'SMALL + 1.0;
          IF FLOAT'SMALL /= NEW_T'SMALL THEN
               FAILED ("INCORRECT RESULTS - 11");
          END IF;
          IF FLOAT'LARGE /= NEW_T'LARGE THEN
               FAILED ("INCORRECT RESULTS - 12");
          END IF;
     END;

     DECLARE  -- LIMITED PRIVATE TYPE.
          OBJ_INT : INTEGER := 1;
          OBJ_FLO : FLOAT := 1.0;

          PACKAGE P1 IS NEW LP (FLOAT);
          USE P1;

          TYPE NEW_T IS NEW SUB_T;
          OBJ_NEWT : NEW_T;
     BEGIN
          PAC_VAR := SUB_T'(1.0);
          IF PAC_VAR /= OBJ_FLO THEN
               FAILED ("INCORRECT RESULTS - 1");
          END IF;
          OBJ_FLO := IDENT_FLO (PAC_VAR) + IDENT_FLO (OBJ_FLO);
          IF OBJ_FLO <= PAC_VAR THEN
               FAILED ("INCORRECT RESULTS - 2");
          END IF;
          PAC_VAR := PAC_VAR * OBJ_FLO;
          IF PAC_VAR NOT IN FLOAT THEN
               FAILED ("INCORRECT RESULTS - 3");
          END IF;
          IF OBJ_FLO NOT IN SUB_T THEN
               FAILED ("INCORRECT RESULTS - 4");
          END IF;
          PAC_VAR := 1.0;
          OBJ_FLO := 1.0;
          OBJ_FLO := PAC_VAR * OBJ_FLO;
          IF OBJ_FLO /= 1.0 THEN
               FAILED ("INCORRECT RESULTS - 5");
          END IF;
          OBJ_FLO := 1.0;
          OBJ_FLO := OBJ_FLO / OBJ_FLO;
          IF OBJ_FLO /= 1.0 THEN
               FAILED ("INCORRECT RESULTS - 6");
          END IF;
          PAC_VAR := 1.0;
          OBJ_FLO := PAC_VAR ** OBJ_INT;
          IF OBJ_FLO /= 1.0 THEN
               FAILED ("INCORRECT RESULTS - 7");
          END IF;
          IF SUB_T'DIGITS /= 5 THEN
               FAILED ("INCORRECT RESULTS - 8");
          END IF;
          OBJ_NEWT := 1.0;
          OBJ_NEWT := OBJ_NEWT - 1.0;
          IF OBJ_NEWT NOT IN NEW_T THEN
               FAILED ("INCORRECT RESULTS - 9");
          END IF;
          IF NEW_T'DIGITS /= 5 THEN
               FAILED ("INCORRECT RESULTS - 10");
          END IF;
          OBJ_NEWT := NEW_T'SMALL + 1.0;
          IF FLOAT'SMALL /= NEW_T'SMALL THEN
               FAILED ("INCORRECT RESULTS - 11");
          END IF;
          IF FLOAT'LARGE /= NEW_T'LARGE THEN
               FAILED ("INCORRECT RESULTS - 12");
          END IF;
     END;

     RESULT;
END CC3232A;
