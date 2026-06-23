-- CE2208B.ADA

-- OBJECTIVE:
--     CHECK THAT DATA CAN BE OVERWRITTEN IN THE SEQUENTIAL FILE AND THE
--     CORRECT VALUES CAN LATER BE READ.  ALSO CHECK WHETHER OVERWRITING
--     TRUNCATES THE FILE TO THE LAST ELEMENT WRITTEN.

-- APPLICABILITY CRITERIA:
--      THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--      THE CREATING AND OPENING OF SEQUENTIAL FILES.

-- HISTORY:
--     TBN  09/30/86  CREATED ORIGINAL TEST.
--     GMT  07/24/87  ADDED CHECKS FOR USE_ERROR AND REMOVED SOME CODE.

WITH SEQUENTIAL_IO;
WITH REPORT; USE REPORT;
PROCEDURE CE2208B IS

     PACKAGE SEQ_IO IS NEW SEQUENTIAL_IO (INTEGER);
     USE SEQ_IO;

     FILE1      : FILE_TYPE;
     INCOMPLETE : EXCEPTION;

BEGIN
     TEST ("CE2208B",
           "CHECK THAT DATA CAN BE OVERWRITTEN IN THE SEQUENTIAL " &
           "FILE AND THE CORRECT VALUES CAN LATER BE READ.  ALSO " &
           "CHECK WHETHER OVERWRITING TRUNCATES THE FILE." );

     -- INITIALIZE TEST FILE

     BEGIN
          CREATE (FILE1, OUT_FILE, LEGAL_FILE_NAME);
     EXCEPTION
          WHEN NAME_ERROR =>
               NOT_APPLICABLE ("NAME_ERROR RAISED DURING CREATE");
               RAISE INCOMPLETE;
          WHEN USE_ERROR =>
               NOT_APPLICABLE ("USE_ERROR RAISED DURING CREATE");
               RAISE INCOMPLETE;
          WHEN OTHERS =>
               FAILED ("UNKNOWN EXCEPTION RAISED DURING CREATE");
               RAISE INCOMPLETE;
     END;

     BEGIN
          FOR I IN 1 .. 25 LOOP
               WRITE (FILE1, I);
          END LOOP;
     EXCEPTION
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED DURING WRITE");
               RAISE INCOMPLETE;
     END;

     BEGIN
          CLOSE (FILE1);
     EXCEPTION
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED DURING CLOSE");
               RAISE INCOMPLETE;
     END;

     BEGIN
          OPEN (FILE1, OUT_FILE, LEGAL_FILE_NAME);
     EXCEPTION
          WHEN USE_ERROR =>
               NOT_APPLICABLE ( "OPEN WITH  OUT_FILE  MODE NOT "  &
                                "SUPPORTED FOR SEQUENTIAL FILES" );
               RAISE INCOMPLETE;
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED DURING OPEN");
               RAISE INCOMPLETE;
     END;

     BEGIN
          FOR I IN 26 .. 36 LOOP
               WRITE (FILE1, I);
          END LOOP;
     EXCEPTION
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED DURING OVERWRITE");
               RAISE INCOMPLETE;
     END;

     BEGIN
          CLOSE (FILE1);
     EXCEPTION
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED DURING 2ND CLOSE");
               RAISE INCOMPLETE;
     END;

     BEGIN
          OPEN (FILE1, IN_FILE, LEGAL_FILE_NAME);
     EXCEPTION
          WHEN USE_ERROR =>
               NOT_APPLICABLE ( "OPEN WITH  IN_FILE  MODE NOT "   &
                                "SUPPORTED FOR SEQUENTIAL FILES" );
               RAISE INCOMPLETE;
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED DURING SECOND OPEN");
               RAISE INCOMPLETE;
     END;

     DECLARE
          END_REACHED : BOOLEAN := FALSE;
          COUNT : INTEGER := 26;
          NUM : INTEGER;
     BEGIN
          WHILE COUNT <= 36 AND NOT END_REACHED LOOP
               BEGIN
                    READ (FILE1, NUM);
                    IF NUM /= COUNT THEN
                         FAILED ("INCORRECT RESULTS READ FROM FILE " &
                                 INTEGER'IMAGE (NUM));
                    END IF;
                    COUNT := COUNT + 1;
               EXCEPTION
                    WHEN END_ERROR =>
                         END_REACHED := TRUE;
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED DURING " &
                                 "READING");
                         RAISE INCOMPLETE;
               END;
          END LOOP;
          IF COUNT <= 36 THEN
               FAILED ("FILE WAS INCOMPLETE");
               RAISE INCOMPLETE;
          ELSE
               COUNT := 12;
               WHILE COUNT <= 25 AND NOT END_REACHED LOOP
                    BEGIN
                         READ (FILE1, NUM);
                         IF NUM /= COUNT THEN
                              COMMENT ("INCORRECT RESULTS READ FROM " &
                                      "FILE " & INTEGER'IMAGE (NUM));
                              COMMENT ("OVERWRITING MAKES PREVIOUS"   &
                                       "DATA ERRONEOUS");
                         END IF;
                         COUNT := COUNT + 1;
                    EXCEPTION
                         WHEN END_ERROR =>
                              END_REACHED := TRUE;
                         WHEN OTHERS =>
                              COMMENT ("UNEXPECTED EXCEPTION RAISED " &
                                      "DURING READING");
                              COMMENT("OVERWRITING DOES NOT TRUNCATE "&
                                      "AND MAKES PREVIOUS DATA "      &
                                      "ERRONEOUS");
                              RAISE INCOMPLETE;
                    END;
               END LOOP;
               IF COUNT = 12 THEN
                    COMMENT ("OVERWRITING TRUNCATES THE FILE TO THE " &
                             "LAST ELEMENT WRITTEN");
               ELSIF COUNT <= 25 THEN
                    COMMENT ("OVERWRITING TRUNCATED, BUT NOT AT LAST " &
                             "ELEMENT");
               ELSE
                    COMMENT ("OVERWRITING DOES NOT TRUNCATE");
               END IF;
          END IF;
     END;

     BEGIN
          DELETE (FILE1);
     EXCEPTION
          WHEN USE_ERROR =>
               NULL;
     END;

     RESULT;

EXCEPTION
     WHEN INCOMPLETE =>
          RESULT;

END CE2208B;
