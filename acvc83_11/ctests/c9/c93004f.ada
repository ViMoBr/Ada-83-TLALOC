-- C93004F.ADA

-- CHECK THAT WHEN AN EXCEPTION IS RAISED DURING THE ACTIVATION OF A
-- TASK, OTHER TASKS ARE UNAFFECTED.

-- THE ENCLOSING BLOCK RECEIVES TASKING_ERROR.

-- THIS TESTS CHECKS THE CASE IN WHICH THE TASKS ARE CREATED BY THE
-- ALLOCATION OF A RECORD OF TASKS OR AN ARRAY OF TASKS.

-- R. WILLIAMS 8/7/86

WITH REPORT; USE REPORT;

PROCEDURE C93004F IS

BEGIN
     TEST ( "C93004F", "CHECK THAT WHEN AN EXCEPTION IS RAISED " &
                       "DURING THE ACTIVATION OF A TASK, OTHER " &
                       "TASKS ARE UNAFFECTED. IN THIS TEST, THE " &
                       "TASKS ARE CREATED BY THE ALLOCATION OF A " &
                       "RECORD OR AN ARRAY OF TASKS" );

     DECLARE

          TASK TYPE T IS 
               ENTRY E;
          END T;

          TASK TYPE TT;

          TASK TYPE TX IS 
               ENTRY E;
          END TX;

          TYPE REC IS
               RECORD
                    TR : T;
               END RECORD;

          TYPE ARR IS ARRAY (IDENT_INT (1) .. IDENT_INT (1)) OF T;

          TYPE RECX IS
               RECORD 
                    TTX1 : TX;
                    TTT  : TT;
                    TTX2 : TX;
               END RECORD;

          TYPE ACCR IS ACCESS REC;
          AR : ACCR;

          TYPE ACCA IS ACCESS ARR;
          AA : ACCA;
               
          TYPE ACCX IS ACCESS RECX;
          AX : ACCX;

          TASK BODY T IS
          BEGIN
               ACCEPT E;
          END T;

          TASK BODY TT IS
          BEGIN
               AR.TR.E;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ( "TASK AR.TR NOT ACTIVE" );
          END TT;

          TASK BODY TX IS
               I : POSITIVE := IDENT_INT (0); -- RAISE 
                                              -- CONSTRAINT_ERROR.
          BEGIN
               IF I /= IDENT_INT (2) OR I = IDENT_INT (1) + 1 THEN
                    FAILED ( "TX ACTIVATED OK" );
               END IF;
          END TX;

     BEGIN
          AR := NEW REC;
          AA := NEW ARR;
          AX := NEW RECX;

          FAILED ( "TASKING_ERROR NOT RAISED IN MAIN" );
          
          AA.ALL (1).E;        -- CLEAN UP.

     EXCEPTION
          WHEN TASKING_ERROR =>

               BEGIN
                    AA.ALL (1).E;
               EXCEPTION
                    WHEN TASKING_ERROR =>
                         FAILED ( "AA.ALL (1) NOT ACTIVATED" );
               END;

          WHEN CONSTRAINT_ERROR =>
               FAILED ( "CONSTRAINT_ERROR RAISED IN MAIN" );
          WHEN OTHERS =>
               FAILED ( "ABNORMAL EXCEPTION IN MAIN" );
     END;

     RESULT;

END C93004F;
