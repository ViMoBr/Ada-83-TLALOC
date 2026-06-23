-- C35502H.ADA

-- CHECK THAT 'PRED' AND 'SUCC' YIELD THE CORRECT RESULTS WHEN 
-- THE PREFIX IS A FORMAL DISCRETE TYPE WHOSE ACTUAL ARGUMENT IS
-- AN ENUMERATION TYPE OTHER THAN A BOOLEAN OR A CHARACTER TYPE.

-- RJW 5/27/86

WITH REPORT; USE REPORT;

PROCEDURE C35502H IS

          TYPE ENUM IS (A, BC, ABC, A_B_C, ABCD);

          TYPE NEWENUM IS NEW ENUM;

BEGIN
     TEST ("C35502H", "CHECK THAT 'PRED' AND 'SUCC' YIELD THE " &
                      "CORRECT RESULTS WHEN THE PREFIX IS A " &
                      "FORMAL DISCRETE TYPE WHOSE ACTUAL " &
                      "ARGUMENT IS AN ENUMERATION TYPE OTHER THAN " &
                      "A CHARACTER OR A BOOLEAN TYPE" );

     DECLARE
          GENERIC
               TYPE E IS (<>);
               STR : STRING;
          PROCEDURE P;
          
          PROCEDURE P IS
               SUBTYPE SE IS E RANGE E'VAL(0) .. E'VAL(1);
          BEGIN
               FOR I IN E'VAL (1) .. E'VAL (4) LOOP
                    IF SE'PRED (I) /= 
                       E'VAL (E'POS (I) - 1) THEN
                         FAILED ("INCORRECT " & STR & "'PRED(" &
                                  E'IMAGE (I) & ")" );
                    END IF;
               END LOOP;

               FOR I IN E'VAL (0) .. E'VAL (3) LOOP
                    IF SE'SUCC (I) /= 
                       E'VAL (E'POS (I) + 1) THEN
                         FAILED ("INCORRECT " & STR & "'SUCC(" &
                                  E'IMAGE (I) & ")" );
                    END IF;
               END LOOP;

          END P;

          PROCEDURE PE IS NEW P ( ENUM, "ENUM" );
          PROCEDURE PN IS NEW P ( NEWENUM, "NEWENUM" );

     BEGIN
          PE;
          PN;
     END;
          
     RESULT;
END C35502H;
