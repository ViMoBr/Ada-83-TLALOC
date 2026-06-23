-- C44003A.ADA

-- OBJECTIVE:
--     CHECK FOR CORRECT PRECEDENCE OF PREDEFINED AND OVERLOADED
--     OPERATIONS ON PREDEFINED INTEGER, USER-DEFINED TYPES, AND
--     ONE-DIMENSIONAL ARRAYS WITH COMPONENTS OF INTEGER TYPES.

-- HISTORY:
--     RJW 10/13/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE C44003A IS

BEGIN
     TEST ("C44003A", "CHECK FOR CORRECT PRECEDENCE OF PREDEFINED " &
                      "AND OVERLOADED OPERATIONS ON PREDEFINED " &
                      "INTEGER, USER-DEFINED TYPES, AND ONE-DIMEN" &
                      "SIONAL ARRAYS WITH COMPONENTS OF INTEGER TYPES");

----- PREDEFINED INTEGER:

     DECLARE
          I1 : INTEGER := 1;
          I2 : INTEGER := 2;
          I5 : INTEGER := 5;

          FUNCTION "OR" (LEFT, RIGHT : INTEGER) RETURN INTEGER IS
          BEGIN
               RETURN 6;
          END "OR";

          FUNCTION "<" (LEFT, RIGHT : INTEGER) RETURN INTEGER IS
          BEGIN
               RETURN 7;
          END "<";

          FUNCTION "-" (LEFT, RIGHT : INTEGER) RETURN INTEGER IS
          BEGIN
               RETURN 8;
          END "-";

          FUNCTION "+" (RIGHT : INTEGER) RETURN INTEGER IS
          BEGIN
               RETURN 9;
          END "+";

          FUNCTION "*" (LEFT, RIGHT : INTEGER) RETURN INTEGER IS
          BEGIN
               RETURN 10;
          END "*";

          FUNCTION "NOT" (RIGHT : INTEGER) RETURN INTEGER IS
          BEGIN
               RETURN 11;
          END "NOT";

     BEGIN
          IF NOT (-ABS I1 + I2 / I1 + I5 ** 2 =  26 AND
                  I1 > 0 AND
                  - I2 * I2 ** 3 = -10) THEN
               FAILED ("INCORRECT RESULT - 1");
          END IF;

          IF (I1 OR NOT I2 < I1 - I5 * I5 ** 3) /= 6 THEN
               FAILED ("INCORRECT RESULT - 2");
          END IF;
     END;

----- USER-DEFINED TYPE:

     DECLARE

          TYPE INT IS RANGE -100..100;

          I1 : INT := 1;
          I2 : INT := 2;
          I5 : INT := 5;

          FUNCTION "AND" (LEFT, RIGHT : INT) RETURN INT IS
          BEGIN
               RETURN 6;
          END "AND";

          FUNCTION ">=" (LEFT, RIGHT : INT) RETURN INT IS
          BEGIN
               RETURN 7;
          END ">=";

          FUNCTION "&" (LEFT, RIGHT : INT) RETURN INT IS
          BEGIN
               RETURN 8;
          END "&";

          FUNCTION "-" (RIGHT : INT) RETURN INT IS
          BEGIN
               RETURN 9;
          END "-";

          FUNCTION "/" (LEFT, RIGHT : INT) RETURN INT IS
          BEGIN
               RETURN 10;
          END "/";

          FUNCTION "ABS" (RIGHT : INT) RETURN INT IS
          BEGIN
               RETURN 11;
          END "ABS";
     BEGIN
          IF ABS I5 - I2 * I1 ** 2 /= 9 OR
             I5 & I1 <= 0 OR
             - I2 * I2 ** 3 /= 9 THEN
               FAILED ("INCORRECT RESULT - 3");
          END IF;

          IF (I1 AND I2 >= I1 + I5 / I2 ** 3) /= 6 THEN
               FAILED ("INCORRECT RESULT - 4");
          END IF;
     END;

----- ARRAYS:

     DECLARE
          TYPE ARR IS ARRAY (INTEGER RANGE <>) OF INTEGER;

          SUBTYPE SARR IS ARR (1 .. 3);

          I1 : SARR := (OTHERS => 1);
          I2 : SARR := (OTHERS => 2);
          I5 : SARR := (OTHERS => 5);

          FUNCTION "XOR" (LEFT, RIGHT : ARR) RETURN ARR IS
          BEGIN
               RETURN (1 .. 3 => 6);
          END "XOR";

          FUNCTION "<=" (LEFT, RIGHT : ARR) RETURN ARR IS
          BEGIN
               RETURN (1 .. 3 => 7);
          END "<=";

          FUNCTION "+" (LEFT, RIGHT : ARR) RETURN ARR IS
          BEGIN
               RETURN (1 .. 3 => 8);
          END "+";

          FUNCTION "MOD" (LEFT, RIGHT : ARR) RETURN ARR IS
          BEGIN
               RETURN (1 .. 3 => 9);
          END "MOD";

          FUNCTION "**" (LEFT, RIGHT : ARR) RETURN ARR IS
          BEGIN
               RETURN (1 .. 3 => 10);
          END "**";
     BEGIN
          IF (I5 ** I1 <= I2 + I5 MOD I1 XOR I1) /= (1 .. 3 => 6) THEN
               FAILED ("INCORRECT RESULT - 5");
          END IF;

          IF (I5 ** I1 & I2) /= (10, 10, 10, 2, 2, 2) OR
             (I1 MOD I2 <= I5) /= (1 .. 3 => 7) THEN
               FAILED ("INCORRECT RESULT - 6");
          END IF;
     END;

     RESULT;

END C44003A;
