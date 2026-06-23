-- C43204F.ADA

-- OBJECTIVE:
--     CHECK THAT AN AGGREGATE WITH AN OTHERS CLAUSE CAN APPEAR AS A
--     CONSTRAINED FORMAL PARAMETER OF A SUBPROGRAM AND THAT THE BOUNDS
--     OF THE AGGREGATE ARE DETERMINED CORRECTLY.

-- HISTORY:
--     JET 08/15/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE C43204F IS

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

     PROCEDURE PROC (PA11 : ARR11 := (1,1,1,1,1,1,
                                      OTHERS => IDENT_INT(2));
                     PA12 : ARR12 := (OTHERS => IDENT_INT(2));
                     PA13 : ARR13 := (OTHERS => IDENT_INT(2));
                     PA21 : ARR21 := ((1,1,1), (1,1,1),
                                      (1, OTHERS => IDENT_INT(2)));
                     PA22 : ARR22 := ((1,1,1), (1,1,1),
                                      (OTHERS => IDENT_INT(2)));
                     PA23 : ARR23 := ((1,1,1), (1,1,1), (1,1,1),
                                      OTHERS => (OTHERS =>
                                      IDENT_INT(2)));
                     PA24 : ARR24 := (OTHERS => (OTHERS =>
                                      IDENT_INT(2)))) IS
     BEGIN
          IF PA11 /= (1, 1, 1, 1, 1, 1, 2) THEN
               FAILED("INCORRECT VALUE OF PA11");
          END IF;

          IF PA12 /= (2, 2, 2, 2, 2, 2, 2) THEN
               FAILED("INCORRECT VALUE OF PA12");
          END IF;

          IF PA13'LENGTH /= 0 THEN
               FAILED("INCORRECT VALUE OF PA13");
          END IF;

          IF PA21 /= ((1,1,1), (1,1,1), (1,2,2)) THEN
               FAILED("INCORRECT VALUE OF PA21");
          END IF;

          IF PA22 /= ((1,1,1), (1,1,1), (2,2,2)) THEN
               FAILED("INCORRECT VALUE OF PA22");
          END IF;

          IF PA23 /= ((1,1,1), (1,1,1), (1,1,1)) THEN
               FAILED("INCORRECT VALUE OF PA23");
          END IF;

          IF PA24'LENGTH /= 0 OR PA24'LENGTH(2) /= 3 THEN
               FAILED("INCORRECT VALUE OF PA24");
          END IF;
     END PROC;

BEGIN
     TEST ("C43204F", "CHECK THAT AN AGGREGATE WITH AN OTHERS CLAUSE " &
                      "CAN APPEAR AS A CONSTRAINED FORMAL PARAMETER " &
                      "OF A SUBPROGRAM AND THAT THE BOUNDS OF THE " &
                      "AGGREGATE ARE DETERMINED CORRECTLY");

     PROC;

     RESULT;

EXCEPTION
     WHEN OTHERS =>
          FAILED ("UNEXPECTED CONSTRAINT_ERROR OR OTHER EXCEPTION " &
                  "RAISED");

          RESULT;
END C43204F;
