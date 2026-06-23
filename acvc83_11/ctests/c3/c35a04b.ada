-- C35A04B.ADA

-- CHECK THAT FOR FIXED POINT TYPES THE SMALL AND LARGE ATTRIBUTES
-- YIELD THE CORRECT VALUES.

-- CASE B: 'MANTISSA = SYSTEM.MAX_MANTISSA.

-- WRG 8/2/86

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;
PROCEDURE C35A04B IS

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

     TEST ("C35A04B", "CHECK THAT FOR FIXED POINT TYPES THE SMALL " &
                      "AND LARGE ATTRIBUTES YIELD THE CORRECT VALUES " &
                      "- 'MANTISSA = SYSTEM.MAX_MANTISSA");

     COMMENT ("VALUE OF SYSTEM.MAX_MANTISSA IS" &
              POSITIVE'IMAGE(MAX_MANTISSA));

     -------------------------------------------------------------------

     DECLARE
       -- TYPE LEFT_OUT_MM IS DELTA 2.0 ** (-(MM+1))
       --      RANGE -(2.0 ** (-1) ) .. 2.0 ** (-1);
          SMALL    : CONSTANT := 2.0 ** (-(MM+1));
          MANTISSA : CONSTANT := MM;
          V1, V2   : LEFT_OUT_MM;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF LEFT_OUT_MM'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR LEFT_OUT_MM'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LEFT_OUT_MM'LARGE /= V2 THEN
               FAILED ("WRONG VALUE FOR LEFT_OUT_MM'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR LEFT_OUT_MM");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE LEFT_EDGE_MM IS DELTA 2.0 ** (-MM) RANGE -1.0 .. 1.0;
          SMALL    : CONSTANT := 2.0 ** (-MM);
          MANTISSA : CONSTANT := MM;
          V1, V2   : LEFT_EDGE_MM;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF LEFT_EDGE_MM'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR LEFT_EDGE_MM'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LEFT_EDGE_MM'LARGE /= V2 THEN
               FAILED ("WRONG VALUE FOR LEFT_EDGE_MM'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR LEFT_EDGE_MM");
     END;


     -------------------------------------------------------------------

     DECLARE
       -- TYPE MIDDLE_MM IS DELTA 2.0 ** (-CEIL_MM_HALF)
       --      RANGE -(2.0 ** FLOOR_MM_HALF) .. 2.0 ** FLOOR_MM_HALF;
          SMALL    : CONSTANT := 2.0 ** (-CEIL_MM_HALF);
          MANTISSA : CONSTANT := MM;
          V1, V2   : MIDDLE_MM;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF MIDDLE_MM'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR MIDDLE_MM'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF MIDDLE_MM'LARGE /= V2 THEN
               FAILED ("WRONG VALUE FOR MIDDLE_MM'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR MIDDLE_MM");
     END;


     -------------------------------------------------------------------

     DECLARE
       -- TYPE RIGHT_EDGE_MM IS DELTA 1.0 RANGE -(2.0 **MM) .. 2.0 **MM;
          SMALL    : CONSTANT := 1.0;
          MANTISSA : CONSTANT := MM;
          V1, V2   : RIGHT_EDGE_MM;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF RIGHT_EDGE_MM'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR RIGHT_EDGE_MM'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF RIGHT_EDGE_MM'LARGE /= V2 THEN
               FAILED ("WRONG VALUE FOR RIGHT_EDGE_MM'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR RIGHT_EDGE_MM");
     END;


     -------------------------------------------------------------------

     DECLARE
       -- TYPE RIGHT_OUT_MM IS DELTA 2.0
       --      RANGE -(2.0 ** (MM+1)) .. 2.0 ** (MM+1);
          SMALL    : CONSTANT := 2.0;
          MANTISSA : CONSTANT := MM;
          V1, V2   : RIGHT_OUT_MM;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF RIGHT_OUT_MM'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR RIGHT_OUT_MM'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF RIGHT_OUT_MM'LARGE /= V2 THEN
               FAILED ("WRONG VALUE FOR RIGHT_OUT_MM'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR RIGHT_OUT_MM");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE LEFT_OUT_MM IS DELTA 2.0 ** (-(MM+1))
       --      RANGE -(2.0 ** (-1) ) .. 2.0 ** (-1);
       -- SUBTYPE ST_LEFT_OUT_MM_LESS_1 IS LEFT_OUT_MM DELTA 2.0**(-MM);
          SMALL    : CONSTANT := 2.0 ** (-MM);
          MANTISSA : CONSTANT := MM - 1;
          V1, V2   : ST_LEFT_OUT_MM_LESS_1;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF ST_LEFT_OUT_MM_LESS_1'SMALL /= V1 THEN
               IF ST_LEFT_OUT_MM_LESS_1'SMALL = LEFT_OUT_MM'SMALL THEN
                    FAILED ("ST_LEFT_OUT_MM_LESS_1'SMALL = " &
                            "LEFT_OUT_MM'SMALL");
               ELSE
                    FAILED ("WRONG VALUE FOR " &
                            "ST_LEFT_OUT_MM_LESS_1'SMALL");
               END IF;
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF ST_LEFT_OUT_MM_LESS_1'LARGE /= V2 THEN
               IF ST_LEFT_OUT_MM_LESS_1'LARGE = LEFT_OUT_MM'LARGE THEN
                    FAILED ("ST_LEFT_OUT_MM_LESS_1'LARGE = " &
                            "LEFT_OUT_MM'LARGE");
               ELSE
                    FAILED ("WRONG VALUE FOR " &
                            "ST_LEFT_OUT_MM_LESS_1'LARGE");
               END IF;
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR ST_LEFT_OUT_MM_LESS_1");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE LEFT_EDGE_MM IS DELTA 2.0 ** (-MM) RANGE -1.0 .. 1.0;
       -- SUBTYPE ST_LEFT_OUT_MM_HALF IS LEFT_EDGE_MM DELTA 2.0 ** (-MM)
       --       RANGE LEFT_EDGE_MM ( -(2.0 ** (-FLOOR_MM_HALF)) ) ..
       --       IDENT_INT (1) * LEFT_EDGE_MM ( 2.0 ** (-FLOOR_MM_HALF));
          SMALL    : CONSTANT := 2.0 ** (-MM);
          MANTISSA : CONSTANT := CEIL_MM_HALF;
          V1, V2   : ST_LEFT_OUT_MM_HALF;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF ST_LEFT_OUT_MM_HALF'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR ST_LEFT_OUT_MM_HALF'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF ST_LEFT_OUT_MM_HALF'LARGE /= V2 THEN
               IF ST_LEFT_OUT_MM_HALF'LARGE = LEFT_EDGE_MM'LARGE THEN
                    FAILED ("ST_LEFT_OUT_MM_HALF'LARGE = " &
                            "LEFT_EDGE_MM'LARGE");
               ELSE
                    FAILED ("WRONG VALUE FOR " &
                            "ST_LEFT_OUT_MM_HALF'LARGE");
               END IF;
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR ST_LEFT_OUT_MM_HALF");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE MIDDLE_MM IS DELTA 2.0 ** (-CEIL_MM_HALF)
       --      RANGE -(2.0 ** FLOOR_MM_HALF) .. 2.0 ** FLOOR_MM_HALF;
       -- SUBTYPE ST_RIGHT_EDGE_MM_HALF IS MIDDLE_MM DELTA 1.0;
          SMALL    : CONSTANT := 1.0;
          MANTISSA : CONSTANT := FLOOR_MM_HALF;
          V1, V2   : ST_RIGHT_EDGE_MM_HALF;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF ST_RIGHT_EDGE_MM_HALF'SMALL /= V1 THEN
               IF ST_RIGHT_EDGE_MM_HALF'SMALL = MIDDLE_MM'SMALL THEN
                    FAILED ("ST_RIGHT_EDGE_MM_HALF'SMALL = " &
                            "MIDDLE_MM'SMALL");
               ELSE
                    FAILED ("WRONG VALUE FOR " &
                            "ST_RIGHT_EDGE_MM_HALF'SMALL");
               END IF;
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF ST_RIGHT_EDGE_MM_HALF'LARGE /= V2 THEN
               IF ST_RIGHT_EDGE_MM_HALF'LARGE = MIDDLE_MM'LARGE THEN
                    FAILED ("ST_RIGHT_EDGE_MM_HALF'LARGE = " &
                            "MIDDLE_MM'LARGE");
               ELSE
                    FAILED ("WRONG VALUE FOR " &
                            "ST_RIGHT_EDGE_MM_HALF'LARGE");
               END IF;
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR ST_RIGHT_EDGE_MM_HALF");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE RIGHT_EDGE_MM IS DELTA 1.0 RANGE -(2.0 **MM) .. 2.0 **MM;
       -- SUBTYPE ST_RIGHT_OUT_MM_HALF IS RIGHT_EDGE_MM
       --         DELTA 2.0 ** FLOOR_MM_HALF;
          SMALL    : CONSTANT := 2.0 ** FLOOR_MM_HALF;
          MANTISSA : CONSTANT := CEIL_MM_HALF;
          V1, V2   : ST_RIGHT_OUT_MM_HALF;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF ST_RIGHT_OUT_MM_HALF'SMALL /= V1 THEN
               IF ST_RIGHT_OUT_MM_HALF'SMALL =
                  RIGHT_EDGE_MM'SMALL THEN
                    FAILED ("ST_RIGHT_OUT_MM_HALF'SMALL = " &
                            "RIGHT_EDGE_MM'SMALL");
               ELSE
                    FAILED ("WRONG VALUE FOR " &
                            "ST_RIGHT_OUT_MM_HALF'SMALL");
               END IF;
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF ST_RIGHT_OUT_MM_HALF'LARGE /= V2 THEN
               IF ST_RIGHT_OUT_MM_HALF'LARGE =
                  RIGHT_EDGE_MM'LARGE THEN
                    FAILED ("ST_RIGHT_OUT_MM_HALF'LARGE = " &
                            "RIGHT_EDGE_MM'LARGE");
               ELSE
                    FAILED ("WRONG VALUE FOR " &
                            "ST_RIGHT_OUT_MM_HALF'LARGE");
               END IF;
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR ST_RIGHT_OUT_MM_HALF");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE RIGHT_OUT_MM IS
       --         DELTA 2.0 RANGE -(2.0 ** (MM+1)) .. 2.0 ** (MM+1);
       -- SUBTYPE ST_RIGHT_OUT_M1 IS RIGHT_OUT_MM
       --         DELTA 2.0 RANGE -4.0 .. 4.0;
          SMALL    : CONSTANT := 2.0;
          MANTISSA : CONSTANT := 1;
          V1, V2   : ST_RIGHT_OUT_M1;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF ST_RIGHT_OUT_M1'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR ST_RIGHT_OUT_M1'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF ST_RIGHT_OUT_M1'LARGE /= V2 THEN
               IF ST_RIGHT_OUT_M1'LARGE = RIGHT_OUT_MM'LARGE THEN
                    FAILED ("ST_RIGHT_OUT_M1'LARGE = " &
                            "RIGHT_OUT_MM'LARGE");
               ELSE
                    FAILED ("WRONG VALUE FOR ST_RIGHT_OUT_M1'LARGE");
               END IF;
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR ST_RIGHT_OUT_M1");
     END;

     -------------------------------------------------------------------

     RESULT;

END C35A04B;
