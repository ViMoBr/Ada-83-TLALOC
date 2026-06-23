-- BC1202B.ADA

-- CHECK THAT A GENERIC FORMAL TYPE PARAMETER CANNOT HAVE A 
-- DERIVED TYPE DEFINITION.

-- ASL 8/7/81
-- SPS 4/19/82

PROCEDURE BC1202B IS
 
     GENERIC
          TYPE T IS RANGE <>;                -- OK.
          TYPE N_T IS NEW T;                 -- ERROR: DERIVED TYPE.
          V1 : T := 0;                       -- OK.
          V2 : T;                            -- OK.
     PACKAGE P IS
     END P;
BEGIN
     NULL;
END BC1202B;
