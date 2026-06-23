-- C64005DC.ADA

-- JRK 7/30/84

SEPARATE (C64005D0M.C64005DA.C64005DB)

PROCEDURE C64005DC (L : LEVEL; C : CALL; T : IN OUT TRACE) IS

     V : STRING (1..2);

     M : CONSTANT NATURAL := LEVEL'POS (L) -
                             LEVEL'POS (LEVEL'FIRST) + 1;
     N : CONSTANT NATURAL := 2 * M + 1;

BEGIN

     V (1) := IDENT_CHAR (ASCII.LC_C);
     V (2) := C;

     -- APPEND ALL V TO T.
     T.S (T.E+1 .. T.E+N) := C64005D0M.V & C64005DA.V & C64005DB.V &
                             C64005DC.V;
     T.E := T.E + N;

     CASE C IS

          WHEN '1' =>
               C64005DA (IDENT_CHAR(LEVEL'FIRST), IDENT_CHAR('2'), T);

          WHEN '2' =>
               C64005DC (L, IDENT_CHAR('3'), T);

          WHEN '3' =>
               -- APPEND MID-POINT SYMBOL TO T.
               T.S (T.E+1) := IDENT_CHAR ('=');
               T.E := T.E + 1;

               -- G := CATENATE ALL V, L, C;
               G := C64005D0M.V & C64005D0M.L &
                    C64005DA.V & C64005DA.L & C64005DA.C &
                    C64005DB.V & C64005DB.L & C64005DB.C &
                    C64005DC.V & C64005DC.L & C64005DC.C;
     END CASE;

     -- APPEND ALL L AND C TO T IN REVERSE ORDER.
     T.S (T.E+1 .. T.E+N) := C64005DC.L & C64005DC.C &
                             C64005DB.L & C64005DB.C &
                             C64005DA.L & C64005DA.C &
                             C64005D0M.L;
     T.E := T.E + N;

END C64005DC;
