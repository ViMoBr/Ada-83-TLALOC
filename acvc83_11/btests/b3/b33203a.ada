-- B33203A.ADA

-- CHECK THAT IN A SUBTYPE INDICATION IN AN ACCESS TYPE DEFINITION,
-- A FIXED POINT CONSTRAINT IS NOT ALLOWED IF THE TYPE MARK DENOTES
-- AN ENUMERATION, INTEGER, FLOATING POINT, ARRAY, RECORD, ACCESS,
-- TASK OR PRIVATE TYPE.  INCLUDE ACCESS TYPE DEFINITIONS IN GENERIC
-- FORMAL PARAMETER DECLARATIONS.

-- JRK 4/2/81
-- VKG 1/6/83
-- JWC 10/9/85  RENAMED FROM B33003C-AB.ADA AND DIVIDED INTO FIVE
--              SEPARATE TESTS. EACH TYPE IS NOW TESTED IN AN ACCESS
--              TYPE DEFINITION. THE TESTS OF TASK TYPE AND FLOAT TYPE
--              WERE ADDED.

PROCEDURE B33203A IS

     TYPE FX IS DELTA 1.0 RANGE 0.0 .. 5.0;

     TYPE E IS (E1, E2);

     TYPE I IS RANGE 0 .. 100;

     TYPE FL IS DIGITS 3;

     TYPE AR IS ARRAY (NATURAL RANGE <>) OF FX;

     TYPE R IS
          RECORD
              I : FX;
          END RECORD;

     TYPE AC IS ACCESS FX;

     TASK TYPE TK IS
     END TK;

     PACKAGE PKG IS
          TYPE P IS PRIVATE;
     PRIVATE
          TYPE P IS NEW FX;
     END PKG;
     USE PKG;

     TYPE T1 IS ACCESS E DELTA 1.0;   -- ERROR: FIXED POINT CONSTRAINT
                                      -- ON ENUMERATION TYPE.
     TYPE T2 IS ACCESS I DELTA 1.0;   -- ERROR: FIXED POINT CONSTRAINT
                                      -- ON INTEGER TYPE.
     TYPE T3 IS ACCESS FL DELTA 1.0;  -- ERROR: FIXED POINT CONSTRAINT
                                      -- ON FLOATING POINT TYPE.
     TYPE T4 IS ACCESS AR DELTA 1.0;  -- ERROR: FIXED POINT CONSTRAINT
                                      -- ON ARRAY TYPE.
     TYPE T5 IS ACCESS R DELTA 1.0;   -- ERROR: FIXED POINT CONSTRAINT
                                      -- ON RECORD TYPE.
     TYPE T6 IS ACCESS AC DELTA 1.0;  -- ERROR: FIXED POINT CONSTRAINT
                                      -- ON ACCESS TYPE.
     TYPE T7 IS ACCESS TK DELTA 1.0;  -- ERROR: FIXED POINT CONSTRAINT
                                      -- ON TASK TYPE.
     TYPE T8 IS ACCESS P DELTA 1.0;   -- ERROR: FIXED POINT CONSTRAINT
                                      -- ON PRIVATE TYPE.

     GENERIC
          TYPE GT1 IS
               ACCESS E DELTA 1.0;    -- ERROR: FIXED POINT CONSTRAINT
                                      -- ON ENUMERATION TYPE.
          TYPE GT2 IS
               ACCESS I DELTA 1.0;    -- ERROR: FIXED POINT CONSTRAINT
                                      -- ON INTEGER TYPE.
          TYPE GT3 IS
               ACCESS FL DELTA 1.0;   -- ERROR: FIXED POINT CONSTRAINT
                                      -- ON FLOATING POINT TYPE.
          TYPE GT4 IS
               ACCESS AR DELTA 1.0;   -- ERROR: FIXED POINT CONSTRAINT
                                      -- ON ARRAY TYPE.
          TYPE GT5 IS
               ACCESS R DELTA 1.0;    -- ERROR: FIXED POINT CONSTRAINT
                                      -- ON RECORD TYPE.
          TYPE GT6 IS
               ACCESS AC DELTA 1.0;   -- ERROR: FIXED POINT CONSTRAINT
                                      -- ON ACCESS TYPE.
          TYPE GT7 IS
               ACCESS TK DELTA 1.0;   -- ERROR: FIXED POINT CONSTRAINT
                                      -- ON TASK TYPE.
          TYPE GT8 IS
               ACCESS P DELTA 1.0;    -- ERROR: FIXED POINT CONSTRAINT
                                      -- ON PRIVATE TYPE.
     PACKAGE GENPCK IS
     END GENPCK;

     TASK BODY TK IS
     BEGIN
          NULL;
     END TK;

BEGIN
     NULL;
END B33203A;
