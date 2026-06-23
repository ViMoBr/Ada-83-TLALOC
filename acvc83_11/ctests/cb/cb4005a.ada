-- CB4005A.ADA

-- CHECK THAT EXCEPTIONS PROPAGATED OUT OF A HANDLER ARE PROPAGATED
-- OUTSIDE THE ENCLOSING UNIT.

-- DAT 4/15/81
-- SPS 3/28/83

WITH REPORT; USE REPORT;

PROCEDURE CB4005A IS

     E , F : EXCEPTION;

     B : BOOLEAN := FALSE;

     PROCEDURE P IS
     BEGIN
          RAISE E;
     EXCEPTION
          WHEN F => FAILED ("WRONG HANDLER 1");
          WHEN E =>
               IF B THEN
                    FAILED ("WRONG HANDLER 2");
               ELSE
                    B := TRUE;
                    RAISE F;
               END IF;
     END P;

BEGIN
     TEST ("CB4005A", "EXCEPTIONS FROM HANDLERS ARE PROPAGATED " & 
           "OUTSIDE");

     BEGIN
          P;
          FAILED ("EXCEPTION NOT PROPAGATED 1");
     EXCEPTION
          WHEN F => NULL;
          WHEN OTHERS => FAILED ("WRONG HANDLER 3");
     END;

     RESULT;
END CB4005A;
