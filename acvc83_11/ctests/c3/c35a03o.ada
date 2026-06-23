-- C35A03O.ADA

-- CHECK THAT FOR FIXED POINT TYPES THE MANTISSA ATTRIBUTE YIELDS THE
-- CORRECT VALUES.

-- CASE O: 'MANTISSA = SYSTEM.MAX_MANTISSA, FOR GENERICS.

-- WRG 7/28/86

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;
PROCEDURE C35A03O IS

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
     FUNCTION F RETURN INTEGER;

     FUNCTION F RETURN INTEGER IS
     BEGIN
          RETURN IDENT_INT (T'MANTISSA);
     END F;

     -------------------------------------------------------------------

     FUNCTION F_LEFT_OUT_MM           IS NEW F (LEFT_OUT_MM          );
     FUNCTION F_LEFT_EDGE_MM          IS NEW F (LEFT_EDGE_MM         );
     FUNCTION F_MIDDLE_MM             IS NEW F (MIDDLE_MM            );
     FUNCTION F_RIGHT_EDGE_MM         IS NEW F (RIGHT_EDGE_MM        );
     FUNCTION F_RIGHT_OUT_MM          IS NEW F (RIGHT_OUT_MM         );
     FUNCTION F_ST_LEFT_OUT_MM_LESS_1 IS NEW F (ST_LEFT_OUT_MM_LESS_1);
     FUNCTION F_ST_LEFT_OUT_MM_HALF   IS NEW F (ST_LEFT_OUT_MM_HALF  );
     FUNCTION F_ST_RIGHT_EDGE_MM_HALF IS NEW F (ST_RIGHT_EDGE_MM_HALF);
     FUNCTION F_ST_RIGHT_OUT_MM_HALF  IS NEW F (ST_RIGHT_OUT_MM_HALF );
     FUNCTION F_ST_RIGHT_OUT_M1       IS NEW F (ST_RIGHT_OUT_M1      );

BEGIN

     TEST ("C35A03O", "CHECK THAT FOR FIXED POINT TYPES THE MANTISSA " &
                      "ATTRIBUTE YIELDS THE CORRECT VALUES - " &
                      "'MANTISSA = SYSTEM.MAX_MANTISSA, GENERICS");

     COMMENT ("VALUE OF SYSTEM.MAX_MANTISSA IS" &
              POSITIVE'IMAGE(MAX_MANTISSA));

     IF F_LEFT_OUT_MM /= MM THEN
          FAILED ("GENERIC 'MANTISSA FOR LEFT_OUT_MM =" &
                  INTEGER'IMAGE(F_LEFT_OUT_MM) );
     END IF;

     IF F_LEFT_EDGE_MM /= MM THEN
          FAILED ("GENERIC 'MANTISSA FOR LEFT_EDGE_MM =" &
                  INTEGER'IMAGE(F_LEFT_EDGE_MM) );
     END IF;

     IF F_MIDDLE_MM /= MM THEN
          FAILED ("GENERIC 'MANTISSA FOR MIDDLE_MM =" &
                  INTEGER'IMAGE(F_MIDDLE_MM) );
     END IF;

     IF F_RIGHT_EDGE_MM /= MM THEN
          FAILED ("GENERIC 'MANTISSA FOR RIGHT_EDGE_MM =" &
                  INTEGER'IMAGE(F_RIGHT_EDGE_MM) );
     END IF;

     IF F_RIGHT_OUT_MM /= MM THEN
          FAILED ("GENERIC 'MANTISSA FOR RIGHT_OUT_MM =" &
                  INTEGER'IMAGE(F_RIGHT_OUT_MM) );
     END IF;

     -------------------------------------------------------------------

     IF F_ST_LEFT_OUT_MM_LESS_1 /= MM - 1 THEN
          FAILED ("GENERIC 'MANTISSA FOR ST_LEFT_OUT_MM_LESS_1 =" &
                  INTEGER'IMAGE(F_ST_LEFT_OUT_MM_LESS_1) );
     END IF;

     IF F_ST_LEFT_OUT_MM_HALF /= CEIL_MM_HALF THEN
          FAILED ("GENERIC 'MANTISSA FOR ST_LEFT_OUT_MM_HALF =" &
                  INTEGER'IMAGE(F_ST_LEFT_OUT_MM_HALF) );
     END IF;

     IF F_ST_RIGHT_EDGE_MM_HALF /= FLOOR_MM_HALF THEN
          FAILED ("GENERIC 'MANTISSA FOR ST_RIGHT_EDGE_MM_HALF =" &
                  INTEGER'IMAGE(F_ST_RIGHT_EDGE_MM_HALF) );
     END IF;

     IF F_ST_RIGHT_OUT_MM_HALF /= CEIL_MM_HALF THEN
          FAILED ("GENERIC 'MANTISSA FOR ST_RIGHT_OUT_MM_HALF =" &
                  INTEGER'IMAGE(F_ST_RIGHT_OUT_MM_HALF) );
     END IF;

     IF F_ST_RIGHT_OUT_M1 /= 1 THEN
          FAILED ("GENERIC 'MANTISSA FOR ST_RIGHT_OUT_M1 =" &
                  INTEGER'IMAGE(F_ST_RIGHT_OUT_M1) );
     END IF;

     RESULT;

END C35A03O;
