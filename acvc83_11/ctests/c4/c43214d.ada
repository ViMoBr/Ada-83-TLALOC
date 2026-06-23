-- C43214D.ADA

-- CHECK THAT THE LOWER BOUND FOR THE STRING LITERAL IS DETERMINED BY
-- THE APPLICABLE INDEX CONSTRAINT, WHEN ONE EXISTS.

-- EG  02/10/84

WITH REPORT;

PROCEDURE C43214D IS

     USE REPORT;

BEGIN

     TEST("C43214D", "CONSTRAINED FUNCTION RESULT TYPE");

     BEGIN

CASE_C :  DECLARE

               TYPE TC IS ARRAY (INTEGER RANGE -1 .. 0, 
                                 IDENT_INT(7) .. 9) OF CHARACTER;

               FUNCTION FUN1 (A : INTEGER) RETURN TC IS
               BEGIN
                    RETURN ("ABC", "DEF");
               END;

          BEGIN

               IF FUN1(5)'FIRST(1) /= -1 THEN
                    FAILED ("LOWER BOUND INCORRECT " &
                            "FOR 'FIRST(1)");
               ELSIF FUN1(5)'FIRST(2) /= 7 THEN
                    FAILED ("LOWER BOUND INCORRECT " &
                            "FOR 'FIRST(2)");
               ELSIF FUN1(5)'LAST(1) /= 0 THEN
                    FAILED ("UPPER BOUND INCORRECT " &
                            "FOR 'LAST(1)");
               ELSIF FUN1(5)'LAST(2) /= 9 THEN
                    FAILED ("UPPER BOUND INCORRECT " &
                            "FOR 'LAST(2)");
               ELSIF FUN1(5) /= ("ABC", "DEF") THEN
                    FAILED ("FUNCTION DOES NOT " &
                            "RETURN THE CORRECT VALUES");
               END IF;

          END CASE_C;

     END;

     RESULT;

END C43214D;
