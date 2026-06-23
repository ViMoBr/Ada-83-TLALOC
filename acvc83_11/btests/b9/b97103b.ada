-- B97103B.ADA


-- CHECK THAT A  SELECTIVE_WAIT  STATEMENT CANNOT APPEAR OUTSIDE A
--     TASK BODY.  (PART B: DIR. INSIDE PROCEDURE (WITHIN A TASK BODY))


-- RM 3/23/1982


PROCEDURE  B97103B  IS
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

               PROCEDURE  WITHIN_OUTER_TASK_BODY  IS
               BEGIN

                    SELECT
                         ACCEPT  A ; -- ERROR: SELECTIVE_WAIT OUTSIDE
                                     --                   TASK BODY.
                    END SELECT;
                    
               END  WITHIN_OUTER_TASK_BODY ;

          BEGIN

               ACCEPT  A ;

          END  TT ;

     BEGIN

          NULL ;

     END  ;

     -------------------------------------------------------------------


END  B97103B ;
