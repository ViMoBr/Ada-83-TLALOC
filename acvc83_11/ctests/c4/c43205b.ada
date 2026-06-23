-- C43205B.ADA

-- CHECK THAT THE BOUNDS OF A POSITIONAL AGGREGATE ARE DETERMINED
-- CORRECTLY. IN PARTICULAR, CHECK THAT THE LOWER BOUND IS GIVEN BY
-- 'FIRST OF THE INDEX SUBTYPE WHEN THE POSITIONAL AGGREGATE IS USED AS:

--   B) AN ACTUAL PARAMETER IN A GENERIC INSTANTIATION, AND THE FORMAL
--      PARAMETER IS UNCONSTRAINED.

-- EG  01/26/84

WITH REPORT;

PROCEDURE C43205B IS

     USE REPORT;

BEGIN

     TEST("C43205B", "CASE B : UNCONSTRAINED ARRAY FORMAL GENERIC " &
                      "PARAMETER");

     BEGIN

CASE_B :  DECLARE

               SUBTYPE STB IS INTEGER RANGE IDENT_INT(-8) .. -5;
               TYPE TB IS ARRAY (STB RANGE <>) OF INTEGER;

               GENERIC
                    B1 : TB;
               PROCEDURE PROC1;

               PROCEDURE PROC1 IS
               BEGIN
                    IF B1'FIRST /= -8 THEN
                         FAILED ("CASE B : LOWER BOUND INCORRECTLY " &
                                 "GIVEN BY 'FIRST");
                    ELSIF B1'LAST /= IDENT_INT(-5) THEN
                         FAILED ("CASE B : UPPER BOUND INCORRECTLY " &
                                 "GIVEN BY 'LAST");
                    ELSIF B1 /= (7, 6, 5, 4) THEN
                         FAILED ("CASE B : ARRAY DOES NOT " &
                                 "CONTAIN THE CORRECT VALUES");
                    END IF;
               END;

               PROCEDURE PROC2 IS NEW PROC1 ((7, 6, IDENT_INT(5), 4));

          BEGIN

               PROC2;

          END CASE_B;

     END;

     RESULT;

END C43205B;
