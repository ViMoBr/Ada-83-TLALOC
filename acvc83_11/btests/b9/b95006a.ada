-- B95006A.ADA

-- CHECK THAT THE IDENTIFIER AT THE END OF AN ACCEPT_STATEMENT, IF
--   PRESENT, MUST BE THAT USED IN THE DECLARATION OF THE CORRESPONDING
--   ENTRY OR ENTRY FAMILY.

-- JRK 10/26/81
-- JWC 6/28/85   RENAMED TO -AB

PROCEDURE B95006A IS

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
          END E1;                  -- ERROR: MISMATCHED IDENTIFIER.

          ACCEPT E1 (I : INTEGER) DO
               J := I;
          END E2;                  -- ERROR: MISMATCHED IDENTIFIER.

          ACCEPT E2 (TRUE) (I : INTEGER) DO
               J := I;
          END E0;                  -- ERROR: MISMATCHED IDENTIFIER.

          ACCEPT E0 DO
               ACCEPT E1 (I : INTEGER) DO
                    ACCEPT E2 (TRUE) (I : INTEGER) DO
                         J := I;
                    END E2;        -- OK.
               END E0;             -- ERROR: MISMATCHED IDENTIFIER.
          END E;                   -- ERROR: UNDEFINED IDENTIFIER.

          ACCEPT E1 (I : INTEGER) DO
               ACCEPT E2 (TRUE) (I : INTEGER) DO
                    ACCEPT E0 DO
                         J := I;
                    END E0;        -- OK.
               END E0;             -- ERROR: MISMATCHED IDENTIFIER.
          END E1;                  -- OK.

     END T;

BEGIN
     NULL;
END B95006A;
