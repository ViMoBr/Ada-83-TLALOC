-- C45111C.ADA

-- CHECK THE TRUTH TABLES FOR THE CORRECT OPERATION OF
-- 'AND' , 'OR' , AND 'XOR' ON BOOLEAN ARRAYS.

--    RJW  1/8/86

WITH  REPORT ;
PROCEDURE  C45111C  IS

     USE REPORT;

     FLOW_INDEX : INTEGER := 0 ;

     TYPE T IS ARRAY (1..4) OF BOOLEAN;

     A : T := (FALSE, FALSE, TRUE, TRUE);
     B : T := (FALSE, TRUE, FALSE, TRUE);

     PROCEDURE  BUMP  IS
     BEGIN
          FLOW_INDEX  :=  FLOW_INDEX + 1 ;
     END BUMP;

BEGIN

     TEST( "C45111C" , "CHECK BOOLEAN TRUTH TABLES 'AND','OR','XOR' " &
                       "FOR ARRAYS" );

                                                  -- BUMP VALUES

     IF (A AND B) = (FALSE, FALSE, FALSE, TRUE) THEN
          BUMP;                                   --     1
     ELSE
          FAILED( "'AND' NOT CORRECT" );
     END IF;

     IF (A OR B) = (FALSE, TRUE, TRUE, TRUE) THEN
          BUMP;                                   --     2
     ELSE
          FAILED( "'OR' NOT CORRECT" );
     END IF;

     IF (A XOR B) = (FALSE, TRUE, TRUE, FALSE) THEN
          BUMP;                                   --     3
     ELSE
          FAILED( "'XOR' NOT CORRECT" );
     END IF;

     IF FLOW_INDEX /= 3 THEN
          FAILED ( "WRONG FLOW_INDEX" );
     END IF;

     RESULT;

END C45111C;
