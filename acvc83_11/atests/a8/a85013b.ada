-- A85013B.ADA

-- CHECK THAT:

--   A) A SUBPROGRAM OR ENTRY CAN BE RENAMED WITHIN ITS OWN BODY.

--   B) THE NEW NAME OF A SUBPROGRAM CAN BE USED IN A RENAMING
--      DECLARATION.

-- EG  02/22/84

WITH REPORT;

PROCEDURE A85013B IS

     USE REPORT;

BEGIN

     TEST("A85013B","CHECK THAT A SUBPROGRAM CAN BE RENAMED WITHIN " &
                    "ITS OWN BODY AND THAT THE NEW NAME CAN BE USED" &
                    " IN A RENAMING DECLARATION");

     DECLARE

          PROCEDURE PROC1 (A : BOOLEAN) IS
               PROCEDURE PROC2 (B : BOOLEAN := FALSE) RENAMES PROC1;
               PROCEDURE PROC3 (C : BOOLEAN := FALSE) RENAMES PROC2;
          BEGIN
               IF A THEN
                    PROC3;
               END IF;
          END PROC1;

     BEGIN

          PROC1 (TRUE);

     END;

     DECLARE

          TASK T IS
               ENTRY E;
          END T;

          TASK BODY T IS
               PROCEDURE E1 RENAMES E;
               PROCEDURE E2 RENAMES E1;
          BEGIN
               ACCEPT E DO
                    DECLARE
                         PROCEDURE E3 RENAMES E;
                         PROCEDURE E4 RENAMES E3;
                    BEGIN
                         NULL;
                    END;
               END E;
          END T;

     BEGIN
          T.E;
     END;

     RESULT;

END A85013B;
