-- C9A006A.ADA


-- CHECK THAT A TASK MAY ABORT ITSELF (AND THAT IN THAT CASE THE NEXT
--     STATEMENT IS NOT EXECUTED).


-- RM 5/26/82
-- RM 7/02/82
-- SPS 11/21/82

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;
PROCEDURE  C9A006A  IS

      TASK_NOT_ABORTED : BOOLEAN := FALSE ;

BEGIN


     -------------------------------------------------------------------


     TEST ("C9A006A", "CHECK THAT A TASK MAY ABORT ITSELF" );

  
     DECLARE


          TASK  REGISTER  IS

               PRAGMA PRIORITY ( PRIORITY'FIRST );  -- LEAST URGENT
               -- OTHER TASKS HAVE HIGHEST PRIORITY ( PRIORITY'LAST )

               ENTRY  SYNC1 ;
               ENTRY  SYNC2 ;

          END  REGISTER ;


          TASK BODY  REGISTER  IS


               TASK TYPE  T_TYPE1  IS

                    PRAGMA PRIORITY ( PRIORITY'LAST ); -- MOST URGENT

                    ENTRY  E ;

               END  T_TYPE1 ;


               TASK TYPE  T_TYPE2  IS

                    PRAGMA PRIORITY ( PRIORITY'LAST ); -- MOST URGENT

                    ENTRY  E ;

               END  T_TYPE2 ;


               T_OBJECT1 : T_TYPE1 ;
               T_OBJECT2 : T_TYPE2 ;


               TASK BODY  T_TYPE1  IS
               BEGIN

                    SYNC1 ;

                    IF  IDENT_INT(1) = 1  THEN
                         ABORT  T_TYPE1 ;
                    END IF;

                    TASK_NOT_ABORTED := TRUE ;

               END  T_TYPE1 ;


               TASK BODY  T_TYPE2  IS
               BEGIN

                    SYNC2 ;

                    IF  IDENT_INT(1) = 1  THEN
                         ABORT  T_OBJECT2 ;
                    END IF;

                    TASK_NOT_ABORTED := TRUE ;

               END  T_TYPE2 ;


          BEGIN


               ACCEPT  SYNC1 ;  -- ALLOWING  ABORT#1

               -- CHECK THAT  #1  WAS ABORTED  -  2 WAYS:

               BEGIN
                    T_OBJECT1.E ;
                    FAILED( "T_OBJECT1.E  DID NOT RAISE" &
                                       "  TASKING_ERROR" );
               EXCEPTION

                    WHEN TASKING_ERROR  =>
                         NULL;

                    WHEN OTHERS  =>
                         FAILED( "OTHER EXCEPTION RAISED - 1" );

               END ;

               IF NOT  T_OBJECT1'TERMINATED  THEN
                    FAILED( "T_OBJECT1'TERMINATED=FALSE" );
               END IF;



               ACCEPT  SYNC2 ;  -- ALLOWING  ABORT#2

               -- CHECK THAT  #2  WAS ABORTED  -  2 WAYS:

               BEGIN
                    T_OBJECT2.E ;
                    FAILED( "T_OBJECT2.E  DID NOT RAISE" &
                                       "  TASKING_ERROR" );
               EXCEPTION

                    WHEN TASKING_ERROR  =>
                         NULL;

                    WHEN OTHERS  =>
                         FAILED( "OTHER EXCEPTION RAISED - 2" );

               END ;

               IF NOT  T_OBJECT2'TERMINATED  THEN
                    FAILED( "T_OBJECT2'TERMINATED=FALSE" );
               END IF;


          END  REGISTER ;


     BEGIN

          NULL;

     END ;


     -------------------------------------------------------------------


     IF  TASK_NOT_ABORTED  THEN
          FAILED( "AT LEAST ONE  T_TYPE  TASK NOT ABORTED" );
     END IF;


     RESULT;


END  C9A006A ;
