-- B97103D.ADA


-- CHECK THAT A  SELECTIVE_WAIT  STATEMENT CANNOT APPEAR OUTSIDE A
--     TASK BODY.  (PART D: DIR. INSIDE PACKAGE (WITHIN A TASK BODY))


-- RM 4/01/1982


PROCEDURE  B97103D  IS
BEGIN


     -------------------------------------------------------------------


     DECLARE


          TASK  TT  IS
               ENTRY  A ;
          END  TT ;


          TASK BODY  TT  IS

               TASK  INNERTASK  IS
                    ENTRY  I ;
               END  INNERTASK ;

               TASK BODY  INNERTASK  IS
               BEGIN
                    ACCEPT  I ;
               END  INNERTASK ;


               PACKAGE  WITHIN_OUTER_TASK_BODY  IS
                    X :INTEGER ;
               END  WITHIN_OUTER_TASK_BODY ;


               PACKAGE BODY  WITHIN_OUTER_TASK_BODY  IS
               BEGIN

                    SELECT
                         ACCEPT  A ; -- ERROR: SELECTIVE_WAIT OUTSIDE
                                     --                     TASK BODY.
                    END SELECT;
                    
               END  WITHIN_OUTER_TASK_BODY ;


          BEGIN

               ACCEPT  A ;

          END  TT ;

     BEGIN

          NULL ;

     END  ;

     -------------------------------------------------------------------


END  B97103D ;
