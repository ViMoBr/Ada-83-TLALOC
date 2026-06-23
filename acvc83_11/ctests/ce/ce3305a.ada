-- CE3305A.ADA

-- OBJECTIVE:
--     CHECK THAT THE LINE AND PAGE LENGTHS MAY BE ALTERED DYNAMICALLY
--     SEVERAL TIMES.  CHECK THAT WHEN RESET TO ZERO, THE LENGTHS ARE
--     UNBOUNDED.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     TEXT FILES WITH UNBOUNDED LINE LENGTH.

-- HISTORY:
--     SPS 09/28/82
--     EG  05/22/85
--     DWC 08/18/87  ADDED CHECK_FILE WITHOUT A'S.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;
WITH CHECK_FILE;

PROCEDURE CE3305A IS

     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("CE3305A", "CHECK THAT LINE AND PAGE LENGTHS MAY BE " &
                      "ALTERED DYNAMICALLY");

     DECLARE
          FT : FILE_TYPE;

          PROCEDURE PUT_CHARS (CNT: INTEGER; CH: CHARACTER) IS
          BEGIN
               FOR I IN 1 .. CNT LOOP
                    PUT (FT, CH);
               END LOOP;
          END PUT_CHARS;

     BEGIN

          BEGIN
               CREATE(FT, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON CREATE " &
                                    "WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED ON CREATE " &
                                    "WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON CREATE");
                    RAISE INCOMPLETE;
          END;

          SET_LINE_LENGTH (FT, 10);
          SET_PAGE_LENGTH (FT, 5);

          PUT_CHARS (150, 'X');         -- 15 LINES

          BEGIN
               SET_LINE_LENGTH (FT, 5);
               SET_PAGE_LENGTH (FT, 10);
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("UNABLE TO CHANGE LINE OR PAGE LENGTH");
          END;

          PUT_CHARS (50, 'B');               -- 10 LINES

          BEGIN
               SET_LINE_LENGTH (FT, 25);
               SET_PAGE_LENGTH (FT,4);
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("UNABLE TO CHANGE LINE OR PAGE LENGTH - 2");
          END;

          PUT_CHARS (310, 'K');              -- 12 LINES, 10 CHARACTERS

--  THIS CAN RAISE USE_ERROR IF AN IMPLEMENTATION REQUIRES A BOUNDED
--  LINE LENGTH FOR AN EXTERNAL FILE.

          BEGIN
               BEGIN
                    SET_LINE_LENGTH (FT, UNBOUNDED);
                    SET_PAGE_LENGTH (FT, UNBOUNDED);
               EXCEPTION
                    WHEN USE_ERROR =>
                         NOT_APPLICABLE ("BOUNDED LINE LENGTH " &
                                         "REQUIRED");
                         RAISE INCOMPLETE;
               END;

               PUT_CHARS (100, 'A');              -- ONE LINE

               CHECK_FILE (FT,"XXXXXXXXXX#" &
                              "XXXXXXXXXX#" &
                              "XXXXXXXXXX#" &
                              "XXXXXXXXXX#" &
                              "XXXXXXXXXX#@" &
                              "XXXXXXXXXX#" &
                              "XXXXXXXXXX#" &
                              "XXXXXXXXXX#" &
                              "XXXXXXXXXX#" &
                              "XXXXXXXXXX#@" &
                              "XXXXXXXXXX#" &
                              "XXXXXXXXXX#" &
                              "XXXXXXXXXX#" &
                              "XXXXXXXXXX#" &
                              "XXXXXXXXXX#" &
                              "BBBBB#" &
                              "BBBBB#" &
                              "BBBBB#" &
                              "BBBBB#" &
                              "BBBBB#@" &
                              "BBBBB#" &
                              "BBBBB#" &
                              "BBBBB#" &
                              "BBBBB#" &
                              "BBBBBKKKKKKKKKKKKKKKKKKKK#@" &
                              "KKKKKKKKKKKKKKKKKKKKKKKKK#" &
                              "KKKKKKKKKKKKKKKKKKKKKKKKK#" &
                              "KKKKKKKKKKKKKKKKKKKKKKKKK#" &
                              "KKKKKKKKKKKKKKKKKKKKKKKKK#@" &
                              "KKKKKKKKKKKKKKKKKKKKKKKKK#" &
                              "KKKKKKKKKKKKKKKKKKKKKKKKK#" &
                              "KKKKKKKKKKKKKKKKKKKKKKKKK#" &
                              "KKKKKKKKKKKKKKKKKKKKKKKKK#@" &
                              "KKKKKKKKKKKKKKKKKKKKKKKKK#" &
                              "KKKKKKKKKKKKKKKKKKKKKKKKK#"&
                              "KKKKKKKKKKKKKKKKKKKKKKKKK#"&
                              "KKKKKKKKKKKKKKKAAAAAAAAAAA" &
                              "AAAAAAAAAAAAAAAAAAAAAAAAAA" &
                              "AAAAAAAAAAAAAAAAAAAAAAAAAA" &
                              "AAAAAAAAAAAAAAAAAAAAAAAAAA" &
                              "AAAAAAAAAAA#@%");

          EXCEPTION
               WHEN INCOMPLETE =>
                    NULL;
          END;

          BEGIN
               DELETE (FT);
          EXCEPTION
               WHEN USE_ERROR =>
                    NULL;
          END;

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE3305A;
