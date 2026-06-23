-- CE2117B.ADA

-- OBJECTIVE:
--     DETERMINE, FOR DIRECT_IO, THE NUMBER OF INTERNAL FILES AN
--     IMPLEMENTATION CAN SUPPORT.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS ONLY APPLICABLE TO IMPLEMENTATIONS WHICH SUPPORT
--     DIRECT FILES.

-- HISTORY:
--     JLH 07/12/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH DIRECT_IO;

PROCEDURE CE2117B IS

     PACKAGE DIR_IO IS NEW DIRECT_IO (INTEGER);
     USE DIR_IO;

     FILES : ARRAY (1..65) OF FILE_TYPE;
     LOOP_COUNT : INTEGER;
     SUFFIX : STRING (1..7);
     INCOMPLETE, CLEANUP : EXCEPTION;

BEGIN

     TEST ("CE2117B", "DETERMINE, FOR DIRECT_IO, THE NUMBER OF " &
                      "INTERNAL FILES AN IMPLEMENTATION CAN SUPPORT");

     BEGIN

          SUFFIX := "AAAAA" & INTEGER'IMAGE(1);

          BEGIN
               CREATE (FILES(1), OUT_FILE, LEGAL_FILE_NAME(1,SUFFIX));
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON CREATE " &
                                    "WITH MODE OUT_FILE");
                    RAISE INCOMPLETE;
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED ON CREATE " &
                                    "WITH MODE OUT_FILE");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON CREATE");
                    RAISE INCOMPLETE;
          END;

          WRITE (FILES(1), 2);
          CLOSE (FILES(1));

          BEGIN
               OPEN (FILES(1), IN_FILE, LEGAL_FILE_NAME(1,SUFFIX));
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON OPEN " &
                                    "WITH MODE IN_FILE");
                    RAISE INCOMPLETE;
          END;

          BEGIN
               FOR I IN 2 .. 65 LOOP
                    LOOP_COUNT := I;
                    IF I <= 9 THEN
                         SUFFIX := "AAAAA" & INTEGER'IMAGE(I);
                    ELSE
                         SUFFIX := "AAAA" & INTEGER'IMAGE(I);
                    END IF;
                    BEGIN
                         CREATE (FILES(I), OUT_FILE,
                                      LEGAL_FILE_NAME(1,SUFFIX));
                    EXCEPTION
                         WHEN USE_ERROR | NAME_ERROR =>
                              COMMENT ("FOR DIRECT_IO, THE " &
                                       "NUMBER OF INTERNAL FILES " &
                                       "SUPPORTED IS: " &
                                       INTEGER'IMAGE(LOOP_COUNT-1));
                              RAISE CLEANUP;
                         WHEN OTHERS =>
                              FAILED ("UNEXPECTED EXCEPTION RAISED");
                              RAISE CLEANUP;
                    END;
                    WRITE (FILES(I), 2);
                    CLOSE (FILES(I));
                    OPEN (FILES(I), IN_FILE, LEGAL_FILE_NAME(1,SUFFIX));
               END LOOP;
          EXCEPTION
               WHEN CLEANUP =>
                    FOR I IN 1 .. LOOP_COUNT-1 LOOP
                         BEGIN
                              DELETE (FILES(I));
                         EXCEPTION
                              WHEN USE_ERROR =>
                                   NULL;
                         END;
                    END LOOP;
          END;

          IF LOOP_COUNT = 65 THEN
               COMMENT ("FOR DIRECT_IO, THIS IMPLEMENTATION CAN " &
                        "SUPPORT AT LEAST 65 INTERNAL FILES");
               BEGIN
                    DELETE (FILES(65));
               EXCEPTION
                    WHEN USE_ERROR =>
                         NULL;
               END;
          END IF;

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE2117B;
