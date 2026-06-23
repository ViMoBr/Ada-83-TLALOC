-- C41303K.ADA


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
--                 ACC ACC REC  ||             |
--                --------------||-------------|--------------------
--       2 '.ALL'  ACC ACC ARR  ||             |
--                --------------||-------------|--------------------
--                 ACC ACC SCLR ||  XXXXXXXXX  |
--      ============================================================


-- RM  1/20/82
-- RM  1/25/82
-- SPS 12/2/82


WITH REPORT;
USE REPORT;
PROCEDURE C41303K IS


BEGIN

     TEST ( "C41303K" , "CHECK THAT IF  A  IS AN IDENTIFIER DENOTING" &
                        " AN ACCESS OBJECT WHICH IN TURN DESIGNATES"  &
                        " AN ACCESS OBJECT,  THE FORM  A.ALL.ALL  IS" &
                        " ACCEPTED" );


     -------------------------------------------------------------------
     ---------------  ACCESS TO ACCESS TO SCALAR  ----------------------

     DECLARE

          TYPE  NEWINT  IS  NEW INTEGER ;

          NEWINT_CONST    :  NEWINT  :=  ( 813 );
          NEWINT_VAR      :  NEWINT  :=  NEWINT_CONST  ;
          NEWINT_CONST2   :  NEWINT  :=  ( 707 );

          TYPE  ACCNEWINT  IS  ACCESS NEWINT ;

          TYPE  ACC_ACCNEWINT  IS  ACCESS ACCNEWINT ;

          ACC_ACCNEWINT_VAR  :  ACC_ACCNEWINT  :=  NEW ACCNEWINT'(
                                                   NEW NEWINT' ( 
                                                   NEWINT_CONST2
                                                              )
                                                                );

     BEGIN

          NEWINT_VAR          :=  ACC_ACCNEWINT_VAR.ALL.ALL ;

          IF  NEWINT_VAR /= NEWINT_CONST2
          THEN
               FAILED( "ACC2 NEWINT,RIGHT SIDE OF ASSIGN., WRONG VAL.");
          END IF;


          ACC_ACCNEWINT_VAR.ALL.ALL  :=  NEWINT_CONST ;

          IF  NEWINT_CONST /= ACC_ACCNEWINT_VAR.ALL.ALL
          THEN
               FAILED( "ACC2 NEWINT,LEFT SIDE OF ASSIGN., WRONG VAL." );
          END IF;


     END ;

     -------------------------------------------------------------------

     RESULT;


END C41303K;
