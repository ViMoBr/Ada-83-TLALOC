-- A83C01D.ADA


-- CHECK THAT COMPONENT NAMES MAY BE THE SAME AS NAMES OF
--    SUBPROGRAMS AND FORMAL PARAMETERS.

--    RM    24 JUNE 1980
--    JRK   10 NOV  1980
--    RM    01 JAN  1982


WITH REPORT;
PROCEDURE  A83C01D  IS

     USE REPORT;

BEGIN

     TEST( "A83C01D" , "CHECK THAT COMPONENT NAMES MAY BE THE SAME AS" &
                       " NAMES OF FORMAL PARAMETERS AND SUBPROGRAMS" ) ;



     -- TEST FOR NAMES OF SUBPROGRAMS AND OF FORMAL PARAMETERS
     --    (THE RECORD IS OUTSIDE THE SUBPROGRAM)

     DECLARE

          PROCEDURE  P1 ( ARG1,ARG2:INTEGER ) ;

          TYPE  R1A  IS
               RECORD
                    ARG1 , ARG2 : BOOLEAN ;
                    P1 , F1     : INTEGER ;
               END RECORD ;

          TYPE  R1  IS
               RECORD
                    P1 , P2 : CHARACTER ;
                    ARG1 , ARG2 , ARG3 : INTEGER ;
                    F1 : R1A ;
               END RECORD ;

          A : R1
            := ( 'A' , 'B' , 0 , 1 , 2 , ( TRUE,FALSE,3,4 ) ) ;

          PROCEDURE  P1 ( ARG1,ARG2:INTEGER )  IS
          BEGIN
               NULL ;
          END P1 ;

          PROCEDURE  P2 ( ARG1,ARG2:CHARACTER; ARG3:INTEGER ) IS
          BEGIN
               NULL ;
          END P2 ;

          FUNCTION  F1 ( ARG1,ARG2:BOOLEAN ) RETURN INTEGER IS
          BEGIN
               RETURN  17 ;
          END F1 ;

     BEGIN

          P2( A.P1 , A.P2 , A.F1.P1+A.F1.F1 );
          A.F1.F1 := F1 ( A.F1.ARG1 , A.F1.ARG2 );

     END ;


     RESULT;

END A83C01D;
