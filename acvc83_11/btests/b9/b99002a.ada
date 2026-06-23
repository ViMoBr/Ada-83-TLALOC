-- B99002A.ADA

-- OBJECTIVE:
--     CHECK THAT THE PREFIX FOR 'COUNT MUST BE AN ENTRY OF A TASK UNIT.
--     TASK'S IDENTITY STATICALLY DETERMINABLE; TASKS OF THE SAME TYPE.

-- HISTORY:
--     RM  05/14/82 CREATED ORIGINAL TEST.
--     SPS 01/24/83
--     DHH 08/16/88 REVISED HEADER AND ADDED TESTS OF SUBTYPE NAME.

PROCEDURE  B99002A  IS
BEGIN
     DECLARE

          TASK TYPE  T_TYPE  IS
               ENTRY  E ;
          END  T_TYPE ;

          SUBTYPE SUB_T IS T_TYPE;

          T_OBJECT1 : T_TYPE ;
          T_OBJECT2 : T_TYPE ;

          TASK BODY  T_TYPE  IS
               BUSY : BOOLEAN := FALSE ;
          BEGIN

               ACCEPT E;

               IF  T_TYPE.E'COUNT = 0  THEN     -- OK.
                    NULL;
               END IF;

               IF  SUB_T.E'COUNT = 0  THEN      -- ERROR: SUBTYPE.
                    NULL;
               END IF;

               IF  T_OBJECT1.E'COUNT = T_OBJECT2.E'COUNT THEN -- ERROR:
                    NULL;                   -- T_OBJECT NOT TASK UNIT.
               END IF;

               IF  E'COUNT = T_OBJECT2.E'COUNT THEN           -- ERROR:
                    NULL;                   -- T_OBJECT2 NOT TASK UNIT.
               END IF;

          END  T_TYPE ;

     BEGIN
          NULL;
     END ;

END  B99002A ;
