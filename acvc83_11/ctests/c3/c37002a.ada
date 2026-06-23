-- C37002A.ADA

-- CHECK THAT INDEX CONSTRAINTS WITH NON-STATIC EXPRESSIONS CAN BE
-- USED TO CONSTRAIN RECORD COMPONENTS HAVING AN ARRAY TYPE.

-- RJW 2/28/86 

WITH REPORT; USE REPORT;

PROCEDURE C37002A IS

BEGIN
     TEST ( "C37002A", "CHECK THAT INDEX CONSTRAINTS WITH " &
                       "NON-STATIC EXPRESSIONS CAN BE USED TO " &
                       "CONSTRAIN RECORD COMPONENTS HAVING AN " &
                       "ARRAY TYPE" );

     DECLARE
          X : INTEGER := IDENT_INT(5);
          SUBTYPE S IS INTEGER RANGE 1 .. X;
          TYPE AR1 IS ARRAY (S) OF INTEGER;

          SUBTYPE T IS INTEGER RANGE X .. 10;
          TYPE AR2 IS ARRAY (T) OF INTEGER;
          TYPE U IS ARRAY (INTEGER RANGE <>) OF INTEGER;
          SUBTYPE V IS INTEGER RANGE 1 .. 10;     

          TYPE R IS 
               RECORD
                    A : STRING (1 .. X);              
                    B : STRING (X .. 10);             
                    C : AR1;                          
                    D : AR2;                          
                    E : STRING (S);
                    F : U(T);
                    G : U(V RANGE 1 ..X);
                    H : STRING (POSITIVE RANGE X .. 10);
                    I : U(AR1'RANGE);
                    J : STRING (AR2'RANGE);
               END RECORD;
          RR : R;
 
     BEGIN
          IF RR.A'LAST /= 5 OR RR.B'FIRST /= 5 OR
             RR.C'LAST /= 5 OR RR.D'FIRST /= 5 OR
             RR.E'LAST /= 5 OR RR.F'FIRST /= 5 OR
             RR.G'LAST /= 5 OR RR.H'FIRST /= 5 OR
             RR.I'LAST /= 5 OR RR.J'FIRST /= 5 THEN 
          
                  FAILED("WRONG VALUE FOR NON-STATIC BOUND");

           END IF;
          
     END;

     RESULT;
END C37002A;
