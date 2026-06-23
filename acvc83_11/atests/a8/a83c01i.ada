-- A83C01I.ADA


-- CHECK THAT COMPONENT NAMES MAY BE THE SAME AS NAMES OF
--    LOOP PARAMETERS.

--    RM    24 JUNE 1980
--    JRK   10 NOV  1980
--    RM    01 JAN  1982


WITH REPORT;
PROCEDURE  A83C01I  IS

     USE REPORT;

BEGIN

     TEST( "A83C01I" , "CHECK THAT COMPONENT NAMES MAY BE THE SAME AS" &
                       " NAMES OF LOOP PARAMETERS" ) ;



     -- TEST FOR LOOP PARAMETERS


     DECLARE

          TYPE  R1A  IS
               RECORD
                    LOOP3 : INTEGER ;
               END RECORD ;

          TYPE  R1  IS
               RECORD
                    LOOP1 : INTEGER ;
                    LOOP2 : R1A ;
               END RECORD ;

          A1 : R1 := ( 3 , ( LOOP3 => 7 ) );

     BEGIN

          FOR  LOOP1  IN  0..1  LOOP

               FOR  LOOP2  IN  0..2  LOOP

                    FOR  LOOP3  IN  0..3  LOOP

                         A1.LOOP1 := A1.LOOP2.LOOP3 ;

                         DECLARE

                              TYPE  R1A  IS
                                   RECORD
                                        LOOP3 : INTEGER ;
                                        LOOP4 : INTEGER ;
                                   END RECORD ;

                              TYPE  R1  IS
                                   RECORD
                                        LOOP1 : INTEGER ;
                                        LOOP2 : R1A ;
                                   END RECORD ;

                              A1 : R1 := ( 3 , ( 6 , 7 ) );

                         BEGIN

                              FOR  LOOP4  IN  0..4  LOOP

                                   A1.LOOP1 := A1.LOOP2.LOOP3 +
                                               A1.LOOP2.LOOP4 ;

                              END LOOP ;

                         END ;

                    END LOOP ;

               END LOOP ;

          END LOOP ;

     END ;



     RESULT;

END A83C01I;
