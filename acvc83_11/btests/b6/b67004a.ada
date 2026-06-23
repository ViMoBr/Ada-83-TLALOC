-- B67004A.ADA

-- CHECK THAT RENAMING DECLARATIONS OF "=" OBEY THE RULES.
-- PARTICULARLY, TESTS ARE:
--   (A) RENAMING WITH "=" ON A SELECTED EQUALITY OPERATOR IS ALLOWED.
--       "=" AS A FUNCTION DESIGNATOR CANNOT RENAME A FUNCTION WITH A
--       SIMPLE NAME, EVEN IF THE SIMPLE NAME RENAMES ANOTHER EQUALITY
--       OPERATOR.
--   (B) "=" AS A FUNCTION DESIGNATOR CANNOT RENAME A FUNCTION WITH A
--       SIMPLE NAME.
--   (C) "=" AS A FUNCTION DESIGNATOR CANNOT RENAME THE INEQUALITY
--       OPERATOR.
--   (D) "=" AS A FUNCTION DESIGNATOR CANNOT RENAME ANOTHER OPERATOR
--       SYMBOL.
--   (E) WHEN "=" IS A GENERIC FORMAL PARAMETER, THE DEFAULT NAME NEED
--       NOT BE THE EQUALITY OPERATOR.

-- SPS 2/22/84
-- CPP 6/27/84
-- JBG 5/29/85

PROCEDURE B67004A IS

     PACKAGE PACK IS
          TYPE T IS LIMITED PRIVATE;
          FUNCTION "=" (X, Y: T) RETURN BOOLEAN;
          FUNCTION F (X, Y: T) RETURN BOOLEAN;
          FUNCTION "/" (X, Y: T) RETURN BOOLEAN;
     PRIVATE
          TYPE T IS RANGE 1 .. 10;
     END PACK;

     PACKAGE BODY PACK IS 
          FUNCTION "=" (X, Y: T) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END "=";

          FUNCTION F (X, Y: T) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END F;

          FUNCTION "/" (X, Y: T) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END "/";
     END PACK;
     USE PACK;

BEGIN

     ----------------------------------------------------

     DECLARE -- (A)
          FUNCTION "=" (X, Y: T) RETURN BOOLEAN 
               RENAMES PACK."=";                  -- OK.
     BEGIN -- (A)
          DECLARE
               FUNCTION EQUAL (X , Y : T) RETURN BOOLEAN
                    RENAMES PACK."=";             -- OK.
               FUNCTION "=" (X, Y: T) RETURN BOOLEAN
                    RENAMES EQUAL;                -- ERROR: EQUAL.
          BEGIN
               NULL;
          END;
     END; -- (A)

     ----------------------------------------------------

     DECLARE --(B)
          FUNCTION "=" (X, Y: T) RETURN BOOLEAN 
                    RENAMES PACK.F;               -- ERROR: F.
     BEGIN -- (B)
          NULL;
     END; -- (B)

     ----------------------------------------------------

     DECLARE -- (C)
          FUNCTION "=" (X, Y: T) RETURN BOOLEAN
                    RENAMES PACK."/=";            -- ERROR: /=.
     BEGIN -- (C)
          NULL;
     END; -- (C)

     ----------------------------------------------------

     DECLARE -- (D)
          FUNCTION "=" (X, Y: T) RETURN BOOLEAN
                    RENAMES "/";                  -- ERROR: /.
     BEGIN -- (D)
          NULL;
     END; -- (D)

     ----------------------------------------------------

     DECLARE -- (E)
          FUNCTION FN (X, Y, Z: CHARACTER) RETURN CHARACTER IS
          BEGIN
               RETURN Z;
          END FN;

          GENERIC
               WITH FUNCTION "=" (X, Y: T) RETURN BOOLEAN
                    IS <>;                        -- OK.
          PACKAGE PKG1 IS
          END PKG1;

          PACKAGE PKG1_INST IS NEW PKG1;          -- OK.

          GENERIC
               WITH FUNCTION "=" (X, Y: T) RETURN BOOLEAN
                    IS PACK."/=";                      -- OK.
          PACKAGE PKG2 IS
          END PKG2;

          GENERIC
               WITH FUNCTION "=" (X, Y: T) RETURN BOOLEAN
                    IS PACK.F;                    -- OK.
          PACKAGE PKG3 IS
          END PKG3;

          PACKAGE NP3 IS NEW PKG3;                -- OK.

          GENERIC
               WITH FUNCTION "=" (X, Y: T) RETURN BOOLEAN
                    IS "*";                       -- ERROR:
                                                  -- WRONG PROFILE.
          PACKAGE PKG4 IS
          END PKG4;

          GENERIC
               WITH FUNCTION "=" (X, Y: T) RETURN BOOLEAN
                    IS "OR";                      -- ERROR:
                                                  -- WRONG PROFILE.
          PACKAGE PKG5 IS
          END PKG5;

          GENERIC
               WITH FUNCTION "=" (X, Y: T) RETURN BOOLEAN
                    IS FN;                        -- ERROR:
                                                  -- WRONG PROFILE.
          PACKAGE PKG6 IS
          END PKG6;

     BEGIN -- (E)
          NULL;
     END; -- (E)

     ----------------------------------------------------

END B67004A;
