-- C35712C.ADA

-- FOR GENERIC FORMAL TYPES, CHECK THAT EXPLICIT CONVERSIONS, 
-- MEMBERSHIP TESTS, AND QUALIFICATION FOR A SUBTYPE ARE EVALUATED 
-- WITH THE ACCURACY OF THE BASE TYPE.

-- R.WILLIAMS 8/26/86

WITH SYSTEM; USE SYSTEM;
WITH REPORT; USE REPORT;
PROCEDURE C35712C IS

BEGIN

     TEST ( "C35712C", "FOR GENERIC FORMAL TYPES, CHECK THAT " &
                       "EXPLICIT CONVERSIONS, MEMBERSHIP TESTS, " &
                       "AND QUALIFICATION FOR A SUBTYPE ARE " &
                       "EVALUATED WITH THE ACCURACY OF THE BASE " &
                       "TYPE" );
                         
     DECLARE
          TYPE REAL IS DIGITS MAX_DIGITS;

          GENERIC
               TYPE R IS DIGITS <>;
          PROCEDURE P;

          PROCEDURE P IS
               LARGE : R := R'LARGE * R (IDENT_INT (1));
               SUBTYPE SUBR IS R DIGITS 1
                               RANGE -R'LARGE .. R'LARGE;
          BEGIN
               BEGIN
                    IF SUBR (LARGE) /= LARGE THEN 
                         FAILED ( "CONVERSION NOT EVALUATED WITH " &
                                  "ACCURACY OF BASE TYPE" );
                    END IF;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         FAILED ( "CONSTRAINT_ERROR RAISED BY " &
                                  "CONVERSION" );
                    WHEN OTHERS =>
                         FAILED ( "OTHER EXCEPTION RAISED BY " &
                                  "CONVERSION" );
               END;
               
               IF LARGE NOT IN SUBR THEN 
                    FAILED ( "MEMBERSHIP TEST NOT PERFORMED WITH " &
                             " OF ACCURACY BASE TYPE" );
               END IF;

               BEGIN
                    IF SUBR'(LARGE) /= LARGE THEN 
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
          END P;
     
          PROCEDURE PROC IS NEW P (REAL);               
     BEGIN
          PROC;     
     END;

     RESULT;
END C35712C;
