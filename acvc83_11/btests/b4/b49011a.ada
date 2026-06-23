-- B49011A.ADA

-- CHECK THAT A STATIC SUBTYPE CANNOT BE A GENERIC FORMAL TYPE, A
-- SUBTYPE OF A GENERIC FORMAL TYPE, OR A TYPE DERIVED INDIRECTLY
-- FROM A GENERIC FORMAL TYPE.

-- L.BROWN  09/19/86

PROCEDURE  B49011A  IS

     TYPE ENUM IS (RED,GREEN,BLUE,BLACK);
     TYPE FT IS DIGITS 5 RANGE 0.0 .. 25.0;
     TYPE FX IS DELTA 3.0 RANGE 0.0 .. 25.0;

     GENERIC
          TYPE R IS DIGITS <>;
          TYPE T IS RANGE <>;
     PACKAGE PACK IS
          SUBTYPE NR IS R RANGE R'FIRST .. R'LAST;
          SUBTYPE NT IS T RANGE 1 .. 10;
          TYPE INT IS RANGE 1 .. NT'(10);                  -- ERROR: NT.
          TYPE FLT IS DIGITS NR'DIGITS;                    -- ERROR: NR.
     END PACK;

     GENERIC
          TYPE T IS (<>);
     FUNCTION FUN RETURN T;
     FUNCTION FUN RETURN T IS
          TYPE S IS NEW T;
          SUBTYPE SS IS S RANGE S'FIRST .. S'PRED(S'LAST);
          XS : CONSTANT := S'POS(S'FIRST);                 -- ERROR: S.
          XT : CONSTANT := T'POS(T'LAST);                  -- ERROR: T.
          XY : CONSTANT := SS'POS(SS'FIRST);               -- ERROR: SS.
     BEGIN
          RETURN T'FIRST;
     END FUN;

     GENERIC
          TYPE FXT IS DELTA <>;
     PROCEDURE PROC;
     PROCEDURE PROC IS
          TYPE F IS NEW FXT;
          TYPE FTX IS NEW F;
          SUBTYPE SFTX IS FTX RANGE FTX'FIRST .. FTX'LAST;
          TYPE X IS DIGITS 5 RANGE SFTX'FIRST .. 10.0;     -- ERROR:
                                                           --    SFTX.
          TYPE FTX1 IS DELTA FTX'(1.0) RANGE 0.0 .. 10.0;  -- ERROR:
                                                           --     FTX.
          TYPE XS IS DELTA 0.25 RANGE 0.0 .. F'LAST;       -- ERROR: F.
          TYPE FXOT IS DELTA FXT'(1.0) RANGE 0.0 .. 10.0;  -- ERROR:
                                                           --     FXT.
     BEGIN
          NULL;
     END PROC;

     PACKAGE PACK1 IS NEW PACK(FT,INTEGER);
     FUNCTION FUN2 IS NEW FUN(ENUM);
     PROCEDURE PROC2 IS NEW PROC(FX);

BEGIN
     NULL;
END B49011A;
