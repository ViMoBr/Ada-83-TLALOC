-- B97104A.ADA


-- CHECK THAT  TERMINATE  CANNOT BE USED OUSIDE A  SELECTIVE_WAIT .
--     (PART A:  PLAIN )


-- RM 4/22/1982


PROCEDURE  B97104A  IS
BEGIN


     -------------------------------------------------------------------


     DECLARE

     BEGIN


               TERMINATE;       -- ERROR:  TERMINATE  OUTSIDE TASK BODY.


     END  ;

     -------------------------------------------------------------------


END  B97104A ;
