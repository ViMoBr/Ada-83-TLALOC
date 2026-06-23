-- C97117A.ADA

-- CHECK THAT PROGRAM_ERROR IS RAISED IF ALL ALTERNATIVES ARE CLOSED AND
-- NO ELSE PART IS PRESENT.

-- WRG 7/10/86

WITH REPORT; USE REPORT;
PROCEDURE C97117A IS

BEGIN

     TEST ("C97117A", "CHECK THAT PROGRAM_ERROR IS RAISED IF ALL " &
                      "ALTERNATIVES ARE CLOSED AND NO ELSE PART IS " &
                      "PRESENT");

     DECLARE

          TASK T IS
               ENTRY E;
          END T;

          TASK BODY T IS
          BEGIN
               SELECT
                    WHEN IDENT_BOOL (FALSE) =>
                         ACCEPT E;
                         FAILED ("CLOSED ACCEPT ALTERNATIVE TAKEN " &
                                 "FOR NONEXISTENT ENTRY CALL");
               OR   WHEN IDENT_BOOL (FALSE) =>
                         DELAY 0.0;
                         FAILED ("CLOSED ALTERNATIVE TAKEN");
               END SELECT;
               FAILED ("PROGRAM_ERROR NOT RAISED");
          EXCEPTION
               WHEN PROGRAM_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED");
          END T;

     BEGIN

          NULL;

     END;

     RESULT;

END C97117A;
