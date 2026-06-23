-- C43214C.ADA

-- CHECK THAT THE LOWER BOUND FOR THE STRING LITERAL IS DETERMINED BY
-- THE APPLICABLE INDEX CONSTRAINT, WHEN ONE EXISTS.

-- EG  02/10/84

WITH REPORT;

PROCEDURE C43214C IS

     USE REPORT;

BEGIN

     TEST("C43214C", "CONSTRAINED ARRAY FORMAL GENERIC " &
                     "PARAMETER");

     BEGIN

CASE_B :  DECLARE

               SUBTYPE STB IS STRING(5 .. 8);

               GENERIC
                    B1 : STB;
               PROCEDURE PROC1;

               PROCEDURE PROC1 IS
               BEGIN
                    IF B1'FIRST /= 5 THEN
                         FAILED ("LOWER BOUND INCORRECT");
                    ELSIF B1'LAST /= 8 THEN
                         FAILED ("UPPER BOUND INCORRECT");
                    ELSIF B1 /= "ABCD" THEN
                         FAILED ("ARRAY DOES NOT " &
                                 "CONTAIN THE CORRECT VALUES");
                    END IF;
               END;

               PROCEDURE PROC2 IS NEW PROC1 ("ABCD");

          BEGIN

               PROC2;

          END CASE_B;

     END;

     RESULT;

END C43214C;
