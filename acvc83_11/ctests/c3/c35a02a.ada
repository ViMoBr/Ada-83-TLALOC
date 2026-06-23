-- C35A02A.ADA

-- CHECK THAT T'DELTA YIELDS CORRECT VALUES FOR SUBTYPE T.

-- RJW 2/27/86

WITH REPORT; USE REPORT;

PROCEDURE C35A02A IS

BEGIN

     TEST ( "C35A02A", "CHECK THAT T'DELTA YIELDS CORRECT VALUES " &
                       "FOR SUBTYPE T" );
                              
     DECLARE
          D  : CONSTANT := 0.125;
          SD : CONSTANT := 1.0;
     
          TYPE VOLT IS DELTA D RANGE 0.0 .. 255.0;
          SUBTYPE ROUGH_VOLTAGE IS VOLT DELTA SD;

          GENERIC
               TYPE FIXED IS DELTA <> ;
          FUNCTION F RETURN FIXED;

          FUNCTION F RETURN FIXED IS
          BEGIN
               RETURN FIXED'DELTA;
          END F;

          FUNCTION VF IS NEW F (VOLT);
          FUNCTION RF IS NEW F (ROUGH_VOLTAGE);

     BEGIN 
          IF VOLT'DELTA /= D THEN
               FAILED ( "INCORRECT VALUE FOR VOLT'DELTA" );
          END IF;
          IF ROUGH_VOLTAGE'DELTA /= SD THEN 
               FAILED ( "INCORRECT VALUE FOR ROUGH_VOLTAGE'DELTA" );
          END IF;

          IF VF /= D THEN
               FAILED ( "INCORRECT VALUE FOR VF" );
          END IF;
          IF RF /= SD THEN
               FAILED ( "INCORRECT VALUE FOR RF" );
          END IF;
     END;               

     RESULT;

END C35A02A;
