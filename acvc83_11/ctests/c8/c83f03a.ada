-- C83F03A.ADA


-- CHECK THAT INSIDE A PACKAGE BODY  AN ATTEMPT TO PLACE AND REFERENCE
--    A LABEL IS SUCCESSFUL EVEN IF ITS IDENTIFIER IS DECLARED IN THE
--    ENVIRONMENT SURROUNDING THE PACKAGE BODY.

-- NESTED PACKAGE BODIES ARE TESTED IN  C83F03B , C83F03C , C83F03D


--    RM    03 SEPTEMBER 1980


WITH REPORT;
PROCEDURE  C83F03A  IS

     USE REPORT;

     X1 , X2 : INTEGER RANGE 1..23 := 17 ;

     TYPE  T1  IS  ( A , B , C) ;

     Z : T1 := A ;

     FLOW_INDEX : INTEGER := 0 ;

BEGIN

     TEST( "C83F03A" , "CHECK THAT INSIDE A PACKAGE BODY " &
                       " AN ATTEMPT TO PLACE AND REFERENCE A LABEL" &
                       " IS SUCCESSFUL EVEN IF ITS IDEN" &
                       "TIFIER IS DECLARED IN THE ENVIRONMENT SURROUND"&
                       "ING THE PACKAGE BODY" ) ;


     DECLARE


          Y1 , Y2 : INTEGER := 13 ;


          PROCEDURE  BUMP  IS
          BEGIN
               FLOW_INDEX := FLOW_INDEX + 1 ;
          END BUMP ;


          PACKAGE  P  IS

               AA : BOOLEAN := FALSE ;

          END  P ;


          PACKAGE BODY  P  IS
          BEGIN

               GOTO  X1 ;

               BUMP ;
               BUMP ;

               <<X1>>   BUMP ;  GOTO  X2 ;
               BUMP ;
               <<T1>>   BUMP ;  GOTO  Z ;
               BUMP ;
               <<Y1>>   BUMP ;  GOTO  Y2 ;
               BUMP ;
               <<Y2>>   BUMP ;  GOTO  T1 ;
               BUMP ;
               <<X2>>   BUMP ;  GOTO  Y1 ;
               BUMP ;
               <<Z >>   BUMP ;  GOTO  ENDING ;
               BUMP ;

               << ENDING >>  NULL;

          END P ;


     BEGIN

          IF  FLOW_INDEX /= 6
          THEN  FAILED( "INCORRECT FLOW OF CONTROL" );
          END IF;

     END ;


     RESULT;   --  POSS. ERROR DURING ELABORATION OF  P

END C83F03A;
