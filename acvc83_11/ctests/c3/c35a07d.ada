-- C35A07D.ADA

-- CHECK THAT FOR FIXED POINT TYPES THE FIRST AND LAST ATTRIBUTES YIELD
-- CORRECT VALUES.

-- CASE D: TYPES TYPICAL OF APPLICATIONS USING FIXED POINT ARITHMETIC.

-- WRG 8/25/86

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;
PROCEDURE C35A07D IS

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
               -- 'SMALL = 2.0 ** (-14) = 0.00006_10351_5625.
     TYPE NATURAL_RADIANS_M8    IS
          DELTA TWO_PI * 2.0 ** ( -7) RANGE 0.0 .. TWO_PI;
               -- 'SMALL = 2.0 ** ( -5) = 0.03125.

     -------------------------------------------------------------------

     SUBTYPE ST_MILES_M8             IS MILES_M16
          DELTA 3000.0 * 2.0 ** (-15) RANGE 0.0 .. 10.0;
     SUBTYPE ST_NATURAL_DEGREES_M11  IS NATURAL_DEGREES_M15
          DELTA 0.25 RANGE 0.0 .. 360.0;
     SUBTYPE ST_SYMMETRIC_RADIANS_M8 IS SYMMETRIC_RADIANS_M16
          DELTA HALF_PI * 2.0 ** (-7) RANGE -HALF_PI .. HALF_PI;
               -- 'SMALL = 2.0 ** ( -7) = 0.00781_25.

