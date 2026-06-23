-- D64005EB.ADA

-- JRK 7/30/84
-- CPP 8/1/84

SEPARATE (D64005E0M.D64005EA)

PROCEDURE D64005EB (L : LEVEL; C : CALL; T : IN OUT TRACE) IS

     V : STRING (1..2);

     M : CONSTANT NATURAL := LEVEL'POS (L) -
                             LEVEL'POS (LEVEL'FIRST) + 1;
     N : CONSTANT NATURAL := 2 * M + 1;

     PROCEDURE D64005EC (L : LEVEL; C : CALL; T : IN OUT TRACE) IS
          SEPARATE;

BEGIN

     V (1) := IDENT_CHAR (ASCII.LC_B);
     V (2) := C;

     -- APPEND ALL V TO T.
     T.S (T.E+1 .. T.E+N) := D64005E0M.V & D64005EA.V & D64005EB.V;
     T.E := T.E + N;

     CASE C IS

          WHEN '1' =>
               D64005EC (LEVEL'SUCC(L), IDENT_CHAR('1'), T);

          WHEN '2' =>
               D64005EB (L, IDENT_CHAR('3'), T);

          WHEN '3' =>
               D64005EC (LEVEL'SUCC(L), IDENT_CHAR('2'), T);
     END CASE;

     -- APPEND ALL L AND C TO T IN REVERSE ORDER.
     T.S (T.E+1 .. T.E+N) := D64005EB.L & D64005EB.C &
                             D64005EA.L & D64005EA.C &
                             D64005E0M.L;
     T.E := T.E + N;

END D64005EB;
