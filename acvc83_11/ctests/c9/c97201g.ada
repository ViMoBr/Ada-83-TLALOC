-- C97201G.ADA


-- CHECK THAT A RENDEZVOUS REQUESTED BY A CONDITIONAL_ENTRY_CALL
--     IS PERFORMED ONLY IF IMMEDIATELY POSSIBLE.

-- CASE  G:  THE CORRESPONDING ACCEPT_STATEMENT IS CLOSED
--     AND THIS FACT IS STATICALLY DETERMINABLE.


-- RM 4/21/82


WITH REPORT; USE REPORT;
PROCEDURE C97201G IS

     ELSE_BRANCH_TAKEN    :  BOOLEAN  :=  FALSE ;
     RENDEZVOUS_OCCURRED  :  BOOLEAN  :=  FALSE ;
     QUEUE_NOT_EMPTY      :  BOOLEAN  :=  FALSE ;
     X                    :  INTEGER  :=  17 ;

BEGIN


     TEST ("C97201G", "CHECK THAT NO RENDEZVOUS REQUESTED BY"      &
                      " A CONDITIONAL_ENTRY_CALL CAN EVER OCCUR"   &
                      " IF THE CORRESPONDING ACCEPT_STATEMENT IS"  &
                      " CLOSED"                                    );


     -------------------------------------------------------------------


     DECLARE


          TASK  T  IS
               ENTRY  DO_IT_NOW_ORELSE( DID_YOU_DO_IT : IN OUT BOOLEAN);
               ENTRY  KEEP_ALIVE ;
          END  T ;
          

          TASK BODY  T  IS
          BEGIN

               IF  DO_IT_NOW_ORELSE'COUNT /= 0  THEN
                    QUEUE_NOT_EMPTY := TRUE ;
               END IF;


               SELECT
                    WHEN  3 = 5  =>
                         ACCEPT  DO_IT_NOW_ORELSE
                                      ( DID_YOU_DO_IT : IN OUT BOOLEAN)
                         DO
                              DID_YOU_DO_IT := TRUE ;
                         END;
               OR
                         ACCEPT  KEEP_ALIVE ; -- TO PREVENT SELECT_ERROR
               END SELECT;


               IF  DO_IT_NOW_ORELSE'COUNT /= 0  THEN
                    QUEUE_NOT_EMPTY := TRUE ;
               END IF;


          END  T ;


     BEGIN

          COMMENT( "PERMANENTLY CLOSED" );

          SELECT
               T.DO_IT_NOW_ORELSE( RENDEZVOUS_OCCURRED );
          ELSE              -- (I.E. CALLER ADOPTS A NO-WAIT POLICY)
                            --      THEREFORE THIS BRANCH MUST BE CHOSEN
               ELSE_BRANCH_TAKEN := TRUE ;
               COMMENT( "ELSE_BRANCH  TAKEN" );
          END SELECT;

          T.KEEP_ALIVE ;    -- THIS ALSO UPDATES THE NONLOCALS

     END;   -- END OF BLOCK CONTAINING THE ENTRY CALL


     -------------------------------------------------------------------


     -- BY NOW, THE TASK IS TERMINATED

     IF  RENDEZVOUS_OCCURRED
     THEN
          FAILED( "RENDEZVOUS OCCURRED" );
     END IF;

     IF  QUEUE_NOT_EMPTY
     THEN
          FAILED( "ENTRY QUEUE NOT EMPTY" );
     END IF;

     IF  ELSE_BRANCH_TAKEN  THEN
          NULL ;
     ELSE
          FAILED( "RENDEZVOUS ATTEMPTED?" );
     END IF;

     RESULT;


END  C97201G ; 
