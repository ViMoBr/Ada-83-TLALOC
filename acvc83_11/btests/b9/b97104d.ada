-- B97104D.ADA


-- CHECK THAT  TERMINATE  CANNOT BE USED OUTSIDE A  SELECTIVE_WAIT .
--     (PART D: DIR. INSIDE TASK BODY WITHIN A TASK BODY)


-- RM 4/22/1982


PROCEDURE  B97104D  IS
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
                    TERMINATE; -- ERROR:  TERMINATE  OUTSIDE  SELECTIVE_
                               --                                  WAIT.
               END  INNERTASK ;


          BEGIN

               ACCEPT  A ;

          END  TT ;

     BEGIN

          NULL ;

     END  ;

     -------------------------------------------------------------------


END  B97104D ;
