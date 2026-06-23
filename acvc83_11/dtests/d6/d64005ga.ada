-- D64005GA.ADA

-- JRK 7/30/84
-- CPP 8/2/84

SEPARATE (D64005G0M)

PROCEDURE D64005GA (L : LEVEL; C : CALL; T : IN OUT TRACE) IS

     V : STRING (1..2);

     M : CONSTANT NATURAL := LEVEL'POS (L) -
                             LEVEL'POS (LEVEL'FIRST) + 1;
     N : CONSTANT NATURAL := 2 * M + 1;

     PROCEDURE D64005GB (L : LEVEL; C : CALL; T : IN OUT TRACE) IS
          SEPARATE;

BEGIN

     V (1) := IDENT_CHAR (ASCII.LC_A);
     V (2) := C;

     -- APPEND ALL V TO T.
     T.S (T.E+1 .. T.E+N) := D64005G0M.V & D64005GA.V;
     T.E := T.E + N;

     CASE C IS

          WHEN '1' =>
               D64005GB (LEVEL'SUCC(L), IDENT_CHAR('1'), T);

          WHEN '2' =>
               D64005GA (L, IDENT_CHAR('3'), T);

          WHEN '3' =>
               D64005GB (LEVEL'SUCC(L), IDENT_CHAR('2'), T);
     END CASE;

     -- APPEND ALL L AND C TO T IN REVERSE ORDER.
     T.S (T.E+1 .. T.E+N) := D64005GA.L & D64005GA.C & D64005G0M.L;
     T.E := T.E + N;

END D64005GA;
