-- D64005EF.ADA

-- JRK 7/30/84
-- CPP 8/1/84

SEPARATE (D64005E0M.D64005EA.D64005EB.D64005EC.D64005ED.D64005EE)

PROCEDURE D64005EF (L : LEVEL; C : CALL; T : IN OUT TRACE) IS

     V : STRING (1..2);

     M : CONSTANT NATURAL := LEVEL'POS (L) -
                             LEVEL'POS (LEVEL'FIRST) + 1;
     N : CONSTANT NATURAL := 2 * M + 1;

BEGIN

     V (1) := IDENT_CHAR (ASCII.LC_F);
     V (2) := C;

     -- APPEND ALL V TO T.
     T.S (T.E+1 .. T.E+N) := D64005E0M.V & D64005EA.V & D64005EB.V &
                             D64005EC.V & D64005ED.V & D64005EE.V &
                             D64005EF.V;
     T.E := T.E + N;

     CASE C IS

          WHEN '1' =>
               D64005EA (IDENT_CHAR(LEVEL'FIRST), IDENT_CHAR('2'), T);

          WHEN '2' =>
               D64005EF (L, IDENT_CHAR('3'), T);

          WHEN '3' =>
               -- APPEND MID-POINT SYMBOL TO T.
               T.S (T.E+1) := IDENT_CHAR ('=');
               T.E := T.E + 1;

               -- G := CATENATE ALL V, L, C;
               G := D64005E0M.V & D64005E0M.L &
                    D64005EA.V & D64005EA.L & D64005EA.C &
                    D64005EB.V & D64005EB.L & D64005EB.C &
                    D64005EC.V & D64005EC.L & D64005EC.C &
                    D64005ED.V & D64005ED.L & D64005ED.C &
                    D64005EE.V & D64005EE.L & D64005EE.C &
                    D64005EF.V & D64005EF.L & D64005EF.C;
     END CASE;

     -- APPEND ALL L AND C TO T IN REVERSE ORDER.
     T.S (T.E+1 .. T.E+N) := D64005EF.L & D64005EF.C &
                             D64005EE.L & D64005EE.C &
                             D64005ED.L & D64005ED.C &
                             D64005EC.L & D64005EC.C &
                             D64005EB.L & D64005EB.C &
                             D64005EA.L & D64005EA.C &
                             D64005E0M.L;
     T.E := T.E + N;

END D64005EF;
