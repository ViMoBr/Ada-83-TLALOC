-- B67001A.ADA

-- OBJECTIVE:
--     CHECK THAT CERTAIN FUNCTION DECLARATIONS WITH
--     OPERATOR SYMBOLS ARE NOT ALLOWED.  IN
--     PARTICULAR, THE FOLLOWING SUBTESTS ARE
--     PERFORMED:
--     (A)  CHECK THAT "IN", "NOT IN", "AND THEN",
--          "OR ELSE", AND "/=" ARE NOT
--          PERMITTED AS OPERATOR SYMBOLS.
--     (B)  CHECK THAT FUNCTIONS FOR "AND", "OR",
--          "XOR", "=", "<=", "<", ">=", ">", "&",
--          "*", "/", "MOD", "REM", AND "**" CANNOT
--          BE DECLARED WITH ONE PARAMETER.
--     (C)  CHECK THAT THE SAME OPERATOR SYMBOLS
--          AS LISTED IN (B) CANNOT BE DECLARED
--          AS FUNCTIONS WITH THREE PARAMETERS.
--     (D)  CHECK THAT FUNCTIONS FOR "NOT" AND "ABS" CANNOT
--          BE DECLARED WITH TWO PARAMETERS.
--     (E)  CHECK THAT FUNCTIONS FOR "+",  "-", "NOT", AND "ABS" CANNOT
--          BE DECLARED WITH ZERO PARAMETERS.
--     (F)  CHECK THAT FUNCTIONS FOR "+" AND "-"
--          CANNOT BE DECLARED WITH THREE PARAMETERS.
--     (G)  CHECK THAT DEFAULT PARAMETERS CANNOT
--          BE SPECIFIED FOR OPERATOR SYMBOL FUNCTIONS.
--     (H)  CHECK THAT NO LEADING OR TRAILING BLANKS ARE ALLOWED.

-- HISTORY:
--     CVP 05/12/81
--     JBG 08/21/83
--     CPP 06/08/84
--     JRK 12/04/84
--     JBG 05/20/85
--     DWC 09/22/87  MOVED CHECK THAT ":=" IS NOT ALLOWED
--                   TO B67001H.ADA.

PROCEDURE B67001A IS
     PACKAGE P IS
          TYPE LIM_PRIV IS LIMITED PRIVATE;
     PRIVATE
          TYPE LIM_PRIV IS NEW INTEGER;
     END P;
     USE P;

