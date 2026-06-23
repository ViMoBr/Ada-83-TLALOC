-- B97104G.ADA


-- CHECK THAT  TERMINATE  CANNOT BE USED OUTSIDE A  SELECTIVE_WAIT .
--     (PART G: INSIDE TASK SPEC)


-- RM 4/22/1982


PROCEDURE  B97104G  IS
BEGIN


     -------------------------------------------------------------------


     DECLARE
  

          TASK TYPE  TT2  IS

               ENTRY  A ;
               ENTRY  B ;

               TERMINATE; -- ERROR:  TERMINATE  OUTSIDE  SELECTIVE_
                          --                                  WAIT.

          END  TT2 ;


          TASK BODY  TT2  IS
          BEGIN
               NULL ;
          END  TT2 ;


     BEGIN


          NULL ;


     END  ;

     -------------------------------------------------------------------


END  B97104G ;
