-- C35A07P.ADA

-- CHECK THAT FOR FIXED POINT TYPES THE FIRST AND LAST ATTRIBUTES YIELD
-- CORRECT VALUES.

-- CASE P: BINARY POINT IS SYSTEM.MAX_MANTISSA BITS OUTSIDE THE
--         MANTISSA, FOR GENERICS.

-- WRG 8/26/86

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;
PROCEDURE C35A07P IS

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
     PROCEDURE INEXACT_CHECK (NAME : STRING);

     PROCEDURE INEXACT_CHECK (NAME : STRING) IS
     BEGIN
          IF T'FIRST > -T'LARGE THEN
               FAILED (NAME & "'FIRST > -" & NAME & "'LARGE");
          END IF;

          IF T'LAST  <  T'LARGE THEN
               FAILED (NAME & "'LAST  <  " & NAME & "'LARGE");
          END IF;
     END INEXACT_CHECK;

     -------------------------------------------------------------------

     PROCEDURE CHECK_LEFT_WAY_OUT_MM
                      IS NEW INEXACT_CHECK (LEFT_WAY_OUT_MM           );
     PROCEDURE CHECK_RIGHT_WAY_OUT_MM
                      IS NEW INEXACT_CHECK (RIGHT_WAY_OUT_MM          );
     PROCEDURE CHECK_ST_LEFT_WAY_OUT_M1
                      IS NEW INEXACT_CHECK (ST_LEFT_WAY_OUT_M1        );
     PROCEDURE CHECK_ST_RIGHT_WAY_OUT_MM_LESS_1
                      IS NEW INEXACT_CHECK (ST_RIGHT_WAY_OUT_MM_LESS_1);

BEGIN

     TEST ("C35A07P", "CHECK THAT FOR FIXED POINT TYPES THE FIRST " &
                      "AND LAST ATTRIBUTES YIELD CORRECT VALUES - " &
                      "BINARY POINT MAX_MANTISSA BITS OUTSIDE THE " &
                      "MANTISSA, GENERICS");

     COMMENT ("VALUE OF SYSTEM.MAX_MANTISSA IS" &
              POSITIVE'IMAGE(MAX_MANTISSA));

     CHECK_LEFT_WAY_OUT_MM            ("LEFT_WAY_OUT_MM           ");
     CHECK_RIGHT_WAY_OUT_MM           ("RIGHT_WAY_OUT_MM          ");
     CHECK_ST_LEFT_WAY_OUT_M1         ("ST_LEFT_WAY_OUT_M1        ");
     CHECK_ST_RIGHT_WAY_OUT_MM_LESS_1 ("ST_RIGHT_WAY_OUT_MM_LESS_1");

     RESULT;

END C35A07P;
