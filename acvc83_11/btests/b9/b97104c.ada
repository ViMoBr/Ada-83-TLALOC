-- B97104C.ADA


-- CHECK THAT  TERMINATE  CANNOT BE USED OUTSIDE A  SELECTIVE_WAIT .
--     (PART C:  IN A PROCEDURE OUTSIDE THE TASK BODY.)


-- RM 4/22/1982


PROCEDURE  B97104C  IS
BEGIN


     -------------------------------------------------------------------


     DECLARE


          PROCEDURE  B ;


          TASK TYPE  TT  IS
               ENTRY  A ;
          END  TT ;

          TASK BODY  TT  IS
          BEGIN

               NULL;

          END  TT ;


          PROCEDURE  B  IS
          BEGIN
               TERMINATE;       -- ERROR:  TERMINATE  OUTSIDE TASK BODY.
               NULL ;
          END  B ;


     BEGIN


               NULL;


     END  ;

     -------------------------------------------------------------------


END  B97104C ;
