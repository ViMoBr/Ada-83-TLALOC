-- C43204G.ADA

-- OBJECTIVE:
--     CHECK THAT AN AGGREGATE WITH AN OTHERS CLAUSE CAN APPEAR AS A
--     CONSTRAINED FORMAL PARAMETER OF AN ENTRY, AND THAT THE BOUNDS
--     OF THE AGGREGATE ARE DETERMINED CORRECTLY.

-- HISTORY:
--     JET 08/15/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE C43204G IS

     TYPE ARR11 IS ARRAY (INTEGER RANGE -3 .. 3) OF INTEGER;
     TYPE ARR12 IS ARRAY (IDENT_INT(-3) .. IDENT_INT(3)) OF INTEGER;
     TYPE ARR13 IS ARRAY (IDENT_INT(1) .. IDENT_INT(-1)) OF INTEGER;
     TYPE ARR21 IS ARRAY (INTEGER RANGE -1 .. 1,
                          INTEGER RANGE -1 .. 1) OF INTEGER;
     TYPE ARR22 IS ARRAY (IDENT_INT(-1) .. IDENT_INT(1),
                          IDENT_INT(-1) .. IDENT_INT(1)) OF INTEGER;
     TYPE ARR23 IS ARRAY (INTEGER RANGE -1 .. 1,
                          IDENT_INT(-1) .. IDENT_INT(1)) OF INTEGER;
     TYPE ARR24 IS ARRAY (IDENT_INT(1) .. IDENT_INT(-1),
                          IDENT_INT(-1) .. IDENT_INT(1)) OF INTEGER;

     TASK T IS
          ENTRY E (EA11 : ARR11 := (1,1,1,1, OTHERS => IDENT_INT(2));
                   EA12 : ARR12 := (OTHERS => IDENT_INT(2));
                   EA13 : ARR13 := (OTHERS => IDENT_INT(2));
                   EA21 : ARR21 := ((1,1,1), (1,1,1), (1,1,1),
                                    OTHERS => (-1..1 => IDENT_INT(2)));
                   EA22 : ARR22 := ((OTHERS => IDENT_INT(2)), (1,1,1),
                                    (1,1,1));
                   EA23 : ARR23 := (-1..0 => (OTHERS => 1),
                                    1 => (OTHERS => IDENT_INT(2)));
                   EA24: ARR24 := (OTHERS => (OTHERS => IDENT_INT(2))));
     END T;

     TASK BODY T IS
     BEGIN
          ACCEPT E (EA11 : ARR11 := (1,1,1,1, OTHERS => IDENT_INT(2));
                    EA12 : ARR12 := (OTHERS => IDENT_INT(2));
                    EA13 : ARR13 := (OTHERS => IDENT_INT(2));
                    EA21 : ARR21 := ((1,1,1), (1,1,1), (1,1,1),
                                     OTHERS => (-1..1 => IDENT_INT(2)));
                    EA22 : ARR22 := ((OTHERS => IDENT_INT(2)), (1,1,1),
                                     (1,1,1));
                    EA23 : ARR23 := (-1..0 => (OTHERS => 1),
                                     1 => (OTHERS => IDENT_INT(2)));
                    EA24 : ARR24 := (OTHERS => (OTHERS =>
                                    IDENT_INT(2))))
          DO
               IF EA11 /= (1, 1, 1, 1, 2, 2, 2) THEN
                    FAILED("INCORRECT VALUE OF EA11");
               END IF;

               IF EA12 /= (2, 2, 2, 2, 2, 2, 2) THEN
                    FAILED("INCORRECT VALUE OF EA12");
               END IF;

               IF EA13'LENGTH /= 0 THEN
                    FAILED("INCORRECT VALUE OF EA13");
               END IF;

               IF EA21 /= ((1,1,1), (1,1,1), (1,1,1)) THEN
                    FAILED("INCORRECT VALUE OF EA21");
               END IF;

               IF EA22 /= ((2,2,2), (1,1,1), (1,1,1)) THEN
                    FAILED("INCORRECT VALUE OF EA22");
               END IF;

               IF EA23 /= ((1,1,1), (1,1,1), (2,2,2)) THEN
                    FAILED("INCORRECT VALUE OF EA23");
               END IF;

               IF EA24'LENGTH /= 0 OR EA24'LENGTH(2) /= 3 THEN
                    FAILED("INCORRECT VALUE OF EA24");
               END IF;
          END E;
     END T;

BEGIN
     TEST ("C43204G", "CHECK THAT AN AGGREGATE WITH AN OTHERS CLAUSE " &
                      "CAN APPEAR AS A CONSTRAINED FORMAL PARAMETER " &
                      "OF AN ENTRY, AND THAT THE BOUNDS OF THE " &
                      "AGGREGATE ARE DETERMINED CORRECTLY");

     T.E;

     RESULT;

EXCEPTION
     WHEN OTHERS =>
          FAILED ("UNEXPECTED CONSTRAINT_ERROR OR OTHER EXCEPTION " &
                  "RAISED");

          IF T'CALLABLE THEN
               T.E;
          END IF;

          RESULT;
END C43204G;
