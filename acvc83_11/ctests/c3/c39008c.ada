-- C39008C.ADA

-- OBJECTIVE:
--     CHECK THAT PROGRAM_ERROR IS RAISED WHEN AN ATTEMPT IS MADE TO
--     ACTIVATE A TASK BEFORE ITS BODY HAS BEEN ELABORATED.  CHECK THE
--     CASE IN WHICH SEVERAL TASKS ARE TO BE ACTIVATED, AND ONLY SOME
--     HAVE UNELABORATED BODIES; NO TASKS SHOULD BE ACTIVATED.

-- HISTORY:
--     BCB 07/08/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C39008C IS

BEGIN
     TEST ("C39008C", "CHECK THAT PROGRAM_ERROR IS RAISED WHEN AN " &
                      "ATTEMPT IS MADE TO ACTIVATE A TASK BEFORE ITS " &
                      "BODY HAS BEEN ELABORATED.  CHECK THE CASE IN " &
                      "WHICH SEVERAL TASKS ARE TO BE ACTIVATED, AND " &
                      "ONLY SOME HAVE UNELABORATED BODIES; NO TASKS " &
                      "SHOULD BE ACTIVATED");

     BEGIN
          DECLARE
               TASK TYPE A;

               TASK TYPE B;

               TASK TYPE C;

               TASK TYPE D;

               PACKAGE P IS
                    W : A;
                    X : B;
                    Y : C;
                    Z : D;
               END P;

               TASK BODY A IS
               BEGIN
                    FAILED ("TASK A ACTIVATED");
               END A;

               TASK BODY D IS
               BEGIN
                    FAILED ("TASK D ACTIVATED");
               END D;

               PACKAGE BODY P IS
               END P;

               TASK BODY B IS
               BEGIN
                    FAILED ("TASK B ACTIVATED");
               END B;

               TASK BODY C IS
               BEGIN
                    FAILED ("TASK C ACTIVATED");
               END C;
          BEGIN
               FAILED ("PROGRAM_ERROR WAS NOT RAISED");
          END;
     EXCEPTION
          WHEN PROGRAM_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("AN EXCEPTION OTHER THAN PROGRAM_ERROR WAS " &
                       "RAISED");
     END;

     RESULT;
END C39008C;
