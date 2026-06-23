-- B24009A.ADA

-- CHECK THAT INTEGER LITERALS MUST NOT HAVE POINTS
-- (BOTH BASED AND DECIMAL).

-- PWB  2/14/86

PROCEDURE B24009A IS

     TYPE FLOATING_1 IS DIGITS 5.;                   -- ERROR: 5.
     TYPE FLOATING_2 IS DIGITS 5.0;                  -- ERROR: 5.0
     TYPE SMALL_INT_1 IS RANGE 0. .. 10;             -- ERROR: 0.
     TYPE SMALL_INT_2 IS RANGE 0.0 .. 10;            -- ERROR: 0.0
     TYPE REC_TYPE_1 (DISC : INTEGER := 5.E2) IS     -- ERROR: 5.
          RECORD
               NULL;
          END RECORD;
     TYPE REC_TYPE_2 (DISC : INTEGER := 5.0E2) IS    -- ERROR: 5.0
          RECORD
               NULL;
          END RECORD;

     TYPE ARR_TYPE IS 
          ARRAY (INTEGER RANGE <>) OF BOOLEAN;

     ARR_1 : ARR_TYPE (1..10.);                      -- ERROR: 10.
     ARR_2 : ARR_TYPE (1..10.0);                     -- ERROR: 10.0
     CON   : CONSTANT INTEGER := 3E4.;               -- ERROR: 4.
     VAR   : INTEGER := 3E4.0;                       -- ERROR: 4.0

     I1, I2, I3 : INTEGER := 0;
     C1 : CHARACTER := 'A';

BEGIN

     IF I1 > 2.#101# OR                              -- ERROR: 2.
        I1 < 2.0#101#                                -- ERROR: 2.0
     THEN
          I2 := 3#12.#E2;                            -- ERROR: 12.
          I3 := 3#12.0#E2;                           -- ERROR: 12.0
     ELSE
          I2 := I1 + 4#10#E1.;                       -- ERROR: 1.
          I3 := I1 * 4#10#E1.0;                      -- ERROR: 1.0
     END IF;

     CASE I1 IS
          WHEN 12.0 =>                               -- ERROR: 12.0
               C1 := CHARACTER'VAL(65.);             -- ERROR: 65.
          WHEN 10.E2 =>                              -- ERROR: 10.
               C1 := CHARACTER'VAL(66.0);            -- ERROR: 66.0
          WHEN OTHERS =>
               C1 := CHARACTER'VAL(8#10.#E2);        -- ERROR: 10.
     END CASE;

END B24009A;
