-- C64005DA.ADA

-- JRK 7/30/84

SEPARATE (C64005D0M)

PROCEDURE C64005DA (L : LEVEL; C : CALL; T : IN OUT TRACE) IS

     V : STRING (1..2);

     M : CONSTANT NATURAL := LEVEL'POS (L) -
                             LEVEL'POS (LEVEL'FIRST) + 1;
     N : CONSTANT NATURAL := 2 * M + 1;

     PROCEDURE C64005DB (L : LEVEL; C : CALL; T : IN OUT TRACE) IS
          SEPARATE;

BEGIN

     V (1) := IDENT_CHAR (ASCII.LC_A);
     V (2) := C;

     -- APPEND ALL V TO T.
     T.S (T.E+1 .. T.E+N) := C64005D0M.V & C64005DA.V;
     T.E := T.E + N;

     CASE C IS

          WHEN '1' =>
               C64005DB (LEVEL'SUCC(L), IDENT_CHAR('1'), T);

          WHEN '2' =>
               C64005DA (L, IDENT_CHAR('3'), T);

          WHEN '3' =>
               C64005DB (LEVEL'SUCC(L), IDENT_CHAR('2'), T);
     END CASE;

     -- APPEND ALL L AND C TO T IN REVERSE ORDER.
     T.S (T.E+1 .. T.E+N) := C64005DA.L & C64005DA.C & C64005D0M.L;
     T.E := T.E + N;

END C64005DA;
