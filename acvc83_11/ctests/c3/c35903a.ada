-- C35903A.ADA

-- CHECK WHETHER THE BASE TYPE OF A FIXED POINT TYPE PROVIDES EXTRA
-- PRECISION OR EXTRA RANGE.

-- WRG 7/21/86

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;
PROCEDURE C35903A IS

BEGIN

     TEST ("C35903A", "CHECK WHETHER THE BASE TYPE OF A FIXED POINT " &
                      "TYPE PROVIDES EXTRA PRECISION OR EXTRA RANGE");

     COMMENT ("VALUE OF SYSTEM.MAX_MANTISSA IS" &
              POSITIVE'IMAGE(MAX_MANTISSA));

     DECLARE

          T_SMALL : CONSTANT := 2.0 ** (-MAX_MANTISSA+2);
          TYPE T IS DELTA T_SMALL RANGE -1.0 .. 1.0;
          X       : T;

     BEGIN

          -- CHECK WHETHER EXTRA PRECISION IS PROVIDED:
          X := T_SMALL;
          X := X / IDENT_INT (4);
          X := X * IDENT_INT (4);
          IF X = T_SMALL THEN
               COMMENT ("IMPLEMENTATION USES ALL EXTRA BITS FOR " &
                        "EXTRA PRECISION");
          ELSE
               X := 2 * T_SMALL;
               X := X / IDENT_INT (4);
               X := X * 4;
               IF X = 2 * T_SMALL THEN
                    COMMENT ("IMPLEMENTATION USES SOME EXTRA BITS " &
                             "FOR EXTRA PRECISION");
               ELSE
                    COMMENT ("IMPLEMENTATION USES NO EXTRA BITS FOR " &
                             "EXTRA PRECISION");
               END IF;
          END IF;

          -- CHECK WHETHER EXTRA RANGE IS PROVIDED:
          X := 0.5;
          BEGIN
               X := X * IDENT_INT (2);
               IF X /= 1.0 THEN
                    FAILED ("INCORRECT EXTRA RANGE RESULT AND NO " &
                            "EXCEPTION RAISED - 1");
               ELSE
                    IF EQUAL (3, 3) THEN
                         X := 0.5;
                    END IF;
                    BEGIN
                         X := (X + X + X + X) / IDENT_INT (4);
                         IF X = 0.5 THEN
                              COMMENT ("IMPLEMENTATION USES ALL " &
                                       "EXTRA BITS FOR EXTRA RANGE");
                         ELSE
                              FAILED ("INCORRECT EXTRA RANGE RESULT " &
                                      "AND NO EXCEPTION RAISED - 2");
                         END IF;
                    EXCEPTION
                         WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
                              COMMENT ("IMPLEMENTATION USES SOME " &
                                       "EXTRA BITS FOR EXTRA RANGE");
                         WHEN OTHERS =>
                              FAILED ("WRONG EXCEPTION RAISED - 2");
                    END;
               END IF;
          EXCEPTION
               WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
                    COMMENT ("IMPLEMENTATION USES NO EXTRA BITS FOR " &
                             "EXTRA RANGE");
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - 1");
          END;

     END;

     RESULT;

END C35903A;
