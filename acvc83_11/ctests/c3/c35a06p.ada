-- C35A06P.ADA

-- OBJECTIVE:
--     CHECK THAT FOR FIXED POINT TYPES THE SAFE_SMALL AND SAFE_LARGE
--     ATTRIBUTES YIELD APPROPRIATE VALUES.

--     CASE P: THIS TEST CHECKS A BASIC TYPE THAT FITS THE
--     CHARACTERISTICS OF DURATION, FOR GENERICS.

-- HISTORY:
--     RJW 11/13/87  CREATED ORIGINAL TEST FROM SPLIT OF C35A06N.

WITH REPORT; USE REPORT;
PROCEDURE C35A06P IS

     -- THE NAME OF EACH TYPE OR SUBTYPE ENDS WITH THAT TYPE'S
     -- 'MANTISSA VALUE.

     TYPE LIKE_DURATION_M23 IS DELTA 0.020 RANGE -86_400.0 .. 86_400.0;

     -------------------------------------------------------------------

     TYPE LIKE_DURATION_M23_BASE IS DELTA LIKE_DURATION_M23'SAFE_SMALL
          RANGE -LIKE_DURATION_M23'SAFE_LARGE ..
                 LIKE_DURATION_M23'SAFE_LARGE;

     -------------------------------------------------------------------

     SUBTYPE ST_MIDDLE_M2    IS LIKE_DURATION_M23
          DELTA 0.5 RANGE -2.0 .. 2.0;

     SUBTYPE ST_MIDDLE_M3    IS LIKE_DURATION_M23
          DELTA 0.5 RANGE  0.0 .. 2.5;

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

     PROCEDURE CHECK_LIKE_DURATION_M23
          IS NEW CHECK_ATTRIBUTES (LIKE_DURATION_M23,
                                   LIKE_DURATION_M23_BASE);

     PROCEDURE CHECK_ST_MIDDLE_M2
          IS NEW CHECK_ATTRIBUTES (ST_MIDDLE_M2,
                                   LIKE_DURATION_M23_BASE);

     PROCEDURE CHECK_ST_MIDDLE_M3
          IS NEW CHECK_ATTRIBUTES (ST_MIDDLE_M3,
                                   LIKE_DURATION_M23_BASE);

BEGIN

     TEST ("C35A06P", "CHECK THAT FOR FIXED POINT TYPES THE " &
                      "SAFE_SMALL AND SAFE_LARGE ATTRIBUTES YIELD " &
                      "APPROPRIATE VALUES - A BASIC DURATION-LIKE " &
                      "TYPE, GENERICS");

     CHECK_LIKE_DURATION_M23("LIKE_DURATION_M23",
           LIKE_DURATION_M23'SAFE_SMALL, LIKE_DURATION_M23'SAFE_LARGE);

     CHECK_ST_MIDDLE_M2     ("ST_MIDDLE_M2",  ST_MIDDLE_M2'SAFE_SMALL,
                                              ST_MIDDLE_M2'SAFE_LARGE);

     CHECK_ST_MIDDLE_M3     ("ST_MIDDLE_M3",  ST_MIDDLE_M3'SAFE_SMALL,
                                              ST_MIDDLE_M3'SAFE_LARGE);

     RESULT;

END C35A06P;
