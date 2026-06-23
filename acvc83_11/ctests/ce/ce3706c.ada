-- CE3706C.ADA

-- OBJECTIVE:
--     CHECK THAT INTEGER_IO PUT RAISES CONSTRAINT_ERROR IF:
--        A) THE BASE IS OUTSIDE THE RANGE 2..16.
--        B) THE VALUE OF WIDTH IS NEGATIVE OR GREATER THAN FIELD'LAST,
--           WHEN FIELD'LAST < INTEGER'LAST.
--        C) THE VALUE OF ITEM IS OUTSIDE THE RANGE OF THE INSTANTIATED
--           TYPE.

-- HISTORY:
--     SPS 10/05/82
--     JBG 08/30/83
--     JLH 09/10/87  ADDED CASES FOR THE VALUE OF THE WIDTH BEING LESS
--                   THAN ZERO AND GREATER THAN FIELD'LAST AND CASES FOR
--                   THE VALUE OF ITEM OUTSIDE THE RANGE OF THE
--                   INSTANTIATED TYPE.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;

PROCEDURE CE3706C IS
BEGIN

     TEST ("CE3706C", "CHECK THAT INTEGER_IO PUT RAISES CONSTRAINT " &
                      "ERROR APPROPRIATELY");

     DECLARE
          FT : FILE_TYPE;
          TYPE INT IS NEW INTEGER RANGE 1 .. 10;
          PACKAGE IIO IS NEW INTEGER_IO (INT);
          USE IIO;
          ST : STRING (1 .. 10);
     BEGIN

          BEGIN
               PUT (FT, 2, 6, 1);
               FAILED ("CONSTRAINT_ERROR NOT RAISED - FILE - 1");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - FILE - 1");
          END;

          BEGIN
               PUT (3, 4, 17);
               FAILED ("CONSTRAINT_ERROR NOT RAISED - DEFAULT - 1");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - DEFAULT - 1");
          END;

          BEGIN
               PUT (TO => ST, ITEM => 4, BASE => -3);
               FAILED ("CONSTRAINT_ERROR NOT RAISED - STRING - 1");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - STRING - 1");
          END;

          BEGIN
               PUT (ST, 5, 17);
               FAILED ("CONSTRAINT_ERROR NOT RAISED - STRING - 2");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - STRING - 2");
          END;

          BEGIN
               PUT (FT, 5, -1);
               FAILED ("CONSTRAINT_ERROR NOT RAISED - FILE - 2");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - FILE - 2");
          END;

          BEGIN
               PUT (7, -3);
               FAILED ("CONSTRAINT_ERROR NOT RAISED - DEFAULT - " &
                       "2");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - DEFAULT - 2");
          END;

          IF FIELD'LAST < INTEGER'LAST THEN
               BEGIN
                    PUT (7, FIELD'LAST+1);
                    FAILED ("CONSTRAINT_ERROR NOT RAISED FOR WIDTH " &
                            "GREATER THAN FIELD'LAST");
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED FOR WIDTH " &
                                 "GREATER THAN FIELD'LAST");
               END;

          END IF;

          BEGIN
               PUT (FT, 11);
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
               PUT (11);
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
END CE3706C;
