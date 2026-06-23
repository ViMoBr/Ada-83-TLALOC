-- B62006E.ADA

-- OBJECTIVE:
--     CHECK THAT AN OUT PARAMETER OR PARAMETER COMPONENT OF AN ACCESS
--     TYPE CANNOT BE USED IN A SELECTED COMPONENT, INDEXED COMPONENT
--     OR SLICE. (REF: LRM 4.1/4.)

-- HISTORY:
--     SPS 02/21/84 CREATED ORIGINAL TEST.
--     DHH 08/16/88 REVISED HEADER AND ENTERED TEST FOR RECORD
--                  DISCRIMINANT.

PROCEDURE B62006E IS

     TYPE ARR_BASE IS ARRAY (INTEGER RANGE <>) OF BOOLEAN;
     SUBTYPE ARR IS ARR_BASE (1..10);
     TYPE ACC_ARR IS ACCESS ARR;
     TYPE RC(T : BOOLEAN := TRUE) IS
          RECORD
               X : BOOLEAN;
          END RECORD;
     TYPE ACC_RC IS ACCESS RC;

     TYPE REC IS
          RECORD
               C : ACC_ARR;
               D : ACC_RC;
          END RECORD;

     PROCEDURE P (C1 : OUT REC; C2 : OUT ACC_ARR; C3 : OUT ACC_RC) IS
          B : BOOLEAN;
          I : INTEGER;
          AR: ARR_BASE(3..3);
     BEGIN
          B := C2(1);                   -- ERROR: INDEX SELECTION.
          AR := C2(3 .. 3);             -- ERROR: SLICE.
          B := C3.T;                    -- ERROR: DISCRIMINANT SELECTION
          B := C1.D.T;                  -- ERROR: DISCRIMINANT COMPONENT
          B := C1.D.X;                  -- ERROR: COMPONENT SELECTION
          B := C1.C.ALL (5);            -- ERROR: INDEX SELECTION
          AR := C1.C(7 .. 7);           -- ERROR: SLICE
     END P;

BEGIN
     NULL;
END B62006E;
