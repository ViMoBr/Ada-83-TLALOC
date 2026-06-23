-- BC1201H.ADA

-- CHECK THAT AN INDEX CONSTRAINT IS NOT ALLOWED ON A COMPONENT
-- TYPE SPECIFICATION IN A GENERIC FORMAL ARRAY TYPE DECLARATION.

-- PWB  2/10/86

PROCEDURE BC1201H IS

     TYPE B_I IS 
          ARRAY (INTEGER RANGE <>) OF BOOLEAN;
     TYPE I_B IS 
          ARRAY (BOOLEAN RANGE <>) OF INTEGER;
     TYPE ENUM IS (ONE, TWO, THREE);
     TYPE I_B_ENUM IS 
          ARRAY (BOOLEAN RANGE <>, ENUM RANGE <>) 
          OF INTEGER;

     GENERIC
          TYPE B_I_ARRAY IS 
               ARRAY (ENUM RANGE <>) OF 
                    B_I (1..5);                   -- ERROR: CONSTRAINT.
          TYPE STRING_ARRAY IS
               ARRAY (BOOLEAN RANGE <>) OF 
                    STRING(1..20);                -- ERROR: CONSTRAINT.
     PROCEDURE GEN_PROC (X : INTEGER);

     GENERIC
          TYPE I_B_ARRAY IS
               ARRAY (ENUM RANGE <>) OF
                    I_B (BOOLEAN);                -- ERROR: CONSTRAINT.
          TYPE I_B_E_ARRAY IS
               ARRAY (INTEGER RANGE <>) OF 
                    I_B_ENUM (TRUE..TRUE, 
                         ENUM'FIRST..ENUM'LAST);  -- ERROR: CONSTRAINT.
     FUNCTION GEN_FUNC (X : INTEGER) 
                       RETURN BOOLEAN;

     GENERIC
          TYPE NULL_ENTRIES IS 
               ARRAY (BOOLEAN RANGE <>) OF 
                    I_B (TRUE..FALSE);            -- ERROR: CONSTRAINT.
     PACKAGE GEN_PACK IS
     END GEN_PACK;

     PROCEDURE GEN_PROC (X : INTEGER) IS
     BEGIN
          NULL;
     END GEN_PROC;

     FUNCTION GEN_FUNC (X : INTEGER) RETURN BOOLEAN IS
     BEGIN
          RETURN (X=5);
     END GEN_FUNC;

BEGIN    -- BC1201H
     NULL;
END BC1201H;
