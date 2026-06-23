-- CE3810B.ADA

-- OBJECTIVE:
--     CHECK THAT FIXED_IO PUT CAN OPERATE ON STRINGS.  ALSO CHECK THAT
--     LAYOUT_ERROR IS RAISED WHEN THE STRING IS INSUFFICIENTLY LONG.

-- HISTORY:
--     DWC 09/15/87  CREATE ORIGINAL TEST.

WITH REPORT;
USE REPORT;
WITH TEXT_IO;
USE TEXT_IO;

PROCEDURE CE3810B IS
BEGIN

     TEST ("CE3810B", "CHECK THAT FIXED_IO PUT CAN OPERATE ON " &
                      "STRINGS.  ALSO CHECK THAT LAYOUT_ERROR IS " &
                      "RAISED WHEN THE STRING IS INSUFFICIENTLY LONG");

     DECLARE
          TYPE FX IS DELTA 0.0001 RANGE 0.0 .. 1000.0;
          PACKAGE FXIO IS NEW FIXED_IO (FX);
          USE FXIO;
          ST1 : CONSTANT STRING  := "  234.5000";
          ST : STRING (ST1'RANGE);
          ST2 : STRING (1 .. 2);

     BEGIN
          BEGIN
               PUT (ST, 234.5);
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    FAILED ("LAYOUT_ERROR RAISED ON PUT" &
                            "TO STRING - FIXED");
               WHEN OTHERS =>
                    FAILED ("SOME EXCEPTION RAISED ON PUT" &
                            "TO STRING -FIXED");
          END;

          IF ST /= ST1 THEN
               FAILED ("PUT FIXED TO STRING INCORRECT; OUTPUT " &
                       "WAS """ & ST & """");
          END IF;

          BEGIN
               PUT (ST (1..7), 234.5000);
               FAILED ("LAYOUT_ERROR NOT RAISED - FIXED - 1");
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - FIXED - 1");
          END;

          BEGIN
               PUT (ST, 2.3, 9, 0);
               FAILED ("LAYOUT_ERROR NOT RAISED - FIXED - 2");
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - FIXED - 2");
          END;

          BEGIN
               PUT (ST2, 2.0, 0, 0);
               FAILED ("LAYOUT_ERROR NOT RAISED - FIXED - 3");
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - FIXED - 3");
          END;

          BEGIN
               PUT (ST, 2.345, 6, 2);
               FAILED ("LAYOUT_ERROR NOT RAISED - FIXED - 4");
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - FIXED - 4");
          END;

          BEGIN
               PUT (ST, 2.0, 0, 7);
               FAILED ("LAYOUT_ERROR NOT RAISED - FIXED - 5");
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - FIXED - 5");
          END;
     END;

     RESULT;
END CE3810B;
