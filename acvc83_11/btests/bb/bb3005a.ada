-- BB3005A.ADA

-- CHECK THAT A STMT OF THE FORM "RAISE <EXCEPTION_NAME> WHEN CONDITION"
--    IS FORBIDDEN.

-- DCB 04/01/80
-- JRK 11/19/80
-- SPS 3/23/83
-- JBG 4/15/85

PROCEDURE BB3005A IS

BEGIN
     BEGIN
          RAISE CONSTRAINT_ERROR WHEN TRUE;  -- ERROR: ILLEGAL FORM OF
                                             -- RAISE.
          NULL;
     EXCEPTION
           WHEN OTHERS =>
                RAISE WHEN TRUE;             -- ERROR: ILLEGAL FORM OF
                                             -- RAISE.
                NULL;
     END;
END BB3005A;
