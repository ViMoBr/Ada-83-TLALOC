-- C35507B.ADA

-- CHECK THAT THE ATTRIBUTE 'WIDTH' YIELDS THE CORRECT RESULTS 
-- WHEN THE PREFIX IS FORMAL DISCRETE TYPE WHOSE ACTUAL PARAMETER IS
-- A CHARACTER TYPE.   

-- RJW 5/29/86

WITH REPORT; USE REPORT;

PROCEDURE  C35507B  IS

     GENERIC
          TYPE CH IS (<>);
     PROCEDURE P ( STR : STRING; W : INTEGER );

     PROCEDURE P ( STR : STRING; W : INTEGER ) IS

          SUBTYPE NOCHAR IS CH RANGE CH'VAL (1) .. CH'VAL(0);
     BEGIN
          IF CH'WIDTH /= W THEN
               FAILED( "INCORRECT WIDTH FOR " & STR );
          END IF;
     
          IF NOCHAR'WIDTH /= 0 THEN
               FAILED( "INCORRECT WIDTH FOR NOCHAR WITH " & STR );
          END IF;
     END P;


BEGIN

     TEST( "C35507B" , "CHECK THAT THE ATTRIBUTE 'WIDTH' YIELDS " &
                       "THE CORRECT RESULTS WHEN THE PREFIX " &
                       "IS A FORMAL DISCRETE TYPE WHOSE ACTUAL " &
                       "PARAMETER IS A CHARACTER TYPE" );

     DECLARE
          TYPE CHAR1 IS (A, 'A');

          SUBTYPE CHAR2 IS CHARACTER RANGE 'A' .. 'Z';
          
          TYPE NEWCHAR IS NEW CHARACTER 
                    RANGE 'A' .. 'Z';

          PROCEDURE P1 IS NEW P (CHAR1);
          PROCEDURE P2 IS NEW P (CHAR2);
          PROCEDURE P3 IS NEW P (NEWCHAR);
     BEGIN
          P1 ("CHAR1", 3);
          P2 ("CHAR2", 3);
          P3 ("NEWCHAR", 3);
     END;

     DECLARE
          SUBTYPE NONGRAPH IS CHARACTER 
                    RANGE CHARACTER'VAL (0) .. CHARACTER'VAL (31);

          MAX : INTEGER := 0;

          PROCEDURE PN IS NEW P (NONGRAPH);
     BEGIN
          FOR CH IN NONGRAPH
               LOOP
                    IF CHARACTER'IMAGE (CH)'LENGTH > MAX THEN
                         MAX := CHARACTER'IMAGE (CH)'LENGTH;
                    END IF;
          END LOOP;
          
          PN ("NONGRAPH", MAX);
     END;                    

     RESULT;
END C35507B;
