-- B74207A.ADA

-- CHECK THAT 'CONSTRAINED CANNOT BE APPPLIED TO A PRIVATE TYPE UNTIL
-- AFTER ITS FULL DECLARATION, NOR IS IT ALLOWED FOR A COMPOSITE TYPE
-- CONTAINING A COMPONENT OF A PRIVATE TYPE, NOR IS IT ALLOWED AFTER THE
-- FULL DECLARATION IF THE FULL DECLARATION IS NOT DERIVED FROM A
-- PRIVATE TYPE.

-- CHECK THAT NO ATTRIBUTES EXCEPT 'BASE, 'SIZE, AND 'CONSTRAINED CAN BE
-- APPLIED TO A PRIVATE TYPE OUTSIDE ITS PACKAGE.  IN PARTICULAR, CHECK
-- THAT ATTRIBUTES LEGAL FOR THE FULL DECLARATION OF THE PRIVATE TYPE
-- ARE NOT ALLOWED:

--     FOR FIXED POINT: 'AFT, 'DELTA, 'FIRST, 'FORE, 'LARGE, 'LAST,
--        'MACHINE_OVERFLOWS, 'MACHINE_ROUNDS, 'MANTISSA, 'SAFE_LARGE,
--        'SAFE_SMALL, 'SMALL.

--     FOR FLOATING POINT: 'DIGITS, 'EMAX, 'EPSILON, 'FIRST, 'LARGE,
--        'LAST, 'MACHINE_EMAX, 'MACHINE_EMIN, 'MACHINE_MANTISSA,
--        'MACHINE_OVERFLOWS, 'MACHINE_RADIX, 'MACHINE_ROUNDS,
--        'MANTISSA, 'SAFE_EMAX, 'SAFE_LARGE, 'SAFE_SMALL, 'SMALL.

--     FOR INTEGER: 'FIRST, 'IMAGE, 'LAST, 'POS, 'PRED, 'SUCC, 'VAL,
--        'VALUE, 'WIDTH.

--     FOR ARRAY: 'FIRST, 'LAST, 'LENGTH, 'RANGE.

--     FOR ACCESS: 'STORAGE_SIZE.

--     FOR TASK: 'STORAGE_SIZE.

-- DSJ 4/29/83
-- JBG 8/21/83
-- JBG 9/22/83
-- JRK 1/6/84
-- JRK 8/24/84
-- JBG 11/8/85 AVOID CONFLICT WITH AI-7 AND AI-275

PROCEDURE B74207A IS

     PACKAGE P IS
          TYPE PD (D : INTEGER) IS PRIVATE;
          TYPE LPD (D : INTEGER) IS LIMITED PRIVATE;
          TYPE P IS PRIVATE;
          TYPE LP IS LIMITED PRIVATE;
          TYPE LPB IS LIMITED PRIVATE;

          TYPE REC IS
               RECORD
