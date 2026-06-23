-- C35A07B.ADA

-- CHECK THAT FOR FIXED POINT TYPES THE FIRST AND LAST ATTRIBUTES YIELD
-- CORRECT VALUES.

-- CASE B: 'MANTISSA = SYSTEM.MAX_MANTISSA.

-- WRG 8/25/86

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;
PROCEDURE C35A07B IS

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
                IDENT_INT (1) * LEFT_EDGE_MM ( 2.0 ** (-FLOOR_MM_HALF));
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

BEGIN

     TEST ("C35A07B", "CHECK THAT FOR FIXED POINT TYPES THE FIRST " &
                      "AND LAST ATTRIBUTES YIELD CORRECT VALUES - " &
                      "'MANTISSA = SYSTEM.MAX_MANTISSA");

     COMMENT ("VALUE OF SYSTEM.MAX_MANTISSA IS" &
              POSITIVE'IMAGE(MAX_MANTISSA));

     -------------------------------------------------------------------

     IF LEFT_OUT_MM'FIRST > -LEFT_OUT_MM'LARGE THEN
          FAILED ("LEFT_OUT_MM'FIRST > -LEFT_OUT_MM'LARGE");
     END IF;
     IF LEFT_OUT_MM'LAST  <  LEFT_OUT_MM'LARGE THEN
          FAILED ("LEFT_OUT_MM'LAST  <  LEFT_OUT_MM'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF LEFT_EDGE_MM'FIRST > -LEFT_EDGE_MM'LARGE THEN
          FAILED ("LEFT_EDGE_MM'FIRST > -LEFT_EDGE_MM'LARGE");
     END IF;
     IF LEFT_EDGE_MM'LAST  <  LEFT_EDGE_MM'LARGE THEN
          FAILED ("LEFT_EDGE_MM'LAST  <  LEFT_EDGE_MM'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF MIDDLE_MM'FIRST > -MIDDLE_MM'LARGE THEN
          FAILED ("MIDDLE_MM'FIRST > -MIDDLE_MM'LARGE");
     END IF;
     IF MIDDLE_MM'LAST  <  MIDDLE_MM'LARGE THEN
          FAILED ("MIDDLE_MM'LAST  <  MIDDLE_MM'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF RIGHT_EDGE_MM'FIRST > -RIGHT_EDGE_MM'LARGE THEN
          FAILED ("RIGHT_EDGE_MM'FIRST > -RIGHT_EDGE_MM'LARGE");
     END IF;
     IF RIGHT_EDGE_MM'LAST  <  RIGHT_EDGE_MM'LARGE THEN
          FAILED ("RIGHT_EDGE_MM'LAST  <  RIGHT_EDGE_MM'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF RIGHT_OUT_MM'FIRST > -RIGHT_OUT_MM'LARGE THEN
          FAILED ("RIGHT_OUT_MM'FIRST > -RIGHT_OUT_MM'LARGE");
     END IF;
     IF RIGHT_OUT_MM'LAST  <  RIGHT_OUT_MM'LARGE THEN
          FAILED ("RIGHT_OUT_MM'LAST  <  RIGHT_OUT_MM'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF ST_LEFT_OUT_MM_LESS_1'FIRST >
       -ST_LEFT_OUT_MM_LESS_1'LARGE THEN
          FAILED ("ST_LEFT_OUT_MM_LESS_1'FIRST > " &
                  "-ST_LEFT_OUT_MM_LESS_1'LARGE");
     END IF;
     IF ST_LEFT_OUT_MM_LESS_1'LAST  <
        ST_LEFT_OUT_MM_LESS_1'LARGE THEN
          FAILED ("ST_LEFT_OUT_MM_LESS_1'LAST  <  " &
                  "ST_LEFT_OUT_MM_LESS_1'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF ST_LEFT_OUT_MM_HALF'FIRST >
       -ST_LEFT_OUT_MM_HALF'LARGE THEN
          FAILED ("ST_LEFT_OUT_MM_HALF'FIRST > " &
                  "-ST_LEFT_OUT_MM_HALF'LARGE");
     END IF;
     IF ST_LEFT_OUT_MM_HALF'LAST  <
        ST_LEFT_OUT_MM_HALF'LARGE THEN
          FAILED ("ST_LEFT_OUT_MM_HALF'LAST  <  " &
                  "ST_LEFT_OUT_MM_HALF'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF ST_RIGHT_EDGE_MM_HALF'FIRST >
       -ST_RIGHT_EDGE_MM_HALF'LARGE THEN
          FAILED ("ST_RIGHT_EDGE_MM_HALF'FIRST > " &
                  "-ST_RIGHT_EDGE_MM_HALF'LARGE");
     END IF;
     IF ST_RIGHT_EDGE_MM_HALF'LAST  <
        ST_RIGHT_EDGE_MM_HALF'LARGE THEN
          FAILED ("ST_RIGHT_EDGE_MM_HALF'LAST  <  " &
                  "ST_RIGHT_EDGE_MM_HALF'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF ST_RIGHT_OUT_MM_HALF'FIRST >
       -ST_RIGHT_OUT_MM_HALF'LARGE THEN
          FAILED ("ST_RIGHT_OUT_MM_HALF'FIRST > " &
                  "-ST_RIGHT_OUT_MM_HALF'LARGE");
     END IF;
     IF ST_RIGHT_OUT_MM_HALF'LAST  <
        ST_RIGHT_OUT_MM_HALF'LARGE THEN
          FAILED ("ST_RIGHT_OUT_MM_HALF'LAST  <  " &
                  "ST_RIGHT_OUT_MM_HALF'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF ST_RIGHT_OUT_M1'FIRST > -ST_RIGHT_OUT_M1'LARGE THEN
          FAILED ("ST_RIGHT_OUT_M1'FIRST > -ST_RIGHT_OUT_M1'LARGE");
     END IF;
     IF ST_RIGHT_OUT_M1'LAST  <  ST_RIGHT_OUT_M1'LARGE THEN
          FAILED ("ST_RIGHT_OUT_M1'LAST  <  ST_RIGHT_OUT_M1'LARGE");
     END IF;

     -------------------------------------------------------------------

     RESULT;

END C35A07B;
