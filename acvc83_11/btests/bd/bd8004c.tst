-- BD8004C.TST

-- OBJECTIVE:
--     IF A PROCEDURE CONTAINS MACHINE CODE STATEMENTS, THEN NO OTHER
--     FORM OF STATEMENT IS ALLOWED.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS THAT SUPPORT THE
--     MACHINE CODE STATEMENTS.  IF SUCH STATEMENTS ARE NOT SUPPORTED,
--     THE "WITH" CLAUSE MUST BE REJECTED.

-- MACRO SUBSTITUTION:
--     THE MACRO MACHINE_CODE_STATEMENT IS A VALID MACHINE CODE
--     STATEMENT THAT IS DEFINED IN THE PACKAGE MACHINE_CODE.  IF THE
--     IMPLEMENTATION DOES NOT SUPPORT MACHINE CODE THEN USE THE
--     ADA NULL STATEMENT (I.E. NULL; ).

-- HISTORY:
--     LDC  06/15/88 CREATED ORIGINAL TEST.

WITH MACHINE_CODE;                                     -- N/A => ERROR.
USE MACHINE_CODE;

PROCEDURE BD8004C IS
     INT : INTEGER;

     PROCEDURE CHECK_BLOCK IS
     BEGIN
          $MACHINE_CODE_STATEMENT
          BEGIN                                        -- ERROR:
               NULL;
          END;
     END CHECK_BLOCK;

     PROCEDURE DO_NOTHING IS
     BEGIN
          NULL;
     END DO_NOTHING;

     PROCEDURE CHECK_CALL IS
     BEGIN
         $MACHINE_CODE_STATEMENT
         DO_NOTHING;                                   -- ERROR:
     END CHECK_CALL;

     PROCEDURE CHECK_DELAY IS
     BEGIN
         DELAY 2.0;                                    -- ERROR:
         $MACHINE_CODE_STATEMENT
     END CHECK_DELAY;

     PROCEDURE CHECK_ENTRY IS
          TASK TSK IS
               ENTRY ENT;
          END TSK;
          TASK BODY TSK IS
          BEGIN
               ACCEPT ENT DO
                   NULL;
               END;
          END TSK;
     BEGIN                                             -- BEGINNING OF
          TSK.ENT;                                     -- CHECK ENTRY.
          $MACHINE_CODE_STATEMENT
     END CHECK_ENTRY;

     PROCEDURE CHECK_LOOP IS
     BEGIN
          $MACHINE_CODE_STATEMENT
          LOOP                                         -- ERROR:
               NULL;
          END LOOP;
     END;

     PROCEDURE CHECK_NULL IS
     BEGIN
          NULL;                                        -- ERROR:
          $MACHINE_CODE_STATEMENT
     END CHECK_NULL;

     PROCEDURE CHECK_RAISE IS
          RAISE_ERR : EXCEPTION;
     BEGIN
          RAISE RAISE_ERR;                             -- ERROR:
          $MACHINE_CODE_STATEMENT
     END CHECK_RAISE;

     PROCEDURE CHECK_RETURN IS
     BEGIN
          $MACHINE_CODE_STATEMENT
          RETURN;                                      -- ERROR:
     END CHECK_RETURN;

BEGIN

     $MACHINE_CODE_STATEMENT
     INT := 5;                                         -- ERROR:

END BD8004C;
