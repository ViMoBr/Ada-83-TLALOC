-- C45631A.ADA

-- CHECK THAT FOR TYPE INTEGER 'ABS A' EQUALS A IF A IS POSITIVE AND 
-- EQUALS -A IF A IS NEGATIVE.

-- RJW 2/10/86

WITH REPORT; USE REPORT;

PROCEDURE C45631A IS
     
BEGIN

     TEST ( "C45631A", "CHECK THAT FOR TYPE INTEGER 'ABS A' " &
                       "EQUALS A IF A IS POSITIVE AND EQUALS -A IF " & 
                       "A IS NEGATIVE" );

     DECLARE 
     
          P : INTEGER := IDENT_INT (1);
          N : INTEGER := IDENT_INT (-1);
          Z : INTEGER := IDENT_INT (0);
     BEGIN 

          IF ABS P = P THEN
               NULL;
          ELSE
               FAILED ( "'ABS' TEST FOR P - 1" );
          END IF;

          IF ABS N = -N THEN
               NULL;
          ELSE
               FAILED ( "'ABS' TEST FOR N - 1" );
          END IF;

          IF ABS Z = Z THEN
               NULL;
          ELSE
               FAILED ( "'ABS TEST FOR Z - 1" );
          END IF;

          IF ABS (Z) = -Z THEN
               NULL;
          ELSE
               FAILED ( "'ABS TEST FOR Z - 2");
          END IF;

          IF "ABS" (RIGHT => P) = P THEN
               NULL;
          ELSE
               FAILED ( "'ABS' TEST FOR P - 2" );
          END IF;

          IF "ABS" (N) = -N THEN
               NULL;
          ELSE
               FAILED ( "'ABS' TEST FOR N - 2 " );
          END IF;

          IF "ABS" (Z) = Z THEN
               NULL;
          ELSE
               FAILED ( "'ABS' TEST FOR Z - 3" );
          END IF;
         
          IF ABS (IDENT_INT (-INTEGER'LAST)) = INTEGER'LAST THEN
               NULL;
          ELSE
               FAILED ( "'ABS' TEST FOR -INTEGER'LAST" );
          END IF;
     END; 

     RESULT;

END C45631A;
