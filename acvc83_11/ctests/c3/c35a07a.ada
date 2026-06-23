-- C35A07A.ADA

-- CHECK THAT FOR FIXED POINT TYPES THE FIRST AND LAST ATTRIBUTES YIELD
-- CORRECT VALUES.

-- CASE A: BASIC TYPES THAT FIT THE CHARACTERISTICS OF DURATION'BASE.

-- WRG 8/25/86

WITH REPORT; USE REPORT;
PROCEDURE C35A07A IS

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
          -- LARGEST MODEL NUMBER IS 960.0.

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
          -- LARGEST MODEL NUMBER IS 1016.0.
     SUBTYPE ST_DECIMAL_M3   IS DECIMAL_M4
          DELTA 100.0 RANGE  -500.0 ..  500.0;
          -- LARGEST MODEL NUMBER IS 448.0.
     SUBTYPE ST_MIDDLE_M15   IS MIDDLE_M15
          RANGE 6.0 .. 3.0;

BEGIN

     TEST ("C35A07A", "CHECK THAT FOR FIXED POINT TYPES THE FIRST " &
                      "AND LAST ATTRIBUTES YIELD CORRECT VALUES - " &
                      "BASIC TYPES");

     -------------------------------------------------------------------

     IF LEFT_OUT_M1'FIRST > -LEFT_OUT_M1'LARGE THEN
          FAILED ("LEFT_OUT_M1'FIRST > -LEFT_OUT_M1'LARGE");
     END IF;
     IF LEFT_OUT_M1'LAST  <  LEFT_OUT_M1'LARGE THEN
          FAILED ("LEFT_OUT_M1'LAST  <  LEFT_OUT_M1'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF LEFT_EDGE_M1'FIRST > -LEFT_EDGE_M1'LARGE THEN
          FAILED ("LEFT_EDGE_M1'FIRST > -LEFT_EDGE_M1'LARGE");
     END IF;
     IF LEFT_EDGE_M1'LAST  <  LEFT_EDGE_M1'LARGE THEN
          FAILED ("LEFT_EDGE_M1'LAST  <  LEFT_EDGE_M1'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF RIGHT_EDGE_M1'FIRST > -RIGHT_EDGE_M1'LARGE THEN
          FAILED ("RIGHT_EDGE_M1'FIRST > -RIGHT_EDGE_M1'LARGE");
     END IF;
     IF RIGHT_EDGE_M1'LAST  <  RIGHT_EDGE_M1'LARGE THEN
          FAILED ("RIGHT_EDGE_M1'LAST  <  RIGHT_EDGE_M1'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF RIGHT_OUT_M1'FIRST > -RIGHT_OUT_M1'LARGE THEN
          FAILED ("RIGHT_OUT_M1'FIRST > -RIGHT_OUT_M1'LARGE");
     END IF;
     IF RIGHT_OUT_M1'LAST  <  RIGHT_OUT_M1'LARGE THEN
          FAILED ("RIGHT_OUT_M1'LAST  <  RIGHT_OUT_M1'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF MIDDLE_M2'FIRST > -MIDDLE_M2'LARGE THEN
          FAILED ("MIDDLE_M2'FIRST > -MIDDLE_M2'LARGE");
     END IF;
     IF MIDDLE_M2'LAST  <  MIDDLE_M2'LARGE THEN
          FAILED ("MIDDLE_M2'LAST  <  MIDDLE_M2'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF MIDDLE_M3'FIRST /= IDENT_INT (1) * 0.0 THEN
          FAILED ("MIDDLE_M3'FIRST /= 0.0");
     END IF;
     IF MIDDLE_M3'LAST /= IDENT_INT (1) * 2.5 THEN
          FAILED ("MIDDLE_M3'LAST /= 2.5");
     END IF;

     -------------------------------------------------------------------

     IF MIDDLE_M15'FIRST > -MIDDLE_M15'LARGE THEN
          FAILED ("MIDDLE_M15'FIRST > -MIDDLE_M15'LARGE");
     END IF;
     IF MIDDLE_M15'LAST  <  MIDDLE_M15'LARGE THEN
          FAILED ("MIDDLE_M15'LAST  <  MIDDLE_M15'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF MIDDLE_M16'FIRST > -MIDDLE_M16'LARGE THEN
          FAILED ("MIDDLE_M16'FIRST > -MIDDLE_M16'LARGE");
     END IF;
     IF MIDDLE_M16'LAST  <  MIDDLE_M16'LARGE THEN
          FAILED ("MIDDLE_M16'LAST  <  MIDDLE_M16'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF LIKE_DURATION_M23'FIRST /= IDENT_INT (1) * (-86_400.0) THEN
          FAILED ("LIKE_DURATION_M23'FIRST /= -86_400.0");
     END IF;
     IF LIKE_DURATION_M23'LAST  /= IDENT_INT (1) * 86_400.0 THEN
          FAILED ("LIKE_DURATION_M23'LAST  /=  86_400.0");
     END IF;

     -------------------------------------------------------------------

     IF DECIMAL_M18'FIRST /= IDENT_INT (1) * (-10_000.0) THEN
          FAILED ("DECIMAL_M18'FIRST /= -10_000.0");
     END IF;
     IF DECIMAL_M18'LAST /= IDENT_INT (1) * 10_000.0 THEN
          FAILED ("DECIMAL_M18'LAST /= 10_000.0");
     END IF;

     -------------------------------------------------------------------

     IF DECIMAL_M4'FIRST > -DECIMAL_M4'LARGE THEN
          FAILED ("DECIMAL_M4'FIRST > -DECIMAL_M4'LARGE");
     END IF;
     IF DECIMAL_M4'LAST  <  DECIMAL_M4'LARGE THEN
          FAILED ("DECIMAL_M4'LAST  <  DECIMAL_M4'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF ST_LEFT_EDGE_M6'FIRST > -ST_LEFT_EDGE_M6'LARGE THEN
          FAILED ("ST_LEFT_EDGE_M6'FIRST > -ST_LEFT_EDGE_M6'LARGE");
     END IF;
     IF ST_LEFT_EDGE_M6'LAST  <  ST_LEFT_EDGE_M6'LARGE THEN
          FAILED ("ST_LEFT_EDGE_M6'LAST  <  ST_LEFT_EDGE_M6'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF ST_MIDDLE_M14'FIRST > -ST_MIDDLE_M14'LARGE THEN
          FAILED ("ST_MIDDLE_M14'FIRST > -ST_MIDDLE_M14'LARGE");
     END IF;
     IF ST_MIDDLE_M14'LAST  <  ST_MIDDLE_M14'LARGE THEN
          FAILED ("ST_MIDDLE_M14'LAST  <  ST_MIDDLE_M14'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF ST_MIDDLE_M2'FIRST > -ST_MIDDLE_M2'LARGE THEN
          FAILED ("ST_MIDDLE_M2'FIRST > -ST_MIDDLE_M2'LARGE");
     END IF;
     IF ST_MIDDLE_M2'LAST  <  ST_MIDDLE_M2'LARGE THEN
          FAILED ("ST_MIDDLE_M2'LAST  <  ST_MIDDLE_M2'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF ST_MIDDLE_M3'FIRST /= IDENT_INT (1) * 0.0 THEN
          FAILED ("ST_MIDDLE_M3'FIRST /= 0.0");
     END IF;
     IF ST_MIDDLE_M3'LAST /= IDENT_INT (1) * 2.5 THEN
          FAILED ("ST_MIDDLE_M3'LAST /= 2.5");
     END IF;

     -------------------------------------------------------------------

     IF ST_DECIMAL_M7'FIRST /= IDENT_INT (1) * (-1000.0) THEN
          FAILED ("ST_DECIMAL_M7'FIRST /= -1000.0");
     END IF;
     IF ST_DECIMAL_M7'LAST /= IDENT_INT (1) * 1000.0 THEN
          FAILED ("ST_DECIMAL_M7'LAST /= 1000.0");
     END IF;

     -------------------------------------------------------------------

     IF ST_DECIMAL_M3'FIRST > -ST_DECIMAL_M3'LARGE THEN
          FAILED ("ST_DECIMAL_M3'FIRST > -ST_DECIMAL_M3'LARGE");
     END IF;
     IF ST_DECIMAL_M3'LAST  <  ST_DECIMAL_M3'LARGE THEN
          FAILED ("ST_DECIMAL_M3'LAST  <  ST_DECIMAL_M3'LARGE");
     END IF;

     -------------------------------------------------------------------

     IF ST_MIDDLE_M15'FIRST /= IDENT_INT (1) * 6.0 THEN
          FAILED ("ST_MIDDLE_M15'FIRST /= 6.0");
     END IF;
     IF ST_MIDDLE_M15'LAST /= IDENT_INT (1) * 3.0 THEN
          FAILED ("ST_MIDDLE_M15'LAST /= 3.0");
     END IF;

     -------------------------------------------------------------------

     RESULT;

END C35A07A;
