-- C35505B.ADA

-- OBJECTIVE:
--     CHECK THAT CONSTRAINT_ERROR IS RAISED FOR 'SUCC AND 'PRED,
--     IF THE RESULT WOULD BE OUTSIDE THE RANGE OF THE BASE TYPE,
--     FOR TYPE INTEGER.

-- HISTORY:
--     DAT 03/30/81  CREATED ORIGINAL TEST.
--     JET 01/05/88  MODIFIED HEADER FORMAT AND ADDED CODE TO
--                   PREVENT OPTIMIZATION.

WITH REPORT; USE REPORT;

PROCEDURE C35505B IS

     SUBTYPE I IS INTEGER RANGE 0 .. 0;

     J : INTEGER;

BEGIN
     TEST ("C35505B", "CHECK THAT CONSTRAINT_ERROR IS RAISED FOR " &
          "INTEGER'SUCC(INTEGER'LAST), INTEGER'PRED(INTEGER'FIRST), " &
          "AND ALSO FOR SUBTYPE OF INTEGER");

     BEGIN
          DECLARE
               J : CONSTANT INTEGER := INTEGER'SUCC(INTEGER'LAST);
          BEGIN
               FAILED ("CONSTRAINT_ERROR NOT RAISED FOR INTEGER'SUCC");

               IF EQUAL (J,J) THEN
                    COMMENT ("NO EXCEPTION RAISED");
               END IF;

          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED AT WRONG PLACE -- 1");
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- 1");
     END;

     BEGIN
          DECLARE
               J : CONSTANT INTEGER := INTEGER'PRED(INTEGER'FIRST);
          BEGIN
               FAILED ("CONSTRAINT_ERROR NOT RAISED FOR INTEGER'PRED");

               IF EQUAL (J,J) THEN
                    COMMENT ("NO EXCEPTION RAISED");
               END IF;

          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED AT WRONG PLACE -- 2");
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- 2");
     END;

     BEGIN
          DECLARE
               J : CONSTANT INTEGER := I'SUCC(INTEGER'LAST);
          BEGIN
               FAILED ("CONSTRAINT_ERROR NOT RAISED FOR I'SUCC");

               IF EQUAL (J,J) THEN
                    COMMENT ("NO EXCEPTION RAISED");
               END IF;

          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED AT WRONG PLACE -- 3");
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- 3");
     END;

     BEGIN
          DECLARE
               J : CONSTANT INTEGER := I'PRED(INTEGER'FIRST);
          BEGIN
               FAILED ("CONSTRAINT_ERROR NOT RAISED FOR I'PRED");

               IF EQUAL (J,J) THEN
                    COMMENT ("NO EXCEPTION RAISED");
               END IF;

          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED AT WRONG PLACE -- 4");
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED -- 4");
     END;

     RESULT;

END C35505B;
