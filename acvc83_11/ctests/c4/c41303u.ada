-- C41303U.ADA


-- CHECK THAT THE NOTATION  L.ALL  IS ALLOWED IF  L  IS THE NAME OF AN
--     ACCESS OBJECT DESIGNATING A RECORD, AN ARRAY, A SCALAR, OR
--     ANOTHER ACCESS OBJECT.
-- CHECK THAT IF  A  IS AN IDENTIFIER DENOTING AN ACCESS OBJECT WHICH
--     IN TURN DESIGNATES AN ACCESS OBJECT, THE FORM  A.ALL.ALL  IS
--     ACCEPTED.


-- THIS OBJECTIVE IS COVERED IN SEVERAL TESTS. IN THE FOLLOWING DIAGRAM,
--     THE PORTION COVERED BY THE CURRENT TEST IS MARKED BY 'X' .


--                              ||   ASSIGNMT  |  PROC. PARAMETERS
--                              ||  ():=  :=() | IN   OUT    IN OUT
--      ========================||=============|====================
--                 ACC REC      ||             |
--                --------------||-------------|--------------------
--       1 '.ALL'  ACC ARR      ||             |
--                --------------||-------------|--------------------
--                 ACC SCLR     ||             |
--      ========================||=============|====================
--                 ACC ACC REC  ||             |
--                --------------||-------------|--------------------
--       1 '.ALL'  ACC ACC ARR  ||             |
--                --------------||-------------|--------------------
--                 ACC ACC SCLR ||             |
--      ========================||=============|====================
--                 ACC ACC REC  ||             |     XXXXXXXXX
--                --------------||-------------|--------------------
--       2 '.ALL'  ACC ACC ARR  ||             |
--                --------------||-------------|--------------------
--                 ACC ACC SCLR ||             |
--      ============================================================


-- RM  1/29/82
-- SPS 12/2/82


WITH REPORT;
USE REPORT;
PROCEDURE C41303U IS


BEGIN

     TEST ( "C41303U" , "CHECK THAT IF  A  IS AN IDENTIFIER DENOTING" &
                        " AN ACCESS OBJECT WHICH IN TURN DESIGNATES"  &
                        " AN ACCESS OBJECT,  THE FORM  A.ALL.ALL  IS" &
                        " ACCEPTED" );


     -------------------------------------------------------------------
     ---------------  ACCESS TO ACCESS TO RECORD  ----------------------

     DECLARE

             TYPE  REC  IS

               RECORD
                    A , B , C : INTEGER ;
               END RECORD ;


          REC_CONST    :  REC  :=  ( 7 , 8 , 9 );
          REC_VAR      :  REC  :=    REC_CONST  ;
          REC_VAR0     :  REC  :=    REC_CONST  ;
          REC_CONST2   :  REC  :=  ( 17 , 18 , 19 );

          TYPE  ACCREC  IS  ACCESS REC ;

          TYPE  ACC_ACCREC  IS  ACCESS ACCREC ;

          ACC_ACCREC_VAR  :  ACC_ACCREC :=  NEW ACCREC'( 
                                            NEW REC'( REC_CONST2 )
                                                      );

          ACC_ACCREC_VAR0 :  ACC_ACCREC :=  NEW ACCREC'( 
                                            NEW REC'( REC_CONST2 )
                                                      );


          PROCEDURE  R_ASSIGN( R_IN    : IN      REC ;
                               R_INOUT : IN OUT  REC )  IS
          BEGIN
               REC_VAR   :=  R_IN    ;
               REC_VAR0  :=  R_INOUT ;
          END ;


          PROCEDURE  L_ASSIGN( L_OUT   :    OUT  REC ;
                               L_INOUT : IN OUT  REC )  IS
          BEGIN
               L_OUT   :=  REC_CONST ;
               L_INOUT :=  REC_CONST ;
          END ;


     BEGIN

          R_ASSIGN( ACC_ACCREC_VAR.ALL.ALL , ACC_ACCREC_VAR0.ALL.ALL );

          IF  REC_VAR /= REC_CONST2
          THEN
               FAILED( "ACC2 RECORD, RIGHT SIDE (1), WRONG VAL." );
          END IF;

          IF  REC_VAR0 /= REC_CONST2
          THEN
               FAILED( "ACC2 RECORD, RIGHT SIDE (2), WRONG VAL." );
          END IF;


          L_ASSIGN( ACC_ACCREC_VAR.ALL.ALL , ACC_ACCREC_VAR0.ALL.ALL );

          IF  ( 7 , 8 , 9 ) /= ACC_ACCREC_VAR.ALL.ALL 
          THEN
               FAILED( "ACC2 RECORD, LEFT SIDE (1), WRONG VAL." );
          END IF;

          IF  ( 7 , 8 , 9 ) /= ACC_ACCREC_VAR0.ALL.ALL 
          THEN
               FAILED( "ACC2 RECORD, LEFT SIDE (2), WRONG VAL." );
          END IF;


     END ;

     -------------------------------------------------------------------

     RESULT;


END C41303U;
