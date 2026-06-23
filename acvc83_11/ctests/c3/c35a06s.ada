-- C35A06S.ADA

-- OBJECTIVE:
--     CHECK THAT FOR FIXED POINT TYPES THE SAFE_SMALL AND SAFE_LARGE
--     ATTRIBUTES YIELD APPROPRIATE VALUES.

--     CASE S: THIS TEST CHECKS BASIC TYPES THAT FIT THE
--     CHARACTERISTICS OF DURATION'BASE, AND WHICH HAVE DECIMAL VALUES
--     FOR DELTAS AND FOR BOUNDS, FOR GENERICS.

-- HISTORY:
--     RJW 11/13/87  CREATED ORIGINAL TEST FROM SPLIT OF C35A03N.

WITH REPORT; USE REPORT;
PROCEDURE C35A06S IS

     -- THE NAME OF EACH TYPE OR SUBTYPE ENDS WITH THAT TYPE'S
     -- 'MANTISSA VALUE.

     TYPE DECIMAL_M18       IS DELTA 0.1   RANGE -10_000.0 .. 10_000.0;
     TYPE DECIMAL_M4        IS DELTA 100.0 RANGE   -1000.0 ..   1000.0;

     -------------------------------------------------------------------

     TYPE DECIMAL_M18_BASE       IS DELTA DECIMAL_M18'SAFE_SMALL
          RANGE -DECIMAL_M18'SAFE_LARGE     .. DECIMAL_M18'SAFE_LARGE;

     TYPE DECIMAL_M4_BASE        IS DELTA DECIMAL_M4'SAFE_SMALL
          RANGE -DECIMAL_M4'SAFE_LARGE      .. DECIMAL_M4'SAFE_LARGE;

     -------------------------------------------------------------------

     SUBTYPE ST_DECIMAL_M7   IS DECIMAL_M18
          DELTA  10.0 RANGE -1000.0 .. 1000.0;

     SUBTYPE ST_DECIMAL_M3   IS DECIMAL_M4
          DELTA 100.0 RANGE  -500.0 ..  500.0;

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

     PROCEDURE CHECK_DECIMAL_M18
          IS NEW CHECK_ATTRIBUTES (DECIMAL_M18,   DECIMAL_M18_BASE);

     PROCEDURE CHECK_DECIMAL_M4
          IS NEW CHECK_ATTRIBUTES (DECIMAL_M4,    DECIMAL_M4_BASE);

     PROCEDURE CHECK_ST_DECIMAL_M7
          IS NEW CHECK_ATTRIBUTES (ST_DECIMAL_M7, DECIMAL_M18_BASE);

     PROCEDURE CHECK_ST_DECIMAL_M3
          IS NEW CHECK_ATTRIBUTES (ST_DECIMAL_M3, DECIMAL_M4_BASE);

BEGIN

     TEST ("C35A06S", "CHECK THAT FOR FIXED POINT TYPES THE " &
                      "SAFE_SMALL AND SAFE_LARGE ATTRIBUTES YIELD " &
                      "APPROPRIATE VALUES - BASIC TYPES, DECIMAL " &
                      "TYPES, GENERICS");

     CHECK_DECIMAL_M18      ("DECIMAL_M18",   DECIMAL_M18'SAFE_SMALL,
                                              DECIMAL_M18'SAFE_LARGE);

     CHECK_DECIMAL_M4       ("DECIMAL_M4",    DECIMAL_M4'SAFE_SMALL,
                                              DECIMAL_M4'SAFE_LARGE);

     CHECK_ST_DECIMAL_M7    ("ST_DECIMAL_M7", ST_DECIMAL_M7'SAFE_SMALL,
                                              ST_DECIMAL_M7'SAFE_LARGE);

     CHECK_ST_DECIMAL_M3    ("ST_DECIMAL_M3", ST_DECIMAL_M3'SAFE_SMALL,
                                              ST_DECIMAL_M3'SAFE_LARGE);

     RESULT;

END C35A06S;
