-- B74301A.ADA

-- (A)  CHECK THAT A DEFERRED CONSTANT CANNOT BE INTRODUCED FOR A TYPE
--    DECLARED IN ANOTHER PACKAGE.

-- (B 1, 2)  CHECK THAT A DEFERRED CONSTANT CANNOT BE INTRODUCED IN THE
--    PRIVATE PART OF A PACKAGE BEFORE OR AFTER FULL TYPE DEF.

-- (C 1, 2)  CHECK THAT A DEFERRED CONSTANT CANNOT BE INTRODUCED IN A
--    PACKAGE BODY OR IN A PACKAGE SPECIFICATION NESTED WITHIN THE
--    PACKAGE SPECIFICATION CONTAINING THE DECLARATION OF THE PRIVATE
--    TYPE.

-- (D 1, 2)  CHECK THAT (EVEN IF A PRIVATE TYPE HAS DEFAULT VALUES
--    SPECIFIED FOR ALL ITS COMPONENTS)  FULL DECLARATIONS MUST BE
--    GIVEN FOR ALL DEFERRED CONSTANTS OF THAT TYPE THAT HAVE BEEN
--    INTRODUCED, AND A FULL DECLARATION CANNOT OMIT AN INITIALIZATION
--    EXPRESSION.

-- DAT 4/6/81
-- RM 5/21/81
-- SPS 8/23/82
-- SPS 2/10/83
-- SPS 10/20/83

PROCEDURE B74301A IS

     PACKAGE PK IS
          TYPE T1 IS PRIVATE;
          TYPE TR IS PRIVATE;
          Z1, Z2: CONSTANT T1;
          Z3, Z4 : CONSTANT TR;
          C1 : CONSTANT T1;                   -- OK.

          PACKAGE P2 IS
               TYPE T2 IS PRIVATE;
               C2 : CONSTANT T1;              -- ERROR: WRONG PKG. (C2)
               C22 : CONSTANT T2;             -- OK.
               C23 : CONSTANT T2;             -- OK.
               C25 : CONSTANT T2;             -- OK.
               C26 : CONSTANT T2;             -- OK.
               C222 : CONSTANT T1;            -- ERROR: WRONG PACKAGE.C2
          PRIVATE
               TYPE T2 IS ACCESS INTEGER;
               C22 : CONSTANT T2 := NULL;
               C23 : CONSTANT T2 := C22;      -- OK.
               C26 : CONSTANT T2 := NULL;
          END P2;                             -- ERROR: C25 UNDEF. (D1)

          USE P2;
          C3 : CONSTANT T2;                   -- ERROR: NOT SAME PKG.(A)
     PRIVATE
          C4 : CONSTANT T1;                   -- ERROR: IN PVT.PART.(B1)

          TYPE T1 IS ACCESS INTEGER;

          PACKAGE P5 IS
               C4A : CONSTANT T1;             -- ERROR: WRONG PKG.  (A)
          END P5;

          PROCEDURE P3 (P : T1 := C1);        -- OK.
          TYPE R3 IS RECORD
               C : T1 := C1;                  -- OK.
          END RECORD;
          V6 : T1;                            -- OK.
          C5 : CONSTANT T1;                   -- ERROR: IN PVT PART.(B2)
          C1 : CONSTANT T1 := NULL;           -- OK.
          V3 : T1 := C1;                      -- OK.
          V4 : CONSTANT T1 := C1;             -- OK.
          V5 : T1;                            -- OK.

          PACKAGE P6 IS
               C4A : CONSTANT T1;             -- ERROR: WRONG PKG.  (A)
               TYPE T1 IS PRIVATE;
               C4B, C4C : CONSTANT T1;        -- OK.
          PRIVATE
               TYPE T1 IS NEW PK.T1;
               C4C : CONSTANT T1 := NULL;     -- OK.
               C4B : CONSTANT T1 := T1(C1);   -- OK.
               C4D : CONSTANT PK.T1 := C1;    -- OK.
          END P6;

          TYPE TR IS RECORD
               C : INTEGER := 0;
          END RECORD;
          Z2 : CONSTANT T1;                   -- ERROR: NO INIT. (D2,B1)
          Z4 : CONSTANT TR;                   -- ERROR: NO INIT.    (D2)
     END PK;                                  -- ERROR: Z1,Z3 UNDEF.(D1)

     USE PK;

     PACKAGE BODY PK IS
          C8 : CONSTANT T1;                   -- ERROR: IN BODY.    (C1)

          PROCEDURE P1 (P : T1 := C1) IS
          BEGIN NULL; END P1;
          PROCEDURE PROC2 (P : T1 := C1) IS
          BEGIN NULL; END PROC2;
          PROCEDURE P3 (P : T1 := C1) IS
          BEGIN NULL; END P3;
     BEGIN NULL; END PK;
BEGIN
     NULL;
END B74301A;
