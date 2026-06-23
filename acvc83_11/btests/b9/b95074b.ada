-- B95074B.ADA

-- CHECK THAT 'FIRST, 'LAST, 'LENGTH, 'RANGE, 'ADDRESS, 'SIZE,
-- 'POSITION, 'FIRST_BIT, AND 'LAST_BIT CANNOT BE APPLIED TO AN OUT
-- PARAMETER OF AN ACCESS TYPE.  ALSO THAT THEY MAY NOT BE APPLIED
-- TO AN ACCESS SUBCOMPONENT OF AN OUT PARAMETER.

-- JWC 6/24/85

WITH SYSTEM;
PROCEDURE B95074B IS

     TYPE ARR IS ARRAY (1 .. 10) OF NATURAL;
     TYPE ACC_ARR IS ACCESS ARR;

     TYPE REC IS RECORD
          C : ACC_ARR;
     END RECORD;

     TASK T IS
          ENTRY E (RECRD1 : OUT REC;
                   RECRD2 : IN REC;
                   RECRD3 : IN OUT REC;
                   ACC_ARR1 : OUT ACC_ARR;
                   ACC_ARR2 : IN ACC_ARR;
                   ACC_ARR3 : IN OUT ACC_ARR);
     END T;

     TASK BODY T IS

          I : INTEGER;

          PROCEDURE Q (X : SYSTEM.ADDRESS) IS
          BEGIN
               NULL;
          END;

     BEGIN

          ACCEPT E (RECRD1 : OUT REC;
                    RECRD2 : IN REC;
                    RECRD3 : IN OUT REC;
                    ACC_ARR1 : OUT ACC_ARR;
                    ACC_ARR2 : IN ACC_ARR;
                    ACC_ARR3 : IN OUT ACC_ARR) DO

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
          END E;

     END T;

BEGIN
     NULL;
END B95074B;
