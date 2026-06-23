-- C41306A.ADA


-- CHECK THAT IF  F  IS A FUNCTION RETURNING A TASK OF A TYPE HAVING
--     AN ENTRY  E ,  AN ENTRY CALL OF THE FORM
--
--                           F.E
--
--     IS PERMITTED.


-- RM  2/2/82
-- ABW 7/16/82

WITH REPORT;
USE REPORT;
PROCEDURE C41306A IS


BEGIN

     TEST ( "C41306A" , "CHECK THAT IF  F  IS A FUNCTION RETURNING" &
                        " A TASK OF A TYPE HAVING AN ENTRY  E ,  AN" &
                        " ENTRY CALL OF THE FORM  F.E  IS PERMITTED");


     -------------------------------------------------------------------

     DECLARE

          X  : INTEGER  :=  0 ;

          TASK TYPE  T  IS
               ENTRY  E ;
          END  T ;

          T1 : T ;

          TASK BODY  T  IS
          BEGIN
               ACCEPT  E  DO
                    X := IDENT_INT(17) ;
               END  E ;
               ACCEPT  E  DO
                    X := IDENT_INT(16) ;
               END  E ;
          END  T ;

          FUNCTION  F1  RETURN  T  IS
          BEGIN
               RETURN  T1 ;
          END  F1 ;

          FUNCTION F2 (A,B : BOOLEAN) RETURN T IS
          BEGIN
               IF A AND B THEN NULL; END IF;
               RETURN T1;
          END F2;

     BEGIN

          F1.E ;                                  -- X SET TO 17.

          IF  X /= 17 THEN
               FAILED("WRONG VALUE FOR GLOBAL VARIABLE - 1");
          END IF;

          X := 0;
          F2(TRUE,TRUE).E;                        -- X SET TO 16.
                            -- X TO BE SET TO 16.

          IF X /= 16 THEN
               FAILED("WRONG VALUE FOR GLOBAL VARIABLE - 2");
          END IF;

     END ;

     -------------------------------------------------------------------

     RESULT;


END C41306A;
