-- D64005GI.ADA

-- JRK 7/30/84
-- CPP 8/2/84

SEPARATE (D64005G0M.D64005GA.D64005GB.D64005GC.D64005GD.D64005GE.
          D64005GF.D64005GG.D64005GH)

PROCEDURE D64005GI (L : LEVEL; C : CALL; T : IN OUT TRACE) IS

     V : STRING (1..2);

     M : CONSTANT NATURAL := LEVEL'POS (L) -
                             LEVEL'POS (LEVEL'FIRST) + 1;
     N : CONSTANT NATURAL := 2 * M + 1;

     PROCEDURE D64005GJ (L : LEVEL; C : CALL; T : IN OUT TRACE) IS
          SEPARATE;

BEGIN

     V (1) := IDENT_CHAR (ASCII.LC_I);
     V (2) := C;

     -- APPEND ALL V TO T.
     T.S (T.E+1 .. T.E+N) := D64005G0M.V & D64005GA.V & D64005GB.V &
                             D64005GC.V & D64005GD.V & D64005GE.V &
                             D64005GF.V & D64005GG.V & D64005GH.V &
                             D64005GI.V;
     T.E := T.E + N;

     CASE C IS

          WHEN '1' =>
               D64005GJ (LEVEL'SUCC(L), IDENT_CHAR('1'), T);

          WHEN '2' =>
               D64005GI (L, IDENT_CHAR('3'), T);

          WHEN '3' =>
               D64005GJ (LEVEL'SUCC(L), IDENT_CHAR('2'), T);
     END CASE;

     -- APPEND ALL L AND C TO T IN REVERSE ORDER.
     T.S (T.E+1 .. T.E+N) := D64005GI.L & D64005GI.C &
                             D64005GH.L & D64005GH.C &
                             D64005GG.L & D64005GG.C &
                             D64005GF.L & D64005GF.C &
                             D64005GE.L & D64005GE.C &
                             D64005GD.L & D64005GD.C &
                             D64005GC.L & D64005GC.C &
                             D64005GB.L & D64005GB.C &
                             D64005GA.L & D64005GA.C &
                             D64005G0M.L;
     T.E := T.E + N;

END D64005GI;
