-- C36104A.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED OR NOT, AS APPROPRIATE,
-- DURING DISCRETE_RANGE ELABORATIONS/EVALUATIONS IN LOOPS,
-- ARRAY_TYPE_DEFINITIONS, ARRAY AGGREGATES, SLICES,
-- AND INDEX CONSTRAINTS IN OBJECT AND TYPE DECLARATIONS,
-- WHERE AN EXPLICIT (SUB)TYPE IS INCLUDED IN EACH DISCRETE_RANGE.
-- MEMBERSHIP OPERATORS ARE CHECKED HERE, ALSO, TO ENSURE THAT
-- EXCEPTIONS ARE NOT RAISED FOR NULL RANGES.
-- ONLY STATIC CASES ARE CHECKED HERE.

-- DAT 2/3/81
-- JRK 2/25/81
-- VKG 1/21/83
-- L.BROWN  7/15/86  1) ADDED ACCESS TYPES.
--                   2) DELETED "NULL INDEX RANGES, CONSTRAINT_ERROR 
--                      RAISED" SECTION.
--                   3) DELETED ANY MENTION OF CASE STATEMENT CHOICES
--                      AND VARIANT CHOICES IN THE ABOVE COMMENT.

WITH REPORT;
PROCEDURE C36104A IS

     USE REPORT;

     TYPE WEEK IS (SUN, MON, TUE, WED, THU, FRI, SAT);
     TYPE WEEK_ARRAY IS ARRAY (WEEK RANGE <>) OF WEEK;
     SUBTYPE WORK_WEEK IS WEEK RANGE MON .. FRI;
     SUBTYPE MID_WEEK IS WORK_WEEK RANGE TUE .. THU;

     TYPE INT_10 IS NEW INTEGER RANGE -10 .. 10;
     TYPE I_10 IS NEW INT_10;
     SUBTYPE I_5 IS I_10 RANGE -5 .. 5;
     TYPE I_5_ARRAY IS ARRAY (I_5 RANGE <>) OF I_5;

