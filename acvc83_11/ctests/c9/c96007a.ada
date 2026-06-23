-- C96007A.ADA

-- CHECK THAT APPROPRIATE EXCEPTIONS ARE RAISED FOR THE TIME_OF()
-- FUNCTION IN THE PACKAGE CALENDAR. PARTICULARLY,
--   (A) TIME_ERROR IS RAISED ON INVALID DATES.
--   (B) CONSTRAINT_ERROR IS RAISED FOR OUT-OF-RANGE PARAMETERS.

-- CPP 8/16/84

WITH CALENDAR;  USE CALENDAR;
WITH REPORT;  USE REPORT;
PROCEDURE C96007A IS

BEGIN
     TEST ("C96007A", "CHECK THAT APPROPRIATE EXCEPTIONS ARE RAISED " &
           "FOR THE TIME_OF FUNCTION IN THE PACKAGE CALENDAR");

     --------------------------------------------

     DECLARE   -- (A)

          BAD_TIME : TIME;

     BEGIN     -- (A)

          BEGIN
               BAD_TIME := TIME_OF (1984, 2, 30);
               FAILED ("EXCEPTION NOT RAISED - 2/30 (A)");
          EXCEPTION
               WHEN TIME_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - 2/30 (A)");
          END;

          BEGIN
               BAD_TIME := TIME_OF (1984, 2, 31);
               FAILED ("EXCEPTION NOT RAISED - 2/31 (A)");
          EXCEPTION
               WHEN TIME_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - 2/31 (A)");
          END;

          BEGIN
               BAD_TIME := TIME_OF (1984, 4, 31);
               FAILED ("EXCEPTION NOT RAISED - 4/31 (A)");
          EXCEPTION
               WHEN TIME_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - 4/31 (A)");
          END;

          BEGIN
               BAD_TIME := TIME_OF (1984, 6, 31);
               FAILED ("EXCEPTION NOT RAISED - 6/31 (A)");
          EXCEPTION
               WHEN TIME_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - 6/31 (A)");
          END;

          BEGIN
               BAD_TIME := TIME_OF (1984, 9, 31);
               FAILED ("EXCEPTION NOT RAISED - 9/31 (A)");
          EXCEPTION
               WHEN TIME_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - 9/31 (A)");
          END;

          BEGIN
               BAD_TIME := TIME_OF (1984, 11, 31);
               FAILED ("EXCEPTION NOT RAISED - 11/31 (A)");
          EXCEPTION
               WHEN TIME_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - 11/31 (A)");
          END;

          BEGIN
               BAD_TIME := TIME_OF (1983, 2, 29);
               FAILED ("EXCEPTION NOT RAISED - 2/29 (A)");
          EXCEPTION
               WHEN TIME_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - 2/29 (A)");
          END;

     END; -- (A)

     --------------------------------------------

     DECLARE   -- (B)

          BAD_TIME : TIME;

     BEGIN     -- (B)

          BEGIN
               BAD_TIME := TIME_OF (1900, 8, 13);
               FAILED ("EXCEPTION NOT RAISED - 1900 (B)");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - 1900 (B)");
          END;

          BEGIN
               BAD_TIME := TIME_OF (2100, 8, 13);
               FAILED ("EXCEPTION NOT RAISED - 2100 (B)");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - 2100 (B)");
          END;

          BEGIN
               BAD_TIME := TIME_OF (1984, 0, 13);
               FAILED ("EXCEPTION NOT RAISED - MONTH (B)1");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - MONTH (B)1");
          END;

          BEGIN
               BAD_TIME := TIME_OF (1984, 13, 13);
               FAILED ("EXCEPTION NOT RAISED - MONTH (B)2");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - MONTH (B)2");
          END;

          BEGIN
               BAD_TIME := TIME_OF (1984, 8, 0);
               FAILED ("EXCEPTION NOT RAISED - DAY (B)1");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - DAY (B)1");
          END;

          BEGIN
               BAD_TIME := TIME_OF (19784, 8, 32);
               FAILED ("EXCEPTION NOT RAISED - DAY (B)2");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - DAY (B)2");
          END;

          BEGIN
               BAD_TIME := TIME_OF (1984, 8, 13, -0.5);
               FAILED ("EXCEPTION NOT RAISED - SECONDS (B)1");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - SECONDS (B)1");
          END;

     END; -- (B)

     --------------------------------------------

     RESULT;
END C96007A;
