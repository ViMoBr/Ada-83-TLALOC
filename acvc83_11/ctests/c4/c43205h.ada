-- C43205H.ADA

-- CHECK THAT THE BOUNDS OF A POSITIONAL AGGREGATE ARE DETERMINED
-- CORRECTLY. IN PARTICULAR, CHECK THAT THE LOWER BOUND IS GIVEN BY
-- THE LOWER BOUND OF THE APPLICABLE INDEX CONSTRAINT WHEN THE
-- POSITIONAL AGGREGATE IS USED AS:

-- AN ACTUAL PARAMETER IN A GENERIC INSTANTIATION, AND THE FORMAL
-- PARAMETER IS CONSTRAINED.

-- EG  01/27/84

WITH REPORT;

PROCEDURE C43205H IS

     USE REPORT;

BEGIN

     TEST("C43205H", "CONSTRAINED ARRAY FORMAL GENERIC " &
                     "PARAMETER");

     BEGIN

CASE_H :  DECLARE

               SUBTYPE STH IS INTEGER RANGE -10 .. 0;
               TYPE BASE IS ARRAY(STH RANGE <>) OF INTEGER;
               SUBTYPE TB IS BASE(IDENT_INT(-8) .. -5);

               GENERIC
                    B1 : TB;
               PROCEDURE PROC1;

               PROCEDURE PROC1 IS
               BEGIN
                    IF B1'FIRST /= -8 THEN
                         FAILED ("CASE B : LOWER BOUND INCORRECT");
                    ELSIF B1'LAST /= -5 THEN
                         FAILED ("CASE B : UPPER BOUND INCORRECT");
                    ELSIF B1 /= (7, 6, 5, 4) THEN
                         FAILED ("CASE B : ARRAY DOES NOT " &
                                 "CONTAIN THE CORRECT VALUES");
                    END IF;
               END;

               PROCEDURE PROC2 IS NEW PROC1 ((7, 6, 5, 4));

          BEGIN

               PROC2;

          END CASE_H;

     END;

     RESULT;

END C43205H;
