-- B24104A.ADA

-- CHECK THAT DECIMAL INTEGER LITERALS MUST NOT HAVE 
-- NEGATIVE EXPONENTS (INCLUDING -0).

-- PWB  2/14/86

PROCEDURE B24104A IS

     TYPE FLOATING_1 IS DIGITS 2E-1;                 -- ERROR: NEG EXP.
     TYPE FLOATING_2 IS DIGITS 5E-0;                 -- ERROR: -0 EXP.
     TYPE SMALL_INT_1 IS RANGE -10 .. 10E-1;         -- ERROR: NEG EXP.
     TYPE SMALL_INT_2 IS RANGE -10 .. 1E-0;          -- ERROR: -0 EXP.
     TYPE REC_TYPE_1 (DISC : INTEGER := 5E-2) IS     -- ERROR: NEG EXP.
          RECORD
               NULL;
          END RECORD;
     TYPE REC_TYPE_2 (DISC : INTEGER := 5E-0) IS     -- ERROR: -0 EXP.
          RECORD
               NULL;
          END RECORD;

     TYPE ARR_TYPE IS 
          ARRAY (INTEGER RANGE <>) OF BOOLEAN;

     ARR_1 : ARR_TYPE (1..10E-1);                    -- ERROR: NEG EXP.
     ARR_2 : ARR_TYPE (1..10E-0);                    -- ERROR: -0 EXP.
     CON   : CONSTANT INTEGER := 4E-1;               -- ERROR: NEG EXP.
     VAR   : INTEGER := 4E-0;                        -- ERROR: -0 EXP.

     I1, I2, I3 : INTEGER := 0;
     C1 : CHARACTER := 'A';

BEGIN

     IF I1 > 2E-1 OR                                 -- ERROR: NEG EXP.
        I1 < 2E-0                                    -- ERROR: -0 EXP.
     THEN
          I2 := 3E-2;                                -- ERROR: NEG EXP.
          I3 := 3E-0;                                -- ERROR: -0 EXP.
     ELSE
          I2 := I1 + 5E-2;                           -- ERROR: NEG EXP.
          I3 := I1 * 5E-0;                           -- ERROR: -0 EXP.
     END IF;

     CASE I1 IS
          WHEN 12E-2 =>                              -- ERROR: NEG EXP.
               C1 := CHARACTER'VAL(65E-1);           -- ERROR: NEG EXP.
          WHEN 15E-0 =>                              -- ERROR: -0 EXP.
               C1 := CHARACTER'VAL(65E-0);           -- ERROR: -0 EXP.
          WHEN OTHERS =>
               NULL;
     END CASE;

END B24104A;