BEGIN

     --------------------------------------------------

     DECLARE -- (A)

          FUNCTION "IN" (I1, I2, I3 : INTEGER)        -- ERROR: IN
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "IN";

          FUNCTION "NOT IN" (I1, I2, I3 : INTEGER)    -- ERROR: NOT IN
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "NOT IN";

          FUNCTION "AND THEN" (B1, B2 : BOOLEAN)      -- ERROR: AND THEN
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "AND THEN";

          FUNCTION "OR ELSE" (B1, B2 : BOOLEAN)       -- ERROR: OR ELSE
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "OR ELSE";

          FUNCTION "/=" (I1, I2: LIM_PRIV)            -- ERROR: /=
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "/=";

     BEGIN -- (A)
          NULL;
     END; -- (A)

     --------------------------------------------------

     DECLARE -- (B)

          FUNCTION "AND" (B1 : BOOLEAN)               -- ERROR: TOO FEW
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "AND";

          FUNCTION "OR" (B1 : BOOLEAN)                -- ERROR: TOO FEW
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "OR";

          FUNCTION "XOR" (B1 : BOOLEAN)               -- ERROR: TOO FEW
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "XOR";

          FUNCTION "=" (B1 : LIM_PRIV)                -- ERROR: TOO FEW
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "=";

          FUNCTION "<=" (B1 : BOOLEAN)                -- ERROR: TOO FEW
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "<=";

          FUNCTION "<" (B1 : BOOLEAN)                 -- ERROR: TOO FEW
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "<";

          FUNCTION ">=" (B1 : BOOLEAN)                -- ERROR: TOO FEW
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END ">=";

          FUNCTION ">" (B1 : BOOLEAN)                 -- ERROR: TOO FEW
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END ">";

          FUNCTION "&" (B1 : BOOLEAN)                 -- ERROR: TOO FEW
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "&";

          FUNCTION "*" (B1 : BOOLEAN)                 -- ERROR: TOO FEW
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "*";

          FUNCTION "/" (B1 : BOOLEAN)                 -- ERROR: TOO FEW
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "/";

          FUNCTION "MOD" (B1 : BOOLEAN)               -- ERROR: TOO FEW
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "MOD";

          FUNCTION "REM" (B1 : BOOLEAN)               -- ERROR: TOO FEW
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "REM";

          FUNCTION "**" (B1 : BOOLEAN)                -- ERROR: TOO FEW
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "**";

     BEGIN -- (B)
          NULL;
     END; -- (B)

     --------------------------------------------------

     DECLARE -- (C)

          FUNCTION "AND" (B1, B2, B3 : BOOLEAN)       -- ERROR: TOO MANY
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "AND";

          FUNCTION "OR" (B1, B2, B3: BOOLEAN)         -- ERROR: TOO MANY
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "OR";

          FUNCTION "XOR" (B1, B2, B3 : BOOLEAN)       -- ERROR: TOO MANY
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "XOR";

          FUNCTION "=" (B1, B2, B3 : LIM_PRIV)        -- ERROR: TOO MANY
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "=";

          FUNCTION "<=" (B1, B2, B3 : BOOLEAN)        -- ERROR: TOO MANY
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "<=";

          FUNCTION "<" (B1, B2, B3 : BOOLEAN)         -- ERROR: TOO MANY
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "<";

          FUNCTION ">=" (B1, B2, B3 : BOOLEAN)        -- ERROR: TOO MANY
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END ">=";

          FUNCTION ">" (B1, B2, B3 : BOOLEAN)         -- ERROR: TOO MANY
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END ">";

          FUNCTION "&" (B1, B2, B3 : BOOLEAN)         -- ERROR: TOO MANY
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "&";

          FUNCTION "*" (B1, B2, B3 : BOOLEAN)         -- ERROR: TOO MANY
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "*";

          FUNCTION "/" (B1, B2, B3 : BOOLEAN)         -- ERROR: TOO MANY
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "/";

          FUNCTION "MOD" (B1, B2, B3 : BOOLEAN)       -- ERROR: TOO MANY
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "MOD";

          FUNCTION "REM" (B1, B2, B3 : BOOLEAN)       -- ERROR: TOO MANY
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "REM";

          FUNCTION "**" (B1, B2, B3 : BOOLEAN)        -- ERROR: TOO MANY
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "**";

     BEGIN -- (C)
          NULL;
     END; -- (C)

     ---------------------------------------------------

     DECLARE -- (D)

          FUNCTION "NOT" (B1, B2 : BOOLEAN)           -- ERROR: TOO MANY
                                                      -- PARAMETERS.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "NOT";

          FUNCTION "ABS" (I1, I2 : INTEGER)           -- ERROR: TOO MANY
                                                      -- PARAMETERS.
               RETURN INTEGER IS
          BEGIN
               RETURN 3;
          END "ABS";

     BEGIN -- (D)
          NULL;
     END; -- (D)

     --------------------------------------------------

     DECLARE -- (E)

          FUNCTION "+" RETURN INTEGER IS              -- ERROR: TOO FEW
                                                      -- PARAMETERS.
          BEGIN
               RETURN 0;
          END "+";

          FUNCTION "-" RETURN INTEGER IS              -- ERROR: TOO FEW
                                                      -- PARAMETERS.
          BEGIN
               RETURN 0;
          END "-";

          FUNCTION "NOT" RETURN BOOLEAN IS            -- ERROR: TOO FEW
                                                      -- PARAMETERS.
          BEGIN
               RETURN TRUE;
          END "NOT";

          FUNCTION "ABS" RETURN INTEGER IS            -- ERROR: TOO FEW
                                                      -- PARAMETERS.
          BEGIN
               RETURN 0;
          END "ABS";

     BEGIN -- (E)
          NULL;
     END; -- (E)

     --------------------------------------------------

     DECLARE -- (F)

          FUNCTION "+" (I1, I2, I3 : INTEGER)         -- ERROR: TOO MANY
                                                      -- PARAMETERS.
               RETURN INTEGER IS
          BEGIN
               RETURN 0;
          END "+";

          FUNCTION "-" (I1, I2, I3 : INTEGER)         -- ERROR: TOO MANY
                                                      -- PARAMETERS.
                RETURN INTEGER IS
          BEGIN
               RETURN 0;
          END "-";

     BEGIN -- (F)
          NULL;
     END; -- (F)

     --------------------------------------------------

     DECLARE -- (G)

          FUNCTION "+" (I1, I2: INTEGER := 0)         -- ERROR: := 0
               RETURN INTEGER IS
          BEGIN
               RETURN 0;
          END "+";

     BEGIN -- (G)
          NULL;
     END; -- (G)

     --------------------------------------------------

     DECLARE -- (H)

          FUNCTION " +" (I1, I2: INTEGER)            -- ERROR: " +"
               RETURN INTEGER IS
          BEGIN
               RETURN 0;
          END " +";

          FUNCTION "+ " (I1, I2: INTEGER)            -- ERROR: "+ "
               RETURN INTEGER IS
          BEGIN
               RETURN 0;
          END "+ ";

          FUNCTION "NOT " (B1, B2: BOOLEAN)          -- ERROR: "NOT "
               RETURN BOOLEAN IS
          BEGIN
               RETURN FALSE;
          END "NOT ";

          FUNCTION " NOT" (B1, B2: BOOLEAN)          -- ERROR: " NOT"
               RETURN BOOLEAN IS
          BEGIN
               RETURN FALSE;
          END " NOT";

     BEGIN -- (H)
          NULL;
     END;  -- (H)

END B67001A;
