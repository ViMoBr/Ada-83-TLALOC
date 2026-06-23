-- C97201D.ADA


-- CHECK THAT A RENDEZVOUS REQUESTED BY A CONDITIONAL_ENTRY_CALL
--     IS PERFORMED ONLY IF IMMEDIATELY POSSIBLE.

-- CASE  D:  THE BODY OF THE TASK CONTAINING THE CALLED ENTRY
--     DOES NOT CONTAIN AN ACCEPT_STATEMENT FOR THAT ENTRY  -
--     AND THIS FACT IS DETERMINED STATICALLY.


-- RM 4/12/82


WITH REPORT; USE REPORT;
PROCEDURE C97201D IS

     ELSE_BRANCH_TAKEN    :  BOOLEAN  :=  FALSE ;

BEGIN


     TEST ("C97201D", "CHECK THAT NO RENDEZVOUS REQUESTED BY"      &
                      " A CONDITIONAL_ENTRY_CALL CAN EVER OCCUR"   &
                      " IN THE ABSENCE OF A CORRESPONDING "        &
                      " ACCEPT_STATEMENT "                         );


     DECLARE


          TASK  T  IS
               ENTRY  DO_IT_NOW_ORELSE ;
               ENTRY  KEEP_ALIVE ;
          END  T ;
          

          TASK BODY  T  IS
          BEGIN

               -- NO ACCEPT_STATEMENT FOR THE ENTRY_CALL BEING TESTED

               ACCEPT  KEEP_ALIVE ;  -- TO PREVENT THIS SERVER TASK FROM
                                     --     TERMINATING IF
                                     --     UPON ACTIVATION
                                     --     IT GETS TO RUN    
                                     --     AHEAD OF THE CALLER (WHICH
                                     --     WOULD LEAD TO A SUBSEQUENT
                                     --     TASKING_ERROR AT THE TIME OF
                                     --     THE NO-WAIT CALL).

          END ;


     BEGIN

          SELECT
               T.DO_IT_NOW_ORELSE ;
          ELSE              -- (I.E. CALLER ADOPTS A NO-WAIT POLICY)
                            --      THEREFORE THIS BRANCH MUST BE CHOSEN
               ELSE_BRANCH_TAKEN := TRUE ;
               COMMENT( "ELSE_BRANCH  TAKEN" );
          END SELECT;

          T.KEEP_ALIVE ;    -- THIS ALSO UPDATES THE NONLOCALS

     END;   -- END OF BLOCK CONTAINING THE ENTRY CALL


     -- BY NOW, THE TASK IS TERMINATED

     IF  ELSE_BRANCH_TAKEN  THEN
          NULL ;
     ELSE
          FAILED( "RENDEZVOUS ATTEMPTED?" );
     END IF;

     RESULT;


END  C97201D ; 
