-- C35A03P.ADA

-- CHECK THAT FOR FIXED POINT TYPES THE MANTISSA ATTRIBUTE YIELDS THE
-- CORRECT VALUES.

-- CASE P: BINARY POINT IS SYSTEM.MAX_MANTISSA BITS OUTSIDE THE
--         MANTISSA, FOR GENERICS.

-- WRG 7/28/86

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;
PROCEDURE C35A03P IS

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
     FUNCTION F RETURN INTEGER;

     FUNCTION F RETURN INTEGER IS
     BEGIN
          RETURN IDENT_INT (T'MANTISSA);
     END F;

     -------------------------------------------------------------------

     FUNCTION F_LEFT_WAY_OUT_MM    IS NEW F(LEFT_WAY_OUT_MM           );
     FUNCTION F_RIGHT_WAY_OUT_MM   IS NEW F(RIGHT_WAY_OUT_MM          );
     FUNCTION F_ST_LEFT_WAY_OUT_M1 IS NEW F(ST_LEFT_WAY_OUT_M1        );
     FUNCTION F_ST_RIGHT_WAY_OUT_MM_LESS_1
                                   IS NEW F(ST_RIGHT_WAY_OUT_MM_LESS_1);


BEGIN

     TEST ("C35A03P", "CHECK THAT FOR FIXED POINT TYPES THE MANTISSA " &
                      "ATTRIBUTE YIELDS THE CORRECT VALUES - BINARY " &
                      "POINT MAX_MANTISSA BITS OUTSIDE THE MANTISSA, " &
                      "GENERICS");

     COMMENT ("VALUE OF SYSTEM.MAX_MANTISSA IS" &
              POSITIVE'IMAGE(MAX_MANTISSA));

     IF F_LEFT_WAY_OUT_MM /= MM THEN
          FAILED ("GENERIC 'MANTISSA FOR LEFT_WAY_OUT_MM =" &
                  INTEGER'IMAGE(F_LEFT_WAY_OUT_MM) );
     END IF;

     IF F_RIGHT_WAY_OUT_MM /= MM THEN
          FAILED ("GENERIC 'MANTISSA FOR RIGHT_WAY_OUT_MM =" &
                  INTEGER'IMAGE(F_RIGHT_WAY_OUT_MM) );
     END IF;

     -------------------------------------------------------------------

     IF F_ST_LEFT_WAY_OUT_M1 /= 1 THEN
          FAILED ("GENERIC 'MANTISSA FOR ST_LEFT_WAY_OUT_M1 =" &
                  INTEGER'IMAGE(F_ST_LEFT_WAY_OUT_M1) );
     END IF;

     IF F_ST_RIGHT_WAY_OUT_MM_LESS_1 /= MM - 1 THEN
          FAILED ("GENERIC 'MANTISSA FOR ST_RIGHT_WAY_OUT_MM_LESS_1 =" &
                  INTEGER'IMAGE(F_ST_RIGHT_WAY_OUT_MM_LESS_1) );
     END IF;

     RESULT;

END C35A03P;
