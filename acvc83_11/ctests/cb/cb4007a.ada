-- CB4007A.ADA

-- OBJECTIVE:
--     CHECK THAT THE STATEMENT PART OF A PACKAGE CAN RAISE, PROPAGATE,
--     AND HANDLE EXCEPTIONS. IF THE BODY'S HANDLERS HANDLE ALL
--     EXCEPTIONS RAISED AND DO NOT RAISE ANY UNHANDLED EXCEPTIONS,
--     NO EXCEPTION IS PROPAGATED.

-- HISTORY:
--     DHH 03/28/88 CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE CB4007A IS
BEGIN

     TEST("CB4007A", "CHECK THAT THE STATEMENT PART OF A PACKAGE " &
                     "CAN RAISE, PROPAGATE, AND HANDLE EXCEPTIONS. " &
                     "IF THE BODY'S HANDLERS HANDLE ALL EXCEPTIONS " &
                     "RAISED AND DO NOT RAISE ANY UNHANDLED " &
                     "EXCEPTIONS, NO EXCEPTION IS PROPAGATED");
     DECLARE

          PACKAGE OUTSIDE IS
          END OUTSIDE;

          PACKAGE BODY OUTSIDE IS

          BEGIN
               DECLARE
                    PACKAGE HANDLER IS
                    END HANDLER;

                    PACKAGE BODY HANDLER IS
                    BEGIN
                         DECLARE
                              PACKAGE PROPAGATE IS
                              END PROPAGATE;

                              PACKAGE BODY PROPAGATE IS
                              BEGIN
                                   DECLARE
                                        PACKAGE RISE IS
                                        END RISE;

                                        PACKAGE BODY RISE IS
                                        BEGIN
                                             RAISE CONSTRAINT_ERROR;
                                             FAILED("EXCEPTION " &
                                                    "NOT RAISED");
                                        END RISE;

                                   BEGIN
                                        NULL;
                                   END;   -- PACKAGE PROPAGATE DECLARE.
                              EXCEPTION
                                   WHEN CONSTRAINT_ERROR =>
                                        RAISE CONSTRAINT_ERROR;
                                   WHEN OTHERS =>
                                        FAILED("UNEXPECTED EXCEPTION " &
                                               "RAISED IN PROPAGATE " &
                                               "PACKAGE");
                              END PROPAGATE;

                         BEGIN
                              NULL;
                         END;               -- PACKAGE HANDLER DECLARE.
                    EXCEPTION
                         WHEN CONSTRAINT_ERROR =>
                             NULL;
                         WHEN OTHERS =>
                              FAILED("UNEXPECTED EXCEPTION RAISED IN " &
                                     "HANDLER PACKAGE");
                    END HANDLER;

               BEGIN
                    NULL;
               END;                    -- PACKAGE OUTSIDE DECLARE.
          EXCEPTION
               WHEN OTHERS =>
                    FAILED("UNEXPECTED EXCEPTION RAISED IN OUTSIDE " &
                           "PACKAGE");
          END OUTSIDE;
     BEGIN
         NULL;
     END;

     RESULT;

EXCEPTION
     WHEN OTHERS =>
          FAILED("UNEXPECTED EXCEPTION RAISED");
          RESULT;
END CB4007A;
