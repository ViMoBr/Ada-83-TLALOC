-- C41303E.ADA


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
--                 ACC ACC REC  ||  XXXXXXXXX  |
--                --------------||-------------|--------------------
--       1 '.ALL'  ACC ACC ARR  ||             |
--                --------------||-------------|--------------------
--                 ACC ACC SCLR ||             |
--      ========================||=============|====================
--                 ACC ACC REC  ||             |
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
PROCEDURE C41303E IS


BEGIN

     TEST ( "C41303E" , "CHECK THAT THE NOTATION  L.ALL  IS ALLOWED IF"
                    &   "  L  IS THE NAME OF AN ACCESS OBJECT"
                    &   " DESIGNATING  ANOTHER ACCESS OBJECT" );


     -------------------------------------------------------------------
     ---------------  ACCESS TO ACCESS TO RECORD  ----------------------

     DECLARE

          TYPE  REC  IS

               RECORD
                    A , B , C : INTEGER ;
               END RECORD ;


          TYPE  ACCREC  IS  ACCESS REC ;

          ACCREC_CONST    :  ACCREC  :=  NEW REC'( 7 , 8 , 9 );
          ACCREC_VAR      :  ACCREC  :=    ACCREC_CONST  ;
          ACCREC_CONST2   :  ACCREC  :=  NEW REC'( 17 , 18 , 19 );

          TYPE  ACC_ACCREC  IS  ACCESS ACCREC ;

          ACC_ACCREC_VAR  :  ACC_ACCREC :=  NEW ACCREC'(ACCREC_CONST2);

     BEGIN

          ACCREC_VAR          :=  ACC_ACCREC_VAR.ALL ;

          IF  ACCREC_VAR /= ACCREC_CONST2
          THEN
               FAILED( "ACC2 RECORD, RIGHT SIDE OF ASSIGN.,WRONG VAL.");
          END IF;


          ACC_ACCREC_VAR.ALL  :=  ACCREC_CONST ;

          IF  ACCREC_CONST /= ACC_ACCREC_VAR.ALL 
          THEN
               FAILED( "ACC2 RECORD, LEFT SIDE OF ASSIGN.,WRONG VAL." );
          END IF;


     END ;

     -------------------------------------------------------------------

     RESULT;


END C41303E;
