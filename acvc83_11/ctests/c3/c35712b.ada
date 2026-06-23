-- C35712B.ADA

-- CHECK WHETHER ASSIGNMENT FOR A SUBTYPE IS PERFORMED WITH LESS 
-- PRECISION THAN THE BASE TYPE, AND IF SO, IF RANGE CONSTRAINT CHECKS
-- ARE PERFORMED AFTER THE VALUE TO BE ASSIGNED IS GIVEN A SUITABLE
-- APPROXIMATION FOR STORAGE.

-- R.WILLIAMS 8/26/86

WITH SYSTEM; USE SYSTEM;
WITH REPORT; USE REPORT;
PROCEDURE C35712B IS

     TYPE REAL IS DIGITS MAX_DIGITS;

BEGIN

     TEST ( "C35712B", "CHECK WHETHER ASSIGNMENT FOR A SUBTYPE IS " &
                       "PERFORMED WITH LESS PRECISION THAN THE " &
                       "BASE TYPE, AND IF SO, IF RANGE CONSTRAINT " &
                       "CHECKS ARE PERFORMED AFTER THE VALUE TO BE " &
                       "ASSIGNED IS GIVEN A SUITABLE APPROXIMATION " &
                       "FOR STORAGE" );
                         
     DECLARE
          LARGE : REAL := REAL'LARGE * REAL (IDENT_INT (1));

          SUBTYPE SUBREAL IS REAL DIGITS 1 
                            RANGE -REAL'LARGE .. REAL'LARGE;
          Z : SUBREAL;

     BEGIN
          Z := LARGE;                         
          IF Z = LARGE * REAL (IDENT_INT (1)) THEN 
               COMMENT ( "ASSIGNMENTS ARE PERFORMED WITH THE SAME " &
                         "PRECISION AS THE BASE TYPE - 1" );
          ELSE
               COMMENT ( "ASSIGNMENTS ARE PERFORMED WITH LESS " &
                         "PRECISION THAN THE BASE TYPE - 1" );
               IF Z NOT IN 
                    2#0.11111# * 2.0 ** REAL'EMAX .. REAL'LARGE THEN
                    FAILED ( "RANGE CONSTRAINT CHECKS ARE PERFORMED " &
                             "BEFORE THE DIGIT APPROXIMATION IS " &
                             "DONE" );
               ELSE 
                    COMMENT ( "RANGE CONSTRAINT CHECKS ARE " &
                              "PERFORMED AFTER THE DIGIT " &
                              "APPROXIMATION IS DONE" );
               END IF;
         END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT ( "ASSIGNMENTS ARE PERFORMED WITH LESS " &
                         "PRECISION THAN THE BASE TYPE AND THE " &
                         "RANGE CONSTRAINT CHECKS ARE PERFORMED " &
                         "AFTER THE DIGIT APPROXIMATION IS DONE" );
     END;

     RESULT;

END C35712B;
