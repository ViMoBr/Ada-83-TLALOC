-- C35A04Q.ADA

-- CHECK THAT FOR FIXED POINT TYPES THE SMALL AND LARGE ATTRIBUTES
-- YIELD THE CORRECT VALUES.

-- CASE Q: TYPES TYPICAL OF APPLICATIONS USING FIXED POINT ARITHMETIC,
--         FOR GENERICS.

-- WRG 8/6/86

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;
PROCEDURE C35A04Q IS

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

     -------------------------------------------------------------------

     GENERIC
          TYPE T IS DELTA <>;
     FUNCTION SM RETURN T;

     FUNCTION SM RETURN T IS
     BEGIN
          RETURN IDENT_INT (1) * T'SMALL;
     END SM;

     GENERIC
          TYPE T IS DELTA <>;
     FUNCTION LG RETURN T;

     FUNCTION LG RETURN T IS
     BEGIN
          RETURN IDENT_INT (1) * T'LARGE;
     END LG;

     GENERIC
          TYPE T IS DELTA <>;
     FUNCTION BAD_LG (V1, V2 : T) RETURN BOOLEAN;

     FUNCTION BAD_LG (V1, V2 : T) RETURN BOOLEAN IS
     BEGIN
          RETURN T'LARGE /= V1 + V2;
     END BAD_LG;

     -------------------------------------------------------------------

     FUNCTION SM_MICRO_ANGLE_ERROR_M15
                                 IS NEW SM    (MICRO_ANGLE_ERROR_M15  );
     FUNCTION SM_TRACK_RANGE_M15 IS NEW SM    (TRACK_RANGE_M15        );
     FUNCTION SM_SECONDS_MM      IS NEW SM    (SECONDS_MM             );
     FUNCTION SM_RANGE_CELL_MM   IS NEW SM    (RANGE_CELL_MM          );
     FUNCTION SM_PIXEL_M10       IS NEW SM    (PIXEL_M10              );
     FUNCTION SM_RULER_M8        IS NEW SM    (RULER_M8               );
     FUNCTION SM_HOURS_M16       IS NEW SM    (HOURS_M16              );
     FUNCTION SM_MILES_M16       IS NEW SM    (MILES_M16              );
     FUNCTION SM_SYMMETRIC_DEGREES_M7
                                 IS NEW SM    (SYMMETRIC_DEGREES_M7   );
     FUNCTION SM_NATURAL_DEGREES_M15
                                 IS NEW SM    (NATURAL_DEGREES_M15    );
     FUNCTION SM_SYMMETRIC_RADIANS_M16
                                 IS NEW SM    (SYMMETRIC_RADIANS_M16  );
     FUNCTION SM_NATURAL_RADIANS_M8
                                 IS NEW SM    (NATURAL_RADIANS_M8     );
     FUNCTION SM_ST_MILES_M8     IS NEW SM    (ST_MILES_M8            );
     FUNCTION SM_ST_NATURAL_DEGREES_M11
                                 IS NEW SM    (ST_NATURAL_DEGREES_M11 );
     FUNCTION SM_ST_SYMMETRIC_RADIANS_M8
                                 IS NEW SM    (ST_SYMMETRIC_RADIANS_M8);

     FUNCTION LG_MICRO_ANGLE_ERROR_M15
                                 IS NEW LG    (MICRO_ANGLE_ERROR_M15  );
     FUNCTION LG_TRACK_RANGE_M15 IS NEW LG    (TRACK_RANGE_M15        );
     FUNCTION LG_SECONDS_MM      IS NEW LG    (SECONDS_MM             );
     FUNCTION LG_RANGE_CELL_MM   IS NEW LG    (RANGE_CELL_MM          );
     FUNCTION LG_PIXEL_M10       IS NEW LG    (PIXEL_M10              );
     FUNCTION BAD_LG_RULER_M8    IS NEW BAD_LG(RULER_M8               );
     FUNCTION BAD_LG_HOURS_M16   IS NEW BAD_LG(HOURS_M16              );
     FUNCTION BAD_LG_MILES_M16   IS NEW BAD_LG(MILES_M16              );
     FUNCTION BAD_LG_SYMMETRIC_DEGREES_M7
                                 IS NEW BAD_LG(SYMMETRIC_DEGREES_M7   );
     FUNCTION BAD_LG_NATURAL_DEGREES_M15
                                 IS NEW BAD_LG(NATURAL_DEGREES_M15    );
     FUNCTION BAD_LG_SYMMETRIC_RADIANS_M16
                                 IS NEW BAD_LG(SYMMETRIC_RADIANS_M16  );
     FUNCTION BAD_LG_NATURAL_RADIANS_M8
                                 IS NEW BAD_LG(NATURAL_RADIANS_M8     );
     FUNCTION BAD_LG_ST_MILES_M8 IS NEW BAD_LG(ST_MILES_M8            );
     FUNCTION BAD_LG_ST_NATURAL_DEGREES_M11
                                 IS NEW BAD_LG(ST_NATURAL_DEGREES_M11 );
     FUNCTION BAD_LG_ST_SYMMETRIC_RADIANS_M8
                                 IS NEW BAD_LG(ST_SYMMETRIC_RADIANS_M8);