--                  A : PD(3);
--                  B : LPD(3);
                    C : P;
                    D : LP;
               END RECORD;

          CP1  : BOOLEAN := P'CONSTRAINED;     -- ERROR: P INCOMPLETE.
          CLP1 : BOOLEAN := LP'CONSTRAINED;    -- ERROR: LP INCOMPLETE.
          CPD1 : BOOLEAN := PD'CONSTRAINED;    -- ERROR: PD INCOMPLETE.
          CLPD1: BOOLEAN := LPD'CONSTRAINED;   -- ERROR: LPD INCOMPLETE.
          CREC1: BOOLEAN := REC'CONSTRAINED;   -- ERROR: REC INCOMPLETE.

     PRIVATE
          CP2  : BOOLEAN := P'CONSTRAINED;     -- ERROR: USE OF P.
          CLP2 : BOOLEAN := LP'CONSTRAINED;    -- ERROR: USE OF LP.
          CPD2 : BOOLEAN := PD'CONSTRAINED;    -- ERROR: PD INCOMPLETE.
          CLPD2: BOOLEAN := LPD'CONSTRAINED;   -- ERROR: LPD INCOMPLETE.
          CREC2: BOOLEAN := REC'CONSTRAINED;   -- ERROR: REC INCOMPLETE.

          TYPE P IS RANGE 1 .. 2;
          TYPE LP IS RANGE 3 .. 4;
          TYPE LPB IS NEW BOOLEAN
                    RANGE LPB'CONSTRAINED .. FALSE;  -- ERROR: LPB NOT
                                                     --        VISIBLE.
          TYPE PD (D : INTEGER) IS RECORD NULL; END RECORD;
          TYPE LPD(D : INTEGER) IS RECORD NULL; END RECORD;

          C_P  : BOOLEAN := P'CONSTRAINED;     -- ERROR: NOT PRIVATE.
          C_LP : BOOLEAN := LP'CONSTRAINED;    -- ERROR: NOT PRIVATE.
          C_PD : BOOLEAN := PD'CONSTRAINED;    -- ERROR: NOT PRIVATE.
          C_LPD: BOOLEAN := LPD'CONSTRAINED;   -- ERROR: NOT PRIVATE.
          C_REC: BOOLEAN := REC'CONSTRAINED;   -- ERROR: NOT PRIVATE.

     END P;

     PACKAGE Q IS
          TYPE FIX IS PRIVATE;
          TYPE FLT IS LIMITED PRIVATE;
          TYPE INT IS PRIVATE;
          TYPE ARR IS LIMITED PRIVATE;
          TYPE REC IS PRIVATE;
          TYPE RECD (D : INTEGER) IS LIMITED PRIVATE;
          TYPE ACC IS PRIVATE;
          TYPE TSK IS LIMITED PRIVATE;
     PRIVATE
          TYPE FIX IS DELTA 0.5 RANGE -10.0 .. 10.0;
          TYPE FLT IS DIGITS 1;
          TYPE INT IS RANGE -10 .. 10;
          TYPE ARR IS ARRAY (1..2) OF INTEGER;
          TYPE REC IS
               RECORD NULL; END RECORD;
          TYPE RECD (D : INTEGER) IS
               RECORD NULL; END RECORD;
          TYPE ACC IS ACCESS ARR;
          TASK TYPE TSK;

          FIX0 : INTEGER := FIX'SIZE;        -- OK.
          FIX1 : BOOLEAN := FIX'CONSTRAINED; -- ERROR: CONSTRAINED.
          FIX2 : INTEGER := FIX'BASE'SIZE;   -- OK.
          FIXA : INTEGER  := FIX'AFT;        -- OK: 'AFT.
          FIXB : FLOAT    := FIX'DELTA;      -- OK: 'DELTA.
          FIXC : FIX      := FIX'FIRST;      -- OK: 'FIRST.
          FIXD : INTEGER  := FIX'FORE;       -- OK: 'FORE.
          FIXE : FLOAT    := FIX'LARGE;      -- OK: 'LARGE.
          FIXF : FIX      := FIX'LAST;       -- OK: 'LAST.
          FIXG : BOOLEAN := FIX'MACHINE_OVERFLOWS; -- OK: ATTR.
          FIXH : BOOLEAN := FIX'MACHINE_ROUNDS;    -- OK: ATTR.
          FIXI : INTEGER  := FIX'MANTISSA;   -- OK: 'MANTISSA.
          FIXJ : FLOAT    := FIX'SAFE_LARGE; -- OK: 'SAFE_LARGE.
          FIXK : FLOAT    := FIX'SAFE_SMALL; -- OK: 'SAFE_SMALL.
          FIXL : FLOAT    := FIX'SMALL;      -- OK: 'SMALL.

          FLT0 : INTEGER := FLT'SIZE;        -- OK.
          FLT1 : BOOLEAN := FLT'CONSTRAINED; -- ERROR: CONSTRAINED.
          FLT2 : INTEGER := FLT'BASE'SIZE;   -- OK.
          FLTA : INTEGER  := FLT'DIGITS;     -- OK: 'DIGITS.
          FLTB : INTEGER  := FLT'EMAX;       -- OK: 'EMAX.
          FLTC : FLOAT    := FLT'EPSILON;    -- OK: 'EPSILON.
          FLTD : FLT      := FLT'FIRST;      -- OK: 'FIRST.
          FLTE : FLOAT    := FLT'LARGE;      -- OK: 'LARGE.
          FLTF : FLT      := FLT'LAST;       -- OK: 'LAST.
          FLTG : INTEGER  := FLT'MACHINE_EMAX;    -- OK: ATTR.
          FLTH : INTEGER  := FLT'MACHINE_EMIN;    -- OK: ATTR.
          FLTI : INTEGER  := FLT'MACHINE_MANTISSA;-- OK: ATTR.
          FLTJ : BOOLEAN  := FLT'MACHINE_OVERFLOWS;-- OK: ATTR.
          FLTK : INTEGER  := FLT'MACHINE_RADIX;   -- OK: ATTR.
          FLTL : BOOLEAN  := FLT'MACHINE_ROUNDS;  -- OK: ATTR.
          FLTM : INTEGER  := FLT'MANTISSA;   -- OK: 'MANTISSA.
          FLTN : INTEGER  := FLT'SAFE_EMAX;  -- OK: 'SAFE_EMAX.
          FLTO : FLOAT    := FLT'SAFE_LARGE; -- OK: 'SAFE_LARGE.
          FLTP : FLOAT    := FLT'SAFE_SMALL; -- OK: 'SAFE_SMALL.
          FLTQ : FLOAT    := FLT'SMALL;      -- OK: 'SMALL.

          INT0 : INTEGER := INT'SIZE;        -- OK.
          INT1 : BOOLEAN := INT'CONSTRAINED; -- ERROR: CONSTRAINED.
          INT2 : INTEGER := INT'BASE'SIZE;   -- OK.
          INTA : INT     := INT'FIRST;       -- OK: 'FIRST.
          X : INT;
          INTB : STRING (1..3) := INT'IMAGE(X);   -- OK: 'IMAGE.
          INTC : INT     := INT'LAST;        -- OK: 'LAST.
          INTD : INT     := INT'POS(X);      -- OK: 'POS.
          INTE : INT     := INT'PRED(X);     -- OK: 'PRED.
          INTF : INT     := INT'SUCC(X);     -- OK: 'SUCC.
          INTG : INT     := INT'VAL(1);      -- OK: 'VAL.
          INTH : INT     := INT'VALUE("1");  -- OK: 'VALUE.
          INTI : INTEGER := INT'WIDTH;       -- OK: 'WIDTH.

          ARR0 : INTEGER := ARR'SIZE;        -- OK.
          ARR1 : BOOLEAN := ARR'CONSTRAINED; -- ERROR: CONSTRAINED.
          ARR2 : INTEGER := ARR'BASE'SIZE;   -- OK.
          ARRA : INTEGER := ARR'FIRST;       -- OK: 'FIRST.
          ARRB : INTEGER := ARR'LAST;        -- OK: 'LAST.
          ARRC : INTEGER := ARR'LENGTH;      -- OK: 'LENGTH.
          ARRD : BOOLEAN := 3 IN ARR'RANGE;  -- OK: 'RANGE.

          REC0 : INTEGER := REC'SIZE;        -- OK.
          REC1 : BOOLEAN := REC'CONSTRAINED; -- ERROR: CONSTRAINED.
          REC2 : INTEGER := REC'BASE'SIZE;   -- OK.

          RECD0 : INTEGER := RECD'SIZE;        -- OK.
          RECD1 : BOOLEAN := RECD'CONSTRAINED; -- ERROR: NOT PRIV.
          RECD2 : INTEGER := RECD'BASE'SIZE;   -- OK.

          ACC0 : INTEGER := ACC'SIZE;        -- OK.
          ACC1 : BOOLEAN := ACC'CONSTRAINED; -- ERROR: CONSTRAINED.
          ACC2 : INTEGER := ACC'BASE'SIZE;   -- OK.
          ACCA : INTEGER := ACC'STORAGE_SIZE;-- OK: ATTR.

          TSK0 : INTEGER := TSK'SIZE;        -- OK.
          TSK1 : BOOLEAN := TSK'CONSTRAINED; -- ERROR: CONSTRAINED.
          TSK2 : INTEGER := TSK'BASE'SIZE;   -- OK.
          TSKA : INTEGER := TSK'STORAGE_SIZE;-- OK: ATTR.

     END Q;

     PACKAGE BODY Q IS
          TASK BODY TSK IS
          BEGIN
               NULL;
          END TSK;
     END Q;
     USE Q;

     PROCEDURE FLTFLT (X : FLT) IS
     BEGIN
          NULL;
     END FLTFLT;

     PACKAGE TEST_ATTRIBUTES IS
          FIX0 : INTEGER := FIX'SIZE;        -- OK.
          FIX1 : BOOLEAN := FIX'CONSTRAINED; -- OK.
          FIX2 : INTEGER := FIX'BASE'SIZE;   -- OK.
          FIXA : INTEGER  := FIX'AFT;        -- ERROR: 'AFT.
          FIXB : FLOAT    := FIX'DELTA;      -- ERROR: 'DELTA.
          FIXC : FIX      := FIX'FIRST;      -- ERROR: 'FIRST.
          FIXD : INTEGER  := FIX'FORE;       -- ERROR: 'FORE.
          FIXE : FLOAT    := FIX'LARGE;      -- ERROR: 'LARGE.
          FIXF : FIX      := FIX'LAST;       -- ERROR: 'LAST.
          FIXG : BOOLEAN := FIX'MACHINE_OVERFLOWS; -- ERROR: ATTR.
          FIXH : BOOLEAN := FIX'MACHINE_ROUNDS;    -- ERROR: ATTR.
          FIXI : INTEGER  := FIX'MANTISSA;   -- ERROR: 'MANTISSA.
          FIXJ : FLOAT    := FIX'SAFE_LARGE; -- ERROR: 'SAFE_LARGE.
          FIXK : FLOAT    := FIX'SAFE_SMALL; -- ERROR: 'SAFE_SMALL.
          FIXL : FLOAT    := FIX'SMALL;      -- ERROR: 'SMALL.

          FLT0 : INTEGER := FLT'SIZE;        -- OK.
          FLT1 : BOOLEAN := FLT'CONSTRAINED; -- OK.
          FLT2 : INTEGER := FLT'BASE'SIZE;   -- OK.
          FLTA : INTEGER  := FLT'DIGITS;     -- ERROR: 'DIGITS.
          FLTB : INTEGER  := FLT'EMAX;       -- ERROR: 'EMAX.
          FLTC : FLOAT    := FLT'EPSILON;    -- ERROR: 'EPSILON.
          FLTE : FLOAT    := FLT'LARGE;      -- ERROR: 'LARGE.
          FLTG : INTEGER  := FLT'MACHINE_EMAX;    -- ERROR: ATTR.
          FLTH : INTEGER  := FLT'MACHINE_EMIN;    -- ERROR: ATTR.
          FLTI : INTEGER  := FLT'MACHINE_MANTISSA;-- ERROR: ATTR.
          FLTJ : BOOLEAN  := FLT'MACHINE_OVERFLOWS;-- ERROR: ATTR.
          FLTK : INTEGER  := FLT'MACHINE_RADIX;   -- ERROR: ATTR.
          FLTL : BOOLEAN  := FLT'MACHINE_ROUNDS;  -- ERROR: ATTR.
          FLTM : INTEGER  := FLT'MANTISSA;   -- ERROR: 'MANTISSA.
          FLTN : INTEGER  := FLT'SAFE_EMAX;  -- ERROR: 'SAFE_EMAX.
          FLTO : FLOAT    := FLT'SAFE_LARGE; -- ERROR: 'SAFE_LARGE.
          FLTP : FLOAT    := FLT'SAFE_SMALL; -- ERROR: 'SAFE_SMALL.
          FLTQ : FLOAT    := FLT'SMALL;      -- ERROR: 'SMALL.

          INT0 : INTEGER := INT'SIZE;        -- OK.
          INT1 : BOOLEAN := INT'CONSTRAINED; -- OK.
          INT2 : INTEGER := INT'BASE'SIZE;   -- OK.
          INTA : INT     := INT'FIRST;       -- ERROR: 'FIRST.
          X : INT;
          INTB : STRING (1..3) := INT'IMAGE(X);   -- ERROR: 'IMAGE.
          INTC : INT     := INT'LAST;        -- ERROR: 'LAST.
          INTD : INT     := INT'POS(X);      -- ERROR: 'POS.
          INTE : INT     := INT'PRED(X);     -- ERROR: 'PRED.
          INTF : INT     := INT'SUCC(X);     -- ERROR: 'SUCC.
          INTG : INT     := INT'VAL(1);      -- ERROR: 'VAL.
          INTH : INT     := INT'VALUE("1");  -- ERROR: 'VALUE.
          INTI : INTEGER := INT'WIDTH;       -- ERROR: 'WIDTH.

          ARR0 : INTEGER := ARR'SIZE;        -- OK.
          ARR1 : BOOLEAN := ARR'CONSTRAINED; -- OK.
          ARR2 : INTEGER := ARR'BASE'SIZE;   -- OK.
          ARRA : INTEGER := ARR'FIRST;       -- ERROR: 'FIRST.
          ARRB : INTEGER := ARR'LAST;        -- ERROR: 'LAST.
          ARRC : INTEGER := ARR'LENGTH;      -- ERROR: 'LENGTH.
          ARRD : BOOLEAN := 3 IN ARR'RANGE;  -- ERROR: 'RANGE.

          REC0 : INTEGER := REC'SIZE;        -- OK.
          REC1 : BOOLEAN := REC'CONSTRAINED; -- OK.
          REC2 : INTEGER := REC'BASE'SIZE;   -- OK.

          RECD0 : INTEGER := RECD'SIZE;        -- OK.
          RECD1 : BOOLEAN := RECD'CONSTRAINED; -- OK.
          RECD2 : INTEGER := RECD'BASE'SIZE;   -- OK.

          ACC0 : INTEGER := ACC'SIZE;        -- OK.
          ACC1 : BOOLEAN := ACC'CONSTRAINED; -- OK.
          ACC2 : INTEGER := ACC'BASE'SIZE;   -- OK.
          ACCA : INTEGER := ACC'STORAGE_SIZE;-- ERROR: ATTR.

          TSK0 : INTEGER := TSK'SIZE;        -- OK.
          TSK1 : BOOLEAN := TSK'CONSTRAINED; -- OK.
          TSK2 : INTEGER := TSK'BASE'SIZE;   -- OK.
          TSKA : INTEGER := TSK'STORAGE_SIZE;-- ERROR: ATTR.

     END TEST_ATTRIBUTES;

     PACKAGE BODY TEST_ATTRIBUTES IS
     BEGIN
          FLTFLT (FLT'FIRST);                -- ERROR: 'FIRST.
          FLTFLT (FLT'LAST);                 -- ERROR: 'LAST.
     END TEST_ATTRIBUTES;

BEGIN

     NULL;

END B74207A;
