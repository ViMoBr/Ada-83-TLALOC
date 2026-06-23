-- C35503L.ADA

-- OBJECTIVE:
--     CHECK THAT 'POS' AND 'VAL' YIELD THE CORRECT RESULTS WHEN THE
--     PREFIX IS A GENERIC FORMAL DISCRETE TYPE WHOSE ACTUAL PARAMETER
--     IS AN INTEGER TYPE.

-- HISTORY:
--     RJW 03/17/86 CREATED ORIGINAL TEST.
--     DHH 10/19/87 SHORTENED LINES CONTAINING MORE THAN 72 CHARACTERS.

WITH REPORT; USE REPORT;

PROCEDURE C35503L IS

BEGIN
     TEST ("C35503L", "CHECK THAT 'POS' AND 'VAL' YIELD THE " &
                      "CORRECT RESULTS WHEN THE PREFIX IS A " &
                      "GENERIC FORMAL DISCRETE TYPE WHOSE " &
                      "ACTUAL PARAMETER IS AN INTEGER TYPE" );

     DECLARE
          TYPE INTRANGE IS RANGE -6 .. 6;

          GENERIC
               TYPE INT IS (<>);
          PROCEDURE P (STR : STRING);

          PROCEDURE P (STR : STRING) IS
               SUBTYPE SINT IS INT RANGE
                   INT'VAL (IDENT_INT(-4)) .. INT'VAL (IDENT_INT(4));
               I :INTEGER;
          BEGIN
               I := IDENT_INT(-6);
               FOR S IN INT'VAL (IDENT_INT(-6)) ..
                                                 INT'VAL (IDENT_INT(6))
               LOOP
                    BEGIN
                         IF SINT'POS (S) /= I THEN
                              FAILED ( "WRONG VALUE FOR " &
                                        STR & "'POS OF "
                                       & INT'IMAGE (S) );
                         END IF;
                    EXCEPTION
                         WHEN OTHERS =>
                              FAILED ( "EXCEPTION RAISED FOR " &
                                        STR & "'POS "
                                       & "OF " & INT'IMAGE (S) );
                    END;
                    BEGIN
                         IF SINT'VAL (I) /= S THEN
                              FAILED ( "WRONG VALUE FOR " &
                                        STR & "'VAL "
                                       & "OF " & INT'IMAGE (S) );
                         END IF;
                    EXCEPTION
                         WHEN OTHERS =>
                              FAILED ( "EXCEPTION RAISED FOR " &
                                        STR & "'VAL "
                                       & "OF " & INT'IMAGE (S) );
                    END;
                    I := I + 1;
               END LOOP;
          END P;

          PROCEDURE P1 IS NEW P (INTRANGE);
          PROCEDURE P2 IS NEW P (INTEGER);

     BEGIN
          P1 ("INTRANGE");
          P2 ("INTEGER");
     END;

     RESULT;

END C35503L;
