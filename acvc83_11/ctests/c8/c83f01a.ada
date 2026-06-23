-- C83F01A.ADA


-- CHECK THAT INSIDE A PACKAGE BODY,  AN ATTEMPT TO REFERENCE AN IDENTI-
--    FIER DECLARED IN THE CORRESPONDING PACKAGE SPECIFICATION
--    IS SUCCESSFUL, EVEN IF THE SAME IDENTIFIER IS DECLARED IN THE
--    ENVIRONMENT SURROUNDING THE PACKAGE BODY.

-- NESTED PACKAGE BODIES ARE TESTED IN  C83F01B , C83F01C , C83F01D


--    RM    05 AUGUST 1980
--    JRK   13 NOV    1980


WITH REPORT;
PROCEDURE  C83F01A  IS

     USE REPORT;

     X1 , X2 : INTEGER RANGE 1..23 := 17 ;

     TYPE  T1  IS  ( A , B , C) ;

     Z : T1 := A ;


BEGIN

     TEST( "C83F01A" , "CHECK THAT INSIDE A PACKAGE BODY, " &
                       "AN ATTEMPT TO REFERENCE AN IDENTIFIER " &
                       "DECLARED IN THE CORRESPONDING PACKAGE SPECI" &
                       "FICATION IS SUCCESSFUL EVEN IF THE SAME IDEN" &
                       "TIFIER IS DECLARED IN THE ENVIRONMENT SURROUND"&
                       "ING THE PACKAGE BODY" ) ;

     COMMENT( "NESTED PACKAGE BODIES ARE TESTED IN  C83F01B , -C , -D");


     DECLARE


          PACKAGE  P  IS

               X1 : BOOLEAN := FALSE ;
               X2 : INTEGER RANGE 1..23 := 11 ;
               Y1 : BOOLEAN := TRUE ;
               Y2 : INTEGER := 5 ;
               T1 : INTEGER := 6 ;
               Z  : INTEGER := 7 ;

          END  P ;


          Y1 , Y2 : INTEGER := 13 ;


          PACKAGE BODY  P  IS
          BEGIN

               X1 := X1 OR Y1 ;
               Z  :=  Z + T1 ;
               Y2 := X2 * Y2 ;

               -- INCORRECT INTERPRETATIONS IN THE FIRST TWO
               --    ASSIGNMENTS  MANIFEST THEMSELVES AT
               --    COMPILE TIME AS TYPE ERRORS.

          END P ;


     BEGIN

          IF  X1 /= 17  OR
              Z  /= A   OR
              Y2 /= 13   OR
              NOT P.X1    OR
              P.Z  /= 13  OR
              P.Y2 /= 55
          THEN  FAILED( "INCORRECT ACCESSING" );
          END IF;

     END ;


     RESULT;   --  POSS. ERROR DURING ELABORATION OF  P

END C83F01A;
