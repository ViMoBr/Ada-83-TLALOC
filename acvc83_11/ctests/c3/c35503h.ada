-- C35503H.ADA

-- OBJECTIVE:
--     CHECK THAT 'PRED' AND 'SUCC' YIELD THE CORRECT RESULT WHEN THE
--     PREFIX IS A GENERIC FORMAL DISCRETE TYPE WHOSE ACTUAL PARAMETER
--     IS AN INTEGER TYPE.

-- HISTORY:
--     RJW 03/17/86 CREATED ORIGINAL TEST.
--     DHH 10/19/87 SHORTENED LINES CONTAINING MORE THAN 72 CHARACTERS.

WITH REPORT; USE REPORT;

PROCEDURE C35503H IS

BEGIN
     TEST ("C35503H", "CHECK THAT 'PRED' AND 'SUCC' YIELD THE " &
                      "CORRECT RESULT WHEN THE PREFIX IS A GENERIC " &
                      "FORMAL DISCRETE TYPE WHOSE ACTUAL PARAMETER " &
                      "IS AN INTEGER TYPE" );

     DECLARE
          TYPE INTRANGE IS RANGE -6 .. 6;

          GENERIC
               TYPE INT IS (<>);
          PROCEDURE P (STR : STRING);

          PROCEDURE P (STR : STRING) IS
               SUBTYPE SINT IS INT
                    RANGE INT'VAL (IDENT_INT(-4)) ..
                                                INT'VAL (IDENT_INT(4));
          BEGIN
               FOR I IN INT'VAL (IDENT_INT(-6))  ..
                                                INT'VAL (IDENT_INT(6))
               LOOP
                    BEGIN
                         IF SINT'PRED (I) /=
                            SINT'VAL (SINT'POS (I) - 1) THEN
                              FAILED ( "WRONG " & STR & "'PRED " &
                                       "FOR " & INT'IMAGE (I) );
                         END IF;
                    EXCEPTION
                         WHEN OTHERS =>
                              FAILED ( "EXCEPTION RAISED FOR " &
                                        STR & "'PRED OF " &
                                        INT'IMAGE (I));
                    END;
                    BEGIN
                         IF SINT'SUCC (I) /=
                            SINT'VAL (SINT'POS (I) + 1) THEN
                              FAILED ( "WRONG " & STR & "'SUCC " &
                                       "FOR " &  INT'IMAGE (I));
                         END IF;
                    EXCEPTION
                         WHEN OTHERS =>
                              FAILED ( "EXCEPTION RAISED FOR " &
                                        STR & "'SUCC OF " &
                                        INT'IMAGE (I));
                    END;
               END LOOP;
          END P;

          PROCEDURE PROC1 IS NEW P (INTRANGE);
          PROCEDURE PROC2 IS NEW P (INTEGER);
     BEGIN
          PROC1 ("INTRANGE");
          PROC2 ("INTEGER");
     END;

     RESULT;
END C35503H;
