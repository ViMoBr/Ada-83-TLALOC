-- A95005A.ADA

-- CHECK THAT THE IDENTIFIER AT THE END OF AN ACCEPT_STATEMENT
--   MAY BE OMITTED.

-- JRK 10/26/81
-- JWC 6/28/85   RENAMED TO -AB

WITH REPORT; USE REPORT;
PROCEDURE A95005A IS

BEGIN
     TEST ("A95005A", "CHECK THAT THE IDENTIFIER AT THE END OF AN" &
                      "ACCEPT_STATEMENT MAY BE OMITTED");

     DECLARE

          TASK T IS
               ENTRY E0;
               ENTRY E1 (I : INTEGER);
               ENTRY E2 (BOOLEAN) (I : INTEGER);
          END T;

          TASK BODY T IS

               J : INTEGER := 0;

          BEGIN

               ACCEPT E0 DO
                    J := 1;
               END;

               ACCEPT E1 (I : INTEGER) DO
                    J := I;
               END;

               ACCEPT E2 (TRUE) (I : INTEGER) DO
                    J := I;
               END;

          END T;

     BEGIN

          T.E0;
          T.E1 (2);
          T.E2 (TRUE) (3);

     END;

     RESULT;
END A95005A;
