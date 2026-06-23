-- C87B37B.ADA

-- CHECK THAT AN IMPLICIT CONVERSION FROM UNIVERSAL  INTEGER
-- IS NOT APPLIED IF THERE IS A LEGAL INTERPRETATION WITHOUT
-- THE IMPLICIT CONVERSION. 

-- MORE THAN ONE SUBPROGRAM PARAMETER

-- RFB 04/09/84
-- EG  05/31/84

WITH REPORT; USE REPORT;

PROCEDURE C87B37B IS

     FUNCTION "<" (L, R : INTEGER) RETURN INTEGER IS
     BEGIN
          RETURN 4;
     END "<";

     PROCEDURE CHECK (B : BOOLEAN; S : STRING) IS
     BEGIN
          IF NOT B THEN 
               FAILED(S); 
          END IF;
     END;

BEGIN

     TEST ("C87B37B","CHECK THAT IMPLICIT CONVERSIONS ARE ONLY USED " &
                     "WHEN NECESSARY FOR UNIVERSAL INTEGER");

     DECLARE   -- CASES INVOLVING MORE THAN ONE SUBPROGRAM PARAMETER

          WHICH_FUNC : INTEGER := 0;

          FUNCTION F (X : BOOLEAN; Y : INTEGER) RETURN INTEGER IS
          BEGIN
               RETURN 1;
          END F;

          FUNCTION F (X : INTEGER; Y : BOOLEAN) RETURN INTEGER IS
          BEGIN
               RETURN 2;
          END F;

          FUNCTION F (X : INTEGER; Y : INTEGER) RETURN FLOAT IS
          BEGIN
               RETURN 3.0;
          END;

     BEGIN

          WHICH_FUNC := F (5 < 5, 6);        -- NO IMPLICIT CONVERSION 
                                             -- (OF 5S)
          CHECK(WHICH_FUNC = 1, "CALLED WRONG F : 1 ");
                                       
          WHICH_FUNC := F (5 < 5, 6 = 6);    -- IMPLICIT CONVERSION 
                                             -- (5S, NOT 6S)
          CHECK(WHICH_FUNC = 2, "CALLED WRONG F : 2");

          WHICH_FUNC := INTEGER (FLOAT'(F (5 < 5, 6 < 6))); 
                                             -- IMPLICIT CONVERSION
          CHECK(WHICH_FUNC = 3, "CALLED WRONG F : 3");

     END;

     RESULT;

END C87B37B;
