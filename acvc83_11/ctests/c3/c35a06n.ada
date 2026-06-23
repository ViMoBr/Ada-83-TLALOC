-- C35A06N.ADA

-- OBJECTIVE:
--     CHECK THAT FOR FIXED POINT TYPES THE SAFE_SMALL AND SAFE_LARGE
--     ATTRIBUTES YIELD APPROPRIATE VALUES.

--     CASE N: THIS TEST CHECKS BASIC TYPES THAT FIT THE
--     CHARACTERISTICS OF DURATION'BASE, AND THAT HAVE MANTISSA
--     VALUES OF ONE - FOR GENERICS.

-- HISTORY:
--     WRG  8/25/86  CREATED ORIGINAL TEST.
--     RJW 11/13/87  SPLIT THE TEST INTO C35A06N,P,R,S.

WITH REPORT; USE REPORT;
PROCEDURE C35A06N IS

     -- THE NAME OF EACH TYPE OR SUBTYPE ENDS WITH THAT TYPE'S
     -- 'MANTISSA VALUE.

     TYPE LEFT_OUT_M1       IS DELTA 0.25  RANGE -0.5 .. 0.5;
     TYPE LEFT_EDGE_M1      IS DELTA 0.5   RANGE -1.0 .. 1.0;
     TYPE RIGHT_EDGE_M1     IS DELTA 1.0   RANGE -2.0 .. 2.0;
     TYPE RIGHT_OUT_M1      IS DELTA 2.0   RANGE -4.0 .. 4.0;

     -------------------------------------------------------------------

     TYPE LEFT_OUT_M1_BASE       IS DELTA LEFT_OUT_M1'SAFE_SMALL
          RANGE -LEFT_OUT_M1'SAFE_LARGE     .. LEFT_OUT_M1'SAFE_LARGE;

     TYPE LEFT_EDGE_M1_BASE      IS DELTA LEFT_EDGE_M1'SAFE_SMALL
          RANGE -LEFT_EDGE_M1'SAFE_LARGE    .. LEFT_EDGE_M1'SAFE_LARGE;

     TYPE RIGHT_EDGE_M1_BASE     IS DELTA RIGHT_EDGE_M1'SAFE_SMALL
          RANGE -RIGHT_EDGE_M1'SAFE_LARGE   .. RIGHT_EDGE_M1'SAFE_LARGE;

     TYPE RIGHT_OUT_M1_BASE      IS DELTA RIGHT_OUT_M1'SAFE_SMALL
          RANGE -RIGHT_OUT_M1'SAFE_LARGE    .. RIGHT_OUT_M1'SAFE_LARGE;

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

     PROCEDURE CHECK_LEFT_OUT_M1
          IS NEW CHECK_ATTRIBUTES (LEFT_OUT_M1,   LEFT_OUT_M1_BASE);

     PROCEDURE CHECK_LEFT_EDGE_M1
          IS NEW CHECK_ATTRIBUTES (LEFT_EDGE_M1,  LEFT_EDGE_M1_BASE);

     PROCEDURE CHECK_RIGHT_EDGE_M1
          IS NEW CHECK_ATTRIBUTES (RIGHT_EDGE_M1, RIGHT_EDGE_M1_BASE);

     PROCEDURE CHECK_RIGHT_OUT_M1
          IS NEW CHECK_ATTRIBUTES (RIGHT_OUT_M1,  RIGHT_OUT_M1_BASE);

BEGIN

     TEST ("C35A06N", "CHECK THAT FOR FIXED POINT TYPES THE " &
                      "SAFE_SMALL AND SAFE_LARGE ATTRIBUTES YIELD " &
                      "APPROPRIATE VALUES - BASIC TYPES, GENERICS, " &
                      "MANTISSA VALUES OF ONE");

     CHECK_LEFT_OUT_M1      ("LEFT_OUT_M1",   LEFT_OUT_M1'SAFE_SMALL,
                                              LEFT_OUT_M1'SAFE_LARGE);

     CHECK_LEFT_EDGE_M1     ("LEFT_EDGE_M1",  LEFT_EDGE_M1'SAFE_SMALL,
                                              LEFT_EDGE_M1'SAFE_LARGE);

     CHECK_RIGHT_EDGE_M1    ("RIGHT_EDGE_M1", RIGHT_EDGE_M1'SAFE_SMALL,
                                              RIGHT_EDGE_M1'SAFE_LARGE);

     CHECK_RIGHT_OUT_M1     ("RIGHT_OUT_M1",  RIGHT_OUT_M1'SAFE_SMALL,
                                              RIGHT_OUT_M1'SAFE_LARGE);
     RESULT;

END C35A06N;
