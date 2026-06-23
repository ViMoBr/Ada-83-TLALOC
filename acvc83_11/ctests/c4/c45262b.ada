-- C45262B.ADA

-- CHECK THAT ORDERING COMPARISONS YIELD CORRECT RESULTS FOR
-- ONE-DIMENSIONAL DISCRETE ARRAY TYPES.  THIS TEST CHECKS STRING TYPES.

-- JWC 9/9/85
-- JRK 6/24/86   FIXED SPELLING IN FAILURE MESSAGE.

WITH REPORT; USE REPORT;

PROCEDURE C45262B IS
BEGIN
     TEST ("C45262B", "ORDERING COMPARISONS OF ONE-DIMENSIONAL " &
                      "DISCRETE ARRAY TYPES - TYPE STRING");

     DECLARE

          STRING1 : STRING(2 .. IDENT_INT(1));
          STRING2 : STRING(3 .. IDENT_INT(1));
          STRING3 : STRING(2 .. IDENT_INT(2)) := (IDENT_INT(2) => 'A');
          STRING4 : STRING(1 .. IDENT_INT(1)) := (IDENT_INT(1) => 'A');
          STRING5 : STRING(1 .. IDENT_INT(1)) := (IDENT_INT(1) => 'B');
          STRING6 : STRING(2 .. IDENT_INT(6)) :=
                                             (2 .. IDENT_INT(6) => 'A');
          STRING7 : STRING(1 .. 5) := (1 .. 4 => 'A', 5 => 'B');
          STRING8 : STRING(1 .. IDENT_INT(5)) :=
                                             (1 .. IDENT_INT(5) => 'A');
          STRING9 : STRING(1 .. IDENT_INT(4)) :=
                                             (1 .. IDENT_INT(4) => 'A');
          STRINGA : STRING(1 .. IDENT_INT(4)) :=
                                             (1 .. IDENT_INT(4) => 'B');

     BEGIN
          IF STRING1 < STRING2 THEN
               FAILED ("NULL ARRAYS STRING1 AND STRING2 NOT EQUAL - <");
          END IF;

          IF NOT (STRING1 <= STRING2) THEN
               FAILED ("NULL ARRAYS STRING1 AND STRING2 NOT EQUAL - " &
                       "<=");
          END IF;

          IF STRING1 > STRING2 THEN
               FAILED ("NULL ARRAYS STRING1 AND STRING2 NOT EQUAL - >");
          END IF;

          IF NOT ( ">=" (STRING1, STRING2) ) THEN
               FAILED ("NULL ARRAYS STRING1 AND STRING2 NOT EQUAL - " &
                       ">=");
          END IF;

          IF STRING3 < STRING1 THEN
               FAILED ("NON-NULL ARRAY STRING3 LESS THAN NULL STRING1");
          END IF;

          IF STRING3 <= STRING1 THEN
               FAILED ("NON-NULL ARRAY STRING3 LESS THAN EQUAL NULL " &
                        "STRING1");
          END IF;

          IF NOT ( ">" (STRING3, STRING1) ) THEN
               FAILED ("NON-NULL ARRAY STRING3 NOT GREATER THAN NULL " &
                       "STRING1");
          END IF;

          IF NOT (STRING3 >= STRING1) THEN
               FAILED ("NON-NULL ARRAY STRING3 NOT GREATER THAN " &
                       "EQUAL NULL STRING1");
          END IF;

          IF STRING3 < STRING4 THEN
               FAILED ("DIFFERENT BOUNDS, SAME NUMBER OF COMPONENTS, " &
                       "COMPONENTS EQUAL - <");
          END IF;

          IF NOT ( "<=" (STRING3, STRING4) ) THEN
               FAILED ("DIFFERENT BOUNDS, SAME NUMBER OF COMPONENTS, " &
                       "COMPONENTS EQUAL - <=");
          END IF;

          IF STRING3 > STRING4 THEN
               FAILED ("DIFFERENT BOUNDS, SAME NUMBER OF COMPONENTS, " &
                       "COMPONENTS EQUAL - >");
          END IF;

          IF NOT (STRING3 >= STRING4) THEN
               FAILED ("DIFFERENT BOUNDS, SAME NUMBER OF COMPONENTS, " &
                       "COMPONENTS EQUAL - >=");
          END IF;

          IF NOT ( "<" (STRING3, STRING5) ) THEN
               FAILED ("DIFFERENT BOUNDS, SAME NUMBER OF COMPONENTS, " &
                       "COMPONENTS NOT EQUAL - <");
          END IF;

          IF NOT (STRING3 <= STRING5) THEN
               FAILED ("DIFFERENT BOUNDS, SAME NUMBER OF COMPONENTS, " &
                       "COMPONENTS NOT EQUAL - <=");
          END IF;

          IF STRING3 > STRING5 THEN
               FAILED ("DIFFERENT BOUNDS, SAME NUMBER OF COMPONENTS, " &
                       "COMPONENTS NOT EQUAL - >");
          END IF;

          IF STRING3 >= STRING5 THEN
               FAILED ("DIFFERENT BOUNDS, SAME NUMBER OF COMPONENTS, " &
                       "COMPONENTS NOT EQUAL - >=");
          END IF;

          IF NOT (STRING6 < STRING7) THEN
               FAILED ("DIFFERENT BOUNDS, SAME NUMBER OF COMPONENTS, " &
                       "MULTIPLE COMPONENTS, COMPONENTS NOT EQUAL - <");
          END IF;

          IF NOT (STRING6 <= STRING7) THEN
               FAILED ("DIFFERENT BOUNDS, SAME NUMBER OF COMPONENTS, " &
                       "MULTIPLE COMPONENTS, COMPONENTS NOT EQUAL - " &
                       "<=");
          END IF;

          IF STRING6 > STRING7 THEN
               FAILED ("DIFFERENT BOUNDS, SAME NUMBER OF COMPONENTS, " &
                       "MULTIPLE COMPONENTS, COMPONENTS NOT EQUAL - >");
          END IF;

          IF ">=" (LEFT => STRING6, RIGHT => STRING7) THEN
               FAILED ("DIFFERENT BOUNDS, SAME NUMBER OF COMPONENTS, " &
                       "MULTIPLE COMPONENTS, COMPONENTS NOT EQUAL - " &
                       ">=");
          END IF;

          IF STRING6 < STRING8 THEN
               FAILED ("DIFFERENT BOUNDS, SAME NUMBER OF COMPONENTS, " &
                       "MULTIPLE COMPONENTS, COMPONENTS EQUAL - <");
          END IF;

          IF NOT (STRING6 <= STRING8) THEN
               FAILED ("DIFFERENT BOUNDS, SAME NUMBER OF COMPONENTS, " &
                       "MULTIPLE COMPONENTS, COMPONENTS EQUAL - <=");
          END IF;

          IF ">" (RIGHT => STRING8, LEFT => STRING6) THEN
               FAILED ("DIFFERENT BOUNDS, SAME NUMBER OF COMPONENTS, " &
                       "MULTIPLE COMPONENTS, COMPONENTS EQUAL - >");
          END IF;

          IF NOT (STRING6 >= STRING8) THEN
               FAILED ("DIFFERENT BOUNDS, SAME NUMBER OF COMPONENTS, " &
                       "MULTIPLE COMPONENTS, COMPONENTS EQUAL - >=");
          END IF;

          IF STRING8 < STRING9 THEN
               FAILED ("DIFFERENT NUMBER OF COMPONENTS, " &
                       "COMPONENTS EQUAL - <");
          END IF;

          IF STRING8 <= STRING9 THEN
               FAILED ("DIFFERENT NUMBER OF COMPONENTS, " &
                       "COMPONENTS EQUAL - <=");
          END IF;

          IF NOT (STRING8 > STRING9) THEN
               FAILED ("DIFFERENT NUMBER OF COMPONENTS, " &
                       "COMPONENTS EQUAL - >");
          END IF;

          IF NOT (STRING8 >= STRING9) THEN
               FAILED ("DIFFERENT NUMBER OF COMPONENTS, " &
                       "COMPONENTS EQUAL - >=");
          END IF;

          IF NOT (STRING8 < STRINGA) THEN
               FAILED ("DIFFERENT NUMBER OF COMPONENTS, " &
                       "COMPONENTS NOT EQUAL - <");
          END IF;

          IF NOT (STRING8 <= STRINGA) THEN
               FAILED ("DIFFERENT NUMBER OF COMPONENTS, " &
                       "COMPONENTS NOT EQUAL - <=");
          END IF;

          IF STRING8 > STRINGA THEN
               FAILED ("DIFFERENT NUMBER OF COMPONENTS, " &
                       "COMPONENTS NOT EQUAL - >");
          END IF;

          IF STRING8 >= STRINGA THEN
               FAILED ("DIFFERENT NUMBER OF COMPONENTS, " &
                       "COMPONENTS NOT EQUAL - >=");
          END IF;

     END;

     RESULT;

END C45262B;
