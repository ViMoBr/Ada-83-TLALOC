-- A83C01J.ADA


-- CHECK THAT COMPONENT NAMES MAY BE THE SAME AS NAMES OF
--    TYPES.
-- (NAMES OF COMPONENTS IN LOGICALLY NESTED RECORDS ARE TESTED IN
--    C83C01B.ADA .)
-- (NAMES OF TASKS ARE TESTED IN  A83C01T.ADA .)

--    RM    24 JUNE 1980
--    JRK   10 NOV  1980
--    RM    01 JAN  1982


WITH REPORT;
PROCEDURE  A83C01J  IS

     USE REPORT;

BEGIN

     TEST( "A83C01J" , "CHECK THAT COMPONENT NAMES MAY BE THE SAME AS" &
                       " NAMES OF TYPES" ) ;


     -- TEST FOR NAMES OF TYPES AND SUBTYPES


     DECLARE

          TYPE  T1  IS NEW INTEGER;
          SUBTYPE  T2  IS T1 RANGE 0..100 ;

          TYPE  R1A  IS
               RECORD
                    T1 : INTEGER ;
                    T2 : INTEGER ;
               END RECORD;

          TYPE  R1  IS
               RECORD
                    T1 : INTEGER ;
                    T2 : R1A ;
               END RECORD ;

          X  : T1 ;
          Y  : T2 ;

          A1 : R1 := ( 2 , ( 3 , 4 ) ) ;

     BEGIN

          A1.T1 := A1.T2.T1 + A1.T2.T2 ;

     END ;



     RESULT;

END A83C01J;
