-- B99003A.ADA


-- CHECK THAT A COUNT ATTRIBUTE FOR AN ENTRY OF A FAMILY THE ENTRY NAME
--     MUST HAVE THE FORM OF AN INDEXED COMPONENT WITH ONE AND ONLY ONE
--     INDEX.


-- RM 5/19/82


PROCEDURE  B99003A  IS
BEGIN


     -------------------------------------------------------------------


     DECLARE


          TASK TYPE  T_TYPE  IS
               ENTRY  E ( BOOLEAN );
          END  T_TYPE ;


          T_OBJECT1 : T_TYPE ;
          T_OBJECT2 : T_TYPE ;


          TASK BODY  T_TYPE  IS
               BUSY : BOOLEAN := FALSE ;
          BEGIN

               IF  E'COUNT = 0  THEN        -- ERROR: INDEX MISSING.
                    NULL;
               END IF;

               IF  E( TRUE OR FALSE ) 'COUNT = 0  THEN     -- OK.
                    NULL;
               END IF;

               IF  E( TRUE , FALSE ) 'COUNT = 0   -- ERROR: 2 INDICES.
               THEN
                    NULL;
               END IF;

          END  T_TYPE ;


     BEGIN

          NULL;

     END ;


     -------------------------------------------------------------------


END  B99003A ;
