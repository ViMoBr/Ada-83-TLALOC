-- B54A12A.ADA

-- OBJECTIVE:
--     CHECK THAT WHEN THE CASE EXPRESSION IS THE NAME OF A CONSTANT
--     OR VARIABLE HAVING A STATIC SUBTYPE, OR IS A QUALIFIED
--     EXPRESSION OR TYPE CONVERSION WITH A STATIC SUBTYPE, NO CHOICE
--     MAY HAVE A VALUE OUTSIDE THE SUBTYPE'S RANGE.

-- HISTORY:
--     BCB 02/29/88  CREATED ORIGINAL TEST.

PROCEDURE B54A12A IS

     SUBTYPE INT IS INTEGER RANGE 1 .. 100;

     A : INT;
     B : CONSTANT INT := 50;
     C : INTEGER;

BEGIN
     CASE A IS
          WHEN 0 => NULL;                -- ERROR: OUTSIDE RANGE OF
                                         --        VARIABLE'S SUBTYPE.
          WHEN 100 => NULL;              -- OK.
          WHEN OTHERS => NULL;           -- OK.
     END CASE;

     CASE A IS
          WHEN 1 => NULL;                -- OK.
          WHEN 101 => NULL;              -- ERROR: OUTSIDE RANGE OF
                                         --        VARIABLE'S SUBTYPE.
          WHEN OTHERS => NULL;           -- OK.
     END CASE;

     CASE B IS
          WHEN 0 => NULL;                -- ERROR: OUTSIDE RANGE OF
                                         --        CONSTANT'S SUBTYPE.
          WHEN 100 => NULL;              -- OK.
          WHEN OTHERS => NULL;           -- OK.
     END CASE;

     CASE B IS
          WHEN 1 => NULL;                -- OK.
          WHEN 101 => NULL;              -- ERROR: OUTSIDE RANGE OF
                                         --        CONSTANT'S SUBTYPE.
          WHEN OTHERS => NULL;           -- OK.
     END CASE;

     CASE INT'(50) IS
          WHEN 0 => NULL;                -- ERROR: OUTSIDE RANGE OF
                                         --        QUALIFIER'S SUBTYPE.
          WHEN 100 => NULL;              -- OK.
          WHEN OTHERS => NULL;           -- OK.
     END CASE;

     CASE INT'(50) IS
          WHEN 1 => NULL;                -- OK.
          WHEN 101 => NULL;              -- ERROR: OUTSIDE RANGE OF
                                         --        QUALIFIER'S SUBTYPE.
          WHEN OTHERS => NULL;           -- OK.
     END CASE;

     CASE INT(C) IS
          WHEN 0 => NULL;                -- ERROR: OUTSIDE RANGE OF
                                         --        CONVERSION'S SUBTYPE.
          WHEN 100 => NULL;              -- OK.
          WHEN OTHERS => NULL;           -- OK.
     END CASE;

     CASE INT(C) IS
          WHEN 1 => NULL;                -- OK.
          WHEN 101 => NULL;              -- ERROR: OUTSIDE RANGE OF
                                         --        CONVERSION'S SUBTYPE.
          WHEN OTHERS => NULL;           -- OK.
     END CASE;

END B54A12A;
