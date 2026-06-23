-- C35A03B.ADA

-- CHECK THAT FOR FIXED POINT TYPES THE MANTISSA ATTRIBUTE YIELDS THE
-- CORRECT VALUES.

-- CASE B: 'MANTISSA = SYSTEM.MAX_MANTISSA.

-- WRG 7/24/86

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;
PROCEDURE C35A03B IS

     MM            : CONSTANT := MAX_MANTISSA;
     FLOOR_MM_HALF : CONSTANT := MM / 2;
     CEIL_MM_HALF  : CONSTANT := MM - FLOOR_MM_HALF;

     -- THE NAME OF EACH TYPE OR SUBTYPE ENDS WITH THAT TYPE'S
     -- 'MANTISSA VALUE.

     TYPE LEFT_OUT_MM    IS
          DELTA 2.0 ** (-(MM+1))
          RANGE -(2.0 ** (-1) ) .. 2.0 ** (-1);
     TYPE LEFT_EDGE_MM   IS
          DELTA 2.0 ** (-MM)
          RANGE -1.0 .. 1.0;
     TYPE MIDDLE_MM      IS
          DELTA 2.0 ** (-CEIL_MM_HALF)
          RANGE -(2.0 ** FLOOR_MM_HALF) .. 2.0 ** FLOOR_MM_HALF;
     TYPE RIGHT_EDGE_MM  IS
          DELTA 1.0
          RANGE -(2.0 ** MM) .. 2.0 ** MM;
     TYPE RIGHT_OUT_MM   IS
          DELTA 2.0
          RANGE -(2.0 ** (MM+1)) .. 2.0 ** (MM+1);

     -------------------------------------------------------------------

     SUBTYPE ST_LEFT_OUT_MM_LESS_1 IS LEFT_OUT_MM
          DELTA 2.0 ** (-MM);
               -- 'MANTISSA = MM - 1.
     SUBTYPE ST_LEFT_OUT_MM_HALF   IS LEFT_EDGE_MM
          DELTA 2.0 ** (-MM)
          RANGE LEFT_EDGE_MM ( -(2.0 ** (-FLOOR_MM_HALF)) ) ..
                IDENT_INT (1) * LEFT_EDGE_MM ( 2.0 ** (-FLOOR_MM_HALF));
               -- 'MANTISSA = CEIL_MM_HALF.
     SUBTYPE ST_RIGHT_EDGE_MM_HALF IS MIDDLE_MM
          DELTA 1.0;
               -- 'MANTISSA = FLOOR_MM_HALF.
     SUBTYPE ST_RIGHT_OUT_MM_HALF  IS RIGHT_EDGE_MM
          DELTA 2.0 ** FLOOR_MM_HALF;
               -- 'MANTISSA = CEIL_MM_HALF.
     SUBTYPE ST_RIGHT_OUT_M1       IS RIGHT_OUT_MM
          DELTA 2.0 RANGE -4.0 .. 4.0;
               -- 'MANTISSA = 1.

