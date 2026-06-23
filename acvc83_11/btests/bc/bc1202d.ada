-- BC1202D.ADA

-- CHECK THAT A GENERIC FORMAL TYPE PARAMETER CANNOT HAVE A 
-- DERIVED TYPE DEFINITION.

-- ASL 8/7/81
-- SPS 4/19/82

PROCEDURE BC1202D IS
 
     GENERIC
          TYPE T IS RANGE <>;                -- OK.
          TYPE DER IS NEW INTEGER;           -- ERROR: DERIVED TYPE.
          V1 : T := 0;                       -- OK.
          V2 : T;                            -- OK.
     PACKAGE P IS
     END P;
BEGIN
     NULL;
END BC1202D;
