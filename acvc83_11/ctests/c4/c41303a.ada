-- C41303A.ADA


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
--                 ACC REC      ||  XXXXXXXXX  |
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
--       2 '.ALL'  ACC ACC ARR  ||             |
--                --------------||-------------|--------------------
--                 ACC ACC SCLR ||             |
--      ============================================================


-- RM  1/20/82
-- RM  1/25/82
-- SPS 12/2/82


WITH REPORT;
USE REPORT;
PROCEDURE C41303A IS


BEGIN

     TEST ( "C41303A" , "CHECK THAT THE NOTATION  L.ALL  IS ALLOWED IF"
                    &   "  L  IS THE NAME OF AN ACCESS OBJECT"
                    &   " DESIGNATING A RECORD, AN ARRAY, OR A SCALAR");


     -------------------------------------------------------------------
     --------------------  ACCESS TO RECORD  ---------------------------

     DECLARE

          TYPE  REC  IS

               RECORD
                    A , B , C : INTEGER ;
               END RECORD ;

          REC_CONST    :  REC  :=  ( 7 , 8 , 9 );
          REC_VAR      :  REC  :=    REC_CONST  ;

          TYPE  ACC_REC  IS  ACCESS REC ;

          ACC_REC_VAR  :  ACC_REC  :=  NEW REC'( 17 , 18 , 19 );

     BEGIN

          REC_VAR          :=  ACC_REC_VAR.ALL ;

          IF  REC_VAR /= ( 17 , 18 , 19 )
          THEN
               FAILED( "ACC. RECORD, RIGHT SIDE OF ASSIGN.,WRONG VAL.");
          END IF;


          ACC_REC_VAR.ALL  :=  REC_CONST ;

          IF  ACC_REC_VAR.ALL /= ( 7 , 8 , 9 )
          THEN
               FAILED( "ACC. RECORD, LEFT SIDE OF ASSIGN.,WRONG VAL." );
          END IF;


     END ;

     -------------------------------------------------------------------

     RESULT;


END C41303A;
