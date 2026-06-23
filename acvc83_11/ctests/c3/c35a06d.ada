-- C35A06D.ADA

-- CHECK THAT FOR FIXED POINT TYPES THE SAFE_SMALL AND SAFE_LARGE
-- ATTRIBUTES YIELD APPROPRIATE VALUES.

-- CASE D: TYPES TYPICAL OF APPLICATIONS USING FIXED POINT ARITHMETIC.

-- WRG 8/22/86

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;
PROCEDURE C35A06D IS

     PI      : CONSTANT := 3.14159_26535_89793_23846;
     TWO_PI  : CONSTANT := 2 * PI;
     HALF_PI : CONSTANT := PI / 2;

     MM : CONSTANT := MAX_MANTISSA;

     -- THE NAME OF EACH TYPE OR SUBTYPE ENDS WITH THAT TYPE'S
     -- 'MANTISSA VALUE.

     TYPE MICRO_ANGLE_ERROR_M15  IS
          DELTA 16.0  RANGE -(2.0 ** 19) .. 2.0 ** 19;
     TYPE TRACK_RANGE_M15        IS
          DELTA 0.125 RANGE -(2.0 ** 12) .. 2.0 ** 12;
     TYPE SECONDS_MM             IS
          DELTA 2.0 ** (8 - MM) RANGE -(2.0 ** 8) .. 2.0 ** 8;
     TYPE RANGE_CELL_MM          IS
          DELTA 2.0 ** (-5)
          RANGE -(2.0 ** (MM - 5) ) .. 2.0 ** (MM - 5);

     TYPE PIXEL_M10 IS DELTA 1.0 / 1024.0 RANGE 0.0 ..  1.0;
     TYPE RULER_M8  IS DELTA 1.0 / 16.0   RANGE 0.0 .. 12.0;

     TYPE HOURS_M16 IS DELTA   24.0 * 2.0 ** (-15) RANGE 0.0 ..   24.0;
     TYPE MILES_M16 IS DELTA 3000.0 * 2.0 ** (-15) RANGE 0.0 .. 3000.0;

     TYPE SYMMETRIC_DEGREES_M7  IS
          DELTA 2.0         RANGE -180.0 .. 180.0;
     TYPE NATURAL_DEGREES_M15   IS
          DELTA 2.0 ** (-6) RANGE    0.0 .. 360.0;
     TYPE SYMMETRIC_RADIANS_M16 IS
          DELTA     PI * 2.0 ** (-15) RANGE -PI .. PI;
     TYPE NATURAL_RADIANS_M8    IS
          DELTA TWO_PI * 2.0 ** ( -7) RANGE 0.0 .. TWO_PI;

     -------------------------------------------------------------------

     SUBTYPE ST_MILES_M8             IS MILES_M16
          DELTA 3000.0 * 2.0 ** (-15) RANGE 0.0 .. 10.0;
     SUBTYPE ST_NATURAL_DEGREES_M11  IS NATURAL_DEGREES_M15
          DELTA 0.25 RANGE 0.0 .. 360.0;
     SUBTYPE ST_SYMMETRIC_RADIANS_M8 IS SYMMETRIC_RADIANS_M16
          DELTA HALF_PI * 2.0 ** (-7) RANGE -HALF_PI .. HALF_PI;

