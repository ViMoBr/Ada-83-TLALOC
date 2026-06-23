-- C35502D.TST

-- CHECK THAT 'IMAGE' AND 'VALUE' YIELD THE CORRECT RESULT FOR THE
-- LONGEST POSSIBLE ENUMERATION LITERAL.

-- RJW 2/21/86

WITH REPORT; USE REPORT;

PROCEDURE C35502D IS

BEGIN
     TEST ("C35502D", "CHECK THAT 'IMAGE' AND 'VALUE' YIELD " &
                      "CORRECT RESULTS FOR THE LONGEST POSSIBLE " &
                      "ENUMERATION LITERAL");

     -- BIG_ID1 IS A MAXIMUM LENGTH IDENTIFIER. BIG_STRING1 AND 
     -- BIG_STRING2 ARE TWO STRING LITERALS WHICH WHEN CONCATENATED 
     -- FORM THE IMAGE OF BIG_ID1;


     DECLARE
          TYPE ENUM IS (
$BIG_ID1
                        );                             

     BEGIN
          BEGIN
               IF ENUM'VALUE (
$BIG_STRING1  
&
$BIG_STRING2
) /= 
$BIG_ID1
                    THEN
                    FAILED ( "INCORRECT RESULTS FOR 'VALUE'" );
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ( "EXCEPTION RAISED FOR 'VALUE'" );
          END;
          BEGIN           
               IF ENUM'IMAGE( 
$BIG_ID1
) /=
(
$BIG_STRING1
&
$BIG_STRING2
)                   THEN
                    FAILED ( "INCORRECT RESULTS FOR 'IMAGE'" );
               END IF;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    FAILED ( "CONSTRAINT_ERROR RAISED FOR 'IMAGE'" );
               WHEN OTHERS =>
                    FAILED ( "OTHER EXCEPTION RAISED FOR 'IMAGE'" );
          END;
     END;

     RESULT;
END C35502D;
