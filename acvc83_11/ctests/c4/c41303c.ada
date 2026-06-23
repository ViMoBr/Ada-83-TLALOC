-- C41303C.ADA


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
--                 ACC SCLR     ||  XXXXXXXXX  |
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
PROCEDURE C41303C IS


BEGIN

     TEST ( "C41303C" , "CHECK THAT THE NOTATION  L.ALL  IS ALLOWED IF"
                    &   "  L  IS THE NAME OF AN ACCESS OBJECT"
                    &   " DESIGNATING A RECORD, AN ARRAY, OR A SCALAR");


     -------------------------------------------------------------------
     --------------------  ACCESS TO SCALAR  ---------------------------

     DECLARE

          TYPE  NEWINT  IS  NEW INTEGER ;

          NEWINT_CONST    :  NEWINT  :=  813 ;
          NEWINT_VAR      :  NEWINT  :=  NEWINT_CONST  ;

          TYPE  ACC_NEWINT  IS  ACCESS NEWINT ;

          ACC_NEWINT_VAR  :  ACC_NEWINT  :=  NEW NEWINT'( 707 );

     BEGIN

          NEWINT_VAR          :=  ACC_NEWINT_VAR.ALL ;

          IF  NEWINT_VAR /= ( 707 )
          THEN
               FAILED( "ACC. NEWINT, RIGHT SIDE OF ASSIGN.,WRONG VAL.");
          END IF;


          ACC_NEWINT_VAR.ALL  :=  NEWINT_CONST ;

          IF  ACC_NEWINT_VAR.ALL /= 813 
          THEN
               FAILED( "ACC. NEWINT, LEFT SIDE OF ASSIGN.,WRONG VAL." );
          END IF;


     END ;

     -------------------------------------------------------------------

     RESULT;


END C41303C;