BEGIN

     TEST ("C35A06D", "CHECK THAT FOR FIXED POINT TYPES THE " &
                      "SAFE_SMALL AND SAFE_LARGE ATTRIBUTES YIELD " &
                      "APPROPRIATE VALUES - TYPICAL TYPES");

     -------------------------------------------------------------------

     IF MICRO_ANGLE_ERROR_M15'SAFE_SMALL /=
        MICRO_ANGLE_ERROR_M15'BASE'SMALL THEN
          FAILED ("MICRO_ANGLE_ERROR_M15'SAFE_SMALL /= " &
                  "MICRO_ANGLE_ERROR_M15'BASE'SMALL");
     END IF;
     IF MICRO_ANGLE_ERROR_M15'SAFE_LARGE /=
        MICRO_ANGLE_ERROR_M15'BASE'LARGE THEN
          FAILED ("MICRO_ANGLE_ERROR_M15'SAFE_LARGE /= " &
                  "MICRO_ANGLE_ERROR_M15'BASE'LARGE");
     END IF;
     IF MICRO_ANGLE_ERROR_M15'SAFE_SMALL /=
        MICRO_ANGLE_ERROR_M15'BASE'SAFE_SMALL THEN
          FAILED ("MICRO_ANGLE_ERROR_M15'SAFE_SMALL /= " &
                  "MICRO_ANGLE_ERROR_M15'BASE'SAFE_SMALL");
     END IF;
     IF MICRO_ANGLE_ERROR_M15'SAFE_LARGE /=
        MICRO_ANGLE_ERROR_M15'BASE'SAFE_LARGE THEN
          FAILED ("MICRO_ANGLE_ERROR_M15'SAFE_LARGE /= " &
                  "MICRO_ANGLE_ERROR_M15'BASE'SAFE_LARGE");
     END IF;
     IF MICRO_ANGLE_ERROR_M15'SMALL <
        MICRO_ANGLE_ERROR_M15'BASE'SAFE_SMALL THEN
          FAILED ("MICRO_ANGLE_ERROR_M15'SMALL < " &
                  "MICRO_ANGLE_ERROR_M15'BASE'SAFE_SMALL");
     END IF;
     IF MICRO_ANGLE_ERROR_M15'LARGE >
        MICRO_ANGLE_ERROR_M15'BASE'SAFE_LARGE THEN
          FAILED ("MICRO_ANGLE_ERROR_M15'LARGE > " &
                  "MICRO_ANGLE_ERROR_M15'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT  : CONSTANT := MICRO_ANGLE_ERROR_M15'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   MICRO_ANGLE_ERROR_M15'SAFE_SMALL;
     BEGIN
          IF MICRO_ANGLE_ERROR_M15'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("MICRO_ANGLE_ERROR_M15'SAFE_LARGE /= " &
                       "(2.0 ** MICRO_ANGLE_ERROR_M15'BASE'MANTISSA -" &
                       " 1.0) * MICRO_ANGLE_ERROR_M15'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     IF TRACK_RANGE_M15'SAFE_SMALL /=
        TRACK_RANGE_M15'BASE'SMALL THEN
          FAILED ("TRACK_RANGE_M15'SAFE_SMALL /= " &
                  "TRACK_RANGE_M15'BASE'SMALL");
     END IF;
     IF TRACK_RANGE_M15'SAFE_LARGE /=
        TRACK_RANGE_M15'BASE'LARGE THEN
          FAILED ("TRACK_RANGE_M15'SAFE_LARGE /= " &
                  "TRACK_RANGE_M15'BASE'LARGE");
     END IF;
     IF TRACK_RANGE_M15'SAFE_SMALL /=
        TRACK_RANGE_M15'BASE'SAFE_SMALL THEN
          FAILED ("TRACK_RANGE_M15'SAFE_SMALL /= " &
                  "TRACK_RANGE_M15'BASE'SAFE_SMALL");
     END IF;
     IF TRACK_RANGE_M15'SAFE_LARGE /=
        TRACK_RANGE_M15'BASE'SAFE_LARGE THEN
          FAILED ("TRACK_RANGE_M15'SAFE_LARGE /= " &
                  "TRACK_RANGE_M15'BASE'SAFE_LARGE");
     END IF;
     IF TRACK_RANGE_M15'SMALL <
        TRACK_RANGE_M15'BASE'SAFE_SMALL THEN
          FAILED ("TRACK_RANGE_M15'SMALL < " &
                  "TRACK_RANGE_M15'BASE'SAFE_SMALL");
     END IF;
     IF TRACK_RANGE_M15'LARGE >
        TRACK_RANGE_M15'BASE'SAFE_LARGE THEN
          FAILED ("TRACK_RANGE_M15'LARGE > " &
                  "TRACK_RANGE_M15'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT  : CONSTANT := TRACK_RANGE_M15'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   TRACK_RANGE_M15'SAFE_SMALL;
     BEGIN
          IF TRACK_RANGE_M15'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("TRACK_RANGE_M15'SAFE_LARGE /= " &
                       "(2.0 ** TRACK_RANGE_M15'BASE'MANTISSA - 1.0) " &
                       "* TRACK_RANGE_M15'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     IF SECONDS_MM'SAFE_SMALL /=
        SECONDS_MM'BASE'SMALL THEN
          FAILED ("SECONDS_MM'SAFE_SMALL /= " &
                  "SECONDS_MM'BASE'SMALL");
     END IF;
     IF SECONDS_MM'SAFE_LARGE /=
        SECONDS_MM'BASE'LARGE THEN
          FAILED ("SECONDS_MM'SAFE_LARGE /= " &
                  "SECONDS_MM'BASE'LARGE");
     END IF;
     IF SECONDS_MM'SAFE_SMALL /=
        SECONDS_MM'BASE'SAFE_SMALL THEN
          FAILED ("SECONDS_MM'SAFE_SMALL /= " &
                  "SECONDS_MM'BASE'SAFE_SMALL");
     END IF;
     IF SECONDS_MM'SAFE_LARGE /=
        SECONDS_MM'BASE'SAFE_LARGE THEN
          FAILED ("SECONDS_MM'SAFE_LARGE /= " &
                  "SECONDS_MM'BASE'SAFE_LARGE");
     END IF;
     IF SECONDS_MM'SMALL <
        SECONDS_MM'BASE'SAFE_SMALL THEN
          FAILED ("SECONDS_MM'SMALL < " &
                  "SECONDS_MM'BASE'SAFE_SMALL");
     END IF;
     IF SECONDS_MM'LARGE >
        SECONDS_MM'BASE'SAFE_LARGE THEN
          FAILED ("SECONDS_MM'LARGE > " &
                  "SECONDS_MM'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT  : CONSTANT := SECONDS_MM'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   SECONDS_MM'SAFE_SMALL;
     BEGIN
          IF SECONDS_MM'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("SECONDS_MM'SAFE_LARGE /= " &
                       "(2.0 ** SECONDS_MM'BASE'MANTISSA - 1.0) * " &
                       "SECONDS_MM'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     IF RANGE_CELL_MM'SAFE_SMALL /=
        RANGE_CELL_MM'BASE'SMALL THEN
          FAILED ("RANGE_CELL_MM'SAFE_SMALL /= " &
                  "RANGE_CELL_MM'BASE'SMALL");
     END IF;
     IF RANGE_CELL_MM'SAFE_LARGE /=
        RANGE_CELL_MM'BASE'LARGE THEN
          FAILED ("RANGE_CELL_MM'SAFE_LARGE /= " &
                  "RANGE_CELL_MM'BASE'LARGE");
     END IF;
     IF RANGE_CELL_MM'SAFE_SMALL /=
        RANGE_CELL_MM'BASE'SAFE_SMALL THEN
          FAILED ("RANGE_CELL_MM'SAFE_SMALL /= " &
                  "RANGE_CELL_MM'BASE'SAFE_SMALL");
     END IF;
     IF RANGE_CELL_MM'SAFE_LARGE /=
        RANGE_CELL_MM'BASE'SAFE_LARGE THEN
          FAILED ("RANGE_CELL_MM'SAFE_LARGE /= " &
                  "RANGE_CELL_MM'BASE'SAFE_LARGE");
     END IF;
     IF RANGE_CELL_MM'SMALL <
        RANGE_CELL_MM'BASE'SAFE_SMALL THEN
          FAILED ("RANGE_CELL_MM'SMALL < " &
                  "RANGE_CELL_MM'BASE'SAFE_SMALL");
     END IF;
     IF RANGE_CELL_MM'LARGE >
        RANGE_CELL_MM'BASE'SAFE_LARGE THEN
          FAILED ("RANGE_CELL_MM'LARGE > " &
                  "RANGE_CELL_MM'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT  : CONSTANT := RANGE_CELL_MM'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   RANGE_CELL_MM'SAFE_SMALL;
     BEGIN
          IF RANGE_CELL_MM'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("RANGE_CELL_MM'SAFE_LARGE /= " &
                       "(2.0 ** RANGE_CELL_MM'BASE'MANTISSA - 1.0) * " &
                       "RANGE_CELL_MM'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     IF PIXEL_M10'SAFE_SMALL /=
        PIXEL_M10'BASE'SMALL THEN
          FAILED ("PIXEL_M10'SAFE_SMALL /= " &
                  "PIXEL_M10'BASE'SMALL");
     END IF;
     IF PIXEL_M10'SAFE_LARGE /=
        PIXEL_M10'BASE'LARGE THEN
          FAILED ("PIXEL_M10'SAFE_LARGE /= " &
                  "PIXEL_M10'BASE'LARGE");
     END IF;
     IF PIXEL_M10'SAFE_SMALL /=
        PIXEL_M10'BASE'SAFE_SMALL THEN
          FAILED ("PIXEL_M10'SAFE_SMALL /= " &
                  "PIXEL_M10'BASE'SAFE_SMALL");
     END IF;
     IF PIXEL_M10'SAFE_LARGE /=
        PIXEL_M10'BASE'SAFE_LARGE THEN
          FAILED ("PIXEL_M10'SAFE_LARGE /= " &
                  "PIXEL_M10'BASE'SAFE_LARGE");
     END IF;
     IF PIXEL_M10'SMALL <
        PIXEL_M10'BASE'SAFE_SMALL THEN
          FAILED ("PIXEL_M10'SMALL < " &
                  "PIXEL_M10'BASE'SAFE_SMALL");
     END IF;
     IF PIXEL_M10'LARGE >
        PIXEL_M10'BASE'SAFE_LARGE THEN
          FAILED ("PIXEL_M10'LARGE > " &
                  "PIXEL_M10'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT  : CONSTANT := PIXEL_M10'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   PIXEL_M10'SAFE_SMALL;
     BEGIN
          IF PIXEL_M10'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("PIXEL_M10'SAFE_LARGE /= " &
                       "(2.0 ** PIXEL_M10'BASE'MANTISSA - 1.0) * " &
                       "PIXEL_M10'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     IF RULER_M8'SAFE_SMALL /=
        RULER_M8'BASE'SMALL THEN
          FAILED ("RULER_M8'SAFE_SMALL /= " &
                  "RULER_M8'BASE'SMALL");
     END IF;
     IF RULER_M8'SAFE_LARGE /=
        RULER_M8'BASE'LARGE THEN
          FAILED ("RULER_M8'SAFE_LARGE /= " &
                  "RULER_M8'BASE'LARGE");
     END IF;
     IF RULER_M8'SAFE_SMALL /=
        RULER_M8'BASE'SAFE_SMALL THEN
          FAILED ("RULER_M8'SAFE_SMALL /= " &
                  "RULER_M8'BASE'SAFE_SMALL");
     END IF;
     IF RULER_M8'SAFE_LARGE /=
        RULER_M8'BASE'SAFE_LARGE THEN
          FAILED ("RULER_M8'SAFE_LARGE /= " &
                  "RULER_M8'BASE'SAFE_LARGE");
     END IF;
     IF RULER_M8'SMALL <
        RULER_M8'BASE'SAFE_SMALL THEN
          FAILED ("RULER_M8'SMALL < " &
                  "RULER_M8'BASE'SAFE_SMALL");
     END IF;
     IF RULER_M8'LARGE >
        RULER_M8'BASE'SAFE_LARGE THEN
          FAILED ("RULER_M8'LARGE > " &
                  "RULER_M8'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT  : CONSTANT := RULER_M8'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   RULER_M8'SAFE_SMALL;
     BEGIN
          IF RULER_M8'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("RULER_M8'SAFE_LARGE /= " &
                       "(2.0 ** RULER_M8'BASE'MANTISSA - 1.0) * " &
                       "RULER_M8'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     IF HOURS_M16'SAFE_SMALL /=
        HOURS_M16'BASE'SMALL THEN
          FAILED ("HOURS_M16'SAFE_SMALL /= " &
                  "HOURS_M16'BASE'SMALL");
     END IF;
     IF HOURS_M16'SAFE_LARGE /=
        HOURS_M16'BASE'LARGE THEN
          FAILED ("HOURS_M16'SAFE_LARGE /= " &
                  "HOURS_M16'BASE'LARGE");
     END IF;
     IF HOURS_M16'SAFE_SMALL /=
        HOURS_M16'BASE'SAFE_SMALL THEN
          FAILED ("HOURS_M16'SAFE_SMALL /= " &
                  "HOURS_M16'BASE'SAFE_SMALL");
     END IF;
     IF HOURS_M16'SAFE_LARGE /=
        HOURS_M16'BASE'SAFE_LARGE THEN
          FAILED ("HOURS_M16'SAFE_LARGE /= " &
                  "HOURS_M16'BASE'SAFE_LARGE");
     END IF;
     IF HOURS_M16'SMALL <
        HOURS_M16'BASE'SAFE_SMALL THEN
          FAILED ("HOURS_M16'SMALL < " &
                  "HOURS_M16'BASE'SAFE_SMALL");
     END IF;
     IF HOURS_M16'LARGE >
        HOURS_M16'BASE'SAFE_LARGE THEN
          FAILED ("HOURS_M16'LARGE > " &
                  "HOURS_M16'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT  : CONSTANT := HOURS_M16'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   HOURS_M16'SAFE_SMALL;
     BEGIN
          IF HOURS_M16'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("HOURS_M16'SAFE_LARGE /= " &
                       "(2.0 ** HOURS_M16'BASE'MANTISSA - 1.0) * " &
                       "HOURS_M16'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     IF MILES_M16'SAFE_SMALL /=
        MILES_M16'BASE'SMALL THEN
          FAILED ("MILES_M16'SAFE_SMALL /= " &
                  "MILES_M16'BASE'SMALL");
     END IF;
     IF MILES_M16'SAFE_LARGE /=
        MILES_M16'BASE'LARGE THEN
          FAILED ("MILES_M16'SAFE_LARGE /= " &
                  "MILES_M16'BASE'LARGE");
     END IF;
     IF MILES_M16'SAFE_SMALL /=
        MILES_M16'BASE'SAFE_SMALL THEN
          FAILED ("MILES_M16'SAFE_SMALL /= " &
                  "MILES_M16'BASE'SAFE_SMALL");
     END IF;
     IF MILES_M16'SAFE_LARGE /=
        MILES_M16'BASE'SAFE_LARGE THEN
          FAILED ("MILES_M16'SAFE_LARGE /= " &
                  "MILES_M16'BASE'SAFE_LARGE");
     END IF;
     IF MILES_M16'SMALL <
        MILES_M16'BASE'SAFE_SMALL THEN
          FAILED ("MILES_M16'SMALL < " &
                  "MILES_M16'BASE'SAFE_SMALL");
     END IF;
     IF MILES_M16'LARGE >
        MILES_M16'BASE'SAFE_LARGE THEN
          FAILED ("MILES_M16'LARGE > " &
                  "MILES_M16'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT  : CONSTANT := MILES_M16'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   MILES_M16'SAFE_SMALL;
     BEGIN
          IF MILES_M16'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("MILES_M16'SAFE_LARGE /= " &
                       "(2.0 ** MILES_M16'BASE'MANTISSA - 1.0) * " &
                       "MILES_M16'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     IF SYMMETRIC_DEGREES_M7'SAFE_SMALL /=
        SYMMETRIC_DEGREES_M7'BASE'SMALL THEN
          FAILED ("SYMMETRIC_DEGREES_M7'SAFE_SMALL /= " &
                  "SYMMETRIC_DEGREES_M7'BASE'SMALL");
     END IF;
     IF SYMMETRIC_DEGREES_M7'SAFE_LARGE /=
        SYMMETRIC_DEGREES_M7'BASE'LARGE THEN
          FAILED ("SYMMETRIC_DEGREES_M7'SAFE_LARGE /= " &
                  "SYMMETRIC_DEGREES_M7'BASE'LARGE");
     END IF;
     IF SYMMETRIC_DEGREES_M7'SAFE_SMALL /=
        SYMMETRIC_DEGREES_M7'BASE'SAFE_SMALL THEN
          FAILED ("SYMMETRIC_DEGREES_M7'SAFE_SMALL /= " &
                  "SYMMETRIC_DEGREES_M7'BASE'SAFE_SMALL");
     END IF;
     IF SYMMETRIC_DEGREES_M7'SAFE_LARGE /=
        SYMMETRIC_DEGREES_M7'BASE'SAFE_LARGE THEN
          FAILED ("SYMMETRIC_DEGREES_M7'SAFE_LARGE /= " &
                  "SYMMETRIC_DEGREES_M7'BASE'SAFE_LARGE");
     END IF;
     IF SYMMETRIC_DEGREES_M7'SMALL <
        SYMMETRIC_DEGREES_M7'BASE'SAFE_SMALL THEN
          FAILED ("SYMMETRIC_DEGREES_M7'SMALL < " &
                  "SYMMETRIC_DEGREES_M7'BASE'SAFE_SMALL");
     END IF;
     IF SYMMETRIC_DEGREES_M7'LARGE >
        SYMMETRIC_DEGREES_M7'BASE'SAFE_LARGE THEN
          FAILED ("SYMMETRIC_DEGREES_M7'LARGE > " &
                  "SYMMETRIC_DEGREES_M7'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT  : CONSTANT := SYMMETRIC_DEGREES_M7'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   SYMMETRIC_DEGREES_M7'SAFE_SMALL;
     BEGIN
          IF SYMMETRIC_DEGREES_M7'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("SYMMETRIC_DEGREES_M7'SAFE_LARGE /= " &
                       "(2.0 ** SYMMETRIC_DEGREES_M7'BASE'MANTISSA - " &
                       "1.0) * SYMMETRIC_DEGREES_M7'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     IF NATURAL_DEGREES_M15'SAFE_SMALL /=
        NATURAL_DEGREES_M15'BASE'SMALL THEN
          FAILED ("NATURAL_DEGREES_M15'SAFE_SMALL /= " &
                  "NATURAL_DEGREES_M15'BASE'SMALL");
     END IF;
     IF NATURAL_DEGREES_M15'SAFE_LARGE /=
        NATURAL_DEGREES_M15'BASE'LARGE THEN
          FAILED ("NATURAL_DEGREES_M15'SAFE_LARGE /= " &
                  "NATURAL_DEGREES_M15'BASE'LARGE");
     END IF;
     IF NATURAL_DEGREES_M15'SAFE_SMALL /=
        NATURAL_DEGREES_M15'BASE'SAFE_SMALL THEN
          FAILED ("NATURAL_DEGREES_M15'SAFE_SMALL /= " &
                  "NATURAL_DEGREES_M15'BASE'SAFE_SMALL");
     END IF;
     IF NATURAL_DEGREES_M15'SAFE_LARGE /=
        NATURAL_DEGREES_M15'BASE'SAFE_LARGE THEN
          FAILED ("NATURAL_DEGREES_M15'SAFE_LARGE /= " &
                  "NATURAL_DEGREES_M15'BASE'SAFE_LARGE");
     END IF;
     IF NATURAL_DEGREES_M15'SMALL <
        NATURAL_DEGREES_M15'BASE'SAFE_SMALL THEN
          FAILED ("NATURAL_DEGREES_M15'SMALL < " &
                  "NATURAL_DEGREES_M15'BASE'SAFE_SMALL");
     END IF;
     IF NATURAL_DEGREES_M15'LARGE >
        NATURAL_DEGREES_M15'BASE'SAFE_LARGE THEN
          FAILED ("NATURAL_DEGREES_M15'LARGE > " &
                  "NATURAL_DEGREES_M15'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT  : CONSTANT := NATURAL_DEGREES_M15'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   NATURAL_DEGREES_M15'SAFE_SMALL;
     BEGIN
          IF NATURAL_DEGREES_M15'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("NATURAL_DEGREES_M15'SAFE_LARGE /= " &
                       "(2.0 ** NATURAL_DEGREES_M15'BASE'MANTISSA - " &
                       "1.0) * NATURAL_DEGREES_M15'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     IF SYMMETRIC_RADIANS_M16'SAFE_SMALL /=
        SYMMETRIC_RADIANS_M16'BASE'SMALL THEN
          FAILED ("SYMMETRIC_RADIANS_M16'SAFE_SMALL /= " &
                  "SYMMETRIC_RADIANS_M16'BASE'SMALL");
     END IF;
     IF SYMMETRIC_RADIANS_M16'SAFE_LARGE /=
        SYMMETRIC_RADIANS_M16'BASE'LARGE THEN
          FAILED ("SYMMETRIC_RADIANS_M16'SAFE_LARGE /= " &
                  "SYMMETRIC_RADIANS_M16'BASE'LARGE");
     END IF;
     IF SYMMETRIC_RADIANS_M16'SAFE_SMALL /=
        SYMMETRIC_RADIANS_M16'BASE'SAFE_SMALL THEN
          FAILED ("SYMMETRIC_RADIANS_M16'SAFE_SMALL /= " &
                  "SYMMETRIC_RADIANS_M16'BASE'SAFE_SMALL");
     END IF;
     IF SYMMETRIC_RADIANS_M16'SAFE_LARGE /=
        SYMMETRIC_RADIANS_M16'BASE'SAFE_LARGE THEN
          FAILED ("SYMMETRIC_RADIANS_M16'SAFE_LARGE /= " &
                  "SYMMETRIC_RADIANS_M16'BASE'SAFE_LARGE");
     END IF;
     IF SYMMETRIC_RADIANS_M16'SMALL <
        SYMMETRIC_RADIANS_M16'BASE'SAFE_SMALL THEN
          FAILED ("SYMMETRIC_RADIANS_M16'SMALL < " &
                  "SYMMETRIC_RADIANS_M16'BASE'SAFE_SMALL");
     END IF;
     IF SYMMETRIC_RADIANS_M16'LARGE >
        SYMMETRIC_RADIANS_M16'BASE'SAFE_LARGE THEN
          FAILED ("SYMMETRIC_RADIANS_M16'LARGE > " &
                  "SYMMETRIC_RADIANS_M16'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT  : CONSTANT := SYMMETRIC_RADIANS_M16'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   SYMMETRIC_RADIANS_M16'SAFE_SMALL;
     BEGIN
          IF SYMMETRIC_RADIANS_M16'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("SYMMETRIC_RADIANS_M16'SAFE_LARGE /= " &
                       "(2.0 ** SYMMETRIC_RADIANS_M16'BASE'MANTISSA " &
                       "- 1.0) * SYMMETRIC_RADIANS_M16'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     IF NATURAL_RADIANS_M8'SAFE_SMALL /=
        NATURAL_RADIANS_M8'BASE'SMALL THEN
          FAILED ("NATURAL_RADIANS_M8'SAFE_SMALL /= " &
                  "NATURAL_RADIANS_M8'BASE'SMALL");
     END IF;
     IF NATURAL_RADIANS_M8'SAFE_LARGE /=
        NATURAL_RADIANS_M8'BASE'LARGE THEN
          FAILED ("NATURAL_RADIANS_M8'SAFE_LARGE /= " &
                  "NATURAL_RADIANS_M8'BASE'LARGE");
     END IF;
     IF NATURAL_RADIANS_M8'SAFE_SMALL /=
        NATURAL_RADIANS_M8'BASE'SAFE_SMALL THEN
          FAILED ("NATURAL_RADIANS_M8'SAFE_SMALL /= " &
                  "NATURAL_RADIANS_M8'BASE'SAFE_SMALL");
     END IF;
     IF NATURAL_RADIANS_M8'SAFE_LARGE /=
        NATURAL_RADIANS_M8'BASE'SAFE_LARGE THEN
          FAILED ("NATURAL_RADIANS_M8'SAFE_LARGE /= " &
                  "NATURAL_RADIANS_M8'BASE'SAFE_LARGE");
     END IF;
     IF NATURAL_RADIANS_M8'SMALL <
        NATURAL_RADIANS_M8'BASE'SAFE_SMALL THEN
          FAILED ("NATURAL_RADIANS_M8'SMALL < " &
                  "NATURAL_RADIANS_M8'BASE'SAFE_SMALL");
     END IF;
     IF NATURAL_RADIANS_M8'LARGE >
        NATURAL_RADIANS_M8'BASE'SAFE_LARGE THEN
          FAILED ("NATURAL_RADIANS_M8'LARGE > " &
                  "NATURAL_RADIANS_M8'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT  : CONSTANT := NATURAL_RADIANS_M8'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   NATURAL_RADIANS_M8'SAFE_SMALL;
     BEGIN
          IF NATURAL_RADIANS_M8'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("NATURAL_RADIANS_M8'SAFE_LARGE /= " &
                       "(2.0 ** NATURAL_RADIANS_M8'BASE'MANTISSA - " &
                       "1.0) * NATURAL_RADIANS_M8'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     IF ST_MILES_M8'SAFE_SMALL /=
        ST_MILES_M8'BASE'SMALL THEN
          FAILED ("ST_MILES_M8'SAFE_SMALL /= " &
                  "ST_MILES_M8'BASE'SMALL");
     END IF;
     IF ST_MILES_M8'SAFE_LARGE /=
        ST_MILES_M8'BASE'LARGE THEN
          FAILED ("ST_MILES_M8'SAFE_LARGE /= " &
                  "ST_MILES_M8'BASE'LARGE");
     END IF;
     IF ST_MILES_M8'SAFE_SMALL /=
        ST_MILES_M8'BASE'SAFE_SMALL THEN
          FAILED ("ST_MILES_M8'SAFE_SMALL /= " &
                  "ST_MILES_M8'BASE'SAFE_SMALL");
     END IF;
     IF ST_MILES_M8'SAFE_LARGE /=
        ST_MILES_M8'BASE'SAFE_LARGE THEN
          FAILED ("ST_MILES_M8'SAFE_LARGE /= " &
                  "ST_MILES_M8'BASE'SAFE_LARGE");
     END IF;
     IF ST_MILES_M8'SMALL <
        ST_MILES_M8'BASE'SAFE_SMALL THEN
          FAILED ("ST_MILES_M8'SMALL < " &
                  "ST_MILES_M8'BASE'SAFE_SMALL");
     END IF;
     IF ST_MILES_M8'LARGE >
        ST_MILES_M8'BASE'SAFE_LARGE THEN
          FAILED ("ST_MILES_M8'LARGE > " &
                  "ST_MILES_M8'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT  : CONSTANT := ST_MILES_M8'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   ST_MILES_M8'SAFE_SMALL;
     BEGIN
          IF ST_MILES_M8'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("ST_MILES_M8'SAFE_LARGE /= " &
                       "(2.0 ** ST_MILES_M8'BASE'MANTISSA - 1.0) * " &
                       "ST_MILES_M8'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     IF ST_NATURAL_DEGREES_M11'SAFE_SMALL /=
        ST_NATURAL_DEGREES_M11'BASE'SMALL THEN
          FAILED ("ST_NATURAL_DEGREES_M11'SAFE_SMALL /= " &
                  "ST_NATURAL_DEGREES_M11'BASE'SMALL");
     END IF;
     IF ST_NATURAL_DEGREES_M11'SAFE_LARGE /=
        ST_NATURAL_DEGREES_M11'BASE'LARGE THEN
          FAILED ("ST_NATURAL_DEGREES_M11'SAFE_LARGE /= " &
                  "ST_NATURAL_DEGREES_M11'BASE'LARGE");
     END IF;
     IF ST_NATURAL_DEGREES_M11'SAFE_SMALL /=
        ST_NATURAL_DEGREES_M11'BASE'SAFE_SMALL THEN
          FAILED ("ST_NATURAL_DEGREES_M11'SAFE_SMALL /= " &
                  "ST_NATURAL_DEGREES_M11'BASE'SAFE_SMALL");
     END IF;
     IF ST_NATURAL_DEGREES_M11'SAFE_LARGE /=
        ST_NATURAL_DEGREES_M11'BASE'SAFE_LARGE THEN
          FAILED ("ST_NATURAL_DEGREES_M11'SAFE_LARGE /= " &
                  "ST_NATURAL_DEGREES_M11'BASE'SAFE_LARGE");
     END IF;
     IF ST_NATURAL_DEGREES_M11'SMALL <
        ST_NATURAL_DEGREES_M11'BASE'SAFE_SMALL THEN
          FAILED ("ST_NATURAL_DEGREES_M11'SMALL < " &
                  "ST_NATURAL_DEGREES_M11'BASE'SAFE_SMALL");
     END IF;
     IF ST_NATURAL_DEGREES_M11'LARGE >
        ST_NATURAL_DEGREES_M11'BASE'SAFE_LARGE THEN
          FAILED ("ST_NATURAL_DEGREES_M11'LARGE > " &
                  "ST_NATURAL_DEGREES_M11'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT  : CONSTANT := ST_NATURAL_DEGREES_M11'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   ST_NATURAL_DEGREES_M11'SAFE_SMALL;
     BEGIN
          IF ST_NATURAL_DEGREES_M11'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("ST_NATURAL_DEGREES_M11'SAFE_LARGE /= " &
                       "(2.0 ** ST_NATURAL_DEGREES_M11'BASE'MANTISSA " &
                       "- 1.0) * ST_NATURAL_DEGREES_M11'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     IF ST_SYMMETRIC_RADIANS_M8'SAFE_SMALL /=
        ST_SYMMETRIC_RADIANS_M8'BASE'SMALL THEN
          FAILED ("ST_SYMMETRIC_RADIANS_M8'SAFE_SMALL /= " &
                  "ST_SYMMETRIC_RADIANS_M8'BASE'SMALL");
     END IF;
     IF ST_SYMMETRIC_RADIANS_M8'SAFE_LARGE /=
        ST_SYMMETRIC_RADIANS_M8'BASE'LARGE THEN
          FAILED ("ST_SYMMETRIC_RADIANS_M8'SAFE_LARGE /= " &
                  "ST_SYMMETRIC_RADIANS_M8'BASE'LARGE");
     END IF;
     IF ST_SYMMETRIC_RADIANS_M8'SAFE_SMALL /=
        ST_SYMMETRIC_RADIANS_M8'BASE'SAFE_SMALL THEN
          FAILED ("ST_SYMMETRIC_RADIANS_M8'SAFE_SMALL /= " &
                  "ST_SYMMETRIC_RADIANS_M8'BASE'SAFE_SMALL");
     END IF;
     IF ST_SYMMETRIC_RADIANS_M8'SAFE_LARGE /=
        ST_SYMMETRIC_RADIANS_M8'BASE'SAFE_LARGE THEN
          FAILED ("ST_SYMMETRIC_RADIANS_M8'SAFE_LARGE /= " &
                  "ST_SYMMETRIC_RADIANS_M8'BASE'SAFE_LARGE");
     END IF;
     IF ST_SYMMETRIC_RADIANS_M8'SMALL <
        ST_SYMMETRIC_RADIANS_M8'BASE'SAFE_SMALL THEN
          FAILED ("ST_SYMMETRIC_RADIANS_M8'SMALL < " &
                  "ST_SYMMETRIC_RADIANS_M8'BASE'SAFE_SMALL");
     END IF;
     IF ST_SYMMETRIC_RADIANS_M8'LARGE >
        ST_SYMMETRIC_RADIANS_M8'BASE'SAFE_LARGE THEN
          FAILED ("ST_SYMMETRIC_RADIANS_M8'LARGE > " &
                  "ST_SYMMETRIC_RADIANS_M8'BASE'SAFE_LARGE");
     END IF;
     DECLARE
          BASE_MANT : CONSTANT := ST_SYMMETRIC_RADIANS_M8'BASE'MANTISSA;
          SAFE_LARGE : CONSTANT := ( (2.0 ** (BASE_MANT - 1) - 1.0) +
                                      2.0 ** (BASE_MANT - 1) ) *
                                   ST_SYMMETRIC_RADIANS_M8'SAFE_SMALL;
     BEGIN
          IF ST_SYMMETRIC_RADIANS_M8'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("ST_SYMMETRIC_RADIANS_M8'SAFE_LARGE /= " &
                       "(2.0 ** ST_SYMMETRIC_RADIANS_M8'BASE'MANTISSA "&
                       "- 1.0) * ST_SYMMETRIC_RADIANS_M8'SAFE_SMALL");
          END IF;
     END;

     -------------------------------------------------------------------

     RESULT;

END C35A06D;
