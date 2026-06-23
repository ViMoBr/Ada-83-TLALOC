-- B9A001A.ADA


-- CHECK THAT AN ABORT STATEMENT MUST NAME AT LEAST ONE TASK.


-- RM 5/14/82


PROCEDURE  B9A001A  IS
BEGIN


     -------------------------------------------------------------------


     DECLARE


          TASK TYPE  T_TYPE  IS
               ENTRY  E ;
          END  T_TYPE ;


          TASK BODY  T_TYPE  IS
               BUSY : BOOLEAN := FALSE ;
          BEGIN

               NULL;
               ABORT  T_TYPE ;      -- OK (THE OBJECT).

          END  T_TYPE ;


     BEGIN

          ABORT ;                   -- ERROR: NO TASK OBJECT.

     END ;


     -------------------------------------------------------------------


END  B9A001A ;
