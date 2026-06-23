-- C35712A.ADA

-- CHECK THAT, FOR FLOATING POINT SUBTYPES, EXPLICIT CONVERSIONS, 
-- MEMBERSHIP TESTS, AND QUALIFICATION ARE EVALUATED WITH THE 
-- ACCURACY OF THE BASE TYPE.

-- R.WILLIAMS 8/26/86

WITH SYSTEM; USE SYSTEM;
WITH REPORT; USE REPORT;
PROCEDURE C35712A IS

BEGIN

     TEST ( "C35712A", "CHECK THAT EXPLICIT CONVERSIONS, MEMBERSHIP " &
                       "TESTS, AND QUALIFICATION FOR A FLOATING " &
                       "POINT SUBTYPE ARE EVALUATED WITH THE " &
                       "ACCURACY OF THE BASE TYPE" );
                         
     DECLARE
          TYPE REAL IS DIGITS MAX_DIGITS;

          LARGE : REAL := REAL'LARGE * REAL (IDENT_INT (1));

          SUBTYPE SUBREAL IS REAL DIGITS 1 
                             RANGE -REAL'LARGE .. REAL'LARGE;

     BEGIN
          BEGIN
               IF SUBREAL (LARGE) /= LARGE THEN 
                    FAILED ( "CONVERSION NOT EVALUATED WITH " &
                             "ACCURACY OF BASE TYPE" );
               END IF;
                    
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    FAILED ( "CONSTRAINT_ERROR RAISED BY CONVERSION" );
               WHEN OTHERS =>
                    FAILED ( "OTHER EXCEPTION RAISED BY CONVERSION" );
          END;
               
          IF LARGE NOT IN SUBREAL THEN
               FAILED ( "MEMBERSHIP TEST NOT PERFORMED WITH " &
                        "ACCURACY OF BASE TYPE" );
          END IF;

          BEGIN
               IF SUBREAL'(LARGE) /= LARGE THEN 
                    FAILED ( "QUALIFICATION NOT EVALUATED WITH " &
                             "ACCURACY OF BASE TYPE" );
               END IF;
                    
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    FAILED ( "CONSTRAINT_ERROR RAISED BY " &
                             "QUALIFICATION" );
               WHEN OTHERS =>
                    FAILED ( "OTHER EXCEPTION RAISED BY " &
                             "QUALIFICATION" );
          END;
     END;

     RESULT;

END C35712A;
