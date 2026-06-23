-- D64005FA.ADA

-- JRK 7/30/84
-- CPP 8/2/84

SEPARATE (D64005F0M)

PROCEDURE D64005FA (L : LEVEL; C : CALL; T : IN OUT TRACE) IS

     V : STRING (1..2);

     M : CONSTANT NATURAL := LEVEL'POS (L) -
                             LEVEL'POS (LEVEL'FIRST) + 1;
     N : CONSTANT NATURAL := 2 * M + 1;

     PROCEDURE D64005FB (L : LEVEL; C : CALL; T : IN OUT TRACE) IS
          SEPARATE;

BEGIN

     V (1) := IDENT_CHAR (ASCII.LC_A);
     V (2) := C;

     -- APPEND ALL V TO T.
     T.S (T.E+1 .. T.E+N) := D64005F0M.V & D64005FA.V;
     T.E := T.E + N;

     CASE C IS

          WHEN '1' =>
               D64005FB (LEVEL'SUCC(L), IDENT_CHAR('1'), T);

          WHEN '2' =>
               D64005FA (L, IDENT_CHAR('3'), T);

          WHEN '3' =>
               D64005FB (LEVEL'SUCC(L), IDENT_CHAR('2'), T);
     END CASE;

     -- APPEND ALL L AND C TO T IN REVERSE ORDER.
     T.S (T.E+1 .. T.E+N) := D64005FA.L & D64005FA.C & D64005F0M.L;
     T.E := T.E + N;

END D64005FA;
