-- B67001E.ADA

-- CHECK THAT WHEN THE OPERATOR SYMBOL "=" IS USED IN A FUNCTION
--   DECLARATION, CERTAIN RULES, WHICH DO NOT APPLY TO OTHER
--   OPERATOR SYMBOLS, MAY NOT BE VIOLATED.
--   SUBTESTS ARE AS FOLLOWS:
--      (A)   CHECK THAT THE PARAMETER TYPES CANNOT BE DIFFERENT,
--            NOR CAN BOTH PARAMETERS BE OF THE SAME SCALAR, 
--            ACCESS, NON-LIMITED TYPE.
--      (B)   CHECK THAT THE PARAMETERS CANNOT BE AN ARRAY TYPE
--            WHOSE COMPONENTS ARE OF A SCALAR, ACCESS,
--            NON-LIMITED PRIVATE, OR RECORD TYPE NONE
--            OF WHOSE COMPONENTS (DIRECTLY OR INDIRECTLY) IS OF A 
--            LIMITED TYPE.
--      (C)   CHECK THAT THE PARAMETERS CANNOT BE OF A RECORD
--            TYPE NONE OF WHOSE SUBCOMPONENTS IS OF A LIMITED TYPE.
--
-- THE IMPORTANT POINT IN THIS TEST IS THAT OVERLOADING OF THE EQUALITY
-- OPERATOR MAY OCCUR ONLY IF THERE ARE TWO PARAMETERS, BOTH OF
-- WHICH ARE OF THE SAME LIMITED TYPE OR OF THE SAME ARRAY
-- OR RECORD TYPE THAT HAS A SUBCOMPONENT OF A LIMITED TYPE.

-- CVP 5/14/81
-- JRK 5/27/81
-- JBG 3/18/82  REMOVE TASK TYPES FROM TEST
-- CPP 6/12/84

