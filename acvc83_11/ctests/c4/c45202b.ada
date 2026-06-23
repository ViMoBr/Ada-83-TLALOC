-- C45202B.ADA

-- CHECK MEMBERSHIP OPERATIONS IN THE CASE IN WHICH A USER HAS 
-- REDEFINED THE ORDERING OPERATORS.

-- RJW 1/22/86

WITH REPORT; USE REPORT;

PROCEDURE C45202B IS


BEGIN

     TEST( "C45202B" , "CHECK MEMBERSHIP OPERATIONS IN WHICH A USER " &
                       "HAS REDEFINED THE ORDERING OPERATORS" ) ;


     DECLARE

          TYPE  T  IS  ( AA, BB, CC, LIT, XX, YY, ZZ );    
          SUBTYPE ST IS T RANGE AA .. LIT;     

          VAR  :           T :=  LIT ;
          CON  :  CONSTANT T :=  LIT ;

          FUNCTION ">" ( L, R : T ) RETURN BOOLEAN IS
          BEGIN
               RETURN T'POS(L) <= T'POS(R);
          END;
                    
          FUNCTION ">=" ( L, R : T ) RETURN BOOLEAN IS
          BEGIN
               RETURN T'POS(L) < T'POS(R);
          END;

          FUNCTION "<" ( L, R : T ) RETURN BOOLEAN IS
          BEGIN
               RETURN T'POS(L) >= T'POS(R);
          END;
                    
          FUNCTION "<=" ( L, R : T ) RETURN BOOLEAN IS
          BEGIN
               RETURN T'POS(L) > T'POS(R);
          END;
                    

     BEGIN

          IF   LIT NOT IN ST      OR
               VAR NOT IN ST      OR
               CON NOT IN ST      OR
               NOT (VAR IN ST)    OR
               XX IN ST           OR
               NOT (XX NOT IN ST) 
          THEN
               FAILED( "WRONG VALUES FOR 'IN ST'" );
          END IF;

          IF   LIT     IN AA ..CC       OR
               VAR NOT IN LIT..ZZ       OR
               CON     IN ZZ ..AA       OR
               NOT (CC IN CC .. YY)     OR
               NOT (BB NOT IN CC .. YY) 
          THEN
               FAILED( "WRONG VALUES FOR 'IN AA..CC'" );
          END IF;

     END;

     RESULT;

END C45202B;
