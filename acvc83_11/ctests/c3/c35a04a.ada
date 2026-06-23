-- C35A04A.ADA

-- CHECK THAT FOR FIXED POINT TYPES THE SMALL AND LARGE ATTRIBUTES
-- YIELD THE CORRECT VALUES.

-- CASE A: BASIC TYPES THAT FIT THE CHARACTERISTICS OF DURATION'BASE.

-- WRG 8/1/86

WITH REPORT; USE REPORT;
PROCEDURE C35A04A IS

     -- THE NAME OF EACH TYPE OR SUBTYPE ENDS WITH THAT TYPE'S
     -- 'MANTISSA VALUE.

     TYPE LEFT_OUT_M1       IS DELTA 0.25  RANGE -0.5 .. 0.5;
     TYPE LEFT_EDGE_M1      IS DELTA 0.5   RANGE -1.0 .. 1.0;
     TYPE RIGHT_EDGE_M1     IS DELTA 1.0   RANGE -2.0 .. 2.0;
     TYPE RIGHT_OUT_M1      IS DELTA 2.0   RANGE -4.0 .. 4.0;
     TYPE MIDDLE_M2         IS DELTA 0.5   RANGE -2.0 .. 2.0;
     TYPE MIDDLE_M3         IS DELTA 0.5   RANGE  0.0 .. 2.5;
     TYPE MIDDLE_M15        IS DELTA 2.0 **(-6) RANGE  -512.0 ..  512.0;
     TYPE MIDDLE_M16        IS DELTA 2.0 **(-6) RANGE -1024.0 .. 1024.0;
     TYPE LIKE_DURATION_M23 IS DELTA 0.020 RANGE -86_400.0 .. 86_400.0;
     TYPE DECIMAL_M18       IS DELTA 0.1   RANGE -10_000.0 .. 10_000.0;
     TYPE DECIMAL_M4        IS DELTA 100.0 RANGE   -1000.0 ..   1000.0;

     -------------------------------------------------------------------

     SUBTYPE ST_LEFT_EDGE_M6 IS MIDDLE_M15
          DELTA 2.0 ** (-6) RANGE IDENT_INT (1) * (-1.0) .. 1.0;
     SUBTYPE ST_MIDDLE_M14   IS MIDDLE_M16
          DELTA 2.0 ** (-5) RANGE -512.0 .. IDENT_INT (1) * 512.0;
     SUBTYPE ST_MIDDLE_M2    IS LIKE_DURATION_M23
          DELTA 0.5 RANGE -2.0 .. 2.0;
     SUBTYPE ST_MIDDLE_M3    IS LIKE_DURATION_M23
          DELTA 0.5 RANGE  0.0 .. 2.5;
     SUBTYPE ST_DECIMAL_M7   IS DECIMAL_M18
          DELTA  10.0 RANGE -1000.0 .. 1000.0;
     SUBTYPE ST_DECIMAL_M3   IS DECIMAL_M4
          DELTA 100.0 RANGE  -500.0 ..  500.0;

