-- A83C01H.ADA


-- CHECK THAT COMPONENT NAMES MAY BE THE SAME AS NAMES OF
--    LABELS.

--    RM    24 JUNE 1980
--    JRK   10 NOV  1980
--    RM    01 JAN  1982


WITH REPORT;
PROCEDURE  A83C01H  IS

     USE REPORT;

BEGIN

     TEST( "A83C01H" , "CHECK THAT COMPONENT NAMES MAY BE THE SAME AS" &
                       " NAMES OF LABELS" ) ;


     -- TEST FOR LABELS

     DECLARE

          TYPE  R1A  IS
               RECORD
                    LAB3 : INTEGER ;
               END RECORD ;

          TYPE  R1  IS
               RECORD
                    LAB1 : INTEGER ;
                    LAB2 : R1A ;
               END RECORD ;

          A1 : R1 := ( 1 , ( LAB3 => 5 ) );

     BEGIN

          << LAB1 >>
          << LAB2 >>
          << LAB3 >>

          A1.LAB1 := A1.LAB2.LAB3 ;

          DECLARE

               TYPE  R1A  IS
                    RECORD
                         LAB3 : INTEGER ;
                         LAB4 : INTEGER ;
                    END RECORD ;

               TYPE  R1  IS
                    RECORD
                         LAB1 : INTEGER ;
                         LAB2 : R1A ;
                    END RECORD ;

               A1 : R1 := ( 3 , ( 6 , 7 ) );

          BEGIN

               << LAB4 >>

               A1.LAB1 := A1.LAB2.LAB3 + A1.LAB2.LAB4 ;

          END ;

     END ;



     RESULT;

END A83C01H;
