-- D64005FG.ADA

-- JRK 7/30/84
-- CPP 8/2/84

SEPARATE (D64005F0M.D64005FA.D64005FB.D64005FC.D64005FD.D64005FE.
          D64005FF)

PROCEDURE D64005FG (L : LEVEL; C : CALL; T : IN OUT TRACE) IS

     V : STRING (1..2);

     M : CONSTANT NATURAL := LEVEL'POS (L) -
                             LEVEL'POS (LEVEL'FIRST) + 1;
     N : CONSTANT NATURAL := 2 * M + 1;

     PROCEDURE D64005FH (L : LEVEL; C : CALL; T : IN OUT TRACE) IS
          SEPARATE;

BEGIN

     V (1) := IDENT_CHAR (ASCII.LC_G);
     V (2) := C;

     -- APPEND ALL V TO T.
     T.S (T.E+1 .. T.E+N) := D64005F0M.V & D64005FA.V & D64005FB.V &
                             D64005FC.V & D64005FD.V & D64005FE.V &
                             D64005FF.V & D64005FG.V;
     T.E := T.E + N;

     CASE C IS

          WHEN '1' =>
               D64005FH (LEVEL'SUCC(L), IDENT_CHAR('1'), T);

          WHEN '2' =>
               D64005FG (L, IDENT_CHAR('3'), T);

          WHEN '3' =>
               D64005FH (LEVEL'SUCC(L), IDENT_CHAR('2'), T);
     END CASE;

     -- APPEND ALL L AND C TO T IN REVERSE ORDER.
     T.S (T.E+1 .. T.E+N) := D64005FG.L & D64005FG.C &
                             D64005FF.L & D64005FF.C &
                             D64005FE.L & D64005FE.C &
                             D64005FD.L & D64005FD.C &
                             D64005FC.L & D64005FC.C &
                             D64005FB.L & D64005FB.C &
                             D64005FA.L & D64005FA.C &
                             D64005F0M.L;
     T.E := T.E + N;

END D64005FG;
