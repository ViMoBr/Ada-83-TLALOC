-- CE2405B.ADA

-- OBJECTIVE:
--     CHECK THAT READ RAISES END_ERROR WHEN THE CURRENT READ POSITION
--     IS GREATER THAN THE END POSITION.  ALSO CHECK THAT END_OF_FILE
--     CORRECTLY DETECTS THE END OF A DIRECT FILE.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     CREATION WITH INOUT_FILE MODE AND OPENING OF IN_FILE MODE.

-- HISTORY:
--     SPS 09/28/82
--     JBG 02/22/84  CHANGE TO .ADA TEST
--     EG  05/16/85
--     GMT 08/03/87  ADDED CODE TO CHECK THAT END_OF_FILE WORKS, AND
--                   ADDED CODE TO PREVENT SOME EXCEPTION PROPAGATION.

WITH REPORT; USE REPORT;
WITH DIRECT_IO;

PROCEDURE CE2405B IS
BEGIN
     TEST ("CE2405B", "CHECK THAT END_ERROR IS RAISED BY READ AT THE " &
                      "END OF A FILE AND THAT END_OF_FILE CORRECTLY " &
                      "DETECTS THE END OF A DIRECT_IO FILE");
     DECLARE
          PACKAGE DIR IS NEW DIRECT_IO (CHARACTER);
          USE DIR;
          FT         : FILE_TYPE;
          CH         : CHARACTER;
          INCOMPLETE : EXCEPTION;
     BEGIN

          -- CREATE AND INITIALIZE FILE

          BEGIN
               CREATE (FT, INOUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR | NAME_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR | NAME_ERROR WAS " &
                                    "RAISED ON CREATE - 1");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED ON CREATE - 2");
                    RAISE INCOMPLETE;
          END;

          BEGIN

               WRITE (FT, 'C');
               WRITE (FT, 'X');

               -- BEGIN TEST

               IF NOT END_OF_FILE (FT) THEN
                    FAILED ("END_OF_FILE RETURNED INCORRECT " &
                            "BOOLEAN VALUE - 3");
               END IF;

               BEGIN
                    READ (FT, CH);
                    FAILED ("END_ERROR NOT RAISED ON READ - 4");
               EXCEPTION
                    WHEN END_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED ON READ - 5");
               END;

               WRITE (FT,'E');

               BEGIN
                    READ (FT, CH);
                    FAILED ("END_ERROR NOT RAISED ON READ - 6");
               EXCEPTION
                    WHEN END_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED ON READ - 7");
               END;

          END;

          CLOSE (FT);

          BEGIN
               OPEN (FT, IN_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON OPEN - 8");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED ON OPEN - 9");
                    RAISE INCOMPLETE;
          END;

          DECLARE
               COUNT_NBR_OF_READS : NATURAL := 0;
               EXPECTED_COUNT     : CONSTANT := 3;
          BEGIN
               LOOP
                    IF END_OF_FILE (FT) THEN
                         EXIT;
                    ELSE
                         READ (FT, CH);
                         COUNT_NBR_OF_READS := COUNT_NBR_OF_READS + 1;
                    END IF;
               END LOOP;

               IF COUNT_NBR_OF_READS /= EXPECTED_COUNT THEN
                      FAILED ("THE BAD VALUE FOR COUNT_NBR_OF_READS " &
                              "IS " &
                               NATURAL'IMAGE (COUNT_NBR_OF_READS) );
               END IF;

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

END CE2405B;
