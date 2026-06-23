-- C45123B.ADA

-- CHECK TRUTH TABLES FOR 'AND THEN' AND 'OR ELSE'.

-- ABW 7/8/82
-- JWC 6/28/85   RENAMED FROM C45105A-AB.ADA

WITH REPORT;
PROCEDURE C45123B IS

     USE REPORT;

     CVAR : BOOLEAN := FALSE;

BEGIN

     TEST( "C45123B" , "CHECK TRUTH TABLES FOR 'AND THEN' " &
                       "AND 'OR ELSE'" );

     FIRST :
     FOR  A  IN  BOOLEAN  LOOP

          SECOND :
          FOR  B  IN  BOOLEAN  LOOP

               CVAR  :=  A AND THEN B ;
               IF  A  THEN
                    IF  CVAR /= B  THEN
                         FAILED("TT ERROR: 'AND THEN(T,.)'");
                    END IF;
               ELSIF  CVAR  THEN
                    FAILED("TT ERROR: 'AND THEN(F,.)'") ;
               END IF;

               CVAR  :=  A OR ELSE B ;
               IF  A  THEN
                    IF CVAR /= TRUE  THEN
                         FAILED("TT ERROR: 'OR ELSE(T,.)'");
                    END IF;
               ELSIF  CVAR /= B  THEN
                    FAILED("TT ERROR: 'OR ELSE(F,.)'") ;
               END IF;

          END LOOP SECOND;

     END LOOP FIRST;

     RESULT;

END C45123B;
