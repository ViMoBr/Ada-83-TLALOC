-- C42007C.ADA

-- CHECK THAT THE BOUNDS OF A STRING LITERAL ARE DETERMINED CORRECTLY.
-- IN PARTICULAR, CHECK THAT THE LOWER BOUND IS GIVEN BY 'FIRST OF THE
-- INDEX SUBTYPE WHEN THE STRING LITERAL IS USED AS:

--   C) THE RETURN EXPRESSION IN A FUNCTION WHOSE RETURN TYPE IS
--      UNCONSTRAINED.

-- TBN  7/23/86

WITH REPORT; USE REPORT;
PROCEDURE C42007C IS

BEGIN

     TEST("C42007C", "CHECK THE BOUNDS OF A STRING LITERAL WHEN USED " &
                     "AS THE RETURN EXPRESSION IN A FUNCTION WHOSE " &
                     "RETURN TYPE IS UNCONSTRAINED");

     BEGIN

CASE_C :  DECLARE

               SUBTYPE I5_10 IS
                            INTEGER RANGE IDENT_INT(5) .. IDENT_INT(10);
               TYPE STR5_10 IS ARRAY (I5_10 RANGE <>) OF CHARACTER;

               FUNCTION FUN1 (A : INTEGER) RETURN STR5_10 IS
               BEGIN
                    IF A = IDENT_INT(1) THEN
                         RETURN "HELLO";
                    ELSE
                         RETURN "HI";
                    END IF;
               END FUN1;

          BEGIN

               IF FUN1(5)'FIRST /= 5 THEN
                    FAILED ("LOWER BOUND INCORRECTLY GIVEN - 1");
               END IF;

               IF FUN1(2)'LAST /= 6 THEN
                    FAILED ("UPPER BOUND INCORRECTLY GIVEN - 1");
               END IF;

               IF FUN1(1)'FIRST /= 5 THEN
                    FAILED ("LOWER BOUND INCORRECTLY GIVEN - 2");
               END IF;

               IF FUN1(1)'LAST /= 9 THEN
                    FAILED ("UPPER BOUND INCORRECTLY GIVEN - 2");
               END IF;

               IF FUN1(1) /= "HELLO" THEN
                    FAILED ("STRING LITERAL INCORRECTLY PASSED - 1");
               END IF;

               IF FUN1(3) /= "HI" THEN
                    FAILED ("STRING LITERAL INCORRECTLY PASSED - 2");
               END IF;

          END CASE_C;

     END;

     RESULT;

END C42007C;
