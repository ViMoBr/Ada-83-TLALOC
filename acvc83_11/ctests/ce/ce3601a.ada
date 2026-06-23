-- CE3601A.ADA

-- OBJECTIVE:
--     CHECK THAT GET (FOR STRINGS AND CHARACTERS), PUT (FOR STRINGS AND
--     CHARACTERS), GET_LINE, AND PUT_LINE RAISE STATUS_ERROR WHEN
--     CALLED WITH AN UNOPEN FILE PARAMETER.  ALSO CHECK NAMES OF FORMAL
--     PARAMETERS.

-- HISTORY:
--     SPS 08/27/82
--     VKG 02/15/83
--     JBG 03/30/83
--     JLH 09/04/87  ADDED CASE WHICH ATTEMPTS TO CREATE FILE AND THEN
--                   RETESTED OBJECTIVE.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;

PROCEDURE CE3601A IS

BEGIN

     TEST ("CE3601A", "STATUS_ERROR RAISED BY GET, PUT, GET_LINE, " &
                      "PUT_LINE WHEN FILE IS NOT OPEN");

     DECLARE
          FILE1, FILE2 : FILE_TYPE;
          CH: CHARACTER := '%';
          LST: NATURAL;
          ST: STRING (1 .. 10);
          LN : STRING (1 .. 80);
     BEGIN
          BEGIN
               GET (FILE => FILE1, ITEM => CH);
               FAILED ("STATUS_ERROR NOT RAISED - GET CHARACTER");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - GET CHARACTER");
          END;

          BEGIN
               GET (FILE => FILE1, ITEM => ST);
               FAILED ("STATUS_ERROR NOT RAISED - GET STRING");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - GET STRING");
          END;

          BEGIN
               GET_LINE (FILE => FILE1, ITEM => LN, LAST => LST);
               FAILED ("STATUS_ERROR NOT RAISED - GET_LINE");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - GET_LINE");
          END;

          BEGIN
               PUT (FILE => FILE1, ITEM => CH);
               FAILED ("STATUS_ERROR NOT RAISED - PUT CHARACTER");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - PUT CHARACTER");
          END;

          BEGIN
               PUT (FILE => FILE1, ITEM => ST);
               FAILED ("STATUS_ERROR NOT RAISED - PUT STRING");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - PUT STRING");
          END;

          BEGIN
               PUT_LINE (FILE => FILE1, ITEM => LN);
               FAILED ("STATUS_ERROR NOT RAISED - PUT_LINE");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - PUT_LINE");
          END;

          BEGIN
               CREATE (FILE2, OUT_FILE);   -- THIS IS ONLY AN ATTEMPT TO
               CLOSE (FILE2);              -- CREATE A FILE. OK, WHETHER
          EXCEPTION                        -- SUCCESSFUL OR NOT.
               WHEN USE_ERROR =>
                    NULL;
          END;

          BEGIN
               GET (FILE => FILE2, ITEM => CH);
               FAILED ("STATUS_ERROR NOT RAISED - GET CHARACTER");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - GET CHARACTER");
          END;

          BEGIN
               GET (FILE => FILE2, ITEM => ST);
               FAILED ("STATUS_ERROR NOT RAISED - GET STRING");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - GET STRING");
          END;

          BEGIN
               GET_LINE (FILE => FILE2, ITEM => LN, LAST => LST);
               FAILED ("STATUS_ERROR NOT RAISED - GET_LINE");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - GET_LINE");
          END;

          BEGIN
               PUT (FILE => FILE2, ITEM => CH);
               FAILED ("STATUS_ERROR NOT RAISED - PUT CHARACTER");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - PUT CHARACTER");
          END;

          BEGIN
               PUT (FILE => FILE2, ITEM => ST);
               FAILED ("STATUS_ERROR NOT RAISED - PUT STRING");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - PUT STRING");
          END;

          BEGIN
               PUT_LINE (FILE => FILE2, ITEM => LN);
               FAILED ("STATUS_ERROR NOT RAISED - PUT_LINE");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - PUT_LINE");
          END;

     END;

     RESULT;

END CE3601A;
