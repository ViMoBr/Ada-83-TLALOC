-- BC1101A.ADA

-- CHECK THAT PARAMETER DECLARATIONS IN GENERIC PARTS CANNOT HAVE
-- THE MODE OUT.
 
-- ASL 8/6/81
 
PROCEDURE BC1101A IS
 
     GENERIC
          P1 : IN INTEGER;                    -- OK.
          P2 : INTEGER;                       -- OK.
          P3 : OUT INTEGER;                   -- ERROR: OUT.
          P4 : IN OUT INTEGER;                -- OK.
     PACKAGE P IS
     END P;

BEGIN
     NULL;
END BC1101A;
