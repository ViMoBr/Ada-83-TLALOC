-- CE3806C.ADA

-- OBJECTIVE:
--     CHECK THAT PUT FOR FLOAT_IO RAISES CONSTRAINT_ERROR WHEN THE
--     VALUES SUPPLIED BY FORE, AFT, OR EXP ARE NEGATIVE OR GREATER
--     THAN FIELD'LAST WHEN FIELD'LAST < FIELD'BASE'LAST.  ALSO CHECK
--     THAT PUT FOR FLOAT_IO RAISES CONSTRAINT_ERROR WHEN THE VALUE OF
--     ITEM IS OUTSIDE THE RANGE OF THE TYPE USED TO INSTANTIATE
--     FLOAT_IO.

-- HISTORY:
--     SPS 09/10/82
--     JBG 08/30/83
--     JLH 09/14/87  ADDED CASES FOR COMPLETE OBJECTIVE.

WITH REPORT;
USE REPORT;
WITH TEXT_IO;
USE TEXT_IO;

PROCEDURE CE3806C IS

BEGIN

     TEST ("CE3806C", "CHECK THAT PUT FOR FLOAT_IO RAISES " &
                      "CONSTRAINT_ERROR APPROPRIATELY");

     DECLARE
          TYPE FLOAT IS DIGITS 5 RANGE 0.0 .. 2.0;
          SUBTYPE MY_FLOAT IS FLOAT DIGITS 5 RANGE 0.0 .. 1.0;
          PACKAGE NFL_IO IS NEW FLOAT_IO (MY_FLOAT);
          USE NFL_IO;
          FT : FILE_TYPE;
          Y : FLOAT := 1.8;
          X : MY_FLOAT := 26.3 / 26.792;

     BEGIN
          BEGIN
               PUT (FT, X, FORE => IDENT_INT(-6));
               FAILED ("CONSTRAINT_ERROR NOT RAISED - NEGATIVE FORE " &
                       "FLOAT");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN STATUS_ERROR =>
                    FAILED ("STATUS_ERROR RAISED INSTEAD OF " &
                            "CONSTRAINT_ERROR - 1");
               WHEN USE_ERROR =>
                    FAILED ("USE_ERROR RAISED INSTEAD OF " &
                            "CONSTRAINT_ERROR - 1");
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - NEGATIVE FORE " &
                            "FLOAT");
          END;

          BEGIN
               PUT (FT, X, AFT => IDENT_INT(-2));
               FAILED ("CONSTRAINT_ERROR NOT RAISED - NEGATIVE AFT " &
                       "FLOAT");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN STATUS_ERROR =>
                    FAILED ("STATUS_ERROR RAISED INSTEAD OF " &
                            "CONSTRAINT_ERROR - 2");
               WHEN USE_ERROR =>
                    FAILED ("USE_ERROR RAISED INSTEAD OF " &
                            "CONSTRAINT_ERROR - 2");
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - NEGATIVE AFT " &
                            "FLOAT");
          END;

          BEGIN
               PUT (FT, X, EXP => IDENT_INT(-1));
               FAILED ("CONSTRAINT_ERROR NOT RAISED - NEGATIVE EXP " &
                       "FLOAT");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN STATUS_ERROR =>
                    FAILED ("STATUS_ERROR RAISED INSTEAD OF " &
                            "CONSTRAINT_ERROR - 3");
               WHEN USE_ERROR =>
                    FAILED ("USE_ERROR RAISED INSTEAD OF " &
                            "CONSTRAINT_ERROR - 3");
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - NEGATIVE EXP " &
                            "FLOAT");
          END;

          IF FIELD'LAST < FIELD'BASE'LAST THEN

               BEGIN
                    PUT (FT, X, FORE => IDENT_INT(FIELD'LAST+1));
                    FAILED ("CONSTRAINT_ERROR NOT RAISED - FORE FLOAT");
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN STATUS_ERROR =>
                         FAILED ("STATUS_ERROR RAISED INSTEAD OF " &
                                 "CONSTRAINT_ERROR - 4");
                    WHEN USE_ERROR =>
                         FAILED ("USE_ERROR RAISED INSTEAD OF " &
                                 "CONSTRAINT_ERROR - 4");
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED - FORE FLOAT");
               END;

               BEGIN
                    PUT (FT, X, AFT => IDENT_INT(FIELD'LAST+1));
                    FAILED ("CONSTRAINT_ERROR NOT RAISED - AFT FLOAT");
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN STATUS_ERROR =>
                         FAILED ("STATUS_ERROR RAISED INSTEAD OF " &
                                 "CONSTRAINT_ERROR - 5");
                    WHEN USE_ERROR =>
                         FAILED ("USE_ERROR RAISED INSTEAD OF " &
                                 "CONSTRAINT_ERROR - 5");
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED - AFT FLOAT");
               END;

               BEGIN
                    PUT (FT, X, EXP => IDENT_INT(FIELD'LAST+1));
                    FAILED ("CONSTRAINT_ERROR NOT RAISED - EXP FLOAT");
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN STATUS_ERROR =>
                         FAILED ("STATUS_ERROR RAISED INSTEAD OF " &
                                 "CONSTRAINT_ERROR - 6");
                    WHEN USE_ERROR =>
                         FAILED ("USE_ERROR RAISED INSTEAD OF " &
                                 "CONSTRAINT_ERROR - 6");
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED - EXP FLOAT");
               END;
           END IF;

           BEGIN
               PUT (FT, Y);
               FAILED ("CONSTRAINT_ERROR NOT RAISED FOR ITEM OUTSIDE " &
                       "RANGE - FILE");
           EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED FOR ITEM OUTSIDE " &
                            "RANGE - FILE");
          END;

          BEGIN
               PUT (Y);
               FAILED ("CONSTRAINT_ERROR NOT RAISED FOR ITEM OUTSIDE " &
                       "RANGE - DEFAULT");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED FOR ITEM OUTSIDE " &
                            "RANGE - DEFAULT");
          END;

     END;

     RESULT;

END CE3806C;
