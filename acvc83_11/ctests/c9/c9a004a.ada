-- C9A004A.ADA


-- CHECK THAT IF A TASK IS ABORTED BEFORE BEING ACTIVATED, THE TASK IS
--     TERMINATED.


-- RM 5/21/82
-- SPS 11/21/82
-- JBG 6/3/85

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;
PROCEDURE  C9A004A  IS

BEGIN


     -------------------------------------------------------------------


     TEST ("C9A004A", "CHECK THAT IF A TASK IS ABORTED"  &
                      " BEFORE BEING ACTIVATED,"         &
                      "  THE TASK IS TERMINATED"         );

  
     DECLARE


          TASK TYPE  T_TYPE  IS

               PRAGMA PRIORITY ( PRIORITY'LAST );  -- MOST URGENT

               ENTRY  E ;

          END  T_TYPE ;


          T_OBJECT1 : T_TYPE ;


          TASK BODY  T_TYPE  IS
               BUSY : BOOLEAN := FALSE ;
          BEGIN

               NULL;

          END  T_TYPE ;


          PACKAGE  P  IS
               X : INTEGER := 0 ;
          END  P ;


          PACKAGE BODY  P  IS
          BEGIN

               IF      T_OBJECT1'TERMINATED  OR
                   NOT T_OBJECT1'CALLABLE
               THEN
                    FAILED( "WRONG VALUES FOR ATTRIBUTES" );
               END IF;

               ABORT  T_OBJECT1 ;  -- ELABORATED BUT NOT YET ACTIVATED.

          END  P ;


     BEGIN


          IF NOT  T_OBJECT1'TERMINATED  THEN
               FAILED(  "ABORTED (BEFORE ACTIVATION) TASK"  &
                        "  NOT TERMINATED"  );
          END IF;

     EXCEPTION

          WHEN TASKING_ERROR =>
               FAILED ("TASKING_ERROR RAISED");

     END;

     RESULT;

END C9A004A;
