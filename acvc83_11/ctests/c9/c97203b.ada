-- C97203B.ADA


-- CHECK THAT A CONDITIONAL_ENTRY_CALL CAN APPEAR IN PLACES WHERE A
--     SELECTIVE_WAIT  CANNOT.

-- PART 2: PROCEDURE BODY EMBEDDED IN TASK BODY.


-- RM 4/09/1982


WITH REPORT;
USE REPORT;
PROCEDURE  C97203B  IS


BEGIN


     TEST ( "C97203B" , "CHECK THAT A  CONDITIONAL_ENTRY_CALL  CAN" &
                        " APPEAR WHERE A  SELECTIVE_WAIT  CANNOT" );


     -------------------------------------------------------------------


     DECLARE


          TASK  TT  IS
               ENTRY  A ( AUTHORIZED : IN BOOLEAN );
          END  TT ;


          TASK BODY  TT  IS


               PROCEDURE  WITHIN_TASK_BODY ;


               PROCEDURE  WITHIN_TASK_BODY  IS
               BEGIN

                    SELECT  -- NOT A SELECTIVE_WAIT
                         A ( FALSE ) ;  -- CALLING (OWN) ENTRY
                    ELSE 
                         COMMENT( "ALTERNATIVE BRANCH TAKEN" );
                    END SELECT;
                    
               END  WITHIN_TASK_BODY ;


          BEGIN


               -- CALL THE INNER PROC. TO FORCE EXEC. OF COND_E_CALL
               WITHIN_TASK_BODY ;


               ACCEPT  A ( AUTHORIZED : IN BOOLEAN )  DO

                    IF  AUTHORIZED  THEN
                         COMMENT(  "AUTHORIZED ENTRY_CALL" );
                    ELSE
                         FAILED( "UNAUTHORIZED ENTRY_CALL" );
                    END IF;

               END  A ;

          END  TT ;


          PROCEDURE  OUTSIDE_TASK_BODY  IS
          BEGIN

               SELECT  -- NOT A SELECTIVE_WAIT
                    TT.A ( FALSE ) ;  -- UNBORN
               ELSE 
                    COMMENT( "(OUT:) ALTERNATIVE BRANCH TAKEN" );
               END SELECT;

          END  OUTSIDE_TASK_BODY ;


          PACKAGE       CREATE_OPPORTUNITY_TO_CALL           IS END;   
          PACKAGE BODY  CREATE_OPPORTUNITY_TO_CALL  IS
          BEGIN
               -- CALL THE OTHER PROC. TO FORCE EXEC. OF COND_E_CALL
               OUTSIDE_TASK_BODY ;
          END  CREATE_OPPORTUNITY_TO_CALL ;


     BEGIN

          TT.A ( TRUE );

     EXCEPTION

          WHEN  TASKING_ERROR  =>
               FAILED( "TASKING ERROR" );

     END  ;

     -------------------------------------------------------------------

     RESULT ;


END  C97203B ;
