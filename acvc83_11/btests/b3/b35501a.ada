-- B35501A.ADA

-- CHECK THAT THE ARGUMENT TO 'SUCC, 'PRED,  AND 'POS
-- MUST BE A DISCRETE TYPE. MATCHING OF PARAMETER AND
-- ATTRIBUTE TYPE IS TESTED ELSEWHERE.

-- DAT 3/26/81

PROCEDURE B35501A IS

     SUBTYPE S IS STRING (1..1);
     TYPE F IS DELTA 1.0 RANGE 0.0 .. 2.0;

     PACKAGE PKG IS
          TYPE P IS PRIVATE;
          TYPE L IS LIMITED PRIVATE;
          OP : CONSTANT P;
          OL : CONSTANT L;
     PRIVATE
          TYPE P IS RANGE 0 .. 2;
          TYPE L IS (A, B, C);
          OP : CONSTANT P := 1;
          OL : CONSTANT L := B;
     END PKG;
     USE PKG;

     R : BOOLEAN;
     I : INTEGER;

BEGIN

     R := S'SUCC("A") IN S;                  -- ERROR: NOT DISCRETE.
     R := CHARACTER'SUCC("A") IN CHARACTER;  -- ERROR: NOT DISCRETE.
     R := F'SUCC(1.0) IN F;                  -- ERROR: NOT DISCRETE.
     R := INTEGER'SUCC(1.0) IN INTEGER;      -- ERROR: NOT DISCRETE.
     R := P'SUCC(OP) = OP;                   -- ERROR: PRIVATE.
     R := OL IN L;                           -- OK.
     R := L'SUCC(OL) IN L;                   -- ERROR: LIM PRIV.

     R := S'PRED("B") IN S;                  -- ERROR: NOT DISCRETE.
     R := CHARACTER'PRED("B") IN CHARACTER;  -- ERROR: NOT DISCRETE.
     R := F'PRED(1.0) IN F;                  -- ERROR: NOT DISCRETE.
     R := INTEGER'PRED(1.0) IN INTEGER;      -- ERROR: NOT DISCRETE.
     R := P'PRED(OP) IN P;                   -- ERROR: NOT DISCRETE.
     R := L'PRED(OL) IN L;                   -- ERROR: NOT DISCRETE.

     I := S'POS("A");                        -- ERROR: NOT DISCRETE.
     I := CHARACTER'POS("A");                -- ERROR: NOT DISCRETE.
     I := F'POS(1.0);                        -- ERROR: NOT DISCRETE.
     I := INTEGER'POS(1.0);                  -- ERROR: NOT DISCRETE.
     I := P'POS(OP);                         -- ERROR: NOT DISCRETE.
     I := L'POS(OL);                         -- ERROR: NOT DISCRETE.

END B35501A;
