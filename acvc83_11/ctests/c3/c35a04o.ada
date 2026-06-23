-- C35A04O.ADA

-- CHECK THAT FOR FIXED POINT TYPES THE SMALL AND LARGE ATTRIBUTES
-- YIELD THE CORRECT VALUES.

-- CASE O: 'MANTISSA = SYSTEM.MAX_MANTISSA, FOR GENERICS.

-- WRG 8/5/86

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;
PROCEDURE C35A04O IS

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
                IDENT_INT (1) * LEFT_EDGE_MM (2.0 ** (-FLOOR_MM_HALF));
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

     -------------------------------------------------------------------

     FUNCTION SM_LEFT_OUT_MM         IS NEW SM (LEFT_OUT_MM           );
     FUNCTION SM_LEFT_EDGE_MM        IS NEW SM (LEFT_EDGE_MM          );
     FUNCTION SM_MIDDLE_MM           IS NEW SM (MIDDLE_MM             );
     FUNCTION SM_RIGHT_EDGE_MM       IS NEW SM (RIGHT_EDGE_MM         );
     FUNCTION SM_RIGHT_OUT_MM        IS NEW SM (RIGHT_OUT_MM          );
     FUNCTION SM_ST_LEFT_OUT_MM_LESS_1
                                     IS NEW SM (ST_LEFT_OUT_MM_LESS_1 );
     FUNCTION SM_ST_LEFT_OUT_MM_HALF IS NEW SM (ST_LEFT_OUT_MM_HALF   );
     FUNCTION SM_ST_RIGHT_EDGE_MM_HALF
                                     IS NEW SM (ST_RIGHT_EDGE_MM_HALF );
     FUNCTION SM_ST_RIGHT_OUT_MM_HALF
                                     IS NEW SM (ST_RIGHT_OUT_MM_HALF  );
     FUNCTION SM_ST_RIGHT_OUT_M1     IS NEW SM (ST_RIGHT_OUT_M1       );

     FUNCTION LG_LEFT_OUT_MM         IS NEW LG (LEFT_OUT_MM           );
     FUNCTION LG_LEFT_EDGE_MM        IS NEW LG (LEFT_EDGE_MM          );
     FUNCTION LG_MIDDLE_MM           IS NEW LG (MIDDLE_MM             );
     FUNCTION LG_RIGHT_EDGE_MM       IS NEW LG (RIGHT_EDGE_MM         );
     FUNCTION LG_RIGHT_OUT_MM        IS NEW LG (RIGHT_OUT_MM          );
     FUNCTION LG_ST_LEFT_OUT_MM_LESS_1
                                     IS NEW LG (ST_LEFT_OUT_MM_LESS_1 );
     FUNCTION LG_ST_LEFT_OUT_MM_HALF IS NEW LG (ST_LEFT_OUT_MM_HALF   );
     FUNCTION LG_ST_RIGHT_EDGE_MM_HALF
                                     IS NEW LG (ST_RIGHT_EDGE_MM_HALF );
     FUNCTION LG_ST_RIGHT_OUT_MM_HALF
                                     IS NEW LG (ST_RIGHT_OUT_MM_HALF  );
     FUNCTION LG_ST_RIGHT_OUT_M1     IS NEW LG (ST_RIGHT_OUT_M1       );

