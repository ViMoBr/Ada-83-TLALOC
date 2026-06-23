-- C41303I.ADA


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
--                 ACC ACC REC  ||  XXXXXXXXX  |
--                --------------||-------------|--------------------
--       2 '.ALL'  ACC ACC ARR  ||             |
--                --------------||-------------|--------------------
--                 ACC ACC SCLR ||             |
--      ============================================================


-- RM  1/20/82
-- RM  1/25/82
-- SPS 12/2/82


WITH REPORT;
USE REPORT;
PROCEDURE C41303I IS


BEGIN

     TEST ( "C41303I" , "CHECK THAT IF  A  IS AN IDENTIFIER DENOTING" &
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
          REC_CONST2   :  REC  :=  ( 17 , 18 , 19 );

          TYPE  ACCREC  IS  ACCESS REC ;

          TYPE  ACC_ACCREC  IS  ACCESS ACCREC ;

          ACC_ACCREC_VAR  :  ACC_ACCREC :=  NEW ACCREC'( 
                                            NEW REC'( REC_CONST2 )
                                                      );

     BEGIN

          REC_VAR          :=  ACC_ACCREC_VAR.ALL.ALL ;

          IF  REC_VAR /= REC_CONST2
          THEN
               FAILED( "ACC2 RECORD,RIGHT SIDE OF ASSIGN., WRONG VAL.");
          END IF;


          ACC_ACCREC_VAR.ALL.ALL  :=  REC_CONST ;

          IF  ( 7 , 8 , 9 ) /= ACC_ACCREC_VAR.ALL.ALL 
          THEN
               FAILED( "ACC2 RECORD, LEFT SIDE OF ASSIGN., WRONG VAL.");
          END IF;


     END ;

     -------------------------------------------------------------------

     RESULT;


END C41303I;
