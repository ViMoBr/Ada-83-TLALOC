-- C45123A.ADA


-- CHECK THE TRUTH TABLES FOR  'AND THEN'  AND  'OR ELSE' .
-- THIS TEST USES THE BOOLEAN LITERALS.

--    RM    1 OCTOBER 1980
-- JWC 9/30/85  RENAMED FROM C45106A.ADA


WITH  REPORT ;
PROCEDURE  C45123A  IS

     USE REPORT;

BEGIN

     TEST( "C45123A" , "CHECK THE TRUTH TABLES FOR  'AND THEN'  AND " &
                       " 'OR ELSE' " ) ;

     FOR  A  IN  BOOLEAN  LOOP
          FOR  B  IN  BOOLEAN  LOOP

               IF  ( A AND THEN B ) /= ( A AND B )
               THEN  FAILED( "TT ERROR: 'AND THEN'" );
               END IF;

               IF  ( A OR ELSE B ) /= ( A OR B )
               THEN  FAILED( "TT ERROR: 'OR ELSE'" );
               END IF;

          END LOOP;
     END LOOP;

     IF  FALSE AND THEN FALSE  THEN FAILED("F AND THEN F = T"); END IF;
     IF  FALSE AND THEN TRUE   THEN FAILED("F AND THEN T = T"); END IF;
     IF  TRUE  AND THEN FALSE  THEN FAILED("T AND THEN F = T"); END IF;
     IF  TRUE  AND THEN TRUE   THEN NULL;
     ELSE                           FAILED("T AND THEN T = F"); END IF;

     IF  FALSE OR ELSE  FALSE  THEN FAILED("F OR ELSE F  = T"); END IF;
     IF  FALSE OR ELSE  TRUE   THEN NULL;
     ELSE                           FAILED("F OR ELSE T  = F"); END IF;
     IF  TRUE  OR ELSE  FALSE  THEN NULL;
     ELSE                           FAILED("T OR ELSE F  = F"); END IF;
     IF  TRUE  OR ELSE  TRUE   THEN NULL;
     ELSE                           FAILED("T OR ELSE T  = F"); END IF;

     RESULT;

END C45123A;