PROCEDURE B67001E IS
BEGIN

     --------------------------------------------------

     DECLARE -- (A)
          -- DECLARE ALL TYPES USED IN THIS SUBTEST.
          TYPE E IS (X, Y, Z);
          TYPE A IS ACCESS INTEGER;

          -- PARAMETERS CANNOT BE OF DIFFERENT TYPES.
          FUNCTION "=" (I1 : INTEGER; B1 : BOOLEAN)    -- ERROR:
               RETURN BOOLEAN IS                  -- PARAM TYPES.
          BEGIN
               RETURN TRUE;
          END "=";

          PACKAGE PKG1 IS
               TYPE LPTYPE1 IS LIMITED PRIVATE;
               TYPE LPTYPE2 IS LIMITED PRIVATE;

               FUNCTION "=" (LP1 : LPTYPE1; LP2 : LPTYPE2) -- ERROR:
                    RETURN BOOLEAN;               -- PARAM TYPES.
          PRIVATE
               TYPE LPTYPE1 IS NEW INTEGER RANGE 0 .. 127;
               TYPE LPTYPE2 IS NEW INTEGER RANGE 0 .. 127;
          END PKG1;

          -- PARAMETERS CANNOT BE OF SAME SCALAR TYPE.
          FUNCTION "=" (I1, I2 : INTEGER)         -- ERROR: INTEGER.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "=";

          FUNCTION "=" (E1, E2 : E)               -- ERROR: E.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "=";

          -- PARAMETERS CANNOT BE OF SAME ACCESS TYPE.
          FUNCTION "=" (A1, A2 : A)               -- ERROR: A.
               RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END "=";

          -- PARAMETERS CANNOT BE OF SAME
          -- NON-LIMITED PRIVATE TYPE.
          PACKAGE PKG2 IS
               TYPE PTYPE IS PRIVATE;

               FUNCTION "=" (P1, P2 : PTYPE)      -- ERROR: PTYPE.
                    RETURN BOOLEAN;
          PRIVATE
               TYPE PTYPE IS NEW INTEGER RANGE 0 .. 127;
          END PKG2;

          -- PACKAGE BODIES FOR PREVIOUS DECLARATIONS.
          PACKAGE BODY PKG1 IS
               FUNCTION "=" (LP1 : LPTYPE1; LP2 : LPTYPE2) -- OPT:
                    RETURN BOOLEAN IS             -- PARAM TYPES.
               BEGIN
                    RETURN TRUE;
               END "=";
          END PKG1;

          PACKAGE BODY PKG2 IS
               FUNCTION "=" (P1, P2 : PTYPE)      -- OPT: PTYPE.
                    RETURN BOOLEAN IS
               BEGIN
                    RETURN TRUE;
               END "=";
          END PKG2;

     BEGIN -- (A)
          NULL;
     END; -- (A)

     --------------------------------------------------

     DECLARE -- (B)
          -- DECLARE ALL TYPES USED IN THIS SUBTEST.
          TYPE AI IS ARRAY (1 .. 2) OF INTEGER;

          TYPE E IS (X, Y, Z);
          TYPE AE IS ARRAY (1 .. 2) OF E;

          TYPE A IS ACCESS INTEGER;
          TYPE AA IS ARRAY (1 .. 2) OF A;

          PACKAGE PKG IS
               TYPE P IS PRIVATE;
          PRIVATE
               TYPE P IS NEW INTEGER RANGE 0 .. 127;
          END PKG;

          USE PKG;
          TYPE AP IS ARRAY (1 .. 2) OF P;

          TYPE R IS
               RECORD
                    I1  : INTEGER;
                    AE1 : AE;
                    A1  : A;
                    AP1 : AP;
               END RECORD;
          TYPE AR IS ARRAY (1 .. 2) OF R;

          -- PARAMETERS CANNOT BE ARRAYS OF A SCALAR 
          -- TYPE.
          FUNCTION "=" (AI1, AI2 : AI) RETURN BOOLEAN IS -- ERROR: AI.
          BEGIN
               RETURN TRUE;
          END "=";

          FUNCTION "=" (AE1, AE2 : AE) RETURN BOOLEAN IS -- ERROR: AE.
          BEGIN
               RETURN TRUE;
          END "=";

          -- PARAMETERS CANNOT BE ARRAYS OF AN
          -- ACCESS TYPE.
          FUNCTION "=" (AA1, AA2 : AA) RETURN BOOLEAN IS -- ERROR: AA.
          BEGIN
               RETURN TRUE;
          END "=";

          -- PARAMETERS CANNOT BE ARRAYS OF A 
          -- NON-LIMITED PRIVATE TYPE.
          FUNCTION "=" (AP1, AP2 : AP) RETURN BOOLEAN IS -- ERROR: AP.
          BEGIN
               RETURN TRUE;
          END "=";

          -- PARAMETERS CANNOT BE ARRAYS OF A
          -- RECORD TYPE, NONE OF WHOSE COMPONENTS
          -- IS OF A LIMITED TYPE.
          FUNCTION "=" (AR1, AR2 : AR) RETURN BOOLEAN IS -- ERROR: AR.
          BEGIN
               RETURN TRUE;
          END "=";

     BEGIN -- (B)
          NULL;
     END; -- (B)

     --------------------------------------------------

     DECLARE -- (C)
          -- DECLARE ALL TYPES USED IN THIS SUBTEST.
          TYPE E IS (X, Y, Z);

          TYPE A IS ACCESS INTEGER;

          PACKAGE PKG IS
               TYPE P IS PRIVATE;
          PRIVATE
               TYPE P IS NEW INTEGER RANGE 0 .. 127;
          END PKG;

          USE PKG;
          TYPE AP IS ARRAY (1 .. 2) OF P;

          TYPE R IS
               RECORD
                    I1  : INTEGER;
                    E1  : E;
                    A1  : A;
                    P1  : P;
                    AP1 : AP;
                    S1  : STRING (1 .. 3);
               END RECORD;

          -- PARAMETERS CANNOT BE A RECORD TYPE
          -- NONE OF WHOSE SUBCOMPONENTS IS OF
          -- A LIMITED TYPE.
          FUNCTION "=" (R1, R2 : R) RETURN BOOLEAN IS -- ERROR: R.
          BEGIN
               RETURN TRUE;
          END "=";

     BEGIN -- (C)
          NULL;
     END; -- (C)

END B67001E;
