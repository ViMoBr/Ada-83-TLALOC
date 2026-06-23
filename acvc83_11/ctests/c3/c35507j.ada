-- C35507J.ADA

-- OBJECTIVE:
--     CHECK THAT THE ATTRIBUTES 'PRED' AND 'SUCC' YIELD THE CORRECT
--     RESULTS WHEN THE PREFIX IS A FORMAL DISCRETE TYPE WHOSE ACTUAL
--     PARAMETER IS A CHARACTER TYPE WITH AN ENUMERATION REPRESENTATION
--     CLAUSE.

-- HISTORY:
--     RJW 06/03/86  CREATED ORIGINAL TEST.
--     JET 09/22/87  MADE REPRESENTATION VALUES CONSECUTIVE.
--     PWB 05/11/89  CHANGED EXTENSION FROM '.DEP' TO '.ADA'.

WITH REPORT; USE REPORT;

PROCEDURE  C35507J  IS

     TYPE CHAR IS ('A', B);
     FOR CHAR USE ('A' => 4, B => 5);

     TYPE NEWCHAR IS NEW CHAR;

BEGIN

     TEST( "C35507J" , "CHECK THAT THE ATTRIBUTES 'PRED' AND " &
                       "'SUCC' YIELD THE CORRECT RESULTS WHEN THE " &
                       "PREFIX IS A FORMAL DISCRETE TYPE WHOSE " &
                       "ACTUAL PARAMETER IS A CHARACTER TYPE WITH " &
                       "WITH AN ENUMERATION REPRESENTATION CLAUSE" );


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

     BEGIN
          PCHAR;
          PNCHAR;

     END;

     RESULT;
END C35507J;
