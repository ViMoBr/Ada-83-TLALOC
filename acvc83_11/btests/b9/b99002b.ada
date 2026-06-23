-- B99002B.ADA

-- CHECK THAT THE PREFIX FOR 'COUNT MUST BE AN ENTRY OF A TASK UNIT.

-- TASK'S IDENTITY STATICALLY DETERMINABLE; TASKS OF DIFFERENT TYPES.

-- RM 5/14/82
-- SPS 1/24/82

PROCEDURE  B99002B  IS
BEGIN


     -------------------------------------------------------------------


     DECLARE


          TASK TYPE  T_TYPE1  IS
               ENTRY  E ;
          END  T_TYPE1 ;

          TASK TYPE  T_TYPE2  IS
               ENTRY  E ;
          END  T_TYPE2 ;


          T_OBJECT1 : T_TYPE1 ;
          T_OBJECT2 : T_TYPE2 ;


          TASK BODY  T_TYPE1  IS
               BUSY : BOOLEAN := FALSE ;
          BEGIN

               IF  E'COUNT = 0  THEN     -- OK.
                    NULL;
               END IF;


               IF  E'COUNT = T_OBJECT2.E'COUNT   -- ERROR: T_OBJECT NOT
                                                 -- TASK UNIT.
               THEN
                    NULL;
               END IF;


          END  T_TYPE1 ;


          TASK BODY  T_TYPE2  IS
               BUSY : BOOLEAN := FALSE ;
          BEGIN

               IF  E'COUNT = 0  THEN     -- OK.
                    NULL;
               END IF;

          END  T_TYPE2 ;


     BEGIN

          NULL;

     END ;


     -------------------------------------------------------------------


END  B99002B ;
