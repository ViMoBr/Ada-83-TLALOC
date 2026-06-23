-- C35711A.ADA

-- CHECK THAT INCOMPATIBLE FLOATING POINT CONSTRAINTS RAISE
-- CONSTRAINT_ERROR

-- RJK 5/18/83

WITH REPORT; USE REPORT;
PROCEDURE C35711A IS

     TYPE FPT IS DIGITS 4 RANGE -1.0 .. 10.0;

BEGIN

     TEST ("C35711A", "CHECK THAT INCOMPATIBLE FLOATING POINT " &
                      "CONSTRAINTS RAISE CONSTRAINT_ERROR");

-- TEST FOR A CORRECT SUBTYPE DEFINITION INVOLVING A COMPATIBILITY CHECK
-- BETWEEN "DIGITS" IN THE TYPE AND IN THE SUBTYPE.

     BEGIN
                                                  
          DECLARE

               SUBTYPE SFP1 IS FPT DIGITS 3 RANGE 0.0 .. 5.0;  -- OK.
               SFP1_VAR : SFP1;

          BEGIN     
               SFP1_VAR := 2.0;
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               FAILED ("FLOATING POINT CONSTRAINTS ARE NOT IN ERROR");
          WHEN OTHERS =>
               FAILED ("EXCEPTION SHOULD NOT BE RAISED WHILE " &
                       "CHECKING DIGITS CONSTRAINT");
     END;

-- TEST FOR INCOMPATIBLE FLOATING POINT CONSTRAINT IN A  SUBTYPE
-- DEFINITION

     BEGIN

          DECLARE

               SUBTYPE SFP2 IS FPT DIGITS 5;  -- DIGITS IS LARGER IN
                                              -- SUBTYPE THAN IN TYPE
                                              -- DEFINITION

          BEGIN
               FAILED ("NO EXCEPTION RAISED FOR INCOMPATIBLE DIGITS");
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR => 
               NULL;
          WHEN OTHERS =>
               FAILED ("INCORRECT EXCEPTION RAISED WHILE CHECKING " &
                       "DIGITS CONSTRAINT");
     END;

-- TEST THAT CONSTRAINT_ERROR IS RAISED FOR A RANGE VIOLATION.

     BEGIN
          
          DECLARE
               
               SUBTYPE SFP3 IS FPT DIGITS 4 RANGE -2.0 .. 0.0;  -- LOWER
                                                                -- BOUND
          
          BEGIN
               FAILED ("NO EXCEPTION RAISED FOR FLOATING POINT LOWER " &
                       "BOUND CONSTRAINT VIOLATION");
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("INCORRECT EXCEPTION RAISED WHILE CHECKING " &
                       "LOWER BOUND FLOATING POINT CONSTRAINT");
     END;

-- TEST THAT CONSTRAINT_ERROR IS RAISED FOR A RANGE VIOLATION.

     BEGIN

          DECLARE

               SUBTYPE SFP4 IS FPT DIGITS 4 RANGE 0.0 .. 15.0;  -- UPPER
                                                                -- BOUND

          BEGIN
               FAILED ("NO EXCEPTION RAISED FOR FLOATING POINT UPPER " &
                       "BOUND CONSTRAINT VIOLATION");
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("INCORRECT EXCEPTION RAISED WHILE CHECKING " &
                       "UPPER BOUND FLOATING POINT CONSTRAINT");
     END;

     RESULT;

END C35711A;
