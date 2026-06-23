-- C35A04N.ADA

-- CHECK THAT FOR FIXED POINT TYPES THE SMALL AND LARGE ATTRIBUTES
-- YIELD THE CORRECT VALUES.

-- CASE N: BASIC TYPES THAT FIT THE CHARACTERISTICS OF DURATION'BASE,
--         FOR GENERICS.

-- WRG 8/4/86

WITH REPORT; USE REPORT;
PROCEDURE C35A04N IS

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

     FUNCTION SM_LEFT_OUT_M1           IS NEW SM    (LEFT_OUT_M1      );
     FUNCTION SM_LEFT_EDGE_M1          IS NEW SM    (LEFT_EDGE_M1     );
     FUNCTION SM_RIGHT_EDGE_M1         IS NEW SM    (RIGHT_EDGE_M1    );
     FUNCTION SM_RIGHT_OUT_M1          IS NEW SM    (RIGHT_OUT_M1     );
     FUNCTION SM_MIDDLE_M2             IS NEW SM    (MIDDLE_M2        );
     FUNCTION SM_MIDDLE_M3             IS NEW SM    (MIDDLE_M3        );
     FUNCTION SM_MIDDLE_M15            IS NEW SM    (MIDDLE_M15       );
     FUNCTION SM_MIDDLE_M16            IS NEW SM    (MIDDLE_M16       );
     FUNCTION SM_LIKE_DURATION_M23     IS NEW SM    (LIKE_DURATION_M23);
     FUNCTION SM_DECIMAL_M18           IS NEW SM    (DECIMAL_M18      );
     FUNCTION SM_DECIMAL_M4            IS NEW SM    (DECIMAL_M4       );
     FUNCTION SM_ST_LEFT_EDGE_M6       IS NEW SM    (ST_LEFT_EDGE_M6  );
     FUNCTION SM_ST_MIDDLE_M14         IS NEW SM    (ST_MIDDLE_M14    );
     FUNCTION SM_ST_MIDDLE_M2          IS NEW SM    (ST_MIDDLE_M2     );
     FUNCTION SM_ST_MIDDLE_M3          IS NEW SM    (ST_MIDDLE_M3     );
     FUNCTION SM_ST_DECIMAL_M7         IS NEW SM    (ST_DECIMAL_M7    );
     FUNCTION SM_ST_DECIMAL_M3         IS NEW SM    (ST_DECIMAL_M3    );

     FUNCTION LG_LEFT_OUT_M1           IS NEW LG    (LEFT_OUT_M1      );
     FUNCTION LG_LEFT_EDGE_M1          IS NEW LG    (LEFT_EDGE_M1     );
     FUNCTION LG_RIGHT_EDGE_M1         IS NEW LG    (RIGHT_EDGE_M1    );
     FUNCTION LG_RIGHT_OUT_M1          IS NEW LG    (RIGHT_OUT_M1     );
     FUNCTION LG_MIDDLE_M2             IS NEW LG    (MIDDLE_M2        );
     FUNCTION BAD_LG_MIDDLE_M3         IS NEW BAD_LG(MIDDLE_M3        );
     FUNCTION LG_MIDDLE_M15            IS NEW LG    (MIDDLE_M15       );
     FUNCTION LG_MIDDLE_M16            IS NEW LG    (MIDDLE_M16       );
     FUNCTION BAD_LG_LIKE_DURATION_M23 IS NEW BAD_LG(LIKE_DURATION_M23);
     FUNCTION BAD_LG_DECIMAL_M18       IS NEW BAD_LG(DECIMAL_M18      );
     FUNCTION BAD_LG_DECIMAL_M4        IS NEW BAD_LG(DECIMAL_M4       );
     FUNCTION LG_ST_LEFT_EDGE_M6       IS NEW LG    (ST_LEFT_EDGE_M6  );
     FUNCTION LG_ST_MIDDLE_M14         IS NEW LG    (ST_MIDDLE_M14    );
     FUNCTION LG_ST_MIDDLE_M2          IS NEW LG    (ST_MIDDLE_M2     );
     FUNCTION BAD_LG_ST_MIDDLE_M3      IS NEW BAD_LG(ST_MIDDLE_M3     );
     FUNCTION BAD_LG_ST_DECIMAL_M7     IS NEW BAD_LG(ST_DECIMAL_M7    );
     FUNCTION BAD_LG_ST_DECIMAL_M3     IS NEW BAD_LG(ST_DECIMAL_M3    );

