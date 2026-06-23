-- CE3411C.ADA

-- OBJECTIVE:
--     CHECK THAT COL OPERATES ON THE CURRENT DEFAULT OUTPUT FILE WHEN
--     NO FILE IS SPECIFIED.  CHECK THAT COL CAN OPERATE ON FILES OF
--     MODES IN_FILE AND OUT_FILE, INCLUDING THE CURRENT DEFAULT
--     INPUT_FILE.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     TEXT FILES.

-- HISTORY:
--     SPS 09/29/82
--     JBG 01/31/83
--     JBG 08/30/83
--     JLH 09/02/87  REMOVED DEPENDENCE ON RESET, REMOVED UNNECESSARY
--                   CODE, AND CHECKED FOR USE_ERROR ON DELETE.

WITH REPORT;
USE REPORT;
WITH TEXT_IO;
USE TEXT_IO;

PROCEDURE CE3411C IS
     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("CE3411C", "CHECK THAT COL OPERATES ON DEFAULT IN_FILE AND "&
                      "OUT_FILE FILES");

     DECLARE
          F1, F2 : FILE_TYPE;
          C : POSITIVE_COUNT;
          X : CHARACTER;
     BEGIN
          IF COL /= COL (STANDARD_OUTPUT) THEN
               FAILED ("COL DEFAULT NOT STANDARD_OUTPUT");
          END IF;

          IF COL /= COL (STANDARD_INPUT) THEN
               FAILED ("COL DEFAULT NOT STANDARD_INPUT");
          END IF;

          IF COL /= COL (CURRENT_INPUT) THEN
               FAILED ("COL DEFAULT NOT CURRENT_INPUT");
          END IF;

          IF COL /= COL (CURRENT_OUTPUT) THEN
               FAILED ("COL DEFAULT NOT CURRENT_OUTPUT");
          END IF;

          BEGIN
               CREATE (F1, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON CREATE WITH " &
                                    "OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED ON CREATE " &
                                    "WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
          END;

          CREATE (F2, OUT_FILE);

          SET_OUTPUT (F2);

          PUT (F1, "STRING");
          IF COL (F1) /= 7 THEN
               FAILED ("COL INCORRECT SUBTEST 1");
          END IF;

          PUT (F2, "OUTPUT STRING");
          IF COL /= COL(F2) AND COL(F2) /= 14 THEN
               FAILED ("COL INCORRECT SUBTEST 2; WAS " &
                       COUNT'IMAGE(COL) & " VS. " &
                       COUNT'IMAGE(COL(F2)));
          END IF;

          CLOSE (F1);

          BEGIN
               OPEN (F1, IN_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON TEXT OPEN " &
                                    "WITH IN_FILE MODE");
                    RAISE INCOMPLETE;
          END;

          SET_INPUT (F1);

          GET (F1, X);
          GET (F1, X);
          GET (F1, X);

          IF X /= 'R' THEN
               FAILED ("INCORRECT VALUE READ");
          END IF;

          IF COL (CURRENT_INPUT) /= 4 AND COL /= 4 THEN
               FAILED ("COL INCORRECT SUBTEST 3");
          END IF;

          BEGIN
               DELETE (F1);
          EXCEPTION
               WHEN USE_ERROR =>
                    NULL;
          END;

          CLOSE (F2);

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE3411C;
