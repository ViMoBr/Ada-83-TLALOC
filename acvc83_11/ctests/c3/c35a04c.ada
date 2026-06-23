-- C35A04C.ADA

-- CHECK THAT FOR FIXED POINT TYPES THE SMALL AND LARGE ATTRIBUTES
-- YIELD THE CORRECT VALUES.

-- CASE C: BINARY POINT IS SYSTEM.MAX_MANTISSA BITS OUTSIDE THE
--         MANTISSA.

-- WRG 8/4/86

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;
PROCEDURE C35A04C IS

     MM : CONSTANT := MAX_MANTISSA;

     -- THE NAME OF EACH TYPE OR SUBTYPE ENDS WITH THAT TYPE'S
     -- 'MANTISSA VALUE.

     TYPE LEFT_WAY_OUT_MM  IS
          DELTA 2.0 ** (-(MM+MM))
          RANGE -(2.0 ** (-MM) )  .. 2.0 ** (-MM);
     TYPE RIGHT_WAY_OUT_MM IS
          DELTA 2.0 ** MM
          RANGE -(2.0 ** (MM+MM)) .. 2.0 ** (MM+MM);

     -------------------------------------------------------------------

     SUBTYPE ST_LEFT_WAY_OUT_M1         IS LEFT_WAY_OUT_MM
          DELTA 2.0 ** (-MM-1);
     SUBTYPE ST_RIGHT_WAY_OUT_MM_LESS_1 IS RIGHT_WAY_OUT_MM
          DELTA 2.0 ** MM
          RANGE RIGHT_WAY_OUT_MM (-(2.0 ** (MM+MM-1))) ..
                RIGHT_WAY_OUT_MM   (2.0 ** (MM+MM-1));

BEGIN

     TEST ("C35A04C", "CHECK THAT FOR FIXED POINT TYPES THE SMALL " &
                      "AND LARGE ATTRIBUTES YIELD THE CORRECT VALUES " &
                      "- BINARY POINT MAX_MANTISSA BITS OUTSIDE THE " &
                      "MANTISSA");

     COMMENT ("VALUE OF SYSTEM.MAX_MANTISSA IS" &
              POSITIVE'IMAGE(MAX_MANTISSA));

     -------------------------------------------------------------------

     DECLARE
       -- TYPE LEFT_WAY_OUT_MM IS DELTA 2.0 ** (-(MM+MM))
       --      RANGE -(2.0 ** (-MM) )  .. 2.0 ** (-MM);
          SMALL    : CONSTANT := 2.0 ** (-(MM+MM));
          MANTISSA : CONSTANT := MM;
          V1, V2   : LEFT_WAY_OUT_MM;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF LEFT_WAY_OUT_MM'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR LEFT_WAY_OUT_MM'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LEFT_WAY_OUT_MM'LARGE /= V2 THEN
               FAILED ("WRONG VALUE FOR LEFT_WAY_OUT_MM'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR LEFT_WAY_OUT_MM");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE RIGHT_WAY_OUT_MM IS DELTA 2.0 ** MM
       --      RANGE -(2.0 ** (MM+MM)) .. 2.0 ** (MM+MM);
          SMALL    : CONSTANT := 2.0 ** MM;
          MANTISSA : CONSTANT := MM;
          V1, V2   : RIGHT_WAY_OUT_MM;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF RIGHT_WAY_OUT_MM'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR RIGHT_WAY_OUT_MM'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF RIGHT_WAY_OUT_MM'LARGE /= V2 THEN
               FAILED ("WRONG VALUE FOR RIGHT_WAY_OUT_MM'LARGE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR RIGHT_WAY_OUT_MM");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE LEFT_WAY_OUT_MM IS DELTA 2.0 ** (-(MM+MM))
       --      RANGE -(2.0 ** (-MM) )  .. 2.0 ** (-MM);
       -- SUBTYPE ST_LEFT_WAY_OUT_M1 IS LEFT_WAY_OUT_MM
       --      DELTA 2.0 ** (-MM-1);
          SMALL    : CONSTANT := 2.0 ** (-MM-1);
          MANTISSA : CONSTANT := 1;
          V1, V2   : ST_LEFT_WAY_OUT_M1;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF ST_LEFT_WAY_OUT_M1'SMALL /= V1 THEN
               IF ST_LEFT_WAY_OUT_M1'SMALL = LEFT_WAY_OUT_MM'SMALL THEN
                    FAILED ("ST_LEFT_WAY_OUT_M1'SMALL = " &
                            "LEFT_WAY_OUT_MM'SMALL");
               ELSE
                    FAILED ("WRONG VALUE FOR " &
                            "ST_LEFT_WAY_OUT_M1'SMALL");
               END IF;
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF ST_LEFT_WAY_OUT_M1'LARGE /= V2 THEN
               IF ST_LEFT_WAY_OUT_M1'LARGE = LEFT_WAY_OUT_MM'LARGE THEN
                    FAILED ("ST_LEFT_WAY_OUT_M1'LARGE = " &
                            "LEFT_WAY_OUT_MM'LARGE");
               ELSE
                    FAILED ("WRONG VALUE FOR " &
                            "ST_LEFT_WAY_OUT_M1'LARGE");
               END IF;
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR ST_LEFT_WAY_OUT_M1");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE RIGHT_WAY_OUT_MM IS DELTA 2.0 ** MM
       --      RANGE -(2.0 ** (MM+MM)) .. 2.0 ** (MM+MM);
       -- SUBTYPE ST_RIGHT_WAY_OUT_MM_LESS_1 IS RIGHT_WAY_OUT_MM
       --      DELTA 2.0 ** MM
       --      RANGE RIGHT_WAY_OUT_MM (-(2.0 ** (MM+MM-1))) ..
       --            RIGHT_WAY_OUT_MM   (2.0 ** (MM+MM-1));
          SMALL    : CONSTANT := 2.0 ** MM;
          MANTISSA : CONSTANT := MM - 1;
          V1, V2   : ST_RIGHT_WAY_OUT_MM_LESS_1;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF ST_RIGHT_WAY_OUT_MM_LESS_1'SMALL /= V1 THEN
               FAILED ("WRONG VALUE FOR " &
                       "ST_RIGHT_WAY_OUT_MM_LESS_1'SMALL");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF ST_RIGHT_WAY_OUT_MM_LESS_1'LARGE /= V2 THEN
               IF ST_RIGHT_WAY_OUT_MM_LESS_1'LARGE =
                  RIGHT_WAY_OUT_MM'LARGE THEN
                    FAILED ("ST_RIGHT_WAY_OUT_MM_LESS_1'LARGE = " &
                            "RIGHT_WAY_OUT_MM'LARGE");
               ELSE
                    FAILED ("WRONG VALUE FOR " &
                            "ST_RIGHT_WAY_OUT_MM_LESS_1'LARGE");
               END IF;
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR " &
                       "ST_RIGHT_WAY_OUT_MM_LESS_1");
     END;

     -------------------------------------------------------------------

     RESULT;

END C35A04C;
