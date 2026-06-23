-- CE3810A.ADA

-- OBJECTIVE:
--     CHECK THAT FLOAT_IO PUT CAN OPERATE ON STRINGS.  ALSO CHECK THAT
--     LAYOUT_ERROR IS RAISED WHEN THE STRING IS INSUFFICIENTLY LONG.

-- HISTORY:
--     SPS 10/07/82
--     VKG 01/20/83
--     SPS 02/18/83
--     DWC 09/15/87  SPLIT CASE FOR FIXED_IO INTO CE3810B.ADA AND
--                   ADDED CASED FOR AFT AND EXP TO RAISE LAYOUT_ERROR.

WITH REPORT;
USE REPORT;
WITH TEXT_IO;
USE TEXT_IO;

PROCEDURE CE3810A IS
BEGIN

     TEST ("CE3810A", "CHECK THAT FLOAT_IO PUT " &
                      "OPERATES ON STRINGS CORRECTLY");

     DECLARE
          TYPE FL IS DIGITS 4;
          PACKAGE FLIO IS NEW FLOAT_IO (FL);
          USE FLIO;
          ST  : STRING (1 .. 2 + (FL'DIGITS-1) + 3 + 2);
          ST1 : STRING (1 .. 10) := " 2.345E+02";
          ST2 : STRING (1 .. 2);
     BEGIN
          PUT (ST, 234.5);
          IF ST /= ST1 THEN
               FAILED ("PUT FLOAT TO STRING INCORRECT; OUTPUT WAS """ &
                        ST & """");
          END IF;

          BEGIN
               PUT (ST(1 .. 8), 234.5);
               FAILED ("LAYOUT_ERROR NOT RAISED - FLOAT - 1");
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - FLOAT - 1");
          END;

          BEGIN
               PUT (ST, 2.3, 9, 0);
               FAILED ("LAYOUT_ERROR NOT RAISED - FLOAT - 2");
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - FLOAT - 2");
          END;

          BEGIN
               PUT (ST2, 2.0, 0, 0);
               FAILED ("LAYOUT_ERROR NOT RAISED - FLOAT - 3");
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - FLOAT - 3");
          END;

          BEGIN
               PUT (ST, 2.345, 6, 2);
               FAILED ("LAYOUT_ERROR NOT RAISED - FLOAT - 4");
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - FLOAT - 4");
          END;

          BEGIN
               PUT (ST, 2.0, 0, 7);
               FAILED ("LAYOUT_ERROR NOT RAISED - FLOAT - 5");
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - FLOAT - 5");
          END;
     END;

     RESULT;

END CE3810A;
