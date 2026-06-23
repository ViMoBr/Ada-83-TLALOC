-- BC1013A.ADA

-- CHECK THAT OPERATOR_SYMBOLS MAY NOT BE USED AS THE NAMES OF GENERIC
-- SUBPROGRAMS.

-- DAT 9/15/81
-- SPS 10/18/82
-- JBG 5/29/85
-- JRK 6/24/86   REVISED SO THAT TYPE LP IS LIMITED AT THE BODY OF "=".

PROCEDURE BC1013A IS

     PACKAGE TYPES IS

          TYPE LP IS LIMITED PRIVATE;
          TYPE T IS RANGE 1..10;

     PRIVATE

          TYPE LP IS NEW INTEGER;

     END TYPES;

     USE TYPES;

     PACKAGE PACK IS

          GENERIC
          FUNCTION "NOT" (X : BOOLEAN) RETURN     -- ERROR: "NOT".
                         BOOLEAN;

          GENERIC
          FUNCTION "AND" (X, Y : BOOLEAN) RETURN  -- ERROR: "AND".
                         BOOLEAN;

          GENERIC
               TYPE T IS (<>);
          FUNCTION "-" (X : T) RETURN T;          -- ERROR: "-".

          GENERIC
               TYPE T IS (<>);
          FUNCTION "*" (X, Y : T) RETURN T;       -- ERROR: "*".

          GENERIC
               TYPE T IS (<>);
          FUNCTION "MOD" (X, Y : T) RETURN T;     -- ERROR: "MOD".

          GENERIC
               TYPE T IS (<>);
          FUNCTION "ABS" (X : T) RETURN T;        -- ERROR: "ABS".

          GENERIC
               TYPE T IS (<>);
          FUNCTION "**" (X : T; Y : INTEGER)      -- ERROR: "**".
                        RETURN T;

          GENERIC
          FUNCTION "&" (X, Y : STRING) RETURN     -- ERROR: "&".
                    STRING;

          GENERIC
               TYPE LP IS LIMITED PRIVATE;
          FUNCTION "=" (X,Y : LP) RETURN BOOLEAN; -- ERROR: "=".

          GENERIC
          FUNCTION "<" (X,Y: STRING) RETURN       -- ERROR: "<".
                       BOOLEAN;

          GENERIC
          FUNCTION ">=" (X, Y : DURATION) RETURN  -- ERROR: ">=".
                        BOOLEAN;

          GENERIC
               TYPE T IS (<>);
          FUNCTION "/" (X, Y : T) RETURN T;       -- ERROR: "/".

     END PACK;

     PACKAGE BODY PACK IS

          FUNCTION "NOT" (X : BOOLEAN) RETURN BOOLEAN IS
          BEGIN RETURN FALSE; END;

          FUNCTION "AND" (X, Y : BOOLEAN) RETURN BOOLEAN IS
          BEGIN RETURN FALSE; END;

          FUNCTION "-" (X : T) RETURN T IS
          BEGIN RETURN T'FIRST; END;

          FUNCTION "*" (X, Y : T) RETURN T IS
          BEGIN RETURN T'LAST; END;

          FUNCTION "MOD" (X, Y : T) RETURN T IS
          BEGIN RETURN X; END;

          FUNCTION "ABS" (X : T) RETURN T IS
          BEGIN RETURN T'FIRST; END;

          FUNCTION "**" (X : T; Y : INTEGER) RETURN T IS
          BEGIN RETURN X; END;

          FUNCTION "&" (X, Y : STRING) RETURN STRING IS
          BEGIN RETURN ""; END;

          FUNCTION "=" (X, Y : LP) RETURN BOOLEAN IS
          BEGIN RETURN FALSE; END;

          FUNCTION "<" (X, Y : STRING) RETURN BOOLEAN IS
          BEGIN RETURN TRUE; END;

          FUNCTION ">=" (X, Y : DURATION) RETURN BOOLEAN IS
          BEGIN RETURN FALSE; END;

          FUNCTION "/" (X, Y : T) RETURN T IS
          BEGIN RETURN T'LAST; END;

     END PACK;

BEGIN
     NULL;
END BC1013A;
