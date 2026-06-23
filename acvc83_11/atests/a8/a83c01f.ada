-- A83C01F.ADA


-- CHECK THAT COMPONENT NAMES MAY BE THE SAME AS NAMES OF
--    PACKAGES (AND OF INCLUDED SUBPROGRAMS, ARGUMENTS).

--    RM    24 JUNE 1980
--    JRK   10 NOV  1980
--    RM    01 JAN  1982


WITH REPORT;
PROCEDURE  A83C01F  IS

     USE REPORT;

BEGIN

     TEST( "A83C01F" , "CHECK THAT COMPONENT NAMES MAY BE THE SAME AS" &
                       " NAMES OF PACKAGES" ) ;


     -- TEST FOR NAMES OF PACKAGES (AND OF INCLUDED SUBPROG.S, ARG.S)
     --    (THE RECORD IS OUTSIDE THE PACKAGE)


     DECLARE

          PACKAGE  PACK1  IS

               PROCEDURE  P1 ( ARG1,ARG2:INTEGER );
               PROCEDURE  P2 ( ARG1,ARG2:CHARACTER; ARG3:INTEGER );
               FUNCTION   F1 ( ARG1,ARG2:BOOLEAN ) RETURN INTEGER ;

          END PACK1 ;

          PACKAGE  PACK2  IS

               PROCEDURE  P1 ( ARG1,ARG2:INTEGER );
               PROCEDURE  P2 ( ARG1,ARG2:CHARACTER; ARG3:INTEGER );
               FUNCTION   F1 ( ARG1,ARG2:BOOLEAN ) RETURN INTEGER ;

          END PACK2 ;

          TYPE  R1A  IS
               RECORD
                    ARG1  , ARG2  : BOOLEAN ;
                    PACK1 , PACK2 : INTEGER ;
               END RECORD ;

          TYPE  R1  IS
               RECORD
                    P1 , PACK1 : CHARACTER ;
                    ARG1 , ARG2 , ARG3 : INTEGER ;
                    PACK2 : R1A ;
               END RECORD ;

          P1 : R1
             := ( 'A' , 'B' , 0 , 1 , 2 , ( TRUE,FALSE,3,4 ) ) ;

          PACKAGE BODY  PACK1  IS

               PROCEDURE  P1 ( ARG1,ARG2:INTEGER )  IS
               BEGIN
                    NULL;
               END ;

               PROCEDURE  P2 ( ARG1,ARG2:CHARACTER; ARG3:INTEGER )  IS
               BEGIN
                    NULL;
               END ;

               FUNCTION   F1 ( ARG1,ARG2:BOOLEAN ) RETURN INTEGER  IS
               BEGIN
                    RETURN  17 ;
               END F1 ;

          END PACK1 ;

          PACKAGE BODY  PACK2  IS

               PROCEDURE  P1 ( ARG1,ARG2:INTEGER )  IS
               BEGIN
                    NULL;
               END ;

               PROCEDURE  P2 ( ARG1,ARG2:CHARACTER; ARG3:INTEGER )  IS
               BEGIN
                    NULL;
               END ;

               FUNCTION   F1 ( ARG1,ARG2:BOOLEAN ) RETURN INTEGER  IS
               BEGIN
                    RETURN  17 ;
               END F1 ;

          END PACK2 ;

     BEGIN

          PACK1.P2( P1.P1 , P1.PACK1 , P1.PACK2.PACK1+P1.PACK2.PACK2 );
          P1.PACK2.PACK1 := PACK1.F1 ( P1.PACK2.ARG1 , P1.PACK2.ARG2 );

     END ;


     RESULT;

END A83C01F;
