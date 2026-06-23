-- CE3906D.ADA

-- OBJECTIVE:
--     CHECK THAT CONSTRAINT_ERROR IS RAISED BY PUT FOR ENUMERATION
--     TYPES WHEN THE VALUE OF WIDTH IS NEGATIVE, WHEN WIDTH IS
--     GREATER THAN FIELD'LAST, OR WHEN THE VALUE OF ITEM IS OUTSIDE
--     THE RANGE OF THE SUBTYPE USED TO INSTANTIATE ENUMERATION_IO.

-- HISTORY:
--     SPS 10/08/82
--     DWC 09/17/87  ADDED CASES FOR CONSTRAINT_ERROR.

WITH REPORT;
USE REPORT;
WITH TEXT_IO;
USE TEXT_IO;

PROCEDURE CE3906D IS
BEGIN

     TEST ("CE3906D", "CHECK THAT CONSTRAINT_ERROR IS RAISED BY PUT " &
                      "FOR ENUMERATION TYPES WHEN THE VALUE OF " &
                      "WIDTH IS NEGATIVE, WHEN WIDTH IS GREATER " &
                      "THAN FIELD'LAST, OR WHEN THE VALUE OF ITEM " &
                      "IS OUTSIDE THE RANGE OF THE SUBTYPE USED TO " &
                      "INSTANTIATE ENUMERATION_IO");

     DECLARE
          FT : FILE_TYPE;
          TYPE DAY IS (SUNDAY, MONDAY, TUESDAY, WEDNESDAY,
                       THURSDAY, FRIDAY, SATURDAY);
          TODAY : DAY := FRIDAY;
          SUBTYPE WEEKDAY IS DAY RANGE MONDAY .. FRIDAY;
          PACKAGE DAY_IO IS NEW ENUMERATION_IO (WEEKDAY);
          USE DAY_IO;
     BEGIN

          BEGIN
               PUT (FT, TODAY, -1);
               FAILED ("CONSTRAINT_ERROR NOT RAISED; NEGATIVE " &
                       "WIDTH - FILE");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN STATUS_ERROR =>
                    FAILED ("RAISED STATUS_ERROR");
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED; NEGATIVE " &
                            "WIDTH - FILE");
          END;

          IF FIELD'LAST < INTEGER'LAST THEN
               BEGIN
                    PUT (FT, TODAY, FIELD'LAST + 1);
                    FAILED ("CONSTRAINT_ERROR NOT RAISED; WIDTH " &
                            "GREATER THAN FIELD'LAST + 1- FILE");
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED; WIDTH " &
                                 "GREATER THAN FIELD'LAST + 1 - FILE");
               END;

               BEGIN
                    PUT (TODAY, FIELD'LAST + 1);
                    FAILED ("CONSTRAINT_ERROR NOT RAISED; WIDTH " &
                            "GREATER THAN FIELD'LAST + 1 - DEFAULT");
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED; WIDTH " &
                                 "GREATER THAN FIELD'LAST + 1 " &
                                 "- DEFAULT");
          END;

          END IF;

          TODAY := SATURDAY;

          BEGIN
               PUT (FT, TODAY);
               FAILED ("CONSTRAINT_ERROR NOT RAISED; ITEM VALUE " &
                       "OUT OF RANGE - FILE");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED; ITEM VALUE " &
                            "OUT OF RANGE - FILE");
          END;

          TODAY := FRIDAY;

          BEGIN
               PUT (TODAY, -3);
               FAILED ("CONSTRAINT_ERROR NOT RAISED; NEGATIVE " &
                       "WIDTH - DEFAULT");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN STATUS_ERROR =>
                    FAILED ("RAISED STATUS_ERROR");
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED; NEGATIVE " &
                            "WIDTH - DEFAULT");
          END;

          TODAY := SATURDAY;

          BEGIN
               PUT (TODAY);
               FAILED ("CONSTRAINT_ERROR NOT RAISED; ITEM VALUE " &
                       "OUT OF RANGE - DEFAULT");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED; ITEM VALUE " &
                            "OUT OF RANGE - DEFAULT");
          END;
     END;

     RESULT;

END CE3906D;
