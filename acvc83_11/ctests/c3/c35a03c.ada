-- C35A03C.ADA

-- CHECK THAT FOR FIXED POINT TYPES THE MANTISSA ATTRIBUTE YIELDS THE
-- CORRECT VALUES.

-- CASE C: BINARY POINT IS SYSTEM.MAX_MANTISSA BITS OUTSIDE THE
--         MANTISSA.

-- WRG 7/25/86

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;
PROCEDURE C35A03C IS

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

     TEST ("C35A03C", "CHECK THAT FOR FIXED POINT TYPES THE MANTISSA " &
                      "ATTRIBUTE YIELDS THE CORRECT VALUES - BINARY " &
                      "POINT MAX_MANTISSA BITS OUTSIDE THE MANTISSA");

     COMMENT ("VALUE OF SYSTEM.MAX_MANTISSA IS" &
              POSITIVE'IMAGE(MAX_MANTISSA));

     IF IDENT_INT (LEFT_WAY_OUT_MM'MANTISSA) /= MM THEN
          FAILED ("LEFT_WAY_OUT_MM'MANTISSA =" &
                  INTEGER'IMAGE(LEFT_WAY_OUT_MM'MANTISSA) );
     END IF;

     IF IDENT_INT (RIGHT_WAY_OUT_MM'MANTISSA) /= MM THEN
          FAILED ("RIGHT_WAY_OUT_MM'MANTISSA =" &
                  INTEGER'IMAGE(RIGHT_WAY_OUT_MM'MANTISSA) );
     END IF;

     -------------------------------------------------------------------

     IF IDENT_INT (ST_LEFT_WAY_OUT_M1'MANTISSA) /= 1 THEN
          IF ST_LEFT_WAY_OUT_M1'MANTISSA =
             IDENT_INT (LEFT_WAY_OUT_MM'MANTISSA) THEN
               FAILED ("ST_LEFT_WAY_OUT_M1'MANTISSA = " &
                       "LEFT_WAY_OUT_MM'MANTISSA =" &
                       INTEGER'IMAGE(ST_LEFT_WAY_OUT_M1'MANTISSA) );
          ELSE
               FAILED ("ST_LEFT_WAY_OUT_M1'MANTISSA =" &
                       INTEGER'IMAGE(ST_LEFT_WAY_OUT_M1'MANTISSA) );
          END IF;
     END IF;

     IF IDENT_INT (ST_RIGHT_WAY_OUT_MM_LESS_1'MANTISSA) /= MM - 1 THEN
          IF ST_RIGHT_WAY_OUT_MM_LESS_1'MANTISSA =
             IDENT_INT (RIGHT_WAY_OUT_MM'MANTISSA) THEN
               FAILED ("ST_RIGHT_WAY_OUT_MM_LESS_1'MANTISSA = " &
                       "RIGHT_WAY_OUT_MM'MANTISSA =" &
                       INTEGER'IMAGE
                            (ST_RIGHT_WAY_OUT_MM_LESS_1'MANTISSA) );
          ELSE
               FAILED ("ST_RIGHT_WAY_OUT_MM_LESS_1'MANTISSA =" &
                       INTEGER'IMAGE
                            (ST_RIGHT_WAY_OUT_MM_LESS_1'MANTISSA) );
          END IF;
     END IF;

     RESULT;

END C35A03C;
