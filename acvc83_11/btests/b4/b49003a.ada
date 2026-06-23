-- B49003A.ADA

-- OBJECTIVE:
--     CHECK THAT A STATIC EXPRESSION IS NOT ALLOWED TO CONTAIN A
--     MEMBERSHIP TEST OR A SHORT-CIRCUIT CONTROL FORM.

-- HISTORY:
--     RJW 2/12/86  CREATED ORIGINAL TEST.
--     SDA 8/31/88  REVISED CODE SO THAT THERE
--                  IS ONLY ONE ERROR PER AGGREGATE.

PROCEDURE B49003A IS

BEGIN
     DECLARE
          SUBTYPE ST IS INTEGER RANGE 1 .. 5;
          B      : BOOLEAN          := TRUE;
          B1, B2 : CONSTANT BOOLEAN := TRUE;

          TYPE INT_RANGE  IS
               RANGE 1 .. BOOLEAN'POS (B1 AND THEN B2); -- ERROR:
                                                -- SHORT-CIRCUIT.
          TYPE INT_RANGE2 IS
               RANGE BOOLEAN'POS (B1 OR ELSE B2) .. 5;  -- ERROR:
                                                -- SHORT-CIRCUIT.
          TYPE INT_RANGE3 IS
               RANGE BOOLEAN'POS (4 IN ST) .. 3;        -- ERROR:
                                                -- MEMBERSHIP TEST.
          TYPE INT_RANGE4 IS
               RANGE 5 .. BOOLEAN'POS (4 NOT IN ST);    -- ERROR:
                                                -- MEMBERSHIP TEST.

          TYPE ARR IS ARRAY (BOOLEAN) OF INTEGER;

          A1 : ARR:= ARR'((TRUE AND THEN FALSE)  => 1,   -- ERROR:
                                                 -- SHORT-CIRCUIT.
                          OTHERS                 => 2);
          A2 : ARR:= ARR'((TRUE OR  ELSE FALSE)  => 1,   -- ERROR:
                                                 -- SHORT-CIRCUIT.
                          OTHERS                 => 2);
          A3 : ARR:= ARR'((TRUE IN BOOLEAN)      => 1,   -- ERROR:
                                                -- MEMBERSHIP TEST.
                          OTHERS                 => 2);
          A4 : ARR:= ARR'((TRUE NOT IN BOOLEAN) => 1,    -- ERROR:
                                                -- MEMBERSHIP TEST.
                          OTHERS                 => 2);

          TYPE R (B : BOOLEAN) IS
               RECORD
                    CASE B IS
                         WHEN (B1 OR ELSE B2) =>         -- ERROR:
                                                 -- SHORT-CIRCUIT.
                              NULL;
                         WHEN (B1 AND THEN FALSE) =>     -- ERROR:
                                                 -- SHORT-CIRCUIT.
                              NULL;
                         WHEN OTHERS =>
                              NULL;
                    END CASE;
               END RECORD;

          TYPE S (B : BOOLEAN) IS
               RECORD
                    CASE B IS
                         WHEN (4 IN ST) =>               -- ERROR:
                                                -- MEMBERSHIP TEST.
                              NULL;
                         WHEN (4 NOT IN ST) =>           -- ERROR:
                                                -- MEMBERSHIP TEST.
                               NULL;
                         WHEN OTHERS =>
                              NULL;
                    END CASE;
               END RECORD;

          TYPE T (B : BOOLEAN) IS
               RECORD
                    CASE B IS
                         WHEN TRUE =>
                              B1 : BOOLEAN;
                         WHEN FALSE =>
                              B2 : BOOLEAN;
                    END CASE;
               END RECORD;

          B7 : T (TRUE)  := (B1 AND THEN B2, TRUE);      -- ERROR:
                                                 -- SHORT-CIRCUIT.

          B8 : T (FALSE) := (4 NOT IN ST, FALSE);         -- ERROR:
                                                -- MEMBERSHIP TEST.

     BEGIN
          CASE B IS
               WHEN (B1 AND THEN FALSE) =>               -- ERROR:
                                                 -- SHORT-CIRCUIT.
                    NULL;
               WHEN (B1 OR ELSE B2) =>                   -- ERROR:
                                                 -- SHORT-CIRCUIT.
                    NULL;
               WHEN OTHERS =>
                    NULL;
          END CASE;

          CASE B IS
               WHEN (4 IN ST) =>                         -- ERROR:
                                                -- MEMBERSHIP TEST.
                    NULL;
               WHEN (4 NOT IN ST) =>                     -- ERROR:
                                                -- MEMBERSHIP TEST.
                    NULL;
               WHEN OTHERS =>
                    NULL;
          END CASE;
     END;

END B49003A;
