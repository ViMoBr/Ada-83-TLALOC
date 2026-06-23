-- B67001G.ADA

-- CHECK THAT WHEN THE OPERATOR SYMBOL "=" IS USED IN A GENERIC
-- INSTANTIATION OF A FUNCTION DECLARATION, CERTAIN RULES, WHICH 
-- DO NOT APPLY TO OTHER OPERATOR SYMBOLS, MAY NOT BE VIOLATED.
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

-- CPP 6/25/84

PROCEDURE B67001G IS

     GENERIC
          TYPE T1 IS LIMITED PRIVATE;
          TYPE T2 IS LIMITED PRIVATE;
     FUNCTION EQUAL (P1 : T1; P2 : T2) RETURN BOOLEAN;
     FUNCTION EQUAL (P1 : T1; P2 : T2) RETURN BOOLEAN IS
     BEGIN
          RETURN TRUE;
     END EQUAL;

     GENERIC
          TYPE T1 IS LIMITED PRIVATE;
     FUNCTION EQ (P1, P2 : T1) RETURN BOOLEAN;
     FUNCTION EQ (P1, P2 : T1) RETURN BOOLEAN IS
     BEGIN
          RETURN TRUE;
     END EQ;
     
BEGIN

     --------------------------------------------------

     DECLARE -- (A)
          -- DECLARE ALL TYPES USED IN THIS SUBTEST.
          TYPE E IS (X, Y, Z);
          TYPE A IS ACCESS INTEGER;

          -- PARAMETERS CANNOT BE OF DIFFERENT TYPES.
          FUNCTION "=" IS NEW EQUAL
               (T1 => INTEGER, T2 => BOOLEAN);    -- ERROR: PARAM TYPES.

          PACKAGE PKG1 IS
               TYPE LPTYPE1 IS LIMITED PRIVATE;
               TYPE LPTYPE2 IS LIMITED PRIVATE;

          PRIVATE
               TYPE LPTYPE1 IS NEW INTEGER RANGE 0 .. 127;
               TYPE LPTYPE2 IS NEW INTEGER RANGE 0 .. 127;
          END PKG1;
          USE PKG1;

          FUNCTION "=" IS NEW EQUAL
               (T1 => LPTYPE1, T2 => LPTYPE2);    -- ERROR: 
                                                  -- PARAM TYPES.
          FUNCTION "=" IS NEW EQUAL
               (LPTYPE1, LPTYPE1);                -- OK.

          -- PARAMETERS CANNOT BE OF SAME SCALAR TYPE.
          FUNCTION "=" IS NEW EQ
               (T1 => INTEGER);                   -- ERROR: INTEGER.

          FUNCTION "=" IS NEW EQ
               (T1 => E);                         -- ERROR: E.

          -- PARAMETERS CANNOT BE OF SAME ACCESS TYPE.
          FUNCTION "=" IS NEW EQ
               (T1 => A);                         -- ERROR: A.

          -- PARAMETERS CANNOT BE OF SAME NON-LIMITED PRIVATE TYPE.
          PACKAGE PKG3 IS
               TYPE PTYPE IS PRIVATE;
          PRIVATE
               TYPE PTYPE IS NEW INTEGER RANGE 0 .. 127;
          END PKG3;

          FUNCTION "=" IS NEW EQ
               (T1 => PKG3.PTYPE);                -- ERROR: PTYPE.

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

          -- PARAMETERS CANNOT BE ARRAYS OF A SCALAR TYPE.
          FUNCTION "=" IS NEW EQ
               (T1 => AI);                        -- ERROR: AI.

          FUNCTION "=" IS NEW EQ
               (T1 => AE);                        -- ERROR: AE.

          -- PARAMETERS CANNOT BE ARRAYS OF AN ACCESS TYPE.
          FUNCTION "=" IS NEW EQ
               (T1 => AA);                        -- ERROR: AA.

          -- PARAMETERS CANNOT BE ARRAYS OF A NON-LIMITED PRIVATE TYPE.
          FUNCTION "=" IS NEW EQ
               (T1 => AP);                        -- ERROR: AP.

          -- PARAMETERS CANNOT BE ARRAYS OF A RECORD TYPE, NONE OF WHOSE
          -- COMPONENTS IS OF A LIMITED TYPE.
          FUNCTION "=" IS NEW EQ
               (T1 => AR);                        -- ERROR: AR.

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

          -- PARAMETERS CANNOT BE A RECORD TYPE NONE OF WHOSE
          -- SUBCOMPONENTS IS OF A LIMITED TYPE.
          FUNCTION "=" IS NEW EQ
               (T1 => R);                         -- ERROR: R.

     BEGIN -- (C)
          NULL;
     END; -- (C)

END B67001G;
