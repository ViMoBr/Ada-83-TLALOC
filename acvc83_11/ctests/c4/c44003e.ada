-- C44003E.ADA

-- OBJECTIVE:
--     CHECK FOR CORRECT PRECEDENCE OF PREDEFINED AND OVERLOADED
--     OPERATIONS ON PREDEFINED AND USER-DEFINED FIXED POINT TYPES, AND
--     ONE-DIMENSIONAL ARRAYS WITH COMPONENTS OF FIXED POINT TYPES.

-- HISTORY:
--     RJW 10/13/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE C44003E IS

BEGIN
     TEST ("C44003E", "CHECK FOR CORRECT PRECEDENCE OF PREDEFINED " &
                      "AND OVERLOADED OPERATIONS ON PREDEFINED AND " &
                      "USER-DEFINED FIXED POINT TYPES, AND ONE-" &
                      "DIMENSIONAL ARRAYS WITH COMPONENTS OF FIXED " &
                      "POINT TYPES");

----- PREDEFINED FIXED:

     DECLARE
          D1 : DURATION := 1.0;
          D2 : DURATION := 2.0;
          D5 : DURATION := 5.0;

          FUNCTION "OR" (LEFT, RIGHT : DURATION) RETURN DURATION IS
          BEGIN
               RETURN 4.5;
          END "OR";

          FUNCTION "<" (LEFT, RIGHT : DURATION) RETURN DURATION IS
          BEGIN
               RETURN 5.5;
          END "<";

          FUNCTION "-" (LEFT, RIGHT : DURATION) RETURN DURATION IS
          BEGIN
               RETURN 6.5;
          END "-";

          FUNCTION "+" (RIGHT : DURATION) RETURN DURATION IS
          BEGIN
               RETURN 7.5;
          END "+";

          FUNCTION "*" (LEFT, RIGHT : DURATION) RETURN DURATION IS
          BEGIN
               RETURN 8.5;
          END "*";

          FUNCTION "NOT" (RIGHT : DURATION) RETURN DURATION IS
          BEGIN
               RETURN 9.5;
          END "NOT";

          FUNCTION "**" (LEFT : DURATION; RIGHT : INTEGER)
                     RETURN DURATION IS
          BEGIN
               RETURN DURATION (FLOAT (LEFT) ** RIGHT);
          END "**";

     BEGIN
          IF NOT (-ABS D1 + D2 * D1 + D5 ** 2 =  32.5 AND
                  D1 > 0.0 AND
                  - D2 * D2 ** 3 = -8.5) THEN
               FAILED ("INCORRECT RESULT - 1");
          END IF;

          IF (D1 OR NOT D2 < D1 - D5 * D5 ** 3) /= 4.5 OR
              DURATION (D1 * 2) > 2.0 OR DURATION (D1 * 2) < 2.0 THEN
               FAILED ("INCORRECT RESULT - 2");
          END IF;
     END;

----- USER-DEFINED TYPE:

     DECLARE
          TYPE USR IS DELTA 2#0.001# RANGE -100.0 .. 100.0;

          D1 : USR := 1.0;
          D2 : USR := 2.0;
          D5 : USR := 5.0;

          FUNCTION "AND" (LEFT, RIGHT : USR) RETURN USR IS
          BEGIN
               RETURN 4.5;
          END "AND";

          FUNCTION ">=" (LEFT, RIGHT : USR) RETURN USR IS
          BEGIN
               RETURN 5.5;
          END ">=";

          FUNCTION "+" (LEFT, RIGHT : USR) RETURN USR IS
          BEGIN
               RETURN 6.5;
          END "+";

          FUNCTION "-" (RIGHT : USR) RETURN USR IS
          BEGIN
               RETURN 7.5;
          END "-";

          FUNCTION "/" (LEFT, RIGHT : USR) RETURN USR IS
          BEGIN
               RETURN 8.5;
          END "/";

          FUNCTION "**" (LEFT, RIGHT : USR) RETURN USR IS
          BEGIN
               RETURN 9.5;
          END "**";

          FUNCTION "**" (LEFT : USR; RIGHT : INTEGER)
                     RETURN USR IS
          BEGIN
               RETURN USR (FLOAT (LEFT) ** RIGHT);
          END "**";

     BEGIN
          IF +D5 - D2 / D1 ** 2 /= -3.5 - 11.0 OR
             ABS D1 <= 0.0 OR
             - D2 / D2 ** 3 /= 7.5 THEN
               FAILED ("INCORRECT RESULT - 3");
          END IF;

          IF (D1 AND D2 >= D1 + D5 / D1 ** 3) /= 4.5 THEN
               FAILED ("INCORRECT RESULT - 4");
          END IF;
     END;

----- ARRAYS:

     DECLARE
          TYPE ARR IS ARRAY (INTEGER RANGE <>) OF DURATION;

          SUBTYPE SARR IS ARR (1 .. 3);

          D1 : SARR := (OTHERS => 1.0);
          D2 : SARR := (OTHERS => 2.0);
          D5 : SARR := (OTHERS => 5.0);

          FUNCTION "XOR" (LEFT, RIGHT : ARR) RETURN ARR IS
          BEGIN
               RETURN (1 .. 3 => 4.5);
          END "XOR";

          FUNCTION "<=" (LEFT, RIGHT : ARR) RETURN ARR IS
          BEGIN
               RETURN (1 .. 3 => 5.5);
          END "<=";

          FUNCTION "&" (LEFT, RIGHT : ARR) RETURN ARR IS
          BEGIN
               RETURN (1 .. 3 => 6.5);
          END "&";

          FUNCTION "MOD" (LEFT, RIGHT : ARR) RETURN ARR IS
          BEGIN
               RETURN (1 .. 3 => 8.5);
          END "MOD";

          FUNCTION "ABS" (RIGHT : ARR) RETURN ARR IS
          BEGIN
               RETURN (1 .. 3 => 9.5);
          END "ABS";
     BEGIN
          IF (ABS D1 <= D2 & D5 MOD D1 XOR D1) /= (1 .. 3 => 4.5) THEN
               FAILED ("INCORRECT RESULT - 5");
          END IF;

          IF (ABS D1 & D2) /= (1 .. 3 => 6.5) OR
             (D1 MOD D2 <= D5) /= (1 .. 3 => 5.5) THEN
               FAILED ("INCORRECT RESULT - 6");
          END IF;
     END;

     RESULT;
END C44003E;
