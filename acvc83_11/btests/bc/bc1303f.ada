-- BC1303F.ADA

-- CHECK THAT ":=" CANNOT BE USED AS A GENERIC FORMAL PARAMETER.

-- PWB  2/11/86

PROCEDURE BC1303F IS

     SUBTYPE BASE IS INTEGER;

     GENERIC
          TYPE BASE IS PRIVATE;
          WITH PROCEDURE ":=" (FROM : IN BASE;          -- ERROR: ":="
                               TO   : OUT BASE);
     PROCEDURE GEN_PROC (X : BASE; Y : OUT BASE);

     GENERIC
          WITH FUNCTION ":=" (X, Y : INTEGER)           -- ERROR: ":="
                        RETURN BOOLEAN IS "<";
     PACKAGE GEN_PACK IS
     END GEN_PACK;

     GENERIC
          TYPE BASE IS (<>);
          WITH PROCEDURE ":=" (FROM : IN BASE;          -- ERROR: ":="
                               TO : OUT BASE) IS <>;
     FUNCTION GEN_FUNC (X : BASE) RETURN BOOLEAN;

     PROCEDURE GEN_PROC (X : BASE; Y : OUT BASE) IS
     BEGIN
          NULL;
     END GEN_PROC;

     FUNCTION GEN_FUNC (X : BASE) RETURN BOOLEAN IS
     BEGIN
          RETURN (X = BASE'FIRST);
     END GEN_FUNC;

BEGIN    -- BC1303F
     NULL;
END BC1303F;
