-- CB2006A.ADA

-- CHECK THAT LOCAL VARIABLES AND PARAMETERS OF A SUBPROGRAM,
-- OR PACKAGE ARE ACCESSIBLE WITHIN A HANDLER.

-- DAT 4/13/81
-- SPS 3/23/83

WITH REPORT; USE REPORT;

PROCEDURE CB2006A IS

     I : INTEGER RANGE 0 .. 1;

     PACKAGE P IS
          V2 : INTEGER := 2;
     END P;

     PROCEDURE PR (J : IN OUT INTEGER) IS
          K : INTEGER := J;
     BEGIN
          I := K;
          FAILED ("CONSTRAINT_ERROR NOT RAISED 1");
     EXCEPTION
          WHEN OTHERS =>
               J := K + 1;
     END PR;

     PACKAGE BODY P IS
          L : INTEGER := 2;
     BEGIN
          TEST ("CB2006A", "LOCAL VARIABLES ARE ACCESSIBLE IN"
               & " HANDLERS");

          I := 1;
          I := I + 1;
          FAILED ("CONSTRAINT_ERROR NOT RAISED 2");
     EXCEPTION
          WHEN OTHERS =>
               PR (L);
               IF L /= V2 + 1 THEN
                    FAILED ("WRONG VALUE IN LOCAL VARIABLE");
               END IF;
     END P;
BEGIN

     RESULT;
END CB2006A;
