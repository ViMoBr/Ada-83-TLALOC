-- B9A001B.ADA


-- CHECK THAT AN ABORT STATEMENT MUST NAME AT LEAST ONE TASK.


-- RM 5/25/82


PROCEDURE  B9A001B  IS
BEGIN


     -------------------------------------------------------------------


     DECLARE


          TASK TYPE  T_TYPE  IS
               ENTRY  E ;
          END  T_TYPE ;


          T_OBJECT1 : T_TYPE ;
          T_OBJECT2 : T_TYPE ;


          TASK BODY  T_TYPE  IS
               BUSY : BOOLEAN := FALSE ;
          BEGIN

               NULL;
               ABORT  T_TYPE ;      -- OK (THE OBJECT).
          END  T_TYPE ;


     BEGIN

          ABORT T_TYPE ;            -- ERROR: NO TASK OBJECT.

          ABORT T_OBJECT2 ;         -- OK.

     END ;


     -------------------------------------------------------------------


END  B9A001B ;
