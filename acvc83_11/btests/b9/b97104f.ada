-- B97104F.ADA


-- CHECK THAT  TERMINATE  CANNOT BE USED OUTSIDE A  SELECTIVE_WAIT .
--     (PART F: DIR. INSIDE PACKAGE (WITHIN A TASK BODY))


-- RM 4/22/1982


PROCEDURE  B97104F  IS
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

                    TERMINATE; -- ERROR:  TERMINATE  OUTSIDE  SELECTIVE_
                               --                                  WAIT.
                    
               END  WITHIN_OUTER_TASK_BODY ;


          BEGIN

               ACCEPT  A ;

          END  TT ;

     BEGIN

          NULL ;

     END  ;

     -------------------------------------------------------------------


END  B97104F ;
