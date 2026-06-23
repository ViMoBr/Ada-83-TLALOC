-- C41303S.ADA


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
--                 ACC ACC SCLR ||             |     XXXXXXXXX
--      ========================||=============|====================
--                 ACC ACC REC  ||             |
--                --------------||-------------|--------------------
--       2 '.ALL'  ACC ACC ARR  ||             |
--                --------------||-------------|--------------------
--                 ACC ACC SCLR ||             |
--      ============================================================


-- RM  1/28/82
-- SPS 12/2/82


WITH REPORT;
USE REPORT;
PROCEDURE C41303S IS


BEGIN

     TEST ( "C41303S" , "CHECK THAT THE NOTATION  L.ALL  IS ALLOWED IF"
                    &   "  L  IS THE NAME OF AN ACCESS OBJECT"
                    &   " DESIGNATING  ANOTHER ACCESS OBJECT" );


     -------------------------------------------------------------------
     ---------------  ACCESS TO ACCESS TO SCALAR  ----------------------

     DECLARE

          TYPE  NEWINT  IS  NEW INTEGER ;

          TYPE  ACCNEWINT  IS  ACCESS NEWINT ;

          ACCNEWINT_CONST    :  ACCNEWINT  :=  NEW NEWINT'( 813 );
          ACCNEWINT_VAR      :  ACCNEWINT  :=  ACCNEWINT_CONST  ;
          ACCNEWINT_VAR0     :  ACCNEWINT  :=  ACCNEWINT_CONST  ;
          ACCNEWINT_CONST2   :  ACCNEWINT  :=  NEW NEWINT'( 707 );

          TYPE  ACC_ACCNEWINT  IS  ACCESS ACCNEWINT ;

          ACC_ACCNEWINT_VAR  :  ACC_ACCNEWINT  :=  NEW ACCNEWINT'(
                                                       ACCNEWINT_CONST2
                                                                );

          ACC_ACCNEWINT_VAR0 :  ACC_ACCNEWINT  :=  NEW ACCNEWINT'(
                                                       ACCNEWINT_CONST2
                                                                );

          PROCEDURE  R_ASSIGN( R_IN    : IN      ACCNEWINT ;
                               R_INOUT : IN OUT  ACCNEWINT )  IS
          BEGIN
               ACCNEWINT_VAR   :=  R_IN    ;
               ACCNEWINT_VAR0  :=  R_INOUT ;
          END ;


          PROCEDURE  L_ASSIGN( L_OUT   :    OUT  ACCNEWINT ;
                               L_INOUT : IN OUT  ACCNEWINT )  IS
          BEGIN
               L_OUT   :=  ACCNEWINT_CONST ;
               L_INOUT :=  ACCNEWINT_CONST ;
          END ;


     BEGIN

          R_ASSIGN( ACC_ACCNEWINT_VAR.ALL , ACC_ACCNEWINT_VAR0.ALL  );

          IF  ACCNEWINT_VAR /= ACCNEWINT_CONST2
          THEN
               FAILED( "ACC. NEWINT, RIGHT SIDE (1), WRONG VAL." );
          END IF;

          IF  ACCNEWINT_VAR0 /= ACCNEWINT_CONST2
          THEN
               FAILED( "ACC. NEWINT, RIGHT SIDE (2), WRONG VAL." );
          END IF;


          L_ASSIGN( ACC_ACCNEWINT_VAR.ALL , ACC_ACCNEWINT_VAR0.ALL  );

          IF  ACCNEWINT_CONST /= ACC_ACCNEWINT_VAR.ALL
          THEN
               FAILED( "ACC. NEWINT, LEFT SIDE (1), WRONG VAL." );
          END IF;

          IF  ACCNEWINT_CONST /= ACC_ACCNEWINT_VAR0.ALL
          THEN
               FAILED( "ACC. NEWINT, LEFT SIDE (2), WRONG VAL." );
          END IF;


     END ;

     -------------------------------------------------------------------

     RESULT;


END C41303S;
