-- C83E03A.ADA


-- CHECK THAT A FORMAL PARAMETER IN A NAMED PARAMETER ASSOCIATION
--    IS NOT CONFUSED WITH AN ACTUAL PARAMETER IDENTIFIER  HAVING THE
--    SAME SPELLING.


--    RM    23 JULY 1980


WITH REPORT;
PROCEDURE  C83E03A  IS

     USE REPORT;

     P : INTEGER RANGE 1..23 := 17 ;
     FLOW_INDEX : INTEGER := 0 ;

BEGIN

     TEST( "C83E03A" , "CHECK THAT A FORMAL PARAMETER IN A NAMED" &
                       " PARAMETER ASSOCIATION  IS NOT CONFUSED" &
                       " WITH AN ACTUAL PARAMETER HAVING THE" &
                       " SAME SPELLING" );

     DECLARE

          PROCEDURE  BUMP  IS
          BEGIN
               FLOW_INDEX := FLOW_INDEX + 1 ;
          END BUMP ;

          PROCEDURE  P1 ( P : INTEGER )  IS
          BEGIN
               IF  P = 17  THEN  BUMP ; END IF ;
          END ;

          FUNCTION  F1 ( P : INTEGER ) RETURN INTEGER  IS
          BEGIN
               RETURN  P ;
          END ;

     BEGIN

          P1 ( P );
          P1 ( P => P );

          IF  F1 ( P + 1 )      = 17 + 1  THEN  BUMP ;  END IF;
          IF  F1 ( P => P + 1 ) = 17 + 1  THEN  BUMP ;  END IF;

     END ;

     IF  FLOW_INDEX /= 4  THEN
          FAILED( "INCORRECT ACCESSING OR INCORRECT FLOW" );
     END IF;

     RESULT;

END C83E03A;
