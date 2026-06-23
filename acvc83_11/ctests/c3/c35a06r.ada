-- C35A06R.ADA

-- OBJECTIVE:
--     CHECK THAT FOR FIXED POINT TYPES THE SAFE_SMALL AND SAFE_LARGE
--     ATTRIBUTES YIELD APPROPRIATE VALUES.

--     CASE R: THIS TEST CHECKS BASIC TYPES THAT FIT THE
--     CHARACTERISTICS OF DURATION'BASE, HAVE MANTISSA VALUES
--     GREATER THAN ONE, AND IN WHICH DELTA IS A POWER OF TWO - FOR
--     GENERICS.

-- HISTORY:
--     RJW 11/13/87  CREATED ORIGINAL TEST FROM SPLIT OF C35A06N.

WITH REPORT; USE REPORT;
PROCEDURE C35A06R IS

     -- THE NAME OF EACH TYPE OR SUBTYPE ENDS WITH THAT TYPE'S
     -- 'MANTISSA VALUE.

     TYPE MIDDLE_M2         IS DELTA 0.5   RANGE -2.0 .. 2.0;
     TYPE MIDDLE_M3         IS DELTA 0.5   RANGE  0.0 .. 2.5;
     TYPE MIDDLE_M15        IS DELTA 2.0 **(-6) RANGE  -512.0 ..  512.0;
     TYPE MIDDLE_M16        IS DELTA 2.0 **(-6) RANGE -1024.0 .. 1024.0;

     -------------------------------------------------------------------

     TYPE MIDDLE_M2_BASE         IS DELTA MIDDLE_M2'SAFE_SMALL
          RANGE -MIDDLE_M2'SAFE_LARGE       .. MIDDLE_M2'SAFE_LARGE;

     TYPE MIDDLE_M3_BASE         IS DELTA MIDDLE_M3'SAFE_SMALL
          RANGE -MIDDLE_M3'SAFE_LARGE       .. MIDDLE_M3'SAFE_LARGE;

     TYPE MIDDLE_M15_BASE        IS DELTA MIDDLE_M15'SAFE_SMALL
          RANGE -MIDDLE_M15'SAFE_LARGE      .. MIDDLE_M15'SAFE_LARGE;

     TYPE MIDDLE_M16_BASE        IS DELTA MIDDLE_M16'SAFE_SMALL
          RANGE -MIDDLE_M16'SAFE_LARGE      .. MIDDLE_M16'SAFE_LARGE;

     -------------------------------------------------------------------

     SUBTYPE ST_LEFT_EDGE_M6 IS MIDDLE_M15
          DELTA 2.0 ** (-6) RANGE IDENT_INT (1) * (-1.0) .. 1.0;

     SUBTYPE ST_MIDDLE_M14   IS MIDDLE_M16
          DELTA 2.0 ** (-5) RANGE -512.0 .. IDENT_INT (1) * 512.0;

     -------------------------------------------------------------------

     GENERIC
          TYPE T IS DELTA <>;
          TYPE B IS DELTA <>;
     PROCEDURE CHECK_ATTRIBUTES (NAME : STRING;
                                 SAFE_SMALL, SAFE_LARGE : B);

     PROCEDURE CHECK_ATTRIBUTES (NAME : STRING;
                                 SAFE_SMALL, SAFE_LARGE : B) IS
     BEGIN
          IF T'SAFE_SMALL /= T'BASE'SMALL THEN
               FAILED ("GENERIC 'SAFE_SMALL VALUE FOR " & NAME &
                       " /= GENERIC 'BASE'SMALL VALUE FOR " & NAME);
          END IF;

          IF T'SAFE_LARGE /= T'BASE'LARGE THEN
               FAILED ("GENERIC 'SAFE_LARGE VALUE FOR " & NAME &
                       " /= GENERIC 'BASE'LARGE VALUE FOR " & NAME);
          END IF;

          IF T'SAFE_SMALL /= T'BASE'SAFE_SMALL THEN
               FAILED ("GENERIC 'SAFE_SMALL VALUE FOR " & NAME &
                       " /= GENERIC 'BASE'SAFE_SMALL VALUE FOR " &
                       NAME);
          END IF;

          IF T'SAFE_LARGE /= T'BASE'SAFE_LARGE THEN
               FAILED ("GENERIC 'SAFE_LARGE VALUE FOR " & NAME &
                       " /= GENERIC 'BASE'SAFE_LARGE VALUE FOR " &
                       NAME);
          END IF;

          IF T'SMALL < T'BASE'SAFE_SMALL THEN
               FAILED ("GENERIC 'SMALL VALUE FOR " & NAME &
                       " < GENERIC 'BASE'SAFE_SMALL FOR " & NAME);
          END IF;

          IF T'LARGE > T'BASE'SAFE_LARGE THEN
               FAILED ("GENERIC 'LARGE VALUE FOR " & NAME &
                       " > GENERIC 'BASE'SAFE_LARGE FOR " & NAME);
          END IF;

          IF T'SAFE_SMALL /= SAFE_SMALL THEN
               FAILED ("GENERIC 'SAFE_SMALL VALUE FOR " & NAME &
                       " /= " & NAME & "'SAFE_SMALL");
          END IF;

          IF T'SAFE_LARGE /= SAFE_LARGE THEN
               FAILED ("GENERIC 'SAFE_LARGE VALUE FOR " & NAME &
                       " /= " & NAME & "'SAFE_LARGE");
          END IF;
     END CHECK_ATTRIBUTES;

     -------------------------------------------------------------------

     PROCEDURE CHECK_MIDDLE_M2
          IS NEW CHECK_ATTRIBUTES (MIDDLE_M2,     MIDDLE_M2_BASE);

     PROCEDURE CHECK_MIDDLE_M3
          IS NEW CHECK_ATTRIBUTES (MIDDLE_M3,     MIDDLE_M3_BASE);

     PROCEDURE CHECK_MIDDLE_M15
          IS NEW CHECK_ATTRIBUTES (MIDDLE_M15,    MIDDLE_M15_BASE);

     PROCEDURE CHECK_MIDDLE_M16
          IS NEW CHECK_ATTRIBUTES (MIDDLE_M16,    MIDDLE_M16_BASE);

     PROCEDURE CHECK_ST_LEFT_EDGE_M6
          IS NEW CHECK_ATTRIBUTES (ST_LEFT_EDGE_M6,
                                   MIDDLE_M15_BASE);

     PROCEDURE CHECK_ST_MIDDLE_M14
          IS NEW CHECK_ATTRIBUTES (ST_MIDDLE_M14, MIDDLE_M16_BASE);

