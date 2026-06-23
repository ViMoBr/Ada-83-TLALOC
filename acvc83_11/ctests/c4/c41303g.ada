-- C41303G.ADA


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
--                 ACC ACC SCLR ||  XXXXXXXXX  |
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
PROCEDURE C41303G IS


BEGIN

     TEST ( "C41303G" , "CHECK THAT THE NOTATION  L.ALL  IS ALLOWED IF"
                    &   "  L  IS THE NAME OF AN ACCESS OBJECT"
                    &   " DESIGNATING  ANOTHER ACCESS OBJECT" );


     -------------------------------------------------------------------
     ---------------  ACCESS TO ACCESS TO SCALAR  ----------------------

     DECLARE

          TYPE  NEWINT  IS  NEW INTEGER ;

          TYPE  ACCNEWINT  IS  ACCESS NEWINT ;

          ACCNEWINT_CONST    :  ACCNEWINT  :=  NEW NEWINT'( 813 );
          ACCNEWINT_VAR      :  ACCNEWINT  :=  ACCNEWINT_CONST  ;
          ACCNEWINT_CONST2   :  ACCNEWINT  :=  NEW NEWINT'( 707 );

          TYPE  ACC_ACCNEWINT  IS  ACCESS ACCNEWINT ;

          ACC_ACCNEWINT_VAR  :  ACC_ACCNEWINT  :=  NEW ACCNEWINT'(
                                                       ACCNEWINT_CONST2
                                                                );

     BEGIN

          ACCNEWINT_VAR          :=  ACC_ACCNEWINT_VAR.ALL ;

          IF  ACCNEWINT_VAR /= ACCNEWINT_CONST2
          THEN
               FAILED( "ACC2 NEWINT, RIGHT SIDE OF ASSIGN.,WRONG VAL.");
          END IF;


          ACC_ACCNEWINT_VAR.ALL  :=  ACCNEWINT_CONST ;

          IF  ACCNEWINT_CONST /= ACC_ACCNEWINT_VAR.ALL
          THEN
               FAILED( "ACC2 NEWINT, LEFT SIDE OF ASSIGN.,WRONG VAL." );
          END IF;


     END ;

     -------------------------------------------------------------------

     RESULT;


END C41303G;
