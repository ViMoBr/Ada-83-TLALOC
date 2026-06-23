-- B62001D.ADA

-- CHECK THAT FUNCTIONS CAN NEITHER BE DECLARED NOR PASSED AS SUBPROGRAM
-- PARAMETERS.

-- DAS 1/23/81
-- JRK 3/16/81
-- JBG 8/21/83

PROCEDURE B62001D IS

     PROCEDURE P11 (F : FUNCTION RETURN INTEGER) IS -- ERROR: FORMAL
                                                    -- FUNC PARAM.
          FUNCTION FF RETURN INTEGER IS
          BEGIN
               RETURN 0;
          END FF;
     BEGIN
          P11 (FF);           -- ERROR: ACTUAL FUNCTION PARAMETER.
                              --  IT IS SUFFICIENT TO DETECT ONLY ONE OF
                              -- THESE ERRORS.
     END P11;

BEGIN
     NULL;
END B62001D;
