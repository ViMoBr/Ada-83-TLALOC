-- C35507H.ADA

-- CHECK THAT THE ATTRIBUTES 'PRED' AND 'SUCC' YIELD THE CORRECT
-- RESULTS WHEN THE PREFIX IS A FORMAL DISCRETE TYPE WHOSE ACTUAL
-- PARAMETER IS A CHARACTER TYPE.

-- RJW 6/03/86
-- DWC 7/01/87     -- ADDED THIRD VALUE TO CHAR TYPE.
                   -- REMOVED SECTION OF CODE AND PLACED INTO
                   -- C35505E.ADA.

WITH REPORT; USE REPORT;

PROCEDURE  C35507H  IS

     TYPE CHAR IS ('A', B, C);

     TYPE NEWCHAR IS NEW CHAR;

BEGIN

     TEST( "C35507H" , "CHECK THAT THE ATTRIBUTES 'PRED' AND " &
                       "'SUCC' YIELD THE CORRECT RESULTS WHEN THE " &
                       "PREFIX IS A FORMAL DISCRETE TYPE WHOSE " &
                       "ACTUAL PARAMETER IS A CHARACTER TYPE" );

     DECLARE
          GENERIC
               TYPE CHTYPE IS (<>);
               STR : STRING;
               I1, I2 : INTEGER;
          PROCEDURE P;

          PROCEDURE P IS
               SUBTYPE SUBCH IS CHTYPE
                    RANGE CHTYPE'VAL (I1) .. CHTYPE'VAL (I2);

          BEGIN
               FOR CH IN SUBCH'VAL (I1 + 1) .. SUBCH'VAL (I2) LOOP
                    IF SUBCH'PRED (CH) /=
                       SUBCH'VAL (SUBCH'POS (CH) - 1) THEN
                         FAILED ( "INCORRECT VALUE FOR " & STR &
                                  "'PRED OF " & SUBCH'IMAGE (CH) );
                    END IF;
               END LOOP;

               FOR CH IN SUBCH'VAL (I1) .. SUBCH'VAL (I2 - 1) LOOP
                    IF SUBCH'SUCC (CH) /=
                       SUBCH'VAL (SUBCH'POS (CH) + 1) THEN
                         FAILED ( "INCORRECT VALUE FOR " & STR &
                                  "'SUCC OF " & SUBCH'IMAGE (CH) );
                    END IF;
               END LOOP;

          END P;

          PROCEDURE PCHAR IS NEW P (CHAR, "CHAR", 0, 1);
          PROCEDURE PNCHAR IS NEW P (NEWCHAR, "NEWCHAR", 0, 1);
          PROCEDURE PCH IS NEW P (CHARACTER, "CHARACTER", 0, 127);
     BEGIN
          PCHAR;
          PNCHAR;
          PCH;
     END;

     RESULT;
END C35507H;
