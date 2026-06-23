-- A72001A.ADA


-- CHECK THAT A PACKAGE SPECIFICATION CAN BE DECLARED WITHIN A PACKAGE
--    SPECIFICATION.


-- RM 04/30/81


WITH REPORT;
PROCEDURE  A72001A  IS

     USE  REPORT ;

BEGIN

     TEST( "A72001A" , "CHECK: PACKAGE SPECIFICATIONS CAN BE NESTED" );

     DECLARE


          PACKAGE  P1  IS
          END  P1 ;


          PACKAGE  P2  IS
               PACKAGE  P3  IS
               END  P3      ;
          END  P2 ;


          PACKAGE  P5  IS

               A : CHARACTER := 'A' ;

               PACKAGE  P6  IS
                    I : INTEGER;
               END  P6 ;

          END  P5 ;


     BEGIN

          NULL ;

     END ;


     RESULT ;


END A72001A;
