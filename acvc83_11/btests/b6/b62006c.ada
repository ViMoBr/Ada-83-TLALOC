-- B62006C.ADA

-- CHECK THAT 'FIRST, 'LAST, 'LENGTH, 'RANGE, 'ADDRESS, 'CONSTRAINED,
-- 'SIZE, 'POSITION, 'FIRST_BIT, AND 'LAST_BIT CANNOT BE APPLIED TO AN
-- OUT PARAMETER OF AN ACCESS TYPE.  ALSO THAT THEY MAY NOT BE APPLIED
-- TO AN ACCESS SUBCOMPONENT OF AN OUT PARAMETER.

-- CHECK THAT EXCEPT FOR 'CONSTRAINED, THEY MAY BE APPLIED TO AN IN OR
-- IN OUT FORMAL PARAMETER.

-- SPS 2/17/84
-- JBG 3/30/84
-- JRK 6/24/86   CLARIFIED ERROR COMMENT.

WITH SYSTEM;
PROCEDURE B62006C IS

     TYPE ARR IS ARRAY (1 .. 10) OF NATURAL;
     TYPE ACC_ARR IS ACCESS ARR;
     TYPE REC (D : INTEGER) IS RECORD
          C : ACC_ARR;
     END RECORD;

     TYPE ACC_REC IS ACCESS REC;

     PROCEDURE P (RECRD1 : OUT REC;
                  RECRD2 : IN REC;
                  RECRD3 : IN OUT REC;
                  ACC_REC1 : OUT ACC_REC;
                  ACC_REC2 : IN ACC_REC;
                  ACC_REC3 : IN OUT ACC_REC;
                  ACC_ARR1 : OUT ACC_ARR;
                  ACC_ARR2 : IN ACC_ARR;
                  ACC_ARR3 : IN OUT ACC_ARR) IS

          I : INTEGER;
          B : BOOLEAN;

          PROCEDURE Q (X : SYSTEM.ADDRESS) IS
          BEGIN
               NULL;
          END;

     BEGIN

          I := ACC_ARR1'FIRST;           -- ERROR: FIRST.
          I := ACC_ARR2'FIRST;           -- OK.
          I := ACC_ARR3'FIRST;           -- OK.

          I := ACC_ARR1'LAST;            -- ERROR: LAST.
          I := ACC_ARR2'LAST;            -- OK.
          I := ACC_ARR3'LAST;            -- OK.

          I := ACC_ARR1'LENGTH;          -- ERROR: LENGTH.
          I := ACC_ARR2'LENGTH;          -- OK.
          I := ACC_ARR3'LENGTH;          -- OK.

          FOR I IN ACC_ARR1'RANGE LOOP   -- ERROR: RANGE.
               NULL;
          END LOOP;

          FOR I IN ACC_ARR2'RANGE LOOP   -- OK.
               NULL;
          END LOOP;

          FOR I IN ACC_ARR3'RANGE LOOP   -- OK.
               NULL;
          END LOOP;

          Q(ACC_ARR1'ADDRESS);           -- ERROR: ADDRESS.
          Q(ACC_ARR2'ADDRESS);           -- OK.
          Q(ACC_ARR3'ADDRESS);           -- OK.

          B := ACC_REC1'CONSTRAINED;     -- ERROR: CONSTRAINED.
          B := ACC_REC2'CONSTRAINED;     -- ERROR: CONSTRAINED.
          B := ACC_REC3'CONSTRAINED;     -- ERROR: CONSTRAINED.
          B := ACC_REC1.ALL'CONSTRAINED; -- ERROR: .ALL.
          B := ACC_REC2.ALL'CONSTRAINED; -- OK.
          B := ACC_REC3.ALL'CONSTRAINED; -- OK.

          I := ACC_ARR1'SIZE;            -- ERROR: SIZE.
          I := ACC_ARR2'SIZE;            -- OK.
          I := ACC_ARR3'SIZE;            -- OK.

          I := RECRD1.C'FIRST;           -- ERROR: FIRST.
          I := RECRD2.C'FIRST;           -- OK.
          I := RECRD3.C'FIRST;           -- OK.

          I := RECRD1.C'LAST;            -- ERROR: LAST.
          I := RECRD2.C'LAST;            -- OK.
          I := RECRD3.C'LAST;            -- OK.

          I := RECRD1.C'LENGTH;          -- ERROR: LENGTH.
          I := RECRD2.C'LENGTH;          -- OK.
          I := RECRD3.C'LENGTH;          -- OK.

          FOR I IN RECRD1.C'RANGE LOOP   -- ERROR: RANGE.
               NULL;
          END LOOP;

          FOR I IN RECRD2.C'RANGE LOOP   -- OK.
               NULL;
          END LOOP;

          FOR I IN RECRD3.C'RANGE LOOP   -- OK.
               NULL;
          END LOOP;

          Q(RECRD1.C'ADDRESS);           -- ERROR: ADDRESS.
          Q(RECRD2.C'ADDRESS);           -- OK.
          Q(RECRD3.C'ADDRESS);           -- OK.

          I := RECRD1.C'SIZE;            -- ERROR: SIZE.
          I := RECRD2.C'SIZE;            -- OK.
          I := RECRD3.C'SIZE;            -- OK.

          I := RECRD1.C'POSITION;        -- ERROR: POSITION.
          I := RECRD2.C'POSITION;        -- OK.
          I := RECRD3.C'POSITION;        -- OK.

          I := RECRD1.C'FIRST_BIT;       -- ERROR: FIRST_BIT.
          I := RECRD2.C'FIRST_BIT;       -- OK.
          I := RECRD3.C'FIRST_BIT;       -- OK.

          I := RECRD1.C'LAST_BIT;        -- ERROR: LAST_BIT.
          I := RECRD2.C'LAST_BIT;        -- OK.
          I := RECRD3.C'LAST_BIT;        -- OK.

     END P;

BEGIN
     NULL;
END B62006C;
