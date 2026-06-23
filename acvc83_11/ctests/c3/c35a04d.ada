-- C35A04D.ADA

-- CHECK THAT FOR FIXED POINT TYPES THE SMALL AND LARGE ATTRIBUTES
-- YIELD THE CORRECT VALUES.

-- CASE D: TYPES TYPICAL OF APPLICATIONS USING FIXED POINT ARITHMETIC.

-- WRG 8/4/86

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;
PROCEDURE C35A04D IS

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

     TEST ("C35A04D", "CHECK THAT FOR FIXED POINT TYPES THE SMALL " &
                      "AND LARGE ATTRIBUTES YIELD THE CORRECT VALUES " &
                      "- TYPICAL TYPES");

     -------------------------------------------------------------------

     DECLARE
       -- TYPE MICRO_ANGLE_ERROR_M15 IS DELTA 16.0
       --      RANGE -(2.0 ** 19) .. 2.0 ** 19;
          SMALL    : CONSTANT := 16.0;
          MANTISSA : CONSTANT := 15;
          V1, V2   : MICRO_ANGLE_ERROR_M15;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF MICRO_ANGLE_ERROR_M15'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR MICRO_ANGLE_ERROR_M15'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF MICRO_ANGLE_ERROR_M15'LARGE /= V2 THEN
               FAILED ("WRONG VALUE FOR MICRO_ANGLE_ERROR_M15'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR MICRO_ANGLE_ERROR_M15");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE TRACK_RANGE_M15 IS
       --      DELTA 0.125 RANGE -(2.0 ** 12) .. 2.0 ** 12;
          SMALL    : CONSTANT := 0.125;
          MANTISSA : CONSTANT := 15;
          V1, V2   : TRACK_RANGE_M15;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF TRACK_RANGE_M15'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR TRACK_RANGE_M15'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF TRACK_RANGE_M15'LARGE /= V2 THEN
               FAILED ("WRONG VALUE FOR TRACK_RANGE_M15'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR TRACK_RANGE_M15");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE SECONDS_MM IS
       --      DELTA 2.0 ** (8-MM) RANGE -(2.0 ** 8) .. 2.0 ** 8;
          SMALL    : CONSTANT := 2.0 ** (8 - MM);
          MANTISSA : CONSTANT := MM;
          V1, V2   : SECONDS_MM;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF SECONDS_MM'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR SECONDS_MM'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF SECONDS_MM'LARGE /= V2 THEN
               FAILED ("WRONG VALUE FOR SECONDS_MM'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR SECONDS_MM");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE RANGE_CELL_MM IS
       --      DELTA 2.0 ** (-5)
       --      RANGE -(2.0 ** (MM-5) ) .. 2.0 ** (MM - 5);
          SMALL    : CONSTANT := 2.0 ** (-5);
          MANTISSA : CONSTANT := MM;
          V1, V2   : RANGE_CELL_MM;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF RANGE_CELL_MM'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR RANGE_CELL_MM'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF RANGE_CELL_MM'LARGE /= V2 THEN
               FAILED ("WRONG VALUE FOR RANGE_CELL_MM'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR RANGE_CELL_MM");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE PIXEL_M10 IS DELTA 1.0 / 1024.0 RANGE 0.0 .. 1.0;
          SMALL    : CONSTANT := 1.0 / 1024;
          MANTISSA : CONSTANT := 10;
          V1, V2   : PIXEL_M10;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF PIXEL_M10'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR PIXEL_M10'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF PIXEL_M10'LARGE /= V2 THEN
               FAILED ("WRONG VALUE FOR PIXEL_M10'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR PIXEL_M10");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE RULER_M8 IS DELTA 1.0 / 16.0 RANGE 0.0 .. 12.0;
          SMALL    : CONSTANT := 1.0 / 16.0;
          MANTISSA : CONSTANT := 8;
          V1, V2   : RULER_M8;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF RULER_M8'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR RULER_M8'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF RULER_M8'LARGE /= V2 + V1 THEN
               FAILED ("WRONG VALUE FOR RULER_M8'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR RULER_M8");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE HOURS_M16 IS DELTA 24.0 * 2.0 ** (-15) RANGE 0.0 .. 24.0;
          SMALL    : CONSTANT := 2.0 ** (-11);
          MANTISSA : CONSTANT := 16;
          V1, V2   : HOURS_M16;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF HOURS_M16'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR HOURS_M16'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF HOURS_M16'LARGE /= V2 + V1 THEN
               FAILED ("WRONG VALUE FOR HOURS_M16'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR HOURS_M16");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE MILES_M16 IS
       --      DELTA 3000.0 * 2.0 ** (-15) RANGE 0.0 .. 3000.0;
          SMALL    : CONSTANT := 2.0 ** (-4);
          MANTISSA : CONSTANT := 16;
          V1, V2   : MILES_M16;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF MILES_M16'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR MILES_M16'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF MILES_M16'LARGE /= V2 + V1 THEN
               FAILED ("WRONG VALUE FOR MILES_M16'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR MILES_M16");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE SYMMETRIC_DEGREES_M7 IS DELTA 2.0 RANGE -180.0 .. 180.0;
          SMALL    : CONSTANT := 2.0;
          MANTISSA : CONSTANT := 7;
          V1, V2   : SYMMETRIC_DEGREES_M7;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF SYMMETRIC_DEGREES_M7'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR SYMMETRIC_DEGREES_M7'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF SYMMETRIC_DEGREES_M7'LARGE /= V2 + V1 THEN
               FAILED ("WRONG VALUE FOR SYMMETRIC_DEGREES_M7'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR SYMMETRIC_DEGREES_M7");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE NATURAL_DEGREES_M15 IS
       --      DELTA 2.0 ** (-6) RANGE 0.0 .. 360.0;
          SMALL    : CONSTANT := 2.0 ** (-6);
          MANTISSA : CONSTANT := 15;
          V1, V2   : NATURAL_DEGREES_M15;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF NATURAL_DEGREES_M15'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR NATURAL_DEGREES_M15'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF NATURAL_DEGREES_M15'LARGE /= V2 + V1 THEN
               FAILED ("WRONG VALUE FOR NATURAL_DEGREES_M15'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR NATURAL_DEGREES_M15");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE SYMMETRIC_RADIANS_M16 IS
       --      DELTA PI * 2.0 ** (-15) RANGE -PI .. PI;
          SMALL    : CONSTANT := 2.0 ** (-14);
          MANTISSA : CONSTANT := 16;
          V1, V2   : SYMMETRIC_RADIANS_M16;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF SYMMETRIC_RADIANS_M16'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR SYMMETRIC_RADIANS_M16'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF SYMMETRIC_RADIANS_M16'LARGE /= V2 + V1 THEN
               FAILED ("WRONG VALUE FOR SYMMETRIC_RADIANS_M16'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR SYMMETRIC_RADIANS_M16");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE NATURAL_RADIANS_M8 IS
       --      DELTA TWO_PI * 2.0 ** (-7) RANGE 0.0 .. TWO_PI;
          SMALL    : CONSTANT := 2.0 ** (-5);
          MANTISSA : CONSTANT := 8;
          V1, V2   : NATURAL_RADIANS_M8;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF NATURAL_RADIANS_M8'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR NATURAL_RADIANS_M8'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF NATURAL_RADIANS_M8'LARGE /= V2 + V1 THEN
               FAILED ("WRONG VALUE FOR NATURAL_RADIANS_M8'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR NATURAL_RADIANS_M8");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE MILES_M16 IS
       --      DELTA 3000.0 * 2.0 ** (-15) RANGE 0.0 .. 3000.0;
       -- SUBTYPE ST_MILES_M8 IS MILES_M16
       --      DELTA 3000.0 * 2.0 ** (-15) RANGE 0.0 .. 10.0;
          SMALL    : CONSTANT := 2.0 ** (-4);
          MANTISSA : CONSTANT := 8;
          V1, V2   : ST_MILES_M8;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF ST_MILES_M8'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR ST_MILES_M8'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF ST_MILES_M8'LARGE /= V2 + V1 THEN
               IF ST_MILES_M8'LARGE = MILES_M16'LARGE THEN
                    FAILED ("ST_MILES_M8'LARGE = " &
                            "MILES_M16'LARGE");
               ELSE
                    FAILED ("WRONG VALUE FOR " &
                            "ST_MILES_M8'LARGE");
               END IF;
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR ST_MILES_M8");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE NATURAL_DEGREES_M15 IS
       --      DELTA 2.0 ** (-6) RANGE 0.0 .. 360.0;
       -- SUBTYPE ST_NATURAL_DEGREES_M11 IS NATURAL_DEGREES_M15
       --      DELTA 0.25 RANGE 0.0 .. 360.0;
          SMALL    : CONSTANT := 0.25;
          MANTISSA : CONSTANT := 11;
          V1, V2   : ST_NATURAL_DEGREES_M11;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF ST_NATURAL_DEGREES_M11'SMALL /= V1 THEN
               IF ST_NATURAL_DEGREES_M11'SMALL =
                  NATURAL_DEGREES_M15'SMALL THEN
                    FAILED ("ST_NATURAL_DEGREES_M11'SMALL = " &
                            "NATURAL_DEGREES_M15'SMALL");
               ELSE
                    FAILED ("WRONG VALUE FOR " &
                            "ST_NATURAL_DEGREES_M11'SMALL");
               END IF;
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF ST_NATURAL_DEGREES_M11'LARGE /= V2 + V1 THEN
               IF ST_NATURAL_DEGREES_M11'LARGE =
                  NATURAL_DEGREES_M15'LARGE THEN
                    FAILED ("ST_NATURAL_DEGREES_M11'LARGE = " &
                            "NATURAL_DEGREES_M15'LARGE");
               ELSE
                    FAILED ("WRONG VALUE FOR " &
                            "ST_NATURAL_DEGREES_M11'LARGE");
               END IF;
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR ST_NATURAL_DEGREES_M11");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE SYMMETRIC_RADIANS_M16 IS
       --      DELTA PI * 2.0 ** (-15) RANGE -PI .. PI;
       -- SUBTYPE ST_SYMMETRIC_RADIANS_M8 IS SYMMETRIC_RADIANS_M16
       --      DELTA HALF_PI * 2.0 ** (-7) RANGE -HALF_PI .. HALF_PI;
          SMALL    : CONSTANT := 2.0 ** (-7);
          MANTISSA : CONSTANT := 8;
          V1, V2   : ST_SYMMETRIC_RADIANS_M8;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF ST_SYMMETRIC_RADIANS_M8'SMALL /= V1 THEN
               IF ST_SYMMETRIC_RADIANS_M8'SMALL =
                  SYMMETRIC_RADIANS_M16'SMALL THEN
                    FAILED ("ST_SYMMETRIC_RADIANS_M8'SMALL = " &
                            "SYMMETRIC_RADIANS_M16'SMALL");
               ELSE
                    FAILED ("WRONG VALUE FOR " &
                            "ST_SYMMETRIC_RADIANS_M8'SMALL");
               END IF;
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF ST_SYMMETRIC_RADIANS_M8'LARGE /= V2 + V1 THEN
               IF ST_SYMMETRIC_RADIANS_M8'LARGE =
                  SYMMETRIC_RADIANS_M16'LARGE THEN
                    FAILED ("ST_SYMMETRIC_RADIANS_M8'LARGE = " &
                            "SYMMETRIC_RADIANS_M16'LARGE");
               ELSE
                    FAILED ("WRONG VALUE FOR " &
                            "ST_SYMMETRIC_RADIANS_M8'LARGE");
               END IF;
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR ST_SYMMETRIC_RADIANS_M8");
     END;

     -------------------------------------------------------------------

     RESULT;

END C35A04D;