BEGIN

     TEST ("C35A06R", "CHECK THAT FOR FIXED POINT TYPES THE " &
                      "SAFE_SMALL AND SAFE_LARGE ATTRIBUTES YIELD " &
                      "APPROPRIATE VALUES - BASIC TYPES, GENERICS " &
                      "MANTISSA VALUES GREATER THAN ONE, DELTA IS " &
                      "POWER OF TWO");

     CHECK_MIDDLE_M2        ("MIDDLE_M2",     MIDDLE_M2'SAFE_SMALL,
                                              MIDDLE_M2'SAFE_LARGE);

     CHECK_MIDDLE_M3        ("MIDDLE_M3",     MIDDLE_M3'SAFE_SMALL,
                                              MIDDLE_M3'SAFE_LARGE);

     CHECK_MIDDLE_M15       ("MIDDLE_M15",    MIDDLE_M15'SAFE_SMALL,
                                              MIDDLE_M15'SAFE_LARGE);

     CHECK_MIDDLE_M16       ("MIDDLE_M16",    MIDDLE_M16'SAFE_SMALL,
                                              MIDDLE_M16'SAFE_LARGE);

     CHECK_ST_LEFT_EDGE_M6  ("ST_LEFT_EDGE_M6",
           ST_LEFT_EDGE_M6'SAFE_SMALL, ST_LEFT_EDGE_M6'SAFE_LARGE);

     CHECK_ST_MIDDLE_M14    ("ST_MIDDLE_M14", ST_MIDDLE_M14'SAFE_SMALL,
                                              ST_MIDDLE_M14'SAFE_LARGE);

     RESULT;

END C35A06R;
