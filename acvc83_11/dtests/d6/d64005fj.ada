-- D64005FJ.ADA

-- JRK 7/30/84
-- CPP 8/2/84

SEPARATE (D64005F0M.D64005FA.D64005FB.D64005FC.D64005FD.D64005FE.
          D64005FF.D64005FG.D64005FH.D64005FI)

PROCEDURE D64005FJ (L : LEVEL; C : CALL; T : IN OUT TRACE) IS

     V : STRING (1..2);

     M : CONSTANT NATURAL := LEVEL'POS (L) -
                             LEVEL'POS (LEVEL'FIRST) + 1;
     N : CONSTANT NATURAL := 2 * M + 1;

BEGIN

     V (1) := IDENT_CHAR (ASCII.LC_J);
     V (2) := C;

     -- APPEND ALL V TO T.
     T.S (T.E+1 .. T.E+N) := D64005F0M.V & D64005FA.V & D64005FB.V &
                             D64005FC.V & D64005FD.V & D64005FE.V &
                             D64005FF.V & D64005FG.V & D64005FH.V &
                             D64005FI.V & D64005FJ.V;
     T.E := T.E + N;

     CASE C IS

          WHEN '1' =>
               D64005FA (IDENT_CHAR(LEVEL'FIRST), IDENT_CHAR('2'), T);

          WHEN '2' =>
               D64005FJ (L, IDENT_CHAR('3'), T);

          WHEN '3' =>
               -- APPEND MID-POINT SYMBOL TO T.
               T.S (T.E+1) := IDENT_CHAR ('=');
               T.E := T.E + 1;

               -- G := CATENATE ALL V, L, C;
               G := D64005F0M.V & D64005F0M.L &
                    D64005FA.V & D64005FA.L & D64005FA.C &
                    D64005FB.V & D64005FB.L & D64005FB.C &
                    D64005FC.V & D64005FC.L & D64005FC.C &
                    D64005FD.V & D64005FD.L & D64005FD.C &
                    D64005FE.V & D64005FE.L & D64005FE.C &
                    D64005FF.V & D64005FF.L & D64005FF.C &
                    D64005FG.V & D64005FG.L & D64005FG.C &
                    D64005FH.V & D64005FH.L & D64005FH.C &
                    D64005FI.V & D64005FI.L & D64005FI.C &
                    D64005FJ.V & D64005FJ.L & D64005FJ.C;
     END CASE;

     -- APPEND ALL L AND C TO T IN REVERSE ORDER.
     T.S (T.E+1 .. T.E+N) := D64005FJ.L & D64005FJ.C &
                             D64005FI.L & D64005FI.C &
                             D64005FH.L & D64005FH.C &
                             D64005FG.L & D64005FG.C &
                             D64005FF.L & D64005FF.C &
                             D64005FE.L & D64005FE.C &
                             D64005FD.L & D64005FD.C &
                             D64005FC.L & D64005FC.C &
                             D64005FB.L & D64005FB.C &
                             D64005FA.L & D64005FA.C &
                             D64005F0M.L;
     T.E := T.E + N;

END D64005FJ;