BEGIN

     TEST ("C35A04N", "CHECK THAT FOR FIXED POINT TYPES THE SMALL " &
                      "AND LARGE ATTRIBUTES YIELD THE CORRECT VALUES " &
                      "- BASIC TYPES, GENERICS");

     -------------------------------------------------------------------

     DECLARE
       -- TYPE LEFT_OUT_M1 IS DELTA 0.25 RANGE -0.5 .. 0.5;
          SMALL    : CONSTANT := 0.25;
          MANTISSA : CONSTANT := 1;
          V1, V2   : LEFT_OUT_M1;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF SM_LEFT_OUT_M1 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR LEFT_OUT_M1");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_LEFT_OUT_M1 /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR LEFT_OUT_M1");
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
          IF SM_LEFT_EDGE_M1 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR LEFT_EDGE_M1");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_LEFT_EDGE_M1 /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR LEFT_EDGE_M1");
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
          IF SM_RIGHT_EDGE_M1 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR RIGHT_EDGE_M1");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_RIGHT_EDGE_M1 /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR RIGHT_EDGE_M1");
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
          IF SM_RIGHT_OUT_M1 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR RIGHT_OUT_M1");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_RIGHT_OUT_M1 /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR RIGHT_OUT_M1");
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
          IF SM_MIDDLE_M2 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR MIDDLE_M2");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_MIDDLE_M2 /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR MIDDLE_M2");
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
          IF SM_MIDDLE_M3 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR MIDDLE_M3");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF BAD_LG_MIDDLE_M3 (V2 ,V1) THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR MIDDLE_M3");
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
          IF SM_MIDDLE_M15 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR MIDDLE_M15");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_MIDDLE_M15 /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR MIDDLE_M15");
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
          IF SM_MIDDLE_M16 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR MIDDLE_M16");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_MIDDLE_M16 /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR MIDDLE_M16");
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
          IF SM_LIKE_DURATION_M23 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR " &
                       "LIKE_DURATION_M23");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF BAD_LG_LIKE_DURATION_M23 (V2, V1) THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR " &
                       "LIKE_DURATION_M23");
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
          IF SM_DECIMAL_M18 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR DECIMAL_M18");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF BAD_LG_DECIMAL_M18 (V2, V1) THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR DECIMAL_M18");
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
          IF SM_DECIMAL_M4 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR DECIMAL_M4");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF BAD_LG_DECIMAL_M4 (V2, V1) THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR DECIMAL_M4");
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
          IF SM_ST_LEFT_EDGE_M6 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR " &
                       "ST_LEFT_EDGE_M6");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_ST_LEFT_EDGE_M6 /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR " &
                       "ST_LEFT_EDGE_M6");
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
          IF SM_ST_MIDDLE_M14 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR ST_MIDDLE_M14");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_ST_MIDDLE_M14 /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR ST_MIDDLE_M14");
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
          IF SM_ST_MIDDLE_M2 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR ST_MIDDLE_M2");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_ST_MIDDLE_M2 /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR ST_MIDDLE_M2");
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
          IF SM_ST_MIDDLE_M3 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR ST_MIDDLE_M3");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF BAD_LG_ST_MIDDLE_M3 (V2 ,V1) THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR ST_MIDDLE_M3");
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
          IF SM_ST_DECIMAL_M7 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR ST_DECIMAL_M7");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF BAD_LG_ST_DECIMAL_M7 (V2, V1) THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR ST_DECIMAL_M7");
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
          IF SM_ST_DECIMAL_M3 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR ST_DECIMAL_M3");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          IF BAD_LG_ST_DECIMAL_M3 (V2, V1) THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR ST_DECIMAL_M3");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR ST_DECIMAL_M3");
     END;

     -------------------------------------------------------------------

     RESULT;

END C35A04N;
