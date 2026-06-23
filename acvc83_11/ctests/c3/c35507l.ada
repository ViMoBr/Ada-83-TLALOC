-- C35507L.ADA

-- CHECK THAT THE ATTRIBUTES 'POS' AND 'VAL' YIELD THE CORRECT 
-- RESULTS WHEN THE PREFIX IS A FORMAL DISCRETE TYPE WHOSE ACTUAL
-- PARAMETER IS A CHARACTER TYPE.   

-- RJW 6/03/86

WITH REPORT; USE REPORT;

PROCEDURE  C35507L  IS

     TYPE CHAR IS ('A', B);

     TYPE NEWCHAR IS NEW CHAR;     

BEGIN

     TEST( "C35507L" , "CHECK THAT THE ATTRIBUTES 'POS' AND " &
                       "'VAL' YIELD THE CORRECT RESULTS WHEN THE " &
                       "PREFIX IS A FORMAL DISCRETE TYPE WHOSE " & 
                       "ACTUAL PARAMETER IS A CHARACTER TYPE" );

     DECLARE
          GENERIC
               TYPE CHTYPE IS (<>);
               STR : STRING;
               I1 : INTEGER;
          PROCEDURE P;

          PROCEDURE P IS
               SUBTYPE SUBCH IS CHTYPE;               
               CH : CHTYPE;
               POSITION : INTEGER;
          BEGIN
               POSITION := 0;
               FOR CH IN CHTYPE LOOP
                    IF SUBCH'POS (CH) /= POSITION THEN 
                         FAILED ( "INCORRECT VALUE FOR " & STR & 
                                  "'POS OF " & CHTYPE'IMAGE (CH) );
                    END IF;
     
                    IF SUBCH'VAL (POSITION) /= CH THEN
                         FAILED ( "INCORRECT VALUE FOR " & STR & 
                                  "'VAL OF CHARACTER IN POSITION - " &
                                    INTEGER'IMAGE (POSITION) );
                    END IF;
                    POSITION := POSITION + 1;
               END LOOP;
     
               BEGIN
                    IF SUBCH'VAL (I1 + 1) = SUBCH'VAL (I1)  THEN
                         FAILED ( "NO EXCEPTION RAISED " &
                                  "FOR " & STR & "'VAL OF " &
                                   INTEGER'IMAGE (I1 + 1) & " - 1" );
                    ELSE
                         FAILED ( "NO EXCEPTION RAISED " &
                                  "FOR " & STR & "'VAL OF " &
                                   INTEGER'IMAGE (I1 + 1) & " - 2" );
                    END IF;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ( "WRONG EXCEPTION RAISED " &
                                  "FOR " & STR & "'VAL OF " &
                                   INTEGER'IMAGE (I1 + 1) );
               END;     

               BEGIN
                    IF SUBCH'VAL (-1) = SUBCH'VAL (0) THEN
                         FAILED ( "NO EXCEPTION RAISED " & 
                                  "FOR " & STR & "'VAL (-1) - 1" );
                    ELSE
                         FAILED ( "NO EXCEPTION RAISED " & 
                                  "FOR " & STR & "'VAL (-1) - 2" );
                    END IF;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ( "WRONG EXCEPTION RAISED " & 
                                  "FOR " & STR & "'VAL (-1)" );
               END;     
          END P;
          
          PROCEDURE PCHAR IS NEW P (CHAR, "CHAR", 1);
          PROCEDURE PNCHAR IS NEW P (NEWCHAR, "NEWCHAR", 1);
          PROCEDURE PCH IS NEW P (CHARACTER, "CHARACTER", 127);
     BEGIN
          PCHAR;
          PNCHAR;
          PCH;
     END;

     RESULT;
END C35507L;
