-- B85007C.ADA

-- CHECK THAT 'FIRST, 'LAST, 'LENGTH, 'RANGE, 'ADDRESS, 'SIZE,
-- 'POSITION, 'FIRST_BIT, AND 'LAST_BIT CANNOT BE APPLIED TO A RENAMED
-- OUT PARAMETER OF AN ACCESS TYPE.  ALSO THAT THEY MAY NOT BE APPLIED 
-- TO A RENAMED ACCESS SUBCOMPONENT OF AN OUT PARAMETER.

-- CHECK THAT 'POSITION, 'FIRST_BIT, AND 'LAST_BIT CANNOT BE APPLIED TO
-- A RENAMED RECORD COMPONENT.

-- SPS 02/17/84 (SEE B62006C-B.ADA)
-- EG  02/21/84
-- JBG 12/2/84

WITH SYSTEM;

PROCEDURE B85007C IS

     TYPE ARR IS ARRAY (1 .. 10) OF NATURAL;
     TYPE ACC_ARR IS ACCESS ARR;
     TYPE REC IS RECORD
          C : ACC_ARR;
          D : INTEGER;
     END RECORD;

     PROCEDURE PROC (RECRD1 : OUT REC;
                     ACC_AR1 : OUT ACC_ARR) IS

          I : INTEGER;
          A : SYSTEM.ADDRESS;

          R1 : REC     RENAMES RECRD1;
          R2 : REC     RENAMES R1;
          R3 : ACC_ARR RENAMES RECRD1.C;
          R4 : ACC_ARR RENAMES R1.C;
          R5 : INTEGER RENAMES RECRD1.D;
          A1 : ACC_ARR RENAMES ACC_AR1;
          A2 : ACC_ARR RENAMES A1;

     BEGIN

          I := A1'FIRST;             -- ERROR: FIRST.
          I := A1'LAST;              -- ERROR: LAST.
          I := A1'LENGTH;            -- ERROR: LENGTH.
          FOR I IN A1'RANGE LOOP     -- ERROR: RANGE.
               NULL;
          END LOOP;
          A := A1'ADDRESS;           -- ERROR: ADDRESS.
          I := A1'SIZE;              -- ERROR: SIZE.
          I := A2'FIRST;             -- ERROR: FIRST.
          I := A2'LAST;              -- ERROR: LAST.
          I := A2'LENGTH;            -- ERROR: LENGTH.
          FOR I IN A2'RANGE LOOP     -- ERROR: RANGE.
               NULL;
          END LOOP;
          A := A2'ADDRESS;           -- ERROR: ADDRESS.
          I := A2'SIZE;              -- ERROR: SIZE.
          I := R1.C'FIRST;           -- ERROR: FIRST.
          I := R1.C'LAST;            -- ERROR: LAST.
          I := R1.C'LENGTH;          -- ERROR: LENGTH.
          FOR I IN R1.C'RANGE LOOP   -- ERROR: RANGE.
               NULL;
          END LOOP;
          A := R1.C'ADDRESS;         -- ERROR: ADDRESS.
          I := R1.C'SIZE;            -- ERROR: SIZE.
          I := R1.C'POSITION;        -- ERROR: POSITION.
          I := R1.C'FIRST_BIT;       -- ERROR: FIRST_BIT.
          I := R1.C'LAST_BIT;        -- ERROR: LAST_BIT.
          I := R2.C'FIRST;           -- ERROR: FIRST.
          I := R2.C'LAST;            -- ERROR: LAST.
          I := R2.C'LENGTH;          -- ERROR: LENGTH.
          FOR I IN R2.C'RANGE LOOP   -- ERROR: RANGE.
               NULL;
          END LOOP;
          A := R2.C'ADDRESS;         -- ERROR: ADDRESS.
          I := R2.C'SIZE;            -- ERROR: SIZE.
          I := R2.C'POSITION;        -- ERROR: POSITION.
          I := R2.C'FIRST_BIT;       -- ERROR: FIRST_BIT.
          I := R2.C'LAST_BIT;        -- ERROR: LAST_BIT.
          I := R3'FIRST;             -- ERROR: FIRST.
          I := R3'LAST;              -- ERROR: LAST.
          I := R3'LENGTH;            -- ERROR: LENGTH.
          FOR I IN R3'RANGE LOOP     -- ERROR: RANGE.
               NULL;
          END LOOP;
          A := R3'ADDRESS;           -- ERROR: ADDRESS.
          I := R3'SIZE;              -- ERROR: SIZE.
          I := R3'POSITION;          -- ERROR: POSITION.
          I := R3'FIRST_BIT;         -- ERROR: FIRST_BIT.
          I := R3'LAST_BIT;          -- ERROR: LAST_BIT.
          I := R4'FIRST;             -- ERROR: FIRST.
          I := R4'LAST;              -- ERROR: LAST.
          I := R4'LENGTH;            -- ERROR: LENGTH.
          FOR I IN R4'RANGE LOOP     -- ERROR: RANGE.
               NULL;
          END LOOP;
          A := R4'ADDRESS;           -- ERROR: ADDRESS.
          I := R4'SIZE;              -- ERROR: SIZE.
          I := R4'POSITION;          -- ERROR: POSITION.
          I := R4'FIRST_BIT;         -- ERROR: FIRST_BIT.
          I := R4'LAST_BIT;          -- ERROR: LAST_BIT.

          I := R5'POSITION;          -- ERROR: POSITION.
          I := R5'FIRST_BIT;         -- ERROR: FIRST_BIT.
          I := R5'LAST_BIT;          -- ERROR: LAST_BIT.

     END PROC;

BEGIN

     NULL;

END B85007C;
