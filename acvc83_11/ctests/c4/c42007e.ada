-- C42007E.ADA

-- CHECK THAT THE BOUNDS OF A STRING LITERAL ARE DETERMINED CORRECTLY.
-- IN PARTICULAR, CHECK THAT THE LOWER BOUND IS GIVEN BY 'FIRST OF THE
-- INDEX SUBTYPE WHEN THE STRING LITERAL IS USED AS:

--   E) THE LEFT OR RIGHT OPERAND OF "&".

-- TBN  7/28/86

WITH REPORT; USE REPORT;
PROCEDURE C42007E IS

BEGIN

     TEST("C42007E", "CHECK THE BOUNDS OF A STRING LITERAL WHEN USED " &
                     "AS THE LEFT OR RIGHT OPERAND OF THE CATENATION " &
                     "OPERATOR");

     BEGIN

CASE_E :  DECLARE

               SUBTYPE STR_RANGE IS INTEGER RANGE 2 .. 10;
               TYPE STR IS ARRAY (STR_RANGE RANGE <>) OF CHARACTER;

               FUNCTION CONCAT1 RETURN STR IS
               BEGIN
                    RETURN ("ABC" & (7 .. 8 => 'D'));
               END CONCAT1;

               FUNCTION CONCAT2 RETURN STR IS
               BEGIN
                    RETURN ((IDENT_INT(4) .. 3 => 'A') & "BC");
               END CONCAT2;

               FUNCTION CONCAT3 RETURN STRING IS
               BEGIN
                    RETURN ("TEST" & (7 .. 8 => 'X'));
               END CONCAT3;

               FUNCTION CONCAT4 RETURN STRING IS
               BEGIN
                    RETURN ((8 .. 5 => 'A') & "DE");
               END CONCAT4;

          BEGIN

               IF CONCAT1'FIRST /= IDENT_INT(2) THEN
                    FAILED ("LOWER BOUND INCORRECTLY DETERMINED - 1");
               END IF;
               IF CONCAT1'LAST /= 6 THEN
                    FAILED ("UPPER BOUND INCORRECTLY DETERMINED - 1");
               END IF;
               IF CONCAT1 /= "ABCDD" THEN
                    FAILED ("STRING INCORRECTLY DETERMINED - 1");
               END IF;

               IF CONCAT2'FIRST /= IDENT_INT(2) THEN
                    FAILED ("LOWER BOUND INCORRECTLY DETERMINED - 2");
               END IF;
               IF CONCAT2'LAST /= 3 THEN
                    FAILED ("UPPER BOUND INCORRECTLY DETERMINED - 2");
               END IF;
               IF CONCAT2 /= "BC" THEN
                    FAILED ("STRING INCORRECTLY DETERMINED - 2");
               END IF;

               IF CONCAT3'FIRST /= IDENT_INT(1) THEN
                    FAILED ("LOWER BOUND INCORRECTLY DETERMINED - 3");
               END IF;
               IF CONCAT3'LAST /= 6 THEN
                    FAILED ("UPPER BOUND INCORRECTLY DETERMINED - 3");
               END IF;
               IF CONCAT3 /= "TESTXX" THEN
                    FAILED ("STRING INCORRECTLY DETERMINED - 3");
               END IF;

               IF CONCAT4'FIRST /= IDENT_INT(1) THEN
                    FAILED ("LOWER BOUND INCORRECTLY DETERMINED - 4");
               END IF;
               IF CONCAT4'LAST /= 2 THEN
                    FAILED ("UPPER BOUND INCORRECTLY DETERMINED - 4");
               END IF;
               IF CONCAT4 /= "DE" THEN
                    FAILED ("STRING INCORRECTLY DETERMINED - 4");
               END IF;

          END CASE_E;

     END;

     RESULT;

END C42007E;