BEGIN

     TEST ("C35A07D", "CHECK THAT FOR FIXED POINT TYPES THE FIRST " &
                      "AND LAST ATTRIBUTES YIELD CORRECT VALUES - " &
                      "TYPICAL TYPES");

     -------------------------------------------------------------------

     IF MICRO_ANGLE_ERROR_M15'FIRST >
       -MICRO_ANGLE_ERROR_M15'LARGE THEN
          FAILED ("MICRO_ANGLE_ERROR_M15'FIRST > " &
                  "-MICRO_ANGLE_ERROR_M15'LARGE");
     END IF;
     IF MICRO_ANGLE_ERROR_M15'LAST  <
        MICRO_ANGLE_ERROR_M15'LARGE THEN
          FAILED ("MICRO_ANGLE_ERROR_M15'LAST  <  " &
                  "MICRO_ANGLE_ERROR_M15'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF TRACK_RANGE_M15'FIRST > -TRACK_RANGE_M15'LARGE THEN
          FAILED ("TRACK_RANGE_M15'FIRST > -TRACK_RANGE_M15'LARGE");
     END IF;
     IF TRACK_RANGE_M15'LAST  <  TRACK_RANGE_M15'LARGE THEN
          FAILED ("TRACK_RANGE_M15'LAST  <  TRACK_RANGE_M15'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF SECONDS_MM'FIRST > -SECONDS_MM'LARGE THEN
          FAILED ("SECONDS_MM'FIRST > -SECONDS_MM'LARGE");
     END IF;
     IF SECONDS_MM'LAST  <  SECONDS_MM'LARGE THEN
          FAILED ("SECONDS_MM'LAST  <  SECONDS_MM'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF RANGE_CELL_MM'FIRST > -RANGE_CELL_MM'LARGE THEN
          FAILED ("RANGE_CELL_MM'FIRST > -RANGE_CELL_MM'LARGE");
     END IF;
     IF RANGE_CELL_MM'LAST  <  RANGE_CELL_MM'LARGE THEN
          FAILED ("RANGE_CELL_MM'LAST  <  RANGE_CELL_MM'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF PIXEL_M10'FIRST /= IDENT_INT (1) * 0.0 THEN
          FAILED ("PIXEL_M10'FIRST /= 0.0");
     END IF;
     IF PIXEL_M10'LAST  <  PIXEL_M10'LARGE THEN
          FAILED ("PIXEL_M10'LAST  < PIXEL_M10'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF RULER_M8'FIRST /= IDENT_INT (1) * 0.0 THEN
          FAILED ("RULER_M8'FIRST /= 0.0");
     END IF;
     IF RULER_M8'LAST /= IDENT_INT (1) * 12.0 THEN
          FAILED ("RULER_M8'LAST /= 12.0");
     END IF;

     -------------------------------------------------------------------

     IF HOURS_M16'FIRST /= IDENT_INT (1) * 0.0 THEN
          FAILED ("HOURS_M16'FIRST /= 0.0");
     END IF;
     IF HOURS_M16'LAST /= IDENT_INT (1) * 24.0 THEN
          FAILED ("HOURS_M16'LAST /= 24.0");
     END IF;

     -------------------------------------------------------------------

     IF MILES_M16'FIRST /= IDENT_INT (1) * 0.0 THEN
          FAILED ("MILES_M16'FIRST /= 0.0");
     END IF;
     IF MILES_M16'LAST /= IDENT_INT (1) * 3000.0 THEN
          FAILED ("MILES_M16'LAST /= 3000.0");
     END IF;

     -------------------------------------------------------------------

     IF SYMMETRIC_DEGREES_M7'FIRST /= IDENT_INT (1) * (-180.0) THEN
          FAILED ("SYMMETRIC_DEGREES_M7'FIRST /= -180.0");
     END IF;
     IF SYMMETRIC_DEGREES_M7'LAST /= IDENT_INT (1) * 180.0 THEN
          FAILED ("SYMMETRIC_DEGREES_M7'LAST /= 180.0");
     END IF;

     -------------------------------------------------------------------

     IF NATURAL_DEGREES_M15'FIRST /= IDENT_INT (1) * 0.0 THEN
          FAILED ("NATURAL_DEGREES_M15'FIRST /= 0.0");
     END IF;
     IF NATURAL_DEGREES_M15'LAST /= IDENT_INT (1) * 360.0 THEN
          FAILED ("NATURAL_DEGREES_M15'LAST /= 360.0");
     END IF;

     -------------------------------------------------------------------

     -- PI IS IN 3.0 + 2319 * 'SMALL .. 3.0 + 2320 * 'SMALL.
     IF SYMMETRIC_RADIANS_M16'FIRST NOT IN
        -3.14160_15625 .. -3.14154_05273_4375 THEN
          FAILED ("SYMMETRIC_RADIANS_M16'FIRST NOT IN " &
                  "-3.14160_15625 .. -3.14154_05273_4375");
     END IF;
     IF SYMMETRIC_RADIANS_M16'LAST  NOT IN
        3.14154_05273_4375 .. 3.14160_15625 THEN
          FAILED ("SYMMETRIC_RADIANS_M16'LAST NOT IN " &
                  "3.14154_05273_4375 .. 3.14160_15625");
     END IF;

     -------------------------------------------------------------------

     IF NATURAL_RADIANS_M8'FIRST /= IDENT_INT (1) * 0.0 THEN
          FAILED ("NATURAL_RADIANS_M8'FIRST /= 0.0");
     END IF;
     -- TWO_PI IS IN 201 * 'SMALL .. 202 * 'SMALL.
     IF NATURAL_RADIANS_M8'LAST  NOT IN 6.28125 .. 6.3125 THEN
          FAILED ("NATURAL_RADIANS_M8'LAST NOT IN 6.28125 .. 6.3125");
     END IF;

     -------------------------------------------------------------------

     IF ST_MILES_M8'FIRST /= IDENT_INT (1) * 0.0 THEN
          FAILED ("ST_MILES_M8'FIRST /= 0.0");
     END IF;
     IF ST_MILES_M8'LAST /= IDENT_INT (1) * 10.0 THEN
          FAILED ("ST_MILES_M8'LAST /= 10.0");
     END IF;

     -------------------------------------------------------------------

     IF ST_NATURAL_DEGREES_M11'FIRST /= IDENT_INT (1) * 0.0 THEN
          FAILED ("ST_NATURAL_DEGREES_M11'FIRST /= 0.0");
     END IF;
     IF ST_NATURAL_DEGREES_M11'LAST /= IDENT_INT (1) * 360.0 THEN
          FAILED ("ST_NATURAL_DEGREES_M11'LAST /= 360.0");
     END IF;

     -------------------------------------------------------------------

     -- HALF_PI IS IN 201 * 'SMALL .. 202 * 'SMALL.
     IF ST_SYMMETRIC_RADIANS_M8'FIRST NOT IN
        -1.57812_5 .. -1.57031_25 THEN
          FAILED ("ST_SYMMETRIC_RADIANS_M8'FIRST NOT IN " &
                  "-1.57812_5 .. -1.57031_25");
     END IF;
     IF ST_SYMMETRIC_RADIANS_M8'LAST  NOT IN
        1.57031_25 .. 1.57812_5 THEN
          FAILED ("ST_SYMMETRIC_RADIANS_M8'LAST NOT IN " &
                  "1.57031_25 .. 1.57812_5");
     END IF;

     -------------------------------------------------------------------

     RESULT;

END C35A07D;
