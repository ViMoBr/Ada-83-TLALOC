-- BC1201I.ADA

-- CHECK THAT A DISCRIMINANT CONSTRAINT IS NOT ALLOWED ON A COMPONENT
-- TYPE SPECIFICATION IN A GENERIC FORMAL ARRAY TYPE DECLARATION.

-- PWB  2/10/86

PROCEDURE BC1201I IS

     TYPE REC_1 (DISC : INTEGER) IS
          RECORD
               NULL;
          END RECORD;

     TYPE REC_2 (DISC : INTEGER := 1) IS
          RECORD
               NULL;
          END RECORD;

     GENERIC
          TYPE ARRAY_1 IS 
               ARRAY (INTEGER RANGE <>) OF 
                    REC_1 (5);                  -- ERROR: CONSTRAINT.
          TYPE ARRAY_2 IS
               ARRAY (BOOLEAN RANGE <>) OF 
                   REC_2 (1);                   -- ERROR: CONSTRAINT.
     PROCEDURE GEN_PROC (X : INTEGER);

     GENERIC
          TYPE ARRAY_1 IS
               ARRAY (BOOLEAN RANGE <>) OF 
                    REC_1 (DISC => 5);          -- ERROR: CONSTRAINT.
          TYPE ARRAY_2 IS
               ARRAY (INTEGER RANGE <>) OF 
                    REC_2 (DISC => 1);          -- ERROR: CONSTRAINT.
     FUNCTION GEN_FUNC (X : INTEGER) 
                       RETURN BOOLEAN;

     GENERIC
          TYPE ARRAY_1 IS
               ARRAY (CHARACTER RANGE <>) OF
                    REC_1(4);                   -- ERROR: CONSTRAINT.
          TYPE ARRAY_2 IS
               ARRAY (BOOLEAN RANGE <>) OF 
                    REC_2 (DISC => 3);          -- ERROR: CONSTRAINT.
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

BEGIN    -- BC1201I
     NULL;
END BC1201I;
