-- C35508H.ADA

-- OBJECTIVE:
--     CHECK THAT 'PRED' AND 'SUCC' YIELD THE CORRECT RESULTS WHEN THE
--     PREFIX IS A FORMAL DISCRETE TYPE WHOSE ACTUAL PARAMETER IS A
--     BOOLEAN TYPE.

-- HISTORY:
--     RJW 03/24/86 CREATED ORIGINAL TEST.
--     DHH 10/19/87 SHORTENED LINES CONTAINING MORE THAN 72 CHARACTERS.

WITH REPORT; USE REPORT;

PROCEDURE C35508H IS

BEGIN
     TEST ("C35508H", "CHECK THAT 'PRED' AND 'SUCC' YIELD THE " &
                      "CORRECT RESULTS WHEN THE PREFIX IS A " &
                      "FORMAL DISCRETE TYPE WHOSE ACTUAL PARAMETER " &
                      "IS A BOOLEAN TYPE" );

     DECLARE

          TYPE NEWBOOL IS NEW BOOLEAN;

          GENERIC
               TYPE BOOL IS (<>);
               F, T : BOOL;
          PROCEDURE P (STR : STRING);

          PROCEDURE P (STR : STRING) IS
               SUBTYPE SBOOL IS BOOL RANGE T .. T;
          BEGIN
               BEGIN
                    IF BOOL'PRED (T) /= F THEN
                         FAILED ( "INCORRECT VALUE FOR " &
                                   STR & "'PRED OF T" );
                    END IF;
                    IF BOOL'SUCC (F) /= T THEN
                         FAILED ( "INCORRECT VALUE FOR " &
                                   STR & "'SUCC OF F" );
                    END IF;
               END;

               BEGIN
                    IF SBOOL'PRED (T) /= F THEN
                         FAILED ( "INCORRECT VALUE FOR SBOOL'PRED " &
                                  "OF T FOR " & STR);
                    END IF;
               END;

               BEGIN
                    IF SBOOL'PRED (SBOOL'BASE'FIRST) = T THEN
                         FAILED("'PRED('FIRST) WRAPPED AROUND " &
                                "TO TRUE FOR " & STR);
                    END IF;
                    FAILED ( "NO EXCEPTION RAISED FOR " &
                              STR & "'PRED (SBOOL'BASE'FIRST)" );
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ( "WRONG EXCEPTION RAISED FOR " &
                                   STR & "'PRED (SBOOL'BASE'FIRST)" );
               END;

               BEGIN
                    IF SBOOL'SUCC (SBOOL'BASE'LAST) = F THEN
                         FAILED("'SUCC('LAST) WRAPPED AROUND TO " &
                                "FALSE FOR " & STR);
                    END IF;
                    FAILED ( "NO EXCEPTION RAISED FOR " & STR &
                             "'SUCC (SBOOL'BASE'LAST)" );
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ( "WRONG EXCEPTION RAISED FOR " &
                                  STR & "'SUCC (SBOOL'BASE'LAST)" );
               END;
          END P;

          PROCEDURE NP1 IS NEW P
                         ( BOOL => BOOLEAN, F => FALSE, T => TRUE );

          PROCEDURE NP2 IS NEW P
                         ( BOOL => NEWBOOL, F => FALSE, T => TRUE );
     BEGIN
          NP1 ("BOOLEAN");
          NP2 ("NEWBOOL");
     END;

     RESULT;
END C35508H;
