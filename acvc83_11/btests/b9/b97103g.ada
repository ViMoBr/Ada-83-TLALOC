-- B97103G.ADA

-- CHECK THAT WITHIN AN ACCEPT STATEMENT AN ENCLOSED SELECTIVE WAIT
-- STATEMENT CANNOT CONTAIN AN ACCEPT STATEMENT THAT NAMES THE ENTRY
-- FAMILY SPECIFIED IN THE OUTSIDE ACCEPT STATEMENT.

-- TBN 2/3/86

PROCEDURE B97103G IS

     TASK T1 IS
          ENTRY E (1 .. 3);
     END T1;

     TASK BODY T1 IS
     BEGIN
          ACCEPT E(2) DO
               SELECT
                    ACCEPT E(2);               -- ERROR: ACCEPT E(2).
               OR
                    TERMINATE;
               END SELECT;
          END E;
     END T1;

     -------------------------------------------------------------------

     TASK T2 IS
          ENTRY FRED (1 .. 2);
     END T2;

     TASK BODY T2 IS

          FLAG : BOOLEAN := TRUE;

     BEGIN
          ACCEPT FRED(1) DO
               SELECT
                    WHEN NOT (FLAG) =>
                         ACCEPT FRED(2);       -- ERROR: ACCEPT FRED(2).
               ELSE
                    IF FLAG THEN
                         ACCEPT FRED(1);       -- ERROR: ACCEPT FRED(1).
                    END IF;
               END SELECT;
          END FRED;
     END T2;

BEGIN
     NULL;
END B97103G;
