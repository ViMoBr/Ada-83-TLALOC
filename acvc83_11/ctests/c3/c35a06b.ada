-- C35A06B.ADA

-- CHECK THAT FOR FIXED POINT TYPES THE SAFE_SMALL AND SAFE_LARGE
-- ATTRIBUTES YIELD APPROPRIATE VALUES.

-- CASE B: 'MANTISSA = SYSTEM.MAX_MANTISSA.

-- WRG 8/21/86

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;
PROCEDURE C35A06B IS

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

     TEST ("C35A06B", "CHECK THAT FOR FIXED POINT TYPES THE " &
                      "SAFE_SMALL AND SAFE_LARGE ATTRIBUTES YIELD " &
                      "APPROPRIATE VALUES - 'MANTISSA = " &
                      "SYSTEM.MAX_MANTISSA");

     COMMENT ("VALUE OF SYSTEM.MAX_MANTISSA IS" &
              POSITIVE'IMAGE(MAX_MANTISSA));

     -------------------------------------------------------------------

     IF LEFT_OUT_MM'SAFE_SMALL /= LEFT_OUT_MM'BASE'SMALL THEN
          FAILED ("LEFT_OUT_MM'SAFE_SMALL /= LEFT_OUT_MM'BASE'SMALL");
     END IF;
     IF LEFT_OUT_MM'SAFE_LARGE /= LEFT_OUT_MM'BASE'LARGE THEN
          FAILED ("LEFT_OUT_MM'SAFE_LARGE /= LEFT_OUT_MM'BASE'LARGE");
     END IF;
     IF LEFT_OUT_MM'SAFE_SMALL /= LEFT_OUT_MM'BASE'SAFE_SMALL THEN
          FAILED ("LEFT_OUT_MM'SAFE_SMALL /= " &
                  "LEFT_OUT_MM'BASE'SAFE_SMALL");
     END IF;
     IF LEFT_OUT_MM'SAFE_LARGE /= LEFT_OUT_MM'BASE'SAFE_LARGE THEN
          FAILED ("LEFT_OUT_MM'SAFE_LARGE /= " &
                  "LEFT_OUT_MM'BASE'SAFE_LARGE");
     END IF;
     IF LEFT_OUT_MM'SMALL < LEFT_OUT_MM'BASE'SAFE_SMALL THEN
          FAILED ("LEFT_OUT_MM'SMALL < LEFT_OUT_MM'BASE'SAFE_SMALL");
     END IF;
     IF LEFT_OUT_MM'LARGE > LEFT_OUT_MM'BASE'SAFE_LARGE THEN
          FAILED ("LEFT_OUT_MM'LARGE > LEFT_OUT_MM'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT  : CONSTANT := LEFT_OUT_MM'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   LEFT_OUT_MM'SAFE_SMALL;
     BEGIN
          IF LEFT_OUT_MM'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("LEFT_OUT_MM'SAFE_LARGE /= " &
                       "(2.0 ** LEFT_OUT_MM'BASE'MANTISSA - 1.0) * " &
                       "LEFT_OUT_MM'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     IF LEFT_EDGE_MM'SAFE_SMALL /= LEFT_EDGE_MM'BASE'SMALL THEN
          FAILED ("LEFT_EDGE_MM'SAFE_SMALL /= LEFT_EDGE_MM'BASE'SMALL");
     END IF;
     IF LEFT_EDGE_MM'SAFE_LARGE /= LEFT_EDGE_MM'BASE'LARGE THEN
          FAILED ("LEFT_EDGE_MM'SAFE_LARGE /= LEFT_EDGE_MM'BASE'LARGE");
     END IF;
     IF LEFT_EDGE_MM'SAFE_SMALL /= LEFT_EDGE_MM'BASE'SAFE_SMALL THEN
          FAILED ("LEFT_EDGE_MM'SAFE_SMALL /= " &
                  "LEFT_EDGE_MM'BASE'SAFE_SMALL");
     END IF;
     IF LEFT_EDGE_MM'SAFE_LARGE /= LEFT_EDGE_MM'BASE'SAFE_LARGE THEN
          FAILED ("LEFT_EDGE_MM'SAFE_LARGE /= " &
                  "LEFT_EDGE_MM'BASE'SAFE_LARGE");
     END IF;
     IF LEFT_EDGE_MM'SMALL < LEFT_EDGE_MM'BASE'SAFE_SMALL THEN
          FAILED ("LEFT_EDGE_MM'SMALL < LEFT_EDGE_MM'BASE'SAFE_SMALL");
     END IF;
     IF LEFT_EDGE_MM'LARGE > LEFT_EDGE_MM'BASE'SAFE_LARGE THEN
          FAILED ("LEFT_EDGE_MM'LARGE > LEFT_EDGE_MM'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT  : CONSTANT := LEFT_EDGE_MM'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   LEFT_EDGE_MM'SAFE_SMALL;
     BEGIN
          IF LEFT_EDGE_MM'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("LEFT_EDGE_MM'SAFE_LARGE /= " &
                       "(2.0 ** LEFT_EDGE_MM'BASE'MANTISSA - 1.0) * " &
                       "LEFT_EDGE_MM'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     IF MIDDLE_MM'SAFE_SMALL /= MIDDLE_MM'BASE'SMALL THEN
          FAILED ("MIDDLE_MM'SAFE_SMALL /= MIDDLE_MM'BASE'SMALL");
     END IF;
     IF MIDDLE_MM'SAFE_LARGE /= MIDDLE_MM'BASE'LARGE THEN
          FAILED ("MIDDLE_MM'SAFE_LARGE /= MIDDLE_MM'BASE'LARGE");
     END IF;
     IF MIDDLE_MM'SAFE_SMALL /= MIDDLE_MM'BASE'SAFE_SMALL THEN
          FAILED ("MIDDLE_MM'SAFE_SMALL /= " &
                  "MIDDLE_MM'BASE'SAFE_SMALL");
     END IF;
     IF MIDDLE_MM'SAFE_LARGE /= MIDDLE_MM'BASE'SAFE_LARGE THEN
          FAILED ("MIDDLE_MM'SAFE_LARGE /= " &
                  "MIDDLE_MM'BASE'SAFE_LARGE");
     END IF;
     IF MIDDLE_MM'SMALL < MIDDLE_MM'BASE'SAFE_SMALL THEN
          FAILED ("MIDDLE_MM'SMALL < MIDDLE_MM'BASE'SAFE_SMALL");
     END IF;
     IF MIDDLE_MM'LARGE > MIDDLE_MM'BASE'SAFE_LARGE THEN
          FAILED ("MIDDLE_MM'LARGE > MIDDLE_MM'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT  : CONSTANT := MIDDLE_MM'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   MIDDLE_MM'SAFE_SMALL;
     BEGIN
          IF MIDDLE_MM'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("MIDDLE_MM'SAFE_LARGE /= " &
                       "(2.0 ** MIDDLE_MM'BASE'MANTISSA - 1.0) * " &
                       "MIDDLE_MM'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     IF RIGHT_EDGE_MM'SAFE_SMALL /= RIGHT_EDGE_MM'BASE'SMALL THEN
          FAILED ("RIGHT_EDGE_MM'SAFE_SMALL /= " &
                  "RIGHT_EDGE_MM'BASE'SMALL");
     END IF;
     IF RIGHT_EDGE_MM'SAFE_LARGE /= RIGHT_EDGE_MM'BASE'LARGE THEN
          FAILED ("RIGHT_EDGE_MM'SAFE_LARGE /= " &
                  "RIGHT_EDGE_MM'BASE'LARGE");
     END IF;
     IF RIGHT_EDGE_MM'SAFE_SMALL /= RIGHT_EDGE_MM'BASE'SAFE_SMALL THEN
          FAILED ("RIGHT_EDGE_MM'SAFE_SMALL /= " &
                  "RIGHT_EDGE_MM'BASE'SAFE_SMALL");
     END IF;
     IF RIGHT_EDGE_MM'SAFE_LARGE /= RIGHT_EDGE_MM'BASE'SAFE_LARGE THEN
          FAILED ("RIGHT_EDGE_MM'SAFE_LARGE /= " &
                  "RIGHT_EDGE_MM'BASE'SAFE_LARGE");
     END IF;
     IF RIGHT_EDGE_MM'SMALL < RIGHT_EDGE_MM'BASE'SAFE_SMALL THEN
          FAILED ("RIGHT_EDGE_MM'SMALL < " &
                  "RIGHT_EDGE_MM'BASE'SAFE_SMALL");
     END IF;
     IF RIGHT_EDGE_MM'LARGE > RIGHT_EDGE_MM'BASE'SAFE_LARGE THEN
          FAILED ("RIGHT_EDGE_MM'LARGE > " &
                  "RIGHT_EDGE_MM'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT  : CONSTANT := RIGHT_EDGE_MM'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   RIGHT_EDGE_MM'SAFE_SMALL;
     BEGIN
          IF RIGHT_EDGE_MM'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("RIGHT_EDGE_MM'SAFE_LARGE /= " &
                       "(2.0 ** RIGHT_EDGE_MM'BASE'MANTISSA - 1.0) * " &
                       "RIGHT_EDGE_MM'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     IF RIGHT_OUT_MM'SAFE_SMALL /= RIGHT_OUT_MM'BASE'SMALL THEN
          FAILED ("RIGHT_OUT_MM'SAFE_SMALL /= RIGHT_OUT_MM'BASE'SMALL");
     END IF;
     IF RIGHT_OUT_MM'SAFE_LARGE /= RIGHT_OUT_MM'BASE'LARGE THEN
          FAILED ("RIGHT_OUT_MM'SAFE_LARGE /= RIGHT_OUT_MM'BASE'LARGE");
     END IF;
     IF RIGHT_OUT_MM'SAFE_SMALL /= RIGHT_OUT_MM'BASE'SAFE_SMALL THEN
          FAILED ("RIGHT_OUT_MM'SAFE_SMALL /= " &
                  "RIGHT_OUT_MM'BASE'SAFE_SMALL");
     END IF;
     IF RIGHT_OUT_MM'SAFE_LARGE /= RIGHT_OUT_MM'BASE'SAFE_LARGE THEN
          FAILED ("RIGHT_OUT_MM'SAFE_LARGE /= " &
                  "RIGHT_OUT_MM'BASE'SAFE_LARGE");
     END IF;
     IF RIGHT_OUT_MM'SMALL < RIGHT_OUT_MM'BASE'SAFE_SMALL THEN
          FAILED ("RIGHT_OUT_MM'SMALL < RIGHT_OUT_MM'BASE'SAFE_SMALL");
     END IF;
     IF RIGHT_OUT_MM'LARGE > RIGHT_OUT_MM'BASE'SAFE_LARGE THEN
          FAILED ("RIGHT_OUT_MM'LARGE > RIGHT_OUT_MM'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT  : CONSTANT := RIGHT_OUT_MM'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   RIGHT_OUT_MM'SAFE_SMALL;
     BEGIN
          IF RIGHT_OUT_MM'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("RIGHT_OUT_MM'SAFE_LARGE /= " &
                       "(2.0 ** RIGHT_OUT_MM'BASE'MANTISSA - 1.0) * " &
                       "RIGHT_OUT_MM'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     IF ST_LEFT_OUT_MM_LESS_1'SAFE_SMALL /=
        ST_LEFT_OUT_MM_LESS_1'BASE'SMALL THEN
          FAILED ("ST_LEFT_OUT_MM_LESS_1'SAFE_SMALL /= " &
                  "ST_LEFT_OUT_MM_LESS_1'BASE'SMALL");
     END IF;
     IF ST_LEFT_OUT_MM_LESS_1'SAFE_LARGE /=
        ST_LEFT_OUT_MM_LESS_1'BASE'LARGE THEN
          FAILED ("ST_LEFT_OUT_MM_LESS_1'SAFE_LARGE /= " &
                  "ST_LEFT_OUT_MM_LESS_1'BASE'LARGE");
     END IF;
     IF ST_LEFT_OUT_MM_LESS_1'SAFE_SMALL /=
        ST_LEFT_OUT_MM_LESS_1'BASE'SAFE_SMALL THEN
          FAILED ("ST_LEFT_OUT_MM_LESS_1'SAFE_SMALL /= " &
                  "ST_LEFT_OUT_MM_LESS_1'BASE'SAFE_SMALL");
     END IF;
     IF ST_LEFT_OUT_MM_LESS_1'SAFE_LARGE /=
        ST_LEFT_OUT_MM_LESS_1'BASE'SAFE_LARGE THEN
          FAILED ("ST_LEFT_OUT_MM_LESS_1'SAFE_LARGE /= " &
                  "ST_LEFT_OUT_MM_LESS_1'BASE'SAFE_LARGE");
     END IF;
     IF ST_LEFT_OUT_MM_LESS_1'SMALL <
        ST_LEFT_OUT_MM_LESS_1'BASE'SAFE_SMALL THEN
          FAILED ("ST_LEFT_OUT_MM_LESS_1'SMALL < " &
                  "ST_LEFT_OUT_MM_LESS_1'BASE'SAFE_SMALL");
     END IF;
     IF ST_LEFT_OUT_MM_LESS_1'LARGE >
        ST_LEFT_OUT_MM_LESS_1'BASE'SAFE_LARGE THEN
          FAILED ("ST_LEFT_OUT_MM_LESS_1'LARGE > " &
                  "ST_LEFT_OUT_MM_LESS_1'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT  : CONSTANT := ST_LEFT_OUT_MM_LESS_1'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   ST_LEFT_OUT_MM_LESS_1'SAFE_SMALL;
     BEGIN
          IF ST_LEFT_OUT_MM_LESS_1'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("ST_LEFT_OUT_MM_LESS_1'SAFE_LARGE /= " &
                       "(2.0 ** ST_LEFT_OUT_MM_LESS_1'BASE'MANTISSA -" &
                       " 1.0) * ST_LEFT_OUT_MM_LESS_1'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     IF ST_LEFT_OUT_MM_HALF'SAFE_SMALL /=
        ST_LEFT_OUT_MM_HALF'BASE'SMALL THEN
          FAILED ("ST_LEFT_OUT_MM_HALF'SAFE_SMALL /= " &
                  "ST_LEFT_OUT_MM_HALF'BASE'SMALL");
     END IF;
     IF ST_LEFT_OUT_MM_HALF'SAFE_LARGE /=
        ST_LEFT_OUT_MM_HALF'BASE'LARGE THEN
          FAILED ("ST_LEFT_OUT_MM_HALF'SAFE_LARGE /= " &
                  "ST_LEFT_OUT_MM_HALF'BASE'LARGE");
     END IF;
     IF ST_LEFT_OUT_MM_HALF'SAFE_SMALL /=
        ST_LEFT_OUT_MM_HALF'BASE'SAFE_SMALL THEN
          FAILED ("ST_LEFT_OUT_MM_HALF'SAFE_SMALL /= " &
                  "ST_LEFT_OUT_MM_HALF'BASE'SAFE_SMALL");
     END IF;
     IF ST_LEFT_OUT_MM_HALF'SAFE_LARGE /=
        ST_LEFT_OUT_MM_HALF'BASE'SAFE_LARGE THEN
          FAILED ("ST_LEFT_OUT_MM_HALF'SAFE_LARGE /= " &
                  "ST_LEFT_OUT_MM_HALF'BASE'SAFE_LARGE");
     END IF;
     IF ST_LEFT_OUT_MM_HALF'SMALL <
        ST_LEFT_OUT_MM_HALF'BASE'SAFE_SMALL THEN
          FAILED ("ST_LEFT_OUT_MM_HALF'SMALL < " &
                  "ST_LEFT_OUT_MM_HALF'BASE'SAFE_SMALL");
     END IF;
     IF ST_LEFT_OUT_MM_HALF'LARGE >
        ST_LEFT_OUT_MM_HALF'BASE'SAFE_LARGE THEN
          FAILED ("ST_LEFT_OUT_MM_HALF'LARGE > " &
                  "ST_LEFT_OUT_MM_HALF'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT  : CONSTANT := ST_LEFT_OUT_MM_HALF'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   ST_LEFT_OUT_MM_HALF'BASE'SAFE_SMALL;
     BEGIN
          IF ST_LEFT_OUT_MM_HALF'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("ST_LEFT_OUT_MM_HALF'SAFE_LARGE /= " &
                       "(2.0 ** ST_LEFT_OUT_MM_HALF'BASE'MANTISSA - " &
                       "1.0) * ST_LEFT_OUT_MM_HALF'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     IF ST_RIGHT_EDGE_MM_HALF'SAFE_SMALL /=
        ST_RIGHT_EDGE_MM_HALF'BASE'SMALL THEN
          FAILED ("ST_RIGHT_EDGE_MM_HALF'SAFE_SMALL /= " &
                  "ST_RIGHT_EDGE_MM_HALF'BASE'SMALL");
     END IF;
     IF ST_RIGHT_EDGE_MM_HALF'SAFE_LARGE /=
        ST_RIGHT_EDGE_MM_HALF'BASE'LARGE THEN
          FAILED ("ST_RIGHT_EDGE_MM_HALF'SAFE_LARGE /= " &
                  "ST_RIGHT_EDGE_MM_HALF'BASE'LARGE");
     END IF;
     IF ST_RIGHT_EDGE_MM_HALF'SAFE_SMALL /=
        ST_RIGHT_EDGE_MM_HALF'BASE'SAFE_SMALL THEN
          FAILED ("ST_RIGHT_EDGE_MM_HALF'SAFE_SMALL /= " &
                  "ST_RIGHT_EDGE_MM_HALF'BASE'SAFE_SMALL");
     END IF;
     IF ST_RIGHT_EDGE_MM_HALF'SAFE_LARGE /=
        ST_RIGHT_EDGE_MM_HALF'BASE'SAFE_LARGE THEN
          FAILED ("ST_RIGHT_EDGE_MM_HALF'SAFE_LARGE /= " &
                  "ST_RIGHT_EDGE_MM_HALF'BASE'SAFE_LARGE");
     END IF;
     IF ST_RIGHT_EDGE_MM_HALF'SMALL <
        ST_RIGHT_EDGE_MM_HALF'BASE'SAFE_SMALL THEN
          FAILED ("ST_RIGHT_EDGE_MM_HALF'SMALL < " &
                  "ST_RIGHT_EDGE_MM_HALF'BASE'SAFE_SMALL");
     END IF;
     IF ST_RIGHT_EDGE_MM_HALF'LARGE >
        ST_RIGHT_EDGE_MM_HALF'BASE'SAFE_LARGE THEN
          FAILED ("ST_RIGHT_EDGE_MM_HALF'LARGE > " &
                  "ST_RIGHT_EDGE_MM_HALF'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT  : CONSTANT := ST_RIGHT_EDGE_MM_HALF'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   ST_RIGHT_EDGE_MM_HALF'SAFE_SMALL;
     BEGIN
          IF ST_RIGHT_EDGE_MM_HALF'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("ST_RIGHT_EDGE_MM_HALF'SAFE_LARGE /= " &
                       "(2.0 ** ST_RIGHT_EDGE_MM_HALF'BASE'MANTISSA -" &
                       " 1.0) * ST_RIGHT_EDGE_MM_HALF'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     IF ST_RIGHT_OUT_MM_HALF'SAFE_SMALL /=
        ST_RIGHT_OUT_MM_HALF'BASE'SMALL THEN
          FAILED ("ST_RIGHT_OUT_MM_HALF'SAFE_SMALL /= " &
                  "ST_RIGHT_OUT_MM_HALF'BASE'SMALL");
     END IF;
     IF ST_RIGHT_OUT_MM_HALF'SAFE_LARGE /=
        ST_RIGHT_OUT_MM_HALF'BASE'LARGE THEN
          FAILED ("ST_RIGHT_OUT_MM_HALF'SAFE_LARGE /= " &
                  "ST_RIGHT_OUT_MM_HALF'BASE'LARGE");
     END IF;
     IF ST_RIGHT_OUT_MM_HALF'SAFE_SMALL /=
        ST_RIGHT_OUT_MM_HALF'BASE'SAFE_SMALL THEN
          FAILED ("ST_RIGHT_OUT_MM_HALF'SAFE_SMALL /= " &
                  "ST_RIGHT_OUT_MM_HALF'BASE'SAFE_SMALL");
     END IF;
     IF ST_RIGHT_OUT_MM_HALF'SAFE_LARGE /=
        ST_RIGHT_OUT_MM_HALF'BASE'SAFE_LARGE THEN
          FAILED ("ST_RIGHT_OUT_MM_HALF'SAFE_LARGE /= " &
                  "ST_RIGHT_OUT_MM_HALF'BASE'SAFE_LARGE");
     END IF;
     IF ST_RIGHT_OUT_MM_HALF'SMALL <
        ST_RIGHT_OUT_MM_HALF'BASE'SAFE_SMALL THEN
          FAILED ("ST_RIGHT_OUT_MM_HALF'SMALL < " &
                  "ST_RIGHT_OUT_MM_HALF'BASE'SAFE_SMALL");
     END IF;
     IF ST_RIGHT_OUT_MM_HALF'LARGE >
        ST_RIGHT_OUT_MM_HALF'BASE'SAFE_LARGE THEN
          FAILED ("ST_RIGHT_OUT_MM_HALF'LARGE > " &
                  "ST_RIGHT_OUT_MM_HALF'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT  : CONSTANT := ST_RIGHT_OUT_MM_HALF'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   ST_RIGHT_OUT_MM_HALF'SAFE_SMALL;
     BEGIN
          IF ST_RIGHT_OUT_MM_HALF'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("ST_RIGHT_OUT_MM_HALF'SAFE_LARGE /= " &
                       "(2.0 ** ST_RIGHT_OUT_MM_HALF'BASE'MANTISSA -" &
                       " 1.0) * ST_RIGHT_OUT_MM_HALF'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     IF ST_RIGHT_OUT_M1'SAFE_SMALL /=
        ST_RIGHT_OUT_M1'BASE'SMALL THEN
          FAILED ("ST_RIGHT_OUT_M1'SAFE_SMALL /= " &
                  "ST_RIGHT_OUT_M1'BASE'SMALL");
     END IF;
     IF ST_RIGHT_OUT_M1'SAFE_LARGE /=
        ST_RIGHT_OUT_M1'BASE'LARGE THEN
          FAILED ("ST_RIGHT_OUT_M1'SAFE_LARGE /= " &
                  "ST_RIGHT_OUT_M1'BASE'LARGE");
     END IF;
     IF ST_RIGHT_OUT_M1'SAFE_SMALL /=
        ST_RIGHT_OUT_M1'BASE'SAFE_SMALL THEN
          FAILED ("ST_RIGHT_OUT_M1'SAFE_SMALL /= " &
                  "ST_RIGHT_OUT_M1'BASE'SAFE_SMALL");
     END IF;
     IF ST_RIGHT_OUT_M1'SAFE_LARGE /=
        ST_RIGHT_OUT_M1'BASE'SAFE_LARGE THEN
          FAILED ("ST_RIGHT_OUT_M1'SAFE_LARGE /= " &
                  "ST_RIGHT_OUT_M1'BASE'SAFE_LARGE");
     END IF;
     IF ST_RIGHT_OUT_M1'SMALL <
        ST_RIGHT_OUT_M1'BASE'SAFE_SMALL THEN
          FAILED ("ST_RIGHT_OUT_M1'SMALL < " &
                  "ST_RIGHT_OUT_M1'BASE'SAFE_SMALL");
     END IF;
     IF ST_RIGHT_OUT_M1'LARGE >
        ST_RIGHT_OUT_M1'BASE'SAFE_LARGE THEN
          FAILED ("ST_RIGHT_OUT_M1'LARGE > " &
                  "ST_RIGHT_OUT_M1'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT  : CONSTANT := ST_RIGHT_OUT_M1'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   ST_RIGHT_OUT_M1'SAFE_SMALL;
     BEGIN
          IF ST_RIGHT_OUT_M1'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("ST_RIGHT_OUT_M1'SAFE_LARGE /= " &
                       "(2.0 ** ST_RIGHT_OUT_M1'BASE'MANTISSA - 1.0) " &
                       "* ST_RIGHT_OUT_M1'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     RESULT;

END C35A06B;
