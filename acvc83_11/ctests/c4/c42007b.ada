-- C42007B.ADA

-- CHECK THAT THE BOUNDS OF A STRING LITERAL ARE DETERMINED CORRECTLY.
-- IN PARTICULAR, CHECK THAT THE LOWER BOUND IS GIVEN BY 'FIRST OF THE
-- INDEX SUBTYPE WHEN THE STRING LITERAL IS USED AS:

--   B) AN ACTUAL PARAMETER IN A GENERIC INSTANTIATION, AND THE FORMAL
--      PARAMETER IS UNCONSTRAINED.

-- TBN  7/23/86

WITH REPORT; USE REPORT;
PROCEDURE C42007B IS

BEGIN

     TEST("C42007B", "CHECK THE BOUNDS OF A STRING LITERAL WHEN " &
                     "USED AS AN ACTUAL PARAMETER IN A GENERIC " &
                     "INSTANTIATION, AND THE FORMAL PARAMETER IS " &
                     "UNCONSTRAINED");

     BEGIN

CASE_B :  DECLARE

               SUBTYPE TEENS IS INTEGER RANGE 11 .. 19;
               TYPE COLOR IS (R, O, Y, G, B, V);
               SUBTYPE S_COLOR IS COLOR RANGE O .. V;
               TYPE TEEN_STR IS ARRAY (TEENS RANGE <>) OF CHARACTER;
               TYPE COLOR_STR IS ARRAY (COLOR RANGE <>) OF CHARACTER;
               TYPE S_COLOR_STR IS
                                  ARRAY (S_COLOR RANGE <>) OF CHARACTER;

               GENERIC
                    TYPE INDEX IS (<>);
                    TYPE STR IS ARRAY (INDEX RANGE <>) OF CHARACTER;
                    B1 : STR;
               PROCEDURE PROC1 (TYPE_ID : STRING);

               PROCEDURE PROC1 (TYPE_ID : STRING) IS
               BEGIN
                    IF B1'FIRST /= INDEX'FIRST THEN
                         FAILED ("LOWER BOUND INCORRECTLY DETERMINED " &
                                 "FOR " & TYPE_ID);
                    END IF;
                    IF B1'LAST /=
                              INDEX'VAL(INDEX'POS(INDEX'FIRST) + 4) THEN
                         FAILED ("UPPER BOUND INCORRECTLY DETERMINED " &
                                 "FOR " & TYPE_ID);
                    END IF;
                    IF B1 /= "HELLO" THEN
                         FAILED ("STRING LITERAL INCORRECT");
                    END IF;
               END;

               PROCEDURE PROC2 IS NEW PROC1 (POSITIVE, STRING, "HELLO");
               PROCEDURE PROC3 IS NEW PROC1 (TEENS, TEEN_STR, "HELLO");
               PROCEDURE PROC4 IS NEW PROC1 (COLOR, COLOR_STR, "HELLO");
               PROCEDURE PROC5 IS NEW PROC1
                                        (S_COLOR, S_COLOR_STR, "HELLO");

          BEGIN

               PROC2 ("STRING");
               PROC3 ("TEEN_STR");
               PROC4 ("COLOR_STR");
               PROC5 ("S_COLOR_STR");

          END CASE_B;

     END;

     RESULT;

END C42007B;
