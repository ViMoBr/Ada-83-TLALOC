-- C41303F.ADA

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
--       1 '.ALL'  ACC ACC ARR  ||  XXXXXXXXX  |
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
PROCEDURE C41303F IS

BEGIN

     TEST ( "C41303F" , "CHECK THAT THE NOTATION  L.ALL  IS ALLOWED IF"
                    &   "  L  IS THE NAME OF AN ACCESS OBJECT"
                    &   " DESIGNATING  ANOTHER ACCESS OBJECT" );


     -------------------------------------------------------------------
     ---------------  ACCESS TO ACCESS TO ARRAY  -----------------------

     DECLARE

          TYPE  ARR     IS  ARRAY(1..2) OF BOOLEAN ;
          TYPE  ACCARR  IS  ACCESS ARR ;

          ACCARR_CONST    :  ACCARR  :=  NEW ARR'( TRUE , FALSE );
          ACCARR_VAR      :  ACCARR  :=    ACCARR_CONST  ;
          ACCARR_CONST2   :  ACCARR  :=  NEW ARR'( FALSE , TRUE );

          TYPE  ACC_ACCARR  IS  ACCESS ACCARR ;

          ACC_ACCARR_VAR  :  ACC_ACCARR :=  NEW ACCARR'(ACCARR_CONST2);

     BEGIN

          ACCARR_VAR          :=  ACC_ACCARR_VAR.ALL ;

          IF  ACCARR_VAR /= ACCARR_CONST2
          THEN
               FAILED( "ACC2 ARRAY, RIGHT SIDE OF ASSIGN., WRONG VAL.");
          END IF;


          ACC_ACCARR_VAR.ALL  :=  ACCARR_CONST ;

          IF  ACCARR_CONST /= ACC_ACCARR_VAR.ALL
          THEN
               FAILED( "ACC2 ARRAY, LEFT SIDE OF ASSIGN., WRONG VAL." );
          END IF;


     END ;

     -------------------------------------------------------------------

     RESULT;


END C41303F;
