-- D64005EE.ADA

-- JRK 7/30/84
-- CPP 8/1/84

SEPARATE (D64005E0M.D64005EA.D64005EB.D64005EC.D64005ED)

PROCEDURE D64005EE (L : LEVEL; C : CALL; T : IN OUT TRACE) IS

     V : STRING (1..2);

     M : CONSTANT NATURAL := LEVEL'POS (L) -
                             LEVEL'POS (LEVEL'FIRST) + 1;
     N : CONSTANT NATURAL := 2 * M + 1;

     PROCEDURE D64005EF (L : LEVEL; C : CALL; T : IN OUT TRACE) IS
          SEPARATE;

BEGIN

     V (1) := IDENT_CHAR (ASCII.LC_E);
     V (2) := C;

     -- APPEND ALL V TO T.
     T.S (T.E+1 .. T.E+N) := D64005E0M.V & D64005EA.V & D64005EB.V &
                             D64005EC.V & D64005ED.V & D64005EE.V;
     T.E := T.E + N;

     CASE C IS

          WHEN '1' =>
               D64005EF (LEVEL'SUCC(L), IDENT_CHAR('1'), T);

          WHEN '2' =>
               D64005EE (L, IDENT_CHAR('3'), T);

          WHEN '3' =>
               D64005EF (LEVEL'SUCC(L), IDENT_CHAR('2'), T);
     END CASE;

     -- APPEND ALL L AND C TO T IN REVERSE ORDER.
     T.S (T.E+1 .. T.E+N) := D64005EE.L & D64005EE.C &
                             D64005ED.L & D64005ED.C &
                             D64005EC.L & D64005EC.C &
                             D64005EB.L & D64005EB.C &
                             D64005EA.L & D64005EA.C &
                             D64005E0M.L;
     T.E := T.E + N;

END D64005EE;
