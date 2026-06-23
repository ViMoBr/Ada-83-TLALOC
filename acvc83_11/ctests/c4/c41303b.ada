-- C41303B.ADA


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
--       1 '.ALL'  ACC ARR      ||  XXXXXXXXX  |
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
--       2 '.ALL'  ACC ACC ARR  ||             |
--                --------------||-------------|--------------------
--                 ACC ACC SCLR ||             |
--      ============================================================


-- RM  1/20/82
-- RM  1/25/82
-- SPS 12/2/82


WITH REPORT;
USE REPORT;
PROCEDURE C41303B IS


BEGIN

     TEST ( "C41303B" , "CHECK THAT THE NOTATION  L.ALL  IS ALLOWED IF"
                    &   "  L  IS THE NAME OF AN ACCESS OBJECT"
                    &   " DESIGNATING A RECORD, AN ARRAY, OR A SCALAR");


     -------------------------------------------------------------------
     --------------------  ACCESS TO ARRAY  ----------------------------

     DECLARE

          TYPE  ARR  IS  ARRAY(1..2) OF BOOLEAN ;

          ARR_CONST    :  ARR  :=  ( TRUE , FALSE );
          ARR_VAR      :  ARR  :=    ARR_CONST  ;

          TYPE  ACC_ARR  IS  ACCESS ARR ;

          ACC_ARR_VAR  :  ACC_ARR  :=  NEW ARR'( FALSE , TRUE );

     BEGIN

          ARR_VAR          :=  ACC_ARR_VAR.ALL ;

          IF  ARR_VAR /= ( FALSE , TRUE )
          THEN
               FAILED( "ACC. ARRAY, RIGHT SIDE OF ASSIGN., WRONG VAL.");
          END IF;


          ACC_ARR_VAR.ALL  :=  ARR_CONST ;

          IF  ACC_ARR_VAR.ALL /= ( TRUE , FALSE )
          THEN
               FAILED( "ACC. ARRAY, LEFT SIDE OF ASSIGN., WRONG VAL." );
          END IF;


     END ;


     -------------------------------------------------------------------

     RESULT;


END C41303B;