BEGIN
     TEST ("C36104A", "CONSTRAINT_ERROR IS RAISED OR NOT IN STATIC "
          & "DISCRETE_RANGES WITH EXPLICIT TYPE_MARKS");

     -- NON-NULL RANGES, CONSTRAINT_ERROR RAISED.

     BEGIN
          DECLARE
               TYPE A IS ARRAY (I_5 RANGE 0 .. 6) OF I_5;
               -- ABOVE DECLARATION RAISES CONSTRAINT_ERROR.
          BEGIN
               FAILED ("CONSTRAINT_ERROR NOT RAISED 1");
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR => NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED 1");
     END;

     BEGIN
          FOR I IN MID_WEEK RANGE MON .. MON LOOP
               NULL;
          END LOOP;
          FAILED ("CONSTRAINT_ERROR NOT RAISED 3");
     EXCEPTION
          WHEN CONSTRAINT_ERROR => NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED 3");
     END;

     BEGIN
          DECLARE
               TYPE P IS ACCESS I_5_ARRAY (I_5 RANGE 0 .. 6);
               -- ABOVE DECLARATION RAISES CONSTRAINT_ERROR.
          BEGIN
               FAILED ("CONSTRAINT_ERROR NOT RAISED 4");
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR => NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED 4");
     END;

     DECLARE
          W : WEEK_ARRAY (MID_WEEK);
     BEGIN
          W := (MID_WEEK RANGE MON .. WED => WED);
          -- CONSTRAINT_ERROR RAISED.
          FAILED ("CONSTRAINT_ERROR NOT RAISED 7");
     EXCEPTION
          WHEN CONSTRAINT_ERROR => NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED 7");
     END;

     DECLARE
          W : WEEK_ARRAY (WORK_WEEK);
     BEGIN
          W := (W'RANGE => WED); -- OK.
          W (MON .. WED) := W (MID_WEEK RANGE MON .. WED); -- EXCEPTION.
          FAILED ("CONSTRAINT_ERROR NOT RAISED 8");
     EXCEPTION
          WHEN CONSTRAINT_ERROR => NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED 8");
     END;

     BEGIN
          DECLARE
               W : WEEK_ARRAY (MID_WEEK RANGE MON .. FRI);
               -- ELABORATION OF ABOVE RAISES CONSTRAINT_ERROR.
          BEGIN
               FAILED ("CONSTRAINT_ERROR NOT RAISED 9");
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR => NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED 9");
     END;

     BEGIN
          DECLARE
               TYPE W IS NEW WEEK_ARRAY (MID_WEEK RANGE SUN .. TUE);
               -- RAISES CONSTRAINT_ERROR.
          BEGIN
               FAILED ("CONSTRAINT_ERROR NOT RAISED 10");
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR => NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED 10");
     END;

     BEGIN
          DECLARE
               SUBTYPE W IS WEEK_ARRAY (MID_WEEK RANGE MON .. WED);
               -- RAISES CONSTRAINT_ERROR.
          BEGIN
               FAILED ("CONSTRAINT_ERROR NOT RAISED 11");
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR => NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED 11");
     END;

     -- NULL DISCRETE/INDEX RANGES, EXCEPTION NOT RAISED.

     BEGIN
          DECLARE
               TYPE A IS ARRAY (I_5 RANGE -5 .. -6) OF I_5;
          BEGIN
               NULL;
          END;
     EXCEPTION
          WHEN OTHERS => FAILED ("EXCEPTION RAISED 1");
     END;

     BEGIN
          FOR I IN MID_WEEK RANGE SAT .. SUN LOOP
               NULL;
          END LOOP;
          FOR I IN MID_WEEK RANGE FRI .. WED LOOP
               NULL;
          END LOOP;
          FOR I IN MID_WEEK RANGE MON .. SUN LOOP
               NULL;
          END LOOP;
          FOR I IN I_5 RANGE 10 .. -10 LOOP
               NULL;
          END LOOP;
          FOR I IN I_5 RANGE 10 .. 9 LOOP
               NULL;
          END LOOP;
          FOR I IN I_5 RANGE -10 .. -11 LOOP
               NULL;
          END LOOP;
          FOR I IN I_5 RANGE -10 .. -20 LOOP
               NULL;
          END LOOP;
          FOR I IN I_5 RANGE 6 .. 5 LOOP
               NULL;
          END LOOP;
     EXCEPTION
          WHEN OTHERS => FAILED ("EXCEPTION RAISED 3");
     END;

     BEGIN
          DECLARE
               TYPE P IS ACCESS I_5_ARRAY (-5 .. -6);
          BEGIN
               NULL;
          END;
     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED 5");
     END;

     DECLARE
          TYPE NARR IS ARRAY(INTEGER RANGE <>) OF INTEGER;
          SUBTYPE SNARR IS INTEGER RANGE 1 .. 2;
          W : NARR(SNARR) := (1,2);
     BEGIN
          IF W = (SNARR RANGE 4 .. 2 => 5) THEN
               FAILED("EVALUATION OF EXPRESSION IS INCORRECT");
          END IF;
     EXCEPTION
          WHEN OTHERS => FAILED ("EXCEPTION RAISED 7");
     END;

     DECLARE
          W : WEEK_ARRAY (MID_WEEK);
     BEGIN
          W := (W'RANGE => WED); -- OK.
          W (TUE .. MON) := W (MID_WEEK RANGE MON .. SUN);
     EXCEPTION
          WHEN OTHERS => FAILED ("EXCEPTION RAISED 8");
     END;

     BEGIN
          DECLARE
               W : WEEK_ARRAY (MID_WEEK RANGE MON .. SUN);
          BEGIN
               NULL;
          END;
     EXCEPTION
          WHEN OTHERS => FAILED ("EXCEPTION RAISED 9");
     END;

     BEGIN
          DECLARE
               TYPE W IS NEW WEEK_ARRAY (MID_WEEK RANGE TUE .. MON);
          BEGIN
               NULL;
          END;
     EXCEPTION
          WHEN OTHERS => FAILED ("EXCEPTION RAISED 10");
     END;

     BEGIN
          DECLARE
               SUBTYPE W IS WEEK_ARRAY (MID_WEEK RANGE TUE .. MON);
          BEGIN
               NULL;
          END;
     EXCEPTION
          WHEN OTHERS => FAILED ("EXCEPTION RAISED 12");
     END;

     -- NULL MEMBERSHIP RANGES, EXCEPTION NOT RAISED.

     BEGIN
          IF SUN IN  SAT .. SUN
          OR SAT IN  FRI .. WED
          OR WED IN  THU .. TUE
          OR THU IN  MON .. SUN
          OR FRI IN  SAT .. FRI
          OR WED IN  FRI .. MON
          THEN
               FAILED ("INCORRECT 'IN' EVALUATION 1");
          END IF;

          IF INTEGER'(0) IN  10 .. -10
          OR INTEGER'(0) IN  10 .. 9
          OR INTEGER'(0) IN  -10 .. -11
          OR INTEGER'(0) IN  -10 .. -20 
          OR INTEGER'(0) IN  6 .. 5
          OR INTEGER'(0) IN  5 .. 3
          OR INTEGER'(0) IN  7 .. 3
          THEN
               FAILED ("INCORRECT 'IN' EVALUATION 2");
          END IF;

          IF WED NOT IN  THU .. TUE
          AND INTEGER'(0) NOT IN  4 .. -4
          THEN NULL;
          ELSE FAILED ("INCORRECT 'NOT IN' EVALUATION");
          END IF;
     EXCEPTION
          WHEN OTHERS => FAILED ("EXCEPTION RAISED 52");
     END;


     RESULT;
END C36104A;
