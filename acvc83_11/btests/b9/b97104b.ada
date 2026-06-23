-- B97104B.ADA


-- CHECK THAT  TERMINATE  CANNOT BE USED OUTSIDE A  SELECTIVE_WAIT .
--     (PART B:  INSIDE TASK BODY (WITHOUT  SELECTIVE_WAIT))


-- RM 4/22/1982


PROCEDURE  B97104B  IS
BEGIN


     -------------------------------------------------------------------


     DECLARE


          TASK TYPE  TT  IS
               ENTRY  A ;
          END  TT ;

          TASK BODY  TT  IS
          BEGIN

               TERMINATE; -- ERROR:  TERMINATE  OUTSIDE  SELECTIVE_WAIT.

          END  TT ;


     BEGIN


               NULL;


     END  ;

     -------------------------------------------------------------------


END  B97104B ;
