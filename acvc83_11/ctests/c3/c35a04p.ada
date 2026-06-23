-- C35A04P.ADA

-- CHECK THAT FOR FIXED POINT TYPES THE SMALL AND LARGE ATTRIBUTES
-- YIELD THE CORRECT VALUES.

-- CASE P: BINARY POINT IS SYSTEM.MAX_MANTISSA BITS OUTSIDE THE
--         MANTISSA, FOR GENERICS.

-- WRG 8/5/86

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;
PROCEDURE C35A04P IS

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

     FUNCTION SM_LEFT_WAY_OUT_MM    IS NEW SM (LEFT_WAY_OUT_MM   );
     FUNCTION SM_RIGHT_WAY_OUT_MM   IS NEW SM (RIGHT_WAY_OUT_MM  );
     FUNCTION SM_ST_LEFT_WAY_OUT_M1 IS NEW SM (ST_LEFT_WAY_OUT_M1);
     FUNCTION SM_ST_RIGHT_WAY_OUT_MM_LESS_1
                                 IS NEW SM (ST_RIGHT_WAY_OUT_MM_LESS_1);

     FUNCTION LG_LEFT_WAY_OUT_MM    IS NEW LG (LEFT_WAY_OUT_MM   );
     FUNCTION LG_RIGHT_WAY_OUT_MM   IS NEW LG (RIGHT_WAY_OUT_MM  );
     FUNCTION LG_ST_LEFT_WAY_OUT_M1 IS NEW LG (ST_LEFT_WAY_OUT_M1);
     FUNCTION LG_ST_RIGHT_WAY_OUT_MM_LESS_1
                                 IS NEW LG (ST_RIGHT_WAY_OUT_MM_LESS_1);

BEGIN

     TEST ("C35A04P", "CHECK THAT FOR FIXED POINT TYPES THE SMALL " &
                      "AND LARGE ATTRIBUTES YIELD THE CORRECT VALUES " &
                      "- BINARY POINT MAX_MANTISSA BITS OUTSIDE THE " &
                      "MANTISSA, GENERICS");

     COMMENT ("VALUE OF SYSTEM.MAX_MANTISSA IS" &
              POSITIVE'IMAGE(MAX_MANTISSA));

     -------------------------------------------------------------------

     DECLARE
       -- TYPE LEFT_WAY_OUT_MM IS DELTA 2.0 ** (-(MM+MM))
       --      RANGE -(2.0 ** (-MM) ) .. 2.0 ** (-MM);
          SMALL    : CONSTANT := 2.0 ** (-(MM+MM));
          MANTISSA : CONSTANT := MM;
          V1, V2   : LEFT_WAY_OUT_MM;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF SM_LEFT_WAY_OUT_MM /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR " &
                       "LEFT_WAY_OUT_MM");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_LEFT_WAY_OUT_MM /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR " &
                       "LEFT_WAY_OUT_MM");
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
          IF SM_RIGHT_WAY_OUT_MM /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR " &
                       "RIGHT_WAY_OUT_MM");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_RIGHT_WAY_OUT_MM /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR " &
                       "RIGHT_WAY_OUT_MM");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR RIGHT_WAY_OUT_MM");
     END;

     -------------------------------------------------------------------

     DECLARE
       -- TYPE LEFT_WAY_OUT_MM IS DELTA 2.0 ** (-(MM+MM))
       --      RANGE -(2.0 ** (-MM) ) .. 2.0 ** (-MM);
       -- SUBTYPE ST_LEFT_WAY_OUT_M1 IS LEFT_WAY_OUT_MM
       --      DELTA 2.0 ** (-MM-1);
          SMALL    : CONSTANT := 2.0 ** (-MM-1);
          MANTISSA : CONSTANT := 1;
          V1, V2   : ST_LEFT_WAY_OUT_M1;
     BEGIN
          V1 := IDENT_INT (1) * SMALL;
          IF SM_ST_LEFT_WAY_OUT_M1 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR " &
                       "ST_LEFT_WAY_OUT_M1");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_ST_LEFT_WAY_OUT_M1 /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR " &
                       "ST_LEFT_WAY_OUT_M1");
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
          IF SM_ST_RIGHT_WAY_OUT_MM_LESS_1 /= V1 THEN
               FAILED ("WRONG GENERIC 'SMALL VALUE FOR " &
                       "ST_RIGHT_WAY_OUT_MM_LESS_1");
          END IF;
          FOR I IN 1 .. IDENT_INT (MANTISSA - 1) LOOP
               V1 := V1 + V1;
          END LOOP;
          V2 := V1 - SMALL;
          V2 := V2 + V1;
          IF LG_ST_RIGHT_WAY_OUT_MM_LESS_1 /= V2 THEN
               FAILED ("WRONG GENERIC 'LARGE VALUE FOR " &
                       "ST_RIGHT_WAY_OUT_MM_LESS_1");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               FAILED ("EXCEPTION RAISED FOR " &
                       "ST_RIGHT_WAY_OUT_MM_LESS_1");
     END;

     -------------------------------------------------------------------

     RESULT;

END C35A04P;
