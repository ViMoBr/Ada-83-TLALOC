-- CE3403D.ADA

-- OBJECTIVE:
--     CHECK THAT SKIP_LINE RAISES CONSTRAINT_ERROR IF SPACING IS
--     ZERO, NEGATIVE, OR GREATER THAN COUNT'LAST WHEN COUNT'LAST
--     IS LESS THAN COUNT'BASE'LAST.

-- HISTORY:
--     ABW 08/26/82
--     SPS 09/16/82
--     SPS 11/11/82
--     DWC 09/09/87  ADDED CASE FOR COUNT'LAST.

WITH REPORT;
USE REPORT;
WITH TEXT_IO;
USE TEXT_IO;

PROCEDURE CE3403D IS

     FILE : FILE_TYPE;

BEGIN

     TEST ("CE3403D" , "CHECK THAT SKIP_LINE RAISES " &
                       "CONSTRAINT_ERROR IF SPACING IS ZERO, " &
                       "NEGATIVE, OR GREATER THAN COUNT'LAST " &
                       "WHEN COUNT'LAST IS LESS THAN " &
                       "COUNT'BASE'LAST");

     BEGIN
          SKIP_LINE (FILE, POSITIVE_COUNT(IDENT_INT(0)));
          FAILED ("CONSTRAINT_ERROR NOT RAISED FOR ZERO");
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED FOR ZERO");
     END;

     BEGIN
          SKIP_LINE (FILE, POSITIVE_COUNT(IDENT_INT(-2)));
          FAILED ("CONSTRAINT_ERROR NOT RAISED FOR NEGATIVE NUMBER");
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED FOR " &
                       "NEGATIVE NUMBER");
     END;

     IF COUNT'LAST < COUNT'BASE'LAST THEN
          BEGIN
               SKIP_LINE (FILE, COUNT'LAST + 1);
               FAILED ("CONSTRAINT_ERROR NOT RAISED FOR " &
                       "COUNT'LAST + 1");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED FOR " &
                            "COUNT'LAST + 1");
          END;
     END IF;

     BEGIN
          SKIP_LINE (POSITIVE_COUNT(IDENT_INT(0)));
          FAILED ("CONSTRAINT_ERROR NOT RAISED FOR ZERO - DEFAULT");
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED FOR ZERO " &
                       "- DEFAULT");
     END;

     BEGIN
          SKIP_LINE (POSITIVE_COUNT(IDENT_INT(-6)));
          FAILED ("CONSTRAINT_ERROR NOT RAISED FOR NEGATIVE NUM " &
                  "- DEFAULT");
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED NEGATIVE NUM " &
                       "- DEFAULT");
     END;

     IF COUNT'LAST < COUNT'BASE'LAST THEN
          BEGIN
               SKIP_LINE (COUNT'LAST + 1);
               FAILED ("CONSTRAINT_ERROR NOT RAISED FOR " &
                       "COUNT'LAST + 1 - DEFAULT");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED FOR " &
                            "COUNT'LAST + 1 - DEFAULT");
          END;
     END IF;

     RESULT;

END CE3403D;
