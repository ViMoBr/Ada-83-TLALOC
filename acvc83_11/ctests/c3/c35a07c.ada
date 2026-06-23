-- C35A07C.ADA

-- CHECK THAT FOR FIXED POINT TYPES THE FIRST AND LAST ATTRIBUTES YIELD
-- CORRECT VALUES.

-- CASE C: BINARY POINT IS SYSTEM.MAX_MANTISSA BITS OUTSIDE THE
--         MANTISSA.

-- WRG 8/25/86

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;
PROCEDURE C35A07C IS

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

     TEST ("C35A07C", "CHECK THAT FOR FIXED POINT TYPES THE FIRST " &
                      "AND LAST ATTRIBUTES YIELD CORRECT VALUES - " &
                      "BINARY POINT MAX_MANTISSA BITS OUTSIDE THE " &
                      "MANTISSA");

     COMMENT ("VALUE OF SYSTEM.MAX_MANTISSA IS" &
              POSITIVE'IMAGE(MAX_MANTISSA));

     -------------------------------------------------------------------

     IF LEFT_WAY_OUT_MM'FIRST > -LEFT_WAY_OUT_MM'LARGE THEN
          FAILED ("LEFT_WAY_OUT_MM'FIRST > -LEFT_WAY_OUT_MM'LARGE");
     END IF;
     IF LEFT_WAY_OUT_MM'LAST  <  LEFT_WAY_OUT_MM'LARGE THEN
          FAILED ("LEFT_WAY_OUT_MM'LAST  <  LEFT_WAY_OUT_MM'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF RIGHT_WAY_OUT_MM'FIRST > -RIGHT_WAY_OUT_MM'LARGE THEN
          FAILED ("RIGHT_WAY_OUT_MM'FIRST > -RIGHT_WAY_OUT_MM'LARGE");
     END IF;
     IF RIGHT_WAY_OUT_MM'LAST  <  RIGHT_WAY_OUT_MM'LARGE THEN
          FAILED ("RIGHT_WAY_OUT_MM'LAST  <  RIGHT_WAY_OUT_MM'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF ST_LEFT_WAY_OUT_M1'FIRST >
       -ST_LEFT_WAY_OUT_M1'LARGE THEN
          FAILED ("ST_LEFT_WAY_OUT_M1'FIRST > " &
                  "-ST_LEFT_WAY_OUT_M1'LARGE");
     END IF;
     IF ST_LEFT_WAY_OUT_M1'LAST  <
        ST_LEFT_WAY_OUT_M1'LARGE THEN
          FAILED ("ST_LEFT_WAY_OUT_M1'LAST  <  " &
                  "ST_LEFT_WAY_OUT_M1'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF ST_RIGHT_WAY_OUT_MM_LESS_1'FIRST >
       -ST_RIGHT_WAY_OUT_MM_LESS_1'LARGE THEN
          FAILED ("ST_RIGHT_WAY_OUT_MM_LESS_1'FIRST > " &
                  "-ST_RIGHT_WAY_OUT_MM_LESS_1'LARGE");
     END IF;
     IF ST_RIGHT_WAY_OUT_MM_LESS_1'LAST  <
        ST_RIGHT_WAY_OUT_MM_LESS_1'LARGE THEN
          FAILED ("ST_RIGHT_WAY_OUT_MM_LESS_1'LAST  <  " &
                  "ST_RIGHT_WAY_OUT_MM_LESS_1'LARGE");
     END IF;

     -------------------------------------------------------------------

     RESULT;

END C35A07C;
