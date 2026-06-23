-- B67001F.ADA

-- CHECK THAT WHEN THE OPERATOR SYMBOL "=" IS USED AS A GENERIC FORMAL
-- SUBPROGRAM PARAMETER, CERTAIN RULES, WHICH DO NOT APPLY TO OTHER
-- OPERATOR SYMBOLS, MAY NOT BE VIOLATED.
-- SUBTESTS ARE AS FOLLOWS:
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

-- CPP 6/18/84
-- JRK 12/4/84

PROCEDURE B67001F IS

     PACKAGE PKG IS
          TYPE LPTYPE1 IS LIMITED PRIVATE;
          TYPE LPTYPE2 IS LIMITED PRIVATE;
          TYPE P IS PRIVATE;
     PRIVATE
          TYPE LPTYPE1 IS NEW INTEGER RANGE 0..127;
          TYPE LPTYPE2 IS NEW INTEGER RANGE 0..127;
          TYPE P IS NEW INTEGER RANGE 0..100;
     END PKG;
     USE PKG;

BEGIN

     --------------------------------------------------

     DECLARE -- (A)

          -- DECLARE ALL TYPES USED IN THIS SUBTEST.
          TYPE E IS (X, Y, Z);
          TYPE A IS ACCESS INTEGER;

          GENERIC
               -- PARAMETERS CANNOT BE OF DIFFERENT TYPES.
               WITH FUNCTION "=" 
                    (I1 : INTEGER; B1 : BOOLEAN)     -- ERROR:
                    RETURN BOOLEAN;                  -- PARAM TYPES.

               WITH FUNCTION "=" 
                    (LP1 : LPTYPE1; LP2 : LPTYPE2)   -- ERROR:
                    RETURN BOOLEAN;                  -- PARAM TYPES.

               -- PARAMETERS CANNOT BE OF SAME SCALAR TYPE.
               WITH FUNCTION "=" 
                    (I1, I2 : INTEGER)               -- ERROR:
                    RETURN BOOLEAN;                  -- INTEGER.

               WITH FUNCTION "=" 
                    (E1, E2 : E) RETURN BOOLEAN;     -- ERROR: E.

               -- PARAMETERS CANNOT BE OF SAME ACCESS TYPE.
               WITH FUNCTION "=" 
                    (A1, A2 : A) RETURN BOOLEAN;     -- ERROR: A.

               -- PARAMETERS CANNOT BE OF SAME NON_LIMITED PRIVATE TYPE.
               WITH FUNCTION "=" 
                    (P1, P2 : P) RETURN BOOLEAN;     -- ERROR: PTYPE.

          PACKAGE PKGA IS
          END PKGA;

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

          TYPE AP IS ARRAY (1 .. 2) OF P;
          TYPE R IS
               RECORD
                    I1  : INTEGER;
                    AE1 : AE;
                    A1  : A;
                    AP1 : AP;
               END RECORD;
          TYPE AR IS ARRAY (1 .. 2) OF R;

          GENERIC
               -- PARAMETERS CANNOT BE ARRAYS OF A SCALAR TYPE.
               WITH FUNCTION "=" 
                    (AI1, AI2 : AI) RETURN BOOLEAN;  -- ERROR: AI.

               WITH FUNCTION "=" 
                    (AE1, AE2 : AE) RETURN BOOLEAN;  -- ERROR: AE.

               -- PARAMETERS CANNOT BE ARRAYS OF AN ACCESS TYPE.
               WITH FUNCTION "=" 
                    (AA1, AA2 : AA) RETURN BOOLEAN;  -- ERROR: AA.

               -- PARAMETERS CANNOT BE ARRAYS OF A NON-LIMITED
               -- PRIVATE TYPE.
               WITH FUNCTION "=" 
                    (AP1, AP2 : AP) RETURN BOOLEAN;     -- ERROR: AP.

               -- PARAMETERS CANNOT BE ARRAYS OF A RECORD TYPE, NONE OF
               -- WHOSE COMPONENTS IS OF A LIMITED TYPE. 
               WITH FUNCTION "=" 
                    (AR1, AR2 : AR) RETURN BOOLEAN;     -- ERROR: AR.

          PACKAGE PKG IS
          END PKG;

     BEGIN -- (B)
          NULL;
     END; -- (B)

     --------------------------------------------------

     DECLARE -- (C)

          -- DECLARE ALL TYPES USED IN THIS SUBTEST.
          TYPE E IS (X, Y, Z);
          TYPE A IS ACCESS INTEGER;
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

          GENERIC
               -- PARAMETERS CANNOT BE A RECORD TYPE NONE OF WHOSE
               -- SUBCOMPONENTS IS OF A LIMITED TYPE.
               WITH FUNCTION "=" 
                    (R1, R2 : R) RETURN BOOLEAN;   -- ERROR: R.

          PACKAGE PKG IS
          END PKG;

     BEGIN -- (C)
          NULL;
     END; -- (C)

END B67001F;
