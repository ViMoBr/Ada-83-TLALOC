-- C83C01B.ADA


-- CHECK THAT COMPONENT NAMES MAY BE THE SAME IN SEPARATE RECORD TYPE
--    DEFINITIONS, BOTH FOR LOGICALLY NESTED AND NON-NESTED RECORD
--    TYPES.

--    RM    24 JUNE 1980
--    RM    10 SEPT 1980   (GIVING NAMES TO ANONYMOUS RECORD TYPES)
--    JRK   12 NOV  1980


WITH REPORT;
PROCEDURE  C83C01B  IS

     USE REPORT;

     NUMBER : INTEGER RANGE 1..23 := 17 ;

     TYPE  T1AAAA  IS
          RECORD
               A : INTEGER ;
          END RECORD ;

     TYPE  T1AAA  IS
          RECORD
               A : T1AAAA ;
          END RECORD ;

     TYPE  T1AA  IS
          RECORD
               A : T1AAA ;
          END RECORD ;

     TYPE  T1A  IS
          RECORD
               A : T1AA ;
          END RECORD ;

     TYPE  T1  IS
          RECORD
               A : T1A ;
          END RECORD ;


     TYPE  T3AA  IS
          RECORD
               A : INTEGER ;
               B : INTEGER ;
          END RECORD ;

     TYPE  T3AB  IS
          RECORD
               A : INTEGER ;
               B : INTEGER ;
          END RECORD ;

     TYPE  T3A  IS
          RECORD
               A : T3AA ;
               B : T3AB ;
          END RECORD ;

     SUBTYPE  T3B  IS  T3AB ;

     TYPE  T3  IS
          RECORD
               A : T3A ;
               B : T3B ;
          END RECORD ;


     V1 : T1 :=   ( A => ( A => ( A => ( A => ( A => 23 ))))) ;
     V2 : T1AA :=               ( A => ( A => ( A =>  1 )))   ;

     V3 : T3 :=   (   (( 1 , 2 ),( 4 , 5 ))  ,  ( 8 , 9)   )  ;

BEGIN

     TEST( "C83C01B" , "CHECK THAT COMPONENT NAMES MAY BE THE SAME IN" &
                       " SEPARATE RECORD TYPE DEFINITIONS" );

     V1.A.A.A.A.A := NUMBER ;
     V2           := V1.A.A ;
     V3.A.B       := V3.B   ;
     
     IF  V2.A.A.A /= NUMBER  OR
         V2.A /= ( A => ( A => 17 ))  OR
         V3.A.A.A + V3.A.A.B + V3.A.B.A + V3.A.B.B
                             + V3.B.A   + V3.B.B    /= 37
     THEN  FAILED( "INCORRECT FIELD SELECTION" );
     END IF;

     RESULT;

END C83C01B;