BEGIN

     TEST ("C35A03B", "CHECK THAT FOR FIXED POINT TYPES THE MANTISSA " &
                      "ATTRIBUTE YIELDS THE CORRECT VALUES - " &
                      "'MANTISSA = SYSTEM.MAX_MANTISSA");

     COMMENT ("VALUE OF SYSTEM.MAX_MANTISSA IS" &
              POSITIVE'IMAGE(MAX_MANTISSA));

     IF IDENT_INT (LEFT_OUT_MM'MANTISSA) /= MM THEN
          FAILED ("LEFT_OUT_MM'MANTISSA =" &
                  INTEGER'IMAGE(LEFT_OUT_MM'MANTISSA) );
     END IF;

     IF IDENT_INT (LEFT_EDGE_MM'MANTISSA) /= MM THEN
          FAILED ("LEFT_EDGE_MM'MANTISSA =" &
                  INTEGER'IMAGE(LEFT_EDGE_MM'MANTISSA) );
     END IF;

     IF IDENT_INT (MIDDLE_MM'MANTISSA) /= MM THEN
          FAILED ("MIDDLE_MM'MANTISSA =" &
                  INTEGER'IMAGE(MIDDLE_MM'MANTISSA) );
     END IF;

     IF IDENT_INT (RIGHT_EDGE_MM'MANTISSA) /= MM THEN
          FAILED ("RIGHT_EDGE_MM'MANTISSA =" &
                  INTEGER'IMAGE(RIGHT_EDGE_MM'MANTISSA) );
     END IF;

     IF IDENT_INT (RIGHT_OUT_MM'MANTISSA) /= MM THEN
          FAILED ("RIGHT_OUT_MM'MANTISSA =" &
                  INTEGER'IMAGE(RIGHT_OUT_MM'MANTISSA) );
     END IF;

     -------------------------------------------------------------------

     IF IDENT_INT (ST_LEFT_OUT_MM_LESS_1'MANTISSA) /= MM - 1 THEN
          IF ST_LEFT_OUT_MM_LESS_1'MANTISSA =
             IDENT_INT (LEFT_OUT_MM'MANTISSA) THEN
               FAILED ("ST_LEFT_OUT_MM_LESS_1'MANTISSA = " &
                       "LEFT_OUT_MM'MANTISSA =" &
                       INTEGER'IMAGE(ST_LEFT_OUT_MM_LESS_1'MANTISSA) );
          ELSE
               FAILED ("ST_LEFT_OUT_MM_LESS_1'MANTISSA =" &
                       INTEGER'IMAGE(ST_LEFT_OUT_MM_LESS_1'MANTISSA) );
          END IF;
     END IF;

     IF IDENT_INT (ST_LEFT_OUT_MM_HALF'MANTISSA) /= CEIL_MM_HALF THEN
          IF ST_LEFT_OUT_MM_HALF'MANTISSA =
             IDENT_INT (LEFT_EDGE_MM'MANTISSA) THEN
               FAILED ("ST_LEFT_OUT_MM_HALF'MANTISSA = " &
                       "LEFT_EDGE_MM'MANTISSA =" &
                       INTEGER'IMAGE(ST_LEFT_OUT_MM_HALF'MANTISSA) );
          ELSE
               FAILED ("ST_LEFT_OUT_MM_HALF'MANTISSA =" &
                       INTEGER'IMAGE(ST_LEFT_OUT_MM_HALF'MANTISSA) );
          END IF;
     END IF;

     IF IDENT_INT (ST_RIGHT_EDGE_MM_HALF'MANTISSA) /= FLOOR_MM_HALF THEN
          IF ST_RIGHT_EDGE_MM_HALF'MANTISSA =
             IDENT_INT (MIDDLE_MM'MANTISSA) THEN
               FAILED ("ST_RIGHT_EDGE_MM_HALF'MANTISSA = " &
                       "MIDDLE_MM'MANTISSA =" &
                       INTEGER'IMAGE(ST_RIGHT_EDGE_MM_HALF'MANTISSA) );
          ELSE
               FAILED ("ST_RIGHT_EDGE_MM_HALF'MANTISSA =" &
                       INTEGER'IMAGE(ST_RIGHT_EDGE_MM_HALF'MANTISSA) );
          END IF;
     END IF;

     IF IDENT_INT (ST_RIGHT_OUT_MM_HALF'MANTISSA) /= CEIL_MM_HALF THEN
          IF ST_RIGHT_OUT_MM_HALF'MANTISSA =
             IDENT_INT (RIGHT_EDGE_MM'MANTISSA) THEN
               FAILED ("ST_RIGHT_OUT_MM_HALF'MANTISSA = " &
                       "RIGHT_EDGE_MM'MANTISSA =" &
                       INTEGER'IMAGE(ST_RIGHT_OUT_MM_HALF'MANTISSA) );
          ELSE
               FAILED ("ST_RIGHT_OUT_MM_HALF'MANTISSA =" &
                       INTEGER'IMAGE(ST_RIGHT_OUT_MM_HALF'MANTISSA) );
          END IF;
     END IF;

     IF IDENT_INT (ST_RIGHT_OUT_M1'MANTISSA) /= 1 THEN
          IF ST_RIGHT_OUT_M1'MANTISSA =
             IDENT_INT (RIGHT_OUT_MM'MANTISSA) THEN
               FAILED ("ST_RIGHT_OUT_M1'MANTISSA = " &
                       "RIGHT_OUT_MM'MANTISSA =" &
                       INTEGER'IMAGE(ST_RIGHT_OUT_M1'MANTISSA) );
          ELSE
               FAILED ("ST_RIGHT_OUT_M1'MANTISSA =" &
                       INTEGER'IMAGE(ST_RIGHT_OUT_M1'MANTISSA) );
          END IF;
     END IF;

     RESULT;

END C35A03B;
