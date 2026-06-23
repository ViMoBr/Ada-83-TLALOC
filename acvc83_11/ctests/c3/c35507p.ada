-- C35507P.ADA

-- CHECK THAT THE ATTRIBUTES 'FIRST' AND 'LAST' YIELD THE CORRECT 
-- RESULTS WHEN THE PREFIX IS A FORMAL DISCRETE TYPE WHOSE ACTUAL
-- PARAMETER IS A CHARACTER TYPE.   

-- RJW 6/03/86

WITH REPORT; USE REPORT;

PROCEDURE  C35507P  IS

     TYPE CHAR IS ('A', B);

     TYPE NEWCHAR IS NEW CHAR;     

     SPACE : CONSTANT CHARACTER := ' ';

     SUBTYPE GRAPHIC IS CHARACTER RANGE SPACE .. ASCII.TILDE;
     SUBTYPE NONGRAPHIC IS CHARACTER RANGE ASCII.NUL .. ASCII.US;
BEGIN

     TEST( "C35507P" , "CHECK THAT THE ATTRIBUTES 'FIRST' AND " &
                       "'LAST' YIELD THE CORRECT RESULTS WHEN THE " &
                       "PREFIX IS A FORMAL DISCRETE TYPE WHOSE " &
                       "ACTUAL PARAMETER IS A CHARACTER TYPE" );

     DECLARE
          GENERIC
               TYPE CHTYPE IS (<>);
               STR : STRING;
               F, L : CHTYPE;
          PROCEDURE P;

          PROCEDURE P IS 
               SUBTYPE NOCHAR IS CHTYPE RANGE L .. F;
          BEGIN 
               IF CHTYPE'FIRST /= F THEN 
                    FAILED ( "INCORRECT VALUE FOR " & STR & "'FIRST" );
               END IF;

               IF CHTYPE'LAST /= L THEN 
                    FAILED ( "INCORRECT VALUE FOR " & STR & "'LAST" );
               END IF;

               IF NOCHAR'FIRST /= L THEN 
                    FAILED ( "INCORRECT VALUE FOR NOCHAR'FIRST AS A " &
                             "SUBTYPE OF " & STR );
               END IF;

               IF NOCHAR'LAST /= F THEN 
                    FAILED ( "INCORRECT VALUE FOR NOCHAR'LAST AS A " &
                             "SUBTYPE OF " & STR  );
               END IF;
          END P;
          
          PROCEDURE P1 IS NEW P (CHAR, "CHAR", 'A', B);          
          PROCEDURE P2 IS NEW P (NEWCHAR, "NEWCHAR", 'A', B);          
          PROCEDURE P3 IS NEW P 
               (GRAPHIC, "GRAPHIC", SPACE, ASCII.TILDE);
          PROCEDURE P4 IS NEW P 
               (NONGRAPHIC, "NONGRAPHIC", ASCII.NUL, ASCII.US);
          PROCEDURE P5 IS NEW P 
               (CHARACTER, "CHARACTER", ASCII.NUL, ASCII.DEL);
     BEGIN
          P1;
          P2;
          P3;
          P4;
          P5;
     END;

     RESULT;
END C35507P;