BEGIN

     TEST ("C35A04A", "CHECK THAT FOR FIXED POINT TYPES THE SMALL " &
                      "AND LARGE ATTRIBUTES YIELD THE CORRECT VALUES " &
                      "- BASIC TYPES");

     -------------------------------------------------------------------

     DECLARE
       -- TYPE LEFT_OUT_M1 IS DELTA 0.25 RANGE -0.5 .. 0.5;
          SMALL    : CONSTANT := 0.25;
          MANTISSA : CONSTANT := 1;
          V1, V2   : LEFT_OUT_M1;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF LEFT_OUT_M1'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR LEFT_OUT_M1'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LEFT_OUT_M1'LARGE /= V2 THEN
               FAILED ("WRONG VALUE FOR LEFT_OUT_M1'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR LEFT_OUT_M1");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE LEFT_EDGE_M1 IS DELTA 0.5 RANGE -1.0 .. 1.0;
          SMALL    : CONSTANT := 0.5;
          MANTISSA : CONSTANT := 1;
          V1, V2   : LEFT_EDGE_M1;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF LEFT_EDGE_M1'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR LEFT_EDGE_M1'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LEFT_EDGE_M1'LARGE /= V2 THEN
               FAILED ("WRONG VALUE FOR LEFT_EDGE_M1'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR LEFT_EDGE_M1");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE RIGHT_EDGE_M1 IS DELTA 1.0 RANGE -2.0 .. 2.0;
          SMALL    : CONSTANT := 1.0;
          MANTISSA : CONSTANT := 1;
          V1, V2   : RIGHT_EDGE_M1;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF RIGHT_EDGE_M1'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR RIGHT_EDGE_M1'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF RIGHT_EDGE_M1'LARGE /= V2 THEN
               FAILED ("WRONG VALUE FOR RIGHT_EDGE_M1'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR RIGHT_EDGE_M1");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE RIGHT_OUT_M1 IS DELTA 2.0 RANGE -4.0 .. 4.0;
          SMALL    : CONSTANT := 2.0;
          MANTISSA : CONSTANT := 1;
          V1, V2   : RIGHT_OUT_M1;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF RIGHT_OUT_M1'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR RIGHT_OUT_M1'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF RIGHT_OUT_M1'LARGE /= V2 THEN
               FAILED ("WRONG VALUE FOR RIGHT_OUT_M1'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR RIGHT_OUT_M1");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE MIDDLE_M2 IS DELTA 0.5 RANGE -2.0 .. 2.0;
          SMALL    : CONSTANT := 0.5;
          MANTISSA : CONSTANT := 2;
          V1, V2   : MIDDLE_M2;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF MIDDLE_M2'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR MIDDLE_M2'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF MIDDLE_M2'LARGE /= V2 THEN
               FAILED ("WRONG VALUE FOR MIDDLE_M2'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR MIDDLE_M2");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE MIDDLE_M3 IS DELTA 0.5 RANGE 0.0 .. 2.5;
          SMALL    : CONSTANT := 0.5;
          MANTISSA : CONSTANT := 3;
          V1, V2   : MIDDLE_M3;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF MIDDLE_M3'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR MIDDLE_M3'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF MIDDLE_M3'LARGE /= V2 + V1 THEN
               FAILED ("WRONG VALUE FOR MIDDLE_M3'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR MIDDLE_M3");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE MIDDLE_M15 IS DELTA 2.0 ** (-6) RANGE -512.0 .. 512.0;
          SMALL    : CONSTANT := 2.0 ** (-6);
          MANTISSA : CONSTANT := 15;
          V1, V2   : MIDDLE_M15;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF MIDDLE_M15'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR MIDDLE_M15'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF MIDDLE_M15'LARGE /= V2 THEN
               FAILED ("WRONG VALUE FOR MIDDLE_M15'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR MIDDLE_M15");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE MIDDLE_M16 IS DELTA 2.0 ** (-6) RANGE -1024.0 .. 1024.0;
          SMALL    : CONSTANT := 2.0 ** (-6);
          MANTISSA : CONSTANT := 16;
          V1, V2   : MIDDLE_M16;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF MIDDLE_M16'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR MIDDLE_M16'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF MIDDLE_M16'LARGE /= V2 THEN
               FAILED ("WRONG VALUE FOR MIDDLE_M16'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR MIDDLE_M16");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE LIKE_DURATION_M23 IS DELTA 0.020
       --      RANGE -86_400.0 .. 86_400.0;
          SMALL    : CONSTANT := 1.0 / 64;
          MANTISSA : CONSTANT := 23;
          V1, V2   : LIKE_DURATION_M23;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF LIKE_DURATION_M23'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR LIKE_DURATION_M23'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF LIKE_DURATION_M23'LARGE /= V2 + V1 THEN
               FAILED ("WRONG VALUE FOR LIKE_DURATION_M23'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR LIKE_DURATION_M23");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE DECIMAL_M18 IS DELTA 0.1 RANGE -10_000.0 .. 10_000.0;
          SMALL    : CONSTANT := 1.0 / 16;
          MANTISSA : CONSTANT := 18;
          V1, V2   : DECIMAL_M18;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF DECIMAL_M18'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR DECIMAL_M18'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF DECIMAL_M18'LARGE /= V2 + V1 THEN
               FAILED ("WRONG VALUE FOR DECIMAL_M18'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR DECIMAL_M18");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE DECIMAL_M4 IS DELTA 100.0 RANGE -1000.0 .. 1000.0;
          SMALL    : CONSTANT := 64.0;
          MANTISSA : CONSTANT := 4;
          V1, V2   : DECIMAL_M4;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF DECIMAL_M4'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR DECIMAL_M4'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF DECIMAL_M4'LARGE /= V2 + V1 THEN
               FAILED ("WRONG VALUE FOR DECIMAL_M4'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR DECIMAL_M4");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE MIDDLE_M15 IS DELTA 2.0**(-6) RANGE -512.0 .. 512.0;
       -- SUBTYPE ST_LEFT_EDGE_M6 IS MIDDLE_M15
       --       DELTA 2.0**(-6) RANGE IDENT_INT (1) * (-1.0) .. 1.0;
          SMALL    : CONSTANT := 2.0 ** (-6);
          MANTISSA : CONSTANT := 6;
          V1, V2   : ST_LEFT_EDGE_M6;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF ST_LEFT_EDGE_M6'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR ST_LEFT_EDGE_M6'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF ST_LEFT_EDGE_M6'LARGE /= V2 THEN
               IF ST_LEFT_EDGE_M6'LARGE = MIDDLE_M15'LARGE THEN
                    FAILED ("ST_LEFT_EDGE_M6'LARGE = MIDDLE_M15'LARGE");
               ELSE
                    FAILED ("WRONG VALUE FOR ST_LEFT_EDGE_M6'LARGE");
               END IF;
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR ST_LEFT_EDGE_M6");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE MIDDLE_M16 IS DELTA 2.0 ** (-6)
       --      RANGE -1024.0 .. 1024.0;
       -- SUBTYPE ST_MIDDLE_M14 IS MIDDLE_M16
       --      DELTA 2.0 ** (-5) RANGE -512.0 .. IDENT_INT (1) * 512.0;
          SMALL    : CONSTANT := 2.0 ** (-5);
          MANTISSA : CONSTANT := 14;
          V1, V2   : ST_MIDDLE_M14;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF ST_MIDDLE_M14'SMALL /= V1 THEN
               IF ST_MIDDLE_M14'SMALL = MIDDLE_M16'SMALL THEN
                    FAILED ("ST_MIDDLE_M14'SMALL = MIDDLE_M16'SMALL");
               ELSE
                    FAILED ("WRONG VALUE FOR ST_MIDDLE_M14'SMALL");
               END IF;
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF ST_MIDDLE_M14'LARGE /= V2 THEN
               IF ST_MIDDLE_M14'LARGE = MIDDLE_M16'LARGE THEN
                    FAILED ("ST_MIDDLE_M14'LARGE = MIDDLE_M16'LARGE");
               ELSE
                    FAILED ("WRONG VALUE FOR ST_MIDDLE_M14'LARGE");
               END IF;
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR ST_MIDDLE_M14");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE LIKE_DURATION_M23 IS DELTA 0.020
       --      RANGE -86_400.0 .. 86_400.0;
       -- SUBTYPE ST_MIDDLE_M2 IS LIKE_DURATION_M23
       --      DELTA 0.5 RANGE -2.0 .. 2.0;
          SMALL    : CONSTANT := 0.5;
          MANTISSA : CONSTANT := 2;
          V1, V2   : ST_MIDDLE_M2;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF ST_MIDDLE_M2'SMALL /= V1 THEN
               IF ST_MIDDLE_M2'SMALL = LIKE_DURATION_M23'SMALL THEN
                    FAILED ("ST_MIDDLE_M2'SMALL = " &
                            "LIKE_DURATION_M23'SMALL");
               ELSE
                    FAILED ("WRONG VALUE FOR ST_MIDDLE_M2'SMALL");
               END IF;
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF ST_MIDDLE_M2'LARGE /= V2 THEN
               IF ST_MIDDLE_M2'LARGE = LIKE_DURATION_M23'LARGE THEN
                    FAILED ("ST_MIDDLE_M2'LARGE = " &
                            "LIKE_DURATION_M23'LARGE");
               ELSE
                    FAILED ("WRONG VALUE FOR ST_MIDDLE_M2'LARGE");
               END IF;
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR ST_MIDDLE_M2");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE LIKE_DURATION_M23 IS DELTA 0.020
       --      RANGE -86_400.0 .. 86_400.0;
       -- SUBTYPE ST_MIDDLE_M3 IS LIKE_DURATION_M23
       --      DELTA 0.5 RANGE 0.0 .. 2.5;
          SMALL    : CONSTANT := 0.5;
          MANTISSA : CONSTANT := 3;
          V1, V2   : ST_MIDDLE_M3;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF ST_MIDDLE_M3'SMALL /= V1 THEN
               IF ST_MIDDLE_M3'SMALL = LIKE_DURATION_M23'SMALL THEN
                    FAILED ("ST_MIDDLE_M3'SMALL = " &
                            "LIKE_DURATION_M23'SMALL");
               ELSE
                    FAILED ("WRONG VALUE FOR ST_MIDDLE_M3'SMALL");
               END IF;
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF ST_MIDDLE_M3'LARGE /= V2 + V1 THEN
               IF ST_MIDDLE_M3'LARGE = LIKE_DURATION_M23'LARGE THEN
                    FAILED ("ST_MIDDLE_M3'LARGE = " &
                            "LIKE_DURATION_M23'LARGE");
               ELSE
                    FAILED ("WRONG VALUE FOR ST_MIDDLE_M3'LARGE");
               END IF;
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR ST_MIDDLE_M3");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE DECIMAL_M18 IS DELTA 0.1 RANGE -10_000.0 .. 10_000.0;
       -- SUBTYPE ST_DECIMAL_M7 IS DECIMAL_M18
       --       DELTA 10.0 RANGE -1000.0 .. 1000.0;
          SMALL    : CONSTANT := 8.0;
          MANTISSA : CONSTANT := 7;
          V1, V2   : ST_DECIMAL_M7;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF ST_DECIMAL_M7'SMALL /= V1 THEN
               IF ST_DECIMAL_M7'SMALL = DECIMAL_M18'SMALL THEN
                    FAILED ("ST_DECIMAL_M7'SMALL = DECIMAL_M18'SMALL");
               ELSE
                    FAILED ("WRONG VALUE FOR ST_DECIMAL_M7'SMALL");
               END IF;
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF ST_DECIMAL_M7'LARGE /= V2 + V1 THEN
               IF ST_DECIMAL_M7'LARGE = DECIMAL_M18'LARGE THEN
                    FAILED ("ST_DECIMAL_M7'LARGE = DECIMAL_M18'LARGE");
               ELSE
                    FAILED ("WRONG VALUE FOR ST_DECIMAL_M7'LARGE");
               END IF;
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR ST_DECIMAL_M7");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE DECIMAL_M4 IS DELTA 100.0 RANGE -1000.0 .. 1000.0;
       -- SUBTYPE ST_DECIMAL_M3 IS DECIMAL_M4
       --       DELTA 100.0 RANGE -500.0 .. 500.0;
          SMALL    : CONSTANT := 64.0;
          MANTISSA : CONSTANT := 3;
          V1, V2   : ST_DECIMAL_M3;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF ST_DECIMAL_M3'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR ST_DECIMAL_M3'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF ST_DECIMAL_M3'LARGE /= V2 + V1 THEN
               IF ST_DECIMAL_M3'LARGE = DECIMAL_M4'LARGE THEN
                    FAILED ("ST_DECIMAL_M3'LARGE = DECIMAL_M4'LARGE");
               ELSE
                    FAILED ("WRONG VALUE FOR ST_DECIMAL_M3'LARGE");
               END IF;
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR ST_DECIMAL_M3");
     END;

     -------------------------------------------------------------------

     RESULT;

END C35A04A;
