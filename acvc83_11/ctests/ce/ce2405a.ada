-- CE2405A.ADA

-- OBJECTIVE:
--     CHECK WHETHER READ FOR DIRECT_IO RAISES DATA_ERROR WHEN THE
--     CURRENT INDEX CORRESPONDS TO AN UNDEFINED ELEMENT, OR WHEN A
--     VALUE READ DOES NOT BELONG TO ELEMENT_TYPE.  CHECK THAT READING
--     CAN CONTINUE AFTER THE EXCEPTION HAS BEEN HANDLED.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     DIRECT FILES.

-- HISTORY:
--     JLH 07/21/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH DIRECT_IO;

PROCEDURE CE2405A IS

     TYPE MEN IS (MIKE, KEVIN, PERRY);

     PACKAGE MALE_IO IS NEW DIRECT_IO (MEN);
     USE MALE_IO;

     TYPE WOMEN IS (CARLA, CHERYL, ROSA, MARIE);

     PACKAGE FEMALE_IO IS NEW DIRECT_IO (WOMEN);
     USE FEMALE_IO;

     SHE_FILE : FEMALE_IO.FILE_TYPE;
     HE_FILE : MALE_IO.FILE_TYPE;
     SON : MEN;
     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("CE2405A", "CHECK WHETHER READ FOR DIRECT_IO RAISES " &
                      "DATA_ERROR WHEN THE CURRENT INDEX CORRESPONDS " &
                      "TO AN UNDEFINED ELEMENT, OR WHEN A VALUE READ " &
                      "DOES NOT BELONG TO ELEMENT_TYPE.  CHECK THAT " &
                      "READING CAN CONTINUE AFTER THE EXCEPTION HAS " &
                      "BEEN HANDLED");

     BEGIN

          BEGIN
               CREATE (SHE_FILE, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN FEMALE_IO.USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON CREATE " &
                                    "WITH MODE OUT_FILE");
                    RAISE INCOMPLETE;
               WHEN FEMALE_IO.NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED ON CREATE " &
                                    "WITH MODE OUT_FILE");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON CREATE");
                    RAISE INCOMPLETE;
          END;

          WRITE (SHE_FILE, CARLA, 2);
          WRITE (SHE_FILE, MARIE);
          WRITE (SHE_FILE, CHERYL);

          CLOSE (SHE_FILE);

          BEGIN
               OPEN (HE_FILE, IN_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN MALE_IO.USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON OPEN " &
                                    "WITH MODE IN_FILE");
                    RAISE INCOMPLETE;
          END;

          BEGIN
               READ (HE_FILE, SON);
               COMMENT ("DATA_ERROR NOT RAISED ON READ FOR INDEX " &
                        "CORRESPONDING TO UNDEFINED ELEMENT");
          EXCEPTION
               WHEN MALE_IO.DATA_ERROR =>
                    COMMENT ("DATA_ERROR RAISED ON READ FOR INDEX " &
                             "CORRESPONDING TO UNDEFINED ELEMENT");
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON READ - 1");
                    RAISE INCOMPLETE;
          END;

          BEGIN
               READ (HE_FILE, SON);
               IF SON /= MIKE THEN
                    FAILED ("INCORRECT VALUE FOR READ - 1");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("UNABLE TO CONTINUE READING - 1");
                    RAISE INCOMPLETE;
          END;

          BEGIN
               READ (HE_FILE, SON);
               COMMENT ("NO EXCEPTION RAISED ON READ WITH ELEMENT " &
                        "THAT DOES NOT BELONG TO ELEMENT_TYPE");
          EXCEPTION
               WHEN MALE_IO.DATA_ERROR =>
                    COMMENT ("DATA_ERROR RAISED ON READ WITH ELEMENT " &
                             "THAT DOES NOT BELONG TO ELEMENT_TYPE");
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON READ - 2");
                    RAISE INCOMPLETE;
          END;

          BEGIN
               READ (HE_FILE, SON);
               IF SON /= KEVIN THEN
                    FAILED ("INCORRECT VALUE FOR READ - 2");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("UNABLE TO CONTINUE READING - 2");
                    RAISE INCOMPLETE;
          END;

          BEGIN
               DELETE (HE_FILE);
          EXCEPTION
               WHEN MALE_IO.USE_ERROR =>
                    NULL;
          END;

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE2405A;
