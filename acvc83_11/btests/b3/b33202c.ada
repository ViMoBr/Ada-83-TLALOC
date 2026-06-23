-- B33202C.ADA

-- CHECK THAT IN A SUBTYPE INDICATION IN A COMPONENT OF A RECORD OR
-- ARRAY TYPE DECLARATION, A FLOATING POINT CONSTRAINT IS NOT ALLOWED
-- IF THE TYPE MARK DENOTES AN ENUMERATION, INTEGER, FIXED POINT, ARRAY,
-- RECORD, ACCESS, TASK OR PRIVATE TYPE.   INCLUDE USE OF CONSTRAINED
-- ARRAY TYPE DEFINITIONS IN GENERIC FORMAL PARAMETER DECLARATION.

-- JRK 4/2/81
-- VKG 1/6/83
-- JWC 10/9/85  RENAMED FROM B33003B-AB.ADA AND DIVIDED INTO FIVE
--              SEPARATE TESTS. EACH TYPE IS NOW TESTED IN A COMPONENT
--              OF A RECORD AND AN ARRAY TYPE DECLARATION. THE TESTS
--              FOR TASK TYPE AND FIXED TYPE WERE ADDED.

PROCEDURE B33202C IS

     TYPE FLT IS DIGITS 4;

     TYPE E IS (E1, E2);

     TYPE I IS RANGE 0 .. 100;

     TYPE FX IS DELTA 0.1 RANGE 0.0 .. 1.0;

     TYPE AR IS ARRAY (NATURAL RANGE <>) OF FLT;

     TYPE R IS
          RECORD
              I : FLT;
          END RECORD;

     TYPE AC IS ACCESS FLT;

     TASK TYPE TK IS
     END TK;

     PACKAGE PKG IS
          TYPE P IS PRIVATE;
     PRIVATE
          TYPE P IS NEW FLT;
     END PKG;
     USE PKG;

     SUBTYPE INT IS INTEGER RANGE 1 .. 2;

     TYPE REC IS
          RECORD
               T1 : E DIGITS 1;     -- ERROR: FLOATING POINT CONSTRAINT
                                    -- ON ENUMERATION TYPE.
               T2 : I DIGITS 1;     -- ERROR: FLOATING POINT CONSTRAINT
                                    -- ON INTEGER TYPE.
               T3 : FX DIGITS 1;    -- ERROR: FLOATING POINT CONSTRAINT
                                    -- ON FIXED TYPE.
               T4 : AR DIGITS 1;    -- ERROR: FLOATING POINT CONSTRAINT
                                    -- ON ARRAY TYPE.
               T5 : R DIGITS 1;     -- ERROR: FLOATING POINT CONSTRAINT
                                    -- ON RECORD TYPE.
               T6 : AC DIGITS 1;    -- ERROR: FLOATING POINT CONSTRAINT
                                    -- ON ACCESS TYPE.
               T7 : TK DIGITS 1;    -- ERROR: FLOATING POINT CONSTRAINT
                                    -- ON TASK TYPE.
               T8 : P DIGITS 1;     -- ERROR: FLOATING POINT CONSTRAINT
                                    -- ON PRIVATE TYPE.
          END RECORD;

     TYPE TA1 IS ARRAY (1 .. 2)
              OF E DIGITS 1;        -- ERROR: FLOATING POINT CONSTRAINT
                                    -- ON ENUMERATION TYPE.
     TYPE TA2 IS ARRAY (1 .. 2)
              OF I DIGITS 1;        -- ERROR: FLOATING POINT CONSTRAINT
                                    -- ON INTEGER TYPE.
     TYPE TA3 IS ARRAY (1 .. 2)
              OF FX DIGITS 1;       -- ERROR: FLOATING POINT CONSTRAINT
                                    -- ON FIXED TYPE.
     TYPE TA4 IS ARRAY (1 .. 2)
              OF AR DIGITS 1;       -- ERROR: FLOATING POINT CONSTRAINT
                                    -- ON ARRAY TYPE.
     TYPE TA5 IS ARRAY (1 .. 2)
              OF R DIGITS 1;        -- ERROR: FLOATING POINT CONSTRAINT
                                    -- ON RECORD TYPE.
     TYPE TA6 IS ARRAY (1 .. 2)
              OF AC DIGITS 1;       -- ERROR: FLOATING POINT CONSTRAINT
                                    -- ON ACCESS TYPE.
     TYPE TA7 IS ARRAY (1 .. 2)
              OF TK DIGITS 1;       -- ERROR: FLOATING POINT CONSTRAINT
                                    -- ON TASK TYPE.
     TYPE TA8 IS ARRAY (1 .. 2)
              OF P DIGITS 1;        -- ERROR: FLOATING POINT CONSTRAINT
                                    -- ON PRIVATE TYPE.

     GENERIC
          TYPE GA1 IS ARRAY (INT)
               OF E DIGITS 1;       -- ERROR: FLOATING POINT CONSTRAINT
                                    -- ON ENUMERATION TYPE.
          TYPE GA2 IS ARRAY (INT)
               OF I DIGITS 1;       -- ERROR: FLOATING POINT CONSTRAINT
                                    -- ON INTEGER TYPE.
          TYPE GA3 IS ARRAY (INT)
               OF FX DIGITS 1;      -- ERROR: FLOATING POINT CONSTRAINT
                                    -- ON FIXED TYPE.
          TYPE GA4 IS ARRAY (INT)
               OF AR DIGITS 1;      -- ERROR: FLOATING POINT CONSTRAINT
                                    -- ON ARRAY TYPE.
          TYPE GA5 IS ARRAY (INT)
               OF R DIGITS 1;       -- ERROR: FLOATING POINT CONSTRAINT
                                    -- ON RECORD TYPE.
          TYPE GA6 IS ARRAY (INT)
               OF AC DIGITS 1;      -- ERROR: FLOATING POINT CONSTRAINT
                                    -- ON ACCESS TYPE.
          TYPE GA7 IS ARRAY (INT)
               OF TK DIGITS 1;      -- ERROR: FLOATING POINT CONSTRAINT
                                    -- ON TASK TYPE.
          TYPE GA8 IS ARRAY (INT)
               OF P DIGITS 1;       -- ERROR: FLOATING POINT CONSTRAINT
                                    -- ON PRIVATE TYPE.
     PACKAGE GENPCK IS
     END GENPCK;

     TASK BODY TK IS
     BEGIN
          NULL;
     END TK;

BEGIN
     NULL;
END B33202C;
