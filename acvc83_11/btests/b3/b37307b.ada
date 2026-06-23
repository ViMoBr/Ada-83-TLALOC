-- B37307B.ADA

-- OBJECTIVE:
--     CHECK THAT RELATIONAL AND LOGICAL OPERATORS ARE NOT
--     ALLOWED IN CHOICES OF A VARIANT PART OF A RECORD IF THE
--     EXPRESSIONS CONTAINING THESE OPERATORS ARE NOT ENCLOSED IN
--     PARENTHESES.

-- HISTORY:
--     ASL 07/09/81
--     JBG 06/16/83
--     DHH 08/16/88 REVISED HEADER AND REPLACED 'OR ELSE' CLAUSE.

PROCEDURE B37307B IS

     T : CONSTANT BOOLEAN := TRUE;
     F : CONSTANT BOOLEAN := FALSE;

     TYPE REC1(DISC : BOOLEAN) IS
          RECORD
               COMP : INTEGER;
               CASE DISC IS
                    WHEN 3 < 5 => NULL;       -- ERROR: NO PARENS.
                    WHEN OTHERS => NULL;
               END CASE;
          END RECORD;

     TYPE REC3(DISC : BOOLEAN) IS
          RECORD
               COMP : INTEGER;
               CASE DISC IS
                    WHEN T AND F => NULL;     -- ERROR: NO PARENS.
                    WHEN T XOR F => NULL;     -- ERROR: NO PARENS.
                    WHEN OTHERS => NULL;
               END CASE;
          END RECORD;

     TYPE REC4(DISC : BOOLEAN) IS
          RECORD
               COMP : INTEGER;
               CASE DISC IS
                    WHEN NOT (T AND F) =>     -- OK.
                         NULL;
                    WHEN NOT T => NULL;       -- OK.
               END CASE;
          END RECORD;

BEGIN
     NULL;
END B37307B;
