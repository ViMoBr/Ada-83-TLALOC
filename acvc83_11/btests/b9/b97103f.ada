-- B97103F.ADA

-- CHECK THAT WITHIN AN ACCEPT STATEMENT AN ENCLOSED SELECTIVE WAIT
-- STATEMENT CANNOT CONTAIN AN ACCEPT STATEMENT THAT NAMES THE SINGLE
-- ENTRY SPECIFIED IN THE OUTSIDE ACCEPT STATEMENT.

-- TBN 2/3/86

PROCEDURE B97103F IS

     TASK T1 IS
          ENTRY E;
     END T1;

     TASK BODY T1 IS
     BEGIN
          ACCEPT E DO
               SELECT
                    ACCEPT E;               -- ERROR: ACCEPT E.
               OR
                    TERMINATE;
               END SELECT;
          END E;
     END T1;

     -------------------------------------------------------------------

     TASK T2 IS
          ENTRY FRED;
          ENTRY JOE;
     END T2;

     TASK BODY T2 IS

          FLAG : BOOLEAN := TRUE;

     BEGIN
          ACCEPT FRED DO
               SELECT
                    WHEN NOT (FLAG) =>
                         ACCEPT JOE;
               ELSE
                    IF FLAG THEN
                         ACCEPT FRED;        -- ERROR: ACCEPT FRED.
                    END IF;
               END SELECT;
          END FRED;
     END T2;

BEGIN
     NULL;
END B97103F;