BEGIN

     TEST ("C35A04O", "CHECK THAT FOR FIXED POINT TYPES THE SMALL " &
                      "AND LARGE ATTRIBUTES YIELD THE CORRECT VALUES " &
                      "- 'MANTISSA = SYSTEM.MAX_MANTISSA, GENERICS");

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
          IF SM_LEFT_OUT_MM /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR LEFT_OUT_MM");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_LEFT_OUT_MM /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR LEFT_OUT_MM");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR LEFT_OUT_MM");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE LEFT_EDGE_MM IS DELTA 2.0 ** (-MM)
       --      RANGE -1.0 .. 1.0;
          SMALL    : CONSTANT := 2.0 ** (-MM);
          MANTISSA : CONSTANT := MM;
          V1, V2   : LEFT_EDGE_MM;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF SM_LEFT_EDGE_MM /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR LEFT_EDGE_MM");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_LEFT_EDGE_MM /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR LEFT_EDGE_MM");
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
          IF SM_MIDDLE_MM /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR MIDDLE_MM");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_MIDDLE_MM /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR MIDDLE_MM");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR MIDDLE_MM");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE RIGHT_EDGE_MM IS DELTA 1.0
       --      RANGE -(2.0 ** MM) .. 2.0 ** MM;
          SMALL    : CONSTANT := 1.0;
          MANTISSA : CONSTANT := MM;
          V1, V2   : RIGHT_EDGE_MM;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF SM_RIGHT_EDGE_MM /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR RIGHT_EDGE_MM");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_RIGHT_EDGE_MM /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR RIGHT_EDGE_MM");
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
          IF SM_RIGHT_OUT_MM /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR RIGHT_OUT_MM");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_RIGHT_OUT_MM /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR RIGHT_OUT_MM");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR RIGHT_OUT_MM");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE LEFT_OUT_MM IS DELTA 2.0 ** (-(MM+1))
       --      RANGE -(2.0 ** (-1) ) .. 2.0 ** (-1);
       -- SUBTYPE ST_LEFT_OUT_MM_LESS_1 IS LEFT_OUT_MM
       --      DELTA 2.0 ** (-MM);
          SMALL    : CONSTANT := 2.0 ** (-MM);
          MANTISSA : CONSTANT := MM - 1;
          V1, V2   : ST_LEFT_OUT_MM_LESS_1;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF SM_ST_LEFT_OUT_MM_LESS_1 /= V1 THEN
                FAILED ("WRONG GENERIC 'SMALL VALUE FOR " &
                        "ST_LEFT_OUT_MM_LESS_1");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_ST_LEFT_OUT_MM_LESS_1 /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR " &
                       "ST_LEFT_OUT_MM_LESS_1");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR ST_LEFT_OUT_MM_LESS_1");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE LEFT_EDGE_MM IS DELTA 2.0 ** (-MM)
       --      RANGE -1.0 .. 1.0;
       -- SUBTYPE ST_LEFT_OUT_MM_HALF IS LEFT_EDGE_MM
       --      DELTA 2.0 ** (-MM)
       --      RANGE LEFT_EDGE_MM ( -(2.0 ** (-FLOOR_MM_HALF)) ) ..
       --      IDENT_INT (1) * LEFT_EDGE_MM (2.0 ** (-FLOOR_MM_HALF));
          SMALL    : CONSTANT := 2.0 ** (-MM);
          MANTISSA : CONSTANT := CEIL_MM_HALF;
          V1, V2   : ST_LEFT_OUT_MM_HALF;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF SM_ST_LEFT_OUT_MM_HALF /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR " &
                       "ST_LEFT_OUT_MM_HALF");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_ST_LEFT_OUT_MM_HALF /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR " &
                       "ST_LEFT_OUT_MM_HALF");
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
          IF SM_ST_RIGHT_EDGE_MM_HALF /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR " &
                       "ST_RIGHT_EDGE_MM_HALF");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_ST_RIGHT_EDGE_MM_HALF /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR " &
                       "ST_RIGHT_EDGE_MM_HALF");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR ST_RIGHT_EDGE_MM_HALF");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE RIGHT_EDGE_MM IS DELTA 1.0
       --      RANGE -(2.0 ** MM) .. 2.0 ** MM;
       -- SUBTYPE ST_RIGHT_OUT_MM_HALF IS RIGHT_EDGE_MM
       --      DELTA 2.0 ** FLOOR_MM_HALF;
          SMALL    : CONSTANT := 2.0 ** FLOOR_MM_HALF;
          MANTISSA : CONSTANT := CEIL_MM_HALF;
          V1, V2   : ST_RIGHT_OUT_MM_HALF;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF SM_ST_RIGHT_OUT_MM_HALF /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR " &
                       "ST_RIGHT_OUT_MM_HALF");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_ST_RIGHT_OUT_MM_HALF /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR " &
                       "ST_RIGHT_OUT_MM_HALF");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR ST_RIGHT_OUT_MM_HALF");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE RIGHT_OUT_MM IS DELTA 2.0
       --      RANGE -(2.0 ** (MM+1)) .. 2.0 ** (MM+1);
       -- SUBTYPE ST_RIGHT_OUT_M1 IS RIGHT_OUT_MM
       --      DELTA 2.0 RANGE -4.0 .. 4.0;
          SMALL    : CONSTANT := 2.0;
          MANTISSA : CONSTANT := 1;
          V1, V2   : ST_RIGHT_OUT_M1;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF SM_ST_RIGHT_OUT_M1 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR " &
                       "ST_RIGHT_OUT_M1");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_ST_RIGHT_OUT_M1 /= V2 THEN
               FAILED("WRONG GENERIC 'LARGE VALUE FOR ST_RIGHT_OUT_M1");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR ST_RIGHT_OUT_M1");
     END;

     -------------------------------------------------------------------

     RESULT;

END C35A04O;
