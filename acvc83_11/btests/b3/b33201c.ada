-- B33201C.ADA

-- CHECK THAT IN A SUBTYPE INDICATION IN A COMPONENT OF A RECORD OR
-- ARRAY TYPE DECLARATION, A RANGE CONSTRAINT IS NOT PERMITTED FOR
-- ARRAY, RECORD, ACCESS, TASK, OR PRIVATE TYPES. INCLUDE A CASE OF
-- A CONSTRAINED ARRAY TYPE DEFINITION IN A GENERIC FORMAL
-- PARAMETER DECLARATION.

-- JRK 4/2/81
-- JWC 10/9/85  RENAMED FROM B33003A.ADA AND DIVIDED INTO FIVE SEPARATE
--              TESTS. EACH TYPE IS NOW TESTED IN A COMPONENT OF A
--              RECORD AND A COMPONENT OF AN ARRAY TYPE DECLARATION.
--              THE TEST OF TASK TYPE WAS ADDED.


PROCEDURE B33201C IS

     TYPE ARR IS ARRAY (NATURAL RANGE <>) OF INTEGER;

     TYPE REC IS
          RECORD
               I : INTEGER;
          END RECORD;

     TYPE ACC IS ACCESS INTEGER;

     PACKAGE PKG IS
          TYPE PRIV IS PRIVATE;
     PRIVATE
          TYPE PRIV IS NEW INTEGER;
     END PKG;
     USE PKG;

     TASK TYPE TSK IS
     END TSK;

     SUBTYPE INT IS INTEGER RANGE 1 .. 2;

     TYPE RT IS
          RECORD
               A : ARR RANGE 0 .. 9;        -- ERROR: RANGE CONSTRAINT
                                            -- ON ARRAY TYPE.
               R : REC RANGE 0 .. 9;        -- ERROR: RANGE CONSTRAINT
                                            -- ON RECORD TYPE.
               C : ACC RANGE 0 .. 9;        -- ERROR: RANGE CONSTRAINT
                                            -- ON ACCESS TYPE.
               P : PRIV RANGE 0 .. 9;       -- ERROR: RANGE CONSTRAINT
                                            -- ON PRIVATE TYPE.
               T : TSK RANGE 0 .. 9;        -- ERROR: RANGE CONSTRAINT
                                            -- ON TASK TYPE.
          END RECORD;

     TYPE ARRARR IS ARRAY (1 .. 2)
                 OF ARR RANGE 0 .. 9;       -- ERROR: RANGE CONSTRAINT
                                            -- ON ARRAY TYPE.
     TYPE ARRREC IS ARRAY (1 .. 2)
                 OF REC RANGE 0 .. 9;       -- ERROR: RANGE CONSTRAINT
                                            -- ON RECORD TYPE.
     TYPE ARRACC IS ARRAY (1 .. 2)
                 OF ACC RANGE 0 .. 9;       -- ERROR: RANGE CONSTRAINT
                                            -- ON ACCESS TYPE.
     TYPE ARRPRIV IS ARRAY (1 .. 2)
                 OF PRIV RANGE 0 .. 9;      -- ERROR: RANGE CONSTRAINT
                                            -- ON PRIVATE TYPE.
     TYPE ARRTSK IS ARRAY (1 .. 2)
                 OF TSK RANGE 0 .. 9;       -- ERROR: RANGE CONSTRAINT
                                            -- ON TASK TYPE.

     GENERIC
          TYPE GENARR IS ARRAY (INT)
                 OF ARR RANGE 0 .. 9;       -- ERROR: RANGE CONSTRAINT
                                            -- ON ARRAY TYPE.
          TYPE GENREC IS ARRAY (INT)
                 OF REC RANGE 0 .. 9;       -- ERROR: RANGE CONSTRAINT
                                            -- ON RECORD TYPE.
          TYPE GENACC IS ARRAY (INT)
                 OF ACC RANGE 0 .. 9;       -- ERROR: RANGE CONSTRAINT
                                            -- ON ACCESS TYPE.
          TYPE GENPRIV IS ARRAY (INT)
                 OF PRIV RANGE 0 .. 9;      -- ERROR: RANGE CONSTRAINT
                                            -- ON PRIVATE TYPE.
          TYPE GENTSK IS ARRAY (INT)
                 OF TSK RANGE 0 .. 9;       -- ERROR: RANGE CONSTRAINT
                                            -- ON TASK TYPE.
     PACKAGE GENPAK IS
     END GENPAK;

     TASK BODY TSK IS
     BEGIN
          NULL;
     END TSK;

BEGIN
     NULL;
END B33201C;
