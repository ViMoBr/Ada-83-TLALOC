-- C35507A.ADA

-- CHECK THAT THE ATTRIBUTE 'WIDTH' YIELDS THE CORRECT RESULTS 
-- WHEN THE PREFIX IS A CHARACTER TYPE.   

-- RJW 5/29/86

WITH REPORT; USE REPORT;

PROCEDURE  C35507A  IS

BEGIN

     TEST( "C35507A" , "CHECK THAT THE ATTRIBUTE 'WIDTH' YIELDS " &
                       "THE CORRECT RESULTS WHEN THE PREFIX " &
                       "IS A CHARACTER TYPE" );

     DECLARE
          TYPE CHAR1 IS (A, 'A');

          SUBTYPE CHAR2 IS CHARACTER RANGE 'A' .. 'Z';

          SUBTYPE NOCHAR IS CHARACTER RANGE 'Z' .. 'A';
          
          TYPE NEWCHAR IS NEW CHARACTER 
                    RANGE 'A' .. 'Z';

     BEGIN
          IF CHAR1'WIDTH /= 3 THEN
               FAILED( "INCORRECT WIDTH FOR CHAR1" );
          END IF;

          IF CHAR2'WIDTH /= 3 THEN
               FAILED( "INCORRECT WIDTH FOR CHAR2" );
          END IF;

          IF NEWCHAR'WIDTH /= 3 THEN
               FAILED( "INCORRECT WIDTH FOR NEWCHAR" );
          END IF;

          IF NOCHAR'WIDTH /= 0 THEN
               FAILED( "INCORRECT WIDTH FOR NOCHAR" );
          END IF;
     END;

     DECLARE
          SUBTYPE NONGRAPH IS CHARACTER 
                    RANGE CHARACTER'VAL (0) .. CHARACTER'VAL (31);

          MAX : INTEGER := 0;

     BEGIN
          FOR CH IN NONGRAPH
               LOOP
                    IF CHARACTER'IMAGE (CH)'LENGTH > MAX THEN
                         MAX := CHARACTER'IMAGE (CH)'LENGTH;
                    END IF;
          END LOOP;
          
          IF NONGRAPH'WIDTH /= MAX THEN
               FAILED ( "INCORRECT WIDTH FOR NONGRAPH" );
          END IF;
     END;                    

     RESULT;
END C35507A;
