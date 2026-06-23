-- C35505E.ADA

-- OBJECTIVE:
--     CHECK THAT CONSTRAINT_ERROR IS RAISED FOR 'SUCC' AND 'PRED',
--     IF THE RESULT WOULD BE OUTSIDE THE RANGE OF THE BASE TYPE,
--     WHEN THE PREFIX IS A FORMAL DISCRETE TYPE WHOSE ACTUAL ARGUMENT
--     IS TYPE CHARACTER OR A SUBTYPE OF TYPE CHARACTER.

-- HISTORY:
--     DWC 07/01/87

WITH REPORT; USE REPORT;

PROCEDURE C35505E IS

     TYPE CHAR IS ('A', B, C);
     SUBTYPE NEWCHAR IS CHAR;

BEGIN
     TEST ( "C35505E", "CHECK THAT CONSTRAINT_ERROR IS RAISED FOR " &
                       "'SUCC' AND 'PRED', IF THE RESULT WOULD BE " &
                       "OUTSIDE THE RANGE OF THE BASE TYPE, WHEN " &
                       "THE PREFIX IS A FORMAL DISCRETE TYPE WHOSE " &
                       "ACTUAL ARGUMENT IS A CHARACTER TYPE ");

     DECLARE
          GENERIC
               TYPE SUBCH IS (<>);
               STR : STRING;
               I1, I2 : INTEGER;
          PROCEDURE P;

          PROCEDURE P IS

               FUNCTION IDENT (C : SUBCH) RETURN SUBCH IS
               BEGIN
                    RETURN SUBCH'VAL (IDENT_INT (SUBCH'POS (C)));
               END IDENT;

          BEGIN
               BEGIN
                    IF SUBCH'PRED (SUBCH'BASE'FIRST) = SUBCH'VAL (0)
                         THEN
                         FAILED ( "CONSTRAINT_ERROR NOT RAISED FOR " &
                                   STR & "'PRED -  1" );
                    ELSE
                         FAILED ( "CONSTRAINT_ERROR NOT RAISED FOR " &
                                   STR & "'PRED -  2" );
                    END IF;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ( "WRONG EXCEPTION RAISED FOR " &
                                   STR & "'PRED - 1" );
               END;

               BEGIN
                    IF SUBCH'SUCC (SUBCH'BASE'LAST) = SUBCH'VAL (0) THEN
                         FAILED ( "CONSTRAINT_ERROR NOT RAISED FOR " &
                                   STR & "'SUCC -  1" );
                    ELSE
                         FAILED ( "CONSTRAINT_ERROR NOT RAISED FOR " &
                                   STR & "'SUCC -  2" );
                    END IF;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ( "WRONG EXCEPTION RAISED FOR " &
                                   STR & "'SUCC - 1" );
               END;

               BEGIN
                    IF SUBCH'PRED (IDENT (SUBCH'BASE'FIRST)) =
                       SUBCH'VAL (I1) THEN
                         FAILED ( "NO EXCEPTION RAISED " &
                                  "FOR " & STR & "'PRED " &
                                  "(IDENT (SUBCH'BASE'FIRST)) - 1" );
                    ELSE
                         FAILED ( "NO EXCEPTION RAISED " &
                                  "FOR " & STR & "'PRED " &
                                  "(IDENT (SUBCH'BASE'FIRST)) - 2" );
                    END IF;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ( "WRONG EXCEPTION RAISED " &
                                  "FOR " & STR & "'PRED " &
                                  "(IDENT (SUBCH'BASE'FIRST))" );
               END;

               BEGIN
                    IF SUBCH'SUCC (IDENT(SUBCH'BASE'LAST)) =
                       SUBCH'VAL (I2) THEN
                         FAILED ( "NO EXCEPTION RAISED " &
                                  "FOR " & STR & "'SUCC " &
                                  "(IDENT (SUBCH'BASE'LAST)) - 1" );
                    ELSE
                         FAILED ( "NO EXCEPTION RAISED " &
                                  "FOR " & STR & "'SUCC " &
                                  "(IDENT (SUBCH'BASE'LAST)) - 2" );
                    END IF;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ( "WRONG EXCEPTION RAISED " &
                                  "FOR " & STR & "'SUCC " &
                                  "(IDENT (SUBCH'BASE'LAST))" );
               END;
          END P;

          PROCEDURE PCHAR  IS NEW P (CHAR, "CHAR", 0, 1);
          PROCEDURE PNCHAR IS NEW P (NEWCHAR, "NEWCHAR", 0, 1);
     BEGIN
          PCHAR;
          PNCHAR;
     END;
RESULT;
END C35505E;
