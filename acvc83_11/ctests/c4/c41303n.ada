-- C41303N.ADA


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
--       1 '.ALL'  ACC ARR      ||             |     XXXXXXXXX
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


-- RM  1/22/82
-- RM  1/26/82
-- SPS 12/2/82


WITH REPORT;
USE REPORT;
PROCEDURE C41303N IS


BEGIN

     TEST ( "C41303N" , "CHECK THAT  L.ALL  , WHERE  L  IS THE NAME OF"
                      & " AN ACCESS OBJECT DESIGNATING A RECORD, AN"
                      & " ARRAY, OR A SCALAR,  IS ALLOWED AS"
                      & " ACTUAL PARAMETER OF ANY MODE" );


     -------------------------------------------------------------------
     --------------------  ACCESS TO ARRAY  ----------------------------

     DECLARE

          TYPE  ARR  IS  ARRAY(1..2) OF BOOLEAN ;

          ARR_CONST    :  ARR  :=  ( TRUE , FALSE );
          ARR_VAR      :  ARR  :=    ARR_CONST  ;
          ARR_VAR0     :  ARR  :=    ARR_CONST  ;

          TYPE  ACC_ARR  IS  ACCESS ARR ;

          ACC_ARR_VAR  :  ACC_ARR  :=  NEW ARR'( FALSE , TRUE );
          ACC_ARR_VAR0 :  ACC_ARR  :=  NEW ARR'( FALSE , TRUE );


          PROCEDURE  R_ASSIGN( R_IN    : IN      ARR ;
                               R_INOUT : IN OUT  ARR )  IS
          BEGIN
               ARR_VAR   :=  R_IN    ;
               ARR_VAR0  :=  R_INOUT ;
          END ;


          PROCEDURE  L_ASSIGN( L_OUT   :    OUT  ARR ;
                               L_INOUT : IN OUT  ARR )  IS
          BEGIN
               L_OUT   :=  ARR_CONST ;
               L_INOUT :=  ARR_CONST ;
          END ;

     BEGIN


          R_ASSIGN( ACC_ARR_VAR.ALL , ACC_ARR_VAR0.ALL );

          IF  ARR_VAR /= ( FALSE , TRUE )                   
          THEN
               FAILED( "ACC. ARRAY, RIGHT SIDE (1), WRONG VAL." );
          END IF;

          IF  ARR_VAR0 /= ( FALSE , TRUE )
          THEN
               FAILED( "ACC. ARRAY, RIGHT SIDE (2), WRONG VAL." );
          END IF;


          L_ASSIGN( ACC_ARR_VAR.ALL , ACC_ARR_VAR0.ALL );

          IF  ACC_ARR_VAR.ALL /= ( TRUE , FALSE )
          THEN
               FAILED( "ACC. ARRAY, LEFT SIDE (1), WRONG VAL." );
          END IF;


          IF  ACC_ARR_VAR0.ALL /= ( TRUE , FALSE )
          THEN
               FAILED( "ACC. ARRAY, LEFT SIDE (2), WRONG VAL." );
          END IF;


     END ;

     -------------------------------------------------------------------

     RESULT;


END C41303N;
