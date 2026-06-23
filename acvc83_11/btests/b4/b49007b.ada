-- B49007B.ADA

-- OBJECTIVE:
--     CHECK THAT A CONSTANT DECLARED BY AN OBJECT DECLARATION CANNOT
--     BE USED IN A STATIC EXPRESSION IF THE SUBTYPE USED IN THE
--     DECLARATION WAS NONSTATIC, OR IF THE CONSTANT WAS INITIALIZED
--     WITH A NONSTATIC EXPRESSION.

-- HISTORY:
--     JET 08/16/88  CREATED ORIGINAL TEST.

PROCEDURE B49007B IS

     TYPE ARR1 IS ARRAY (0..10) OF BOOLEAN;

     I : INTEGER := 0;

     C1 : CONSTANT INTEGER := ARR1'FIRST;
     C2 : CONSTANT INTEGER := I;

     TYPE INT1 IS RANGE C1 .. 100;           -- ERROR: NONSTATIC TYPE.
     TYPE INT2 IS RANGE C2 .. 100;           -- ERROR: NONSTATIC INIT.

     TYPE REC1(D : INTEGER) IS RECORD
          CASE D IS
               WHEN C1 =>                    -- ERROR: NONSTATIC TYPE.
                    I : INTEGER;
               WHEN C2 =>                    -- ERROR: NONSTATIC INIT.
                    J : INTEGER;
               WHEN OTHERS =>
                    K : INTEGER;
          END CASE;
     END RECORD;

     TYPE REC2(D : INTEGER := 0) IS RECORD
          CASE D IS
               WHEN 1 => I : INTEGER;
               WHEN OTHERS => J : INTEGER;
          END CASE;
     END RECORD;

     R1 : REC2 := (D => C1, J => 1);         -- ERROR: NONSTATIC TYPE.
     R2 : REC2 := (D => C2, J => 1);         -- ERROR: NONSTATIC INIT.

BEGIN
     CASE INTEGER(1) IS
          WHEN C1 => NULL;                   -- ERROR: NONSTATIC TYPE.
          WHEN C2 => NULL;                   -- ERROR: NONSTATIC INIT.
          WHEN OTHERS => NULL;
     END CASE;
END B49007B;
