-- B37004A.ADA

-- (A) CHECK THAT RECORD COMPONENTS CANNOT BE UNCONSTRAINED ARRAYS,
--     EVEN IF INITIALIZED TO A STATIC VALUE.
-- (B) CHECK THAT COMPONENTS CANNOT BE USED IN ANOTHER RECORD
--     COMPONENT'S CONSTRAINT OR INITIAL VALUE, OR IN ITS OWN
--     CONSTRAINT OR INITIAL VALUES.
-- (C) CHECK THAT THE BASE TYPES OF A COMPONENT AND ITS INITIAL VALUE
--     MUST MATCH.
-- (F) CHECK THAT THE NAME OF A RECORD TYPE CANNOT BE USED INSIDE ITS
--     RECORD DEFINITION.

-- DAT 5/18/81
-- SPS 11/3/82
-- VKG 1/13/83
-- RJW 1/9/86 - ADDED 'C20', DELETED 'C21' TO 'C30' AND CASE (G).

PROCEDURE B37004A IS

     SUBTYPE S1 IS INTEGER RANGE 1 .. 1;
     TYPE U IS ARRAY (S1 RANGE <>) OF S1;
     TYPE ARR IS ARRAY(S1) OF S1;

     TYPE R (D : S1);
     TYPE AR IS ACCESS R;
     TYPE R (D : S1) IS RECORD
          C2 : U := (1 => 1);                       -- ERROR: A
          C3 : STRING := "ABC";                     -- ERROR: A

          C4 : S1 := S1'FIRST;                      -- OK.
          C5 : STRING (1 .. C4);                    -- ERROR: B1
          C6 : AR (D => C4);                        -- ERROR: B1
          C7 : FLOAT RANGE 1.0 .. 1.0 := 1.0;       -- OK.
          C8 : FLOAT DIGITS 1 RANGE 1.0 .. C7;      -- ERROR: B1
          C9 : INTEGER RANGE 1 .. C4;               -- ERROR: B1
          C10 : INTEGER := C4;                      -- ERROR: B1

          C11 : ARR := (S1 => 1);                   -- OK.
          C13 : AR (D => C11'FIRST);                -- ERROR: B1
          C14 : FLOAT DIGITS C11'FIRST;             -- ERROR: B1
          C15 : S1 RANGE C11'FIRST .. 1;            -- ERROR: B1
          C16 : STRING (S1) := (C11'RANGE => ' ');  -- ERROR: B1
          C17 : STRING (S1) := (C11'FIRST => ' ');  -- ERROR: B1
          C18 : INTEGER := C4'SIZE;                 -- ERROR: B1
          C19 : INTEGER := C19'FIRST;               -- ERROR: B2
          C20 : STRING (S1) := (C20'RANGE => ' ');  -- ERROR: B2

          C32 : U (1 .. C32'FIRST);                 -- ERROR: B2
          C33 : FLOAT := 1;                         -- ERROR: C
          C34 : INTEGER := 1.0;                     -- ERROR: C
          C35 : AR := NEW AR;                       -- ERROR: C

          C36 : AR := NEW R(1);                     -- ERROR: F

          C37 : INTEGER := R'SIZE;                  -- ERROR: F

     END RECORD;

BEGIN

     NULL;

END B37004A;
