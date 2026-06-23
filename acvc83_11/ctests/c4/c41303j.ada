-- C41303J.ADA


-- CHECK THAT THE NOTATION  L.ALL  IS ALLOWED IF  L  IS THE NAME OF AN
--     ACCESS OBJECT DESIGNATING A RECORD, AN ARRAY, A SCALAR, OR
--     ANOTHER ACCESS OBJECT.
-- CHECK THAT IF  A  IS AN IDENTIFIER DENOTING AN ACCESS OBJECT WHICH
--     IN TURN DESIGNATES AN ACCESS OBJECT, THE FORM A.ALL.ALL  IS
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
--                 ACC ACC REC  ||             |
--                --------------||-------------|--------------------
--       2 '.ALL'  ACC ACC ARR  ||  XXXXXXXXX  |
--                --------------||-------------|--------------------
--                 ACC ACC SCLR ||             |
--      ============================================================


-- RM  1/20/82
-- RM  1/25/82
-- SPS 12/2/82


WITH REPORT;
USE REPORT;
PROCEDURE C41303J IS


BEGIN

     TEST ( "C41303J" , "CHECK THAT IF  A  IS AN IDENTIFIER DENOTING" &
                        " AN ACCESS OBJECT WHICH IN TURN DESIGNATES"  &
                        " AN ACCESS OBJECT,  THE FORM  A.ALL.ALL  IS" &
                        " ACCEPTED" );


     -------------------------------------------------------------------
     ---------------  ACCESS TO ACCESS TO ARRAY  -----------------------

     DECLARE

          TYPE  ARR     IS  ARRAY(1..2) OF BOOLEAN ;

          ARR_CONST    :  ARR  :=  ( TRUE , FALSE );
          ARR_VAR      :  ARR  :=    ARR_CONST  ;
          ARR_CONST2   :  ARR  :=  ( FALSE , TRUE );

          TYPE  ACCARR  IS  ACCESS ARR ;

          TYPE  ACC_ACCARR  IS  ACCESS ACCARR ;

          ACC_ACCARR_VAR  :  ACC_ACCARR :=  NEW ACCARR'(
                                            NEW ARR'( ARR_CONST2 )
                                                      );

     BEGIN

          ARR_VAR          :=  ACC_ACCARR_VAR.ALL.ALL ;

          IF  ARR_VAR /= ARR_CONST2
          THEN
               FAILED( "ACC2 ARRAY, RIGHT SIDE OF ASSIGN., WRONG VAL.");
          END IF;


          ACC_ACCARR_VAR.ALL.ALL  :=  ARR_CONST ;

          IF  ( TRUE , FALSE ) /= ACC_ACCARR_VAR.ALL.ALL
          THEN
               FAILED( "ACC2 ARRAY, LEFT SIDE OF ASSIGN., WRONG VAL." );
          END IF;


     END ;

     -------------------------------------------------------------------

     RESULT;


END C41303J;