BEGIN

     TEST ("C35A04Q", "CHECK THAT FOR FIXED POINT TYPES THE SMALL " &
                      "AND LARGE ATTRIBUTES YIELD THE CORRECT VALUES " &
                      "- TYPICAL TYPES, GENERICS");

     -------------------------------------------------------------------

     DECLARE
       -- TYPE MICRO_ANGLE_ERROR_M15 IS DELTA 16.0
       --      RANGE -(2.0 ** 19) .. 2.0 ** 19;
          SMALL    : CONSTANT := 16.0;
          MANTISSA : CONSTANT := 15;
          V1, V2   : MICRO_ANGLE_ERROR_M15;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF SM_MICRO_ANGLE_ERROR_M15 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR " &
                       "MICRO_ANGLE_ERROR_M15");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_MICRO_ANGLE_ERROR_M15 /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR " &
                       "MICRO_ANGLE_ERROR_M15");
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
          IF SM_TRACK_RANGE_M15 /= V1 THEN
               FAILED("WRONG GENERIC 'SMALL VALUE FOR TRACK_RANGE_M15");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_TRACK_RANGE_M15 /= V2 THEN
               FAILED("WRONG GENERIC 'LARGE VALUE FOR TRACK_RANGE_M15");
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
          IF SM_SECONDS_MM /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR " &
                       "SECONDS_MM");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_SECONDS_MM /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR " &
                       "SECONDS_MM");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR SECONDS_MM");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE RANGE_CELL_MM IS
       --      DELTA 2.0 ** (-5)
       --      RANGE -(2.0 ** (MM - 5) ) .. 2.0 ** (MM - 5);
          SMALL    : CONSTANT := 2.0 ** (-5);
          MANTISSA : CONSTANT := MM;
          V1, V2   : RANGE_CELL_MM;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF SM_RANGE_CELL_MM /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR " &
                       "RANGE_CELL_MM");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_RANGE_CELL_MM /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR " &
                       "RANGE_CELL_MM");
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
          IF SM_PIXEL_M10 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR PIXEL_M10");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_PIXEL_M10 /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR PIXEL_M10");
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
          IF SM_RULER_M8 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR RULER_M8");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF BAD_LG_RULER_M8 (V2, V1) THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR RULER_M8");
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
          IF SM_HOURS_M16 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR HOURS_M16");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF BAD_LG_HOURS_M16 (V2, V1) THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR HOURS_M16");
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
          IF SM_MILES_M16 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR MILES_M16");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF BAD_LG_MILES_M16 (V2, V1) THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR MILES_M16");
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
          IF SM_SYMMETRIC_DEGREES_M7 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR " &
                       "SYMMETRIC_DEGREES_M7");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF BAD_LG_SYMMETRIC_DEGREES_M7 (V2, V1) THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR " &
                       "SYMMETRIC_DEGREES_M7");
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
          IF SM_NATURAL_DEGREES_M15 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR " &
                       "NATURAL_DEGREES_M15");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF BAD_LG_NATURAL_DEGREES_M15 (V2, V1) THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR " &
                       "NATURAL_DEGREES_M15");
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
          IF SM_SYMMETRIC_RADIANS_M16 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR " &
                       "SYMMETRIC_RADIANS_M16");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF BAD_LG_SYMMETRIC_RADIANS_M16 (V2, V1) THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR " &
                       "SYMMETRIC_RADIANS_M16");
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
          IF SM_NATURAL_RADIANS_M8 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR " &
                       "NATURAL_RADIANS_M8");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF BAD_LG_NATURAL_RADIANS_M8 (V2, V1) THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR " &
                       "NATURAL_RADIANS_M8");
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
          IF SM_ST_MILES_M8 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR ST_MILES_M8");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF BAD_LG_ST_MILES_M8 (V2, V1) THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR ST_MILES_M8");
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
          IF SM_ST_NATURAL_DEGREES_M11 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR " &
                       "ST_NATURAL_DEGREES_M11");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF BAD_LG_ST_NATURAL_DEGREES_M11 (V2, V1) THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR " &
                       "ST_NATURAL_DEGREES_M11");
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
          IF SM_ST_SYMMETRIC_RADIANS_M8 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR " &
                       "ST_SYMMETRIC_RADIANS_M8");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF BAD_LG_ST_SYMMETRIC_RADIANS_M8 (V2, V1) THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR " &
                       "ST_SYMMETRIC_RADIANS_M8");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR ST_SYMMETRIC_RADIANS_M8");
     END;

     -------------------------------------------------------------------

     RESULT;

END C35A04Q;
