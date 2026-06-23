-- B74304A.ADA

--    CHECK THAT A DEFERRED CONSTANT CANNOT BE USED AS AN
--    INITIAL VALUE FOR AN OBJECT OR CONSTANT DECLARATION UNTIL AFTER
--    THE FULL CONSTANT DECLARATION.

-- DAT 4/6/81
-- RM 5/21/81
-- SPS 8/23/82
-- SPS 2/10/83
-- SPS 10/20/83

PROCEDURE B74304A IS
 
     PACKAGE PK IS
          TYPE T1 IS PRIVATE;
          C1 : CONSTANT T1;                   -- OK.

          PACKAGE P2 IS
               TYPE T2 IS PRIVATE;
               C22 : CONSTANT T2;             -- OK.
               C23 : CONSTANT T2;             -- OK.
               C24 : CONSTANT T2;             -- OK.
               C25 : CONSTANT T2;             -- OK.
               C26 : CONSTANT T2;             -- OK.
               C27 : CONSTANT T2;             -- OK.
          PRIVATE
               TYPE T2 IS ACCESS INTEGER;
               C22 : CONSTANT T2 := NULL;
               C23 : CONSTANT T2 := C22;      -- OK.
               C24 : CONSTANT T2 := C26;      -- ERROR: C26 UNDEF.
               C26 : CONSTANT T2 := NULL;
               C27 : CONSTANT T2 := C25;      -- ERROR: C25 UNDEF. 
               C25 : CONSTANT T2 := C22;      -- OK.
          END P2;                            

          USE P2;
     PRIVATE

          TYPE T1 IS ACCESS INTEGER;

          PACKAGE P5 IS
               TYPE T1 IS PRIVATE;
               C4B, C4C : CONSTANT T1;        -- OK.
          PRIVATE
               TYPE T1 IS NEW PK.T1;          -- OK.
               C4C : CONSTANT T1 := NULL;     -- OK.
               C4B : CONSTANT T1 := T1(C1);   -- ERROR: C1 UNDEF.   
               C4D : CONSTANT PK.T1 := C1;    -- ERROR: C1 UNDEF.   
          END P5;

          V7 : T1 := C1;                      -- ERROR: C1 UNDEF.   
          V8 : CONSTANT T1 := C1;             -- ERROR: C1 UNDEF.   
          C1 : CONSTANT T1 := NULL;           -- OK.
     END PK;
BEGIN
     NULL;
END B74304A;
