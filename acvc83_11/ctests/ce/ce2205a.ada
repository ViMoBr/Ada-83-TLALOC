-- CE2205A.ADA

-- OBJECTIVE:
--     CHECK WHETHER  READ  FOR A SEQUENTIAL FILE RAISES  DATA_ERROR OR
--     CONSTRAINT_ERROR WHEN AN ELEMENT IS READ THAT IS OUTSIDE THE
--     RANGE OF THE ITEM TYPE BUT WITHIN THE RANGE OF THE INSTANTIATED
--     TYPE, AND CHECK THAT READING CAN CONTINUE AFTER THE EXCEPTION
--     HAS BEEN HANDLED.

--          A) CHECK ENUMERATION TYPE.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH
--     SUPPORT SEQUENTIAL FILES.

-- HISTORY:
--     SPS 09/28/82
--     JBG 06/04/84
--     TBN 11/04/86  REVISED TEST TO OUTPUT A NON_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     GMT 07/24/87  RENAMED FROM CE2210A.ADA AND REMOVED THE USE OF
--                   RESET.
--     PWB 05/18/89  DELETED CALL TO FAILED WHEN NO EXCEPTION RAISED.

WITH REPORT; USE REPORT;
WITH SEQUENTIAL_IO;

PROCEDURE CE2205A IS
BEGIN

     TEST ("CE2205A", "CHECK WHETHER READ FOR A SEQUENTIAL FILE " &
                      "RAISES  DATA_ERROR OR CONSTRAINT_ERROR WHEN " &
                      "AN ELEMENT IS READ THAT IS OUTSIDE THE RANGE " &
                      "OF THE ITEM TYPE BUT WITHIN THE RANGE OF THE " &
                      "INSTANTIATED TYPE, AND CHECK THAT READING CAN " &
                      "CONTINUE AFTER THE EXCEPTION HAS BEEN HANDLED");
     DECLARE
          PACKAGE  SEQ  IS NEW  SEQUENTIAL_IO (CHARACTER);
          USE SEQ;
          FT : FILE_TYPE;
          SUBTYPE CH IS CHARACTER  RANGE 'A' .. 'D';
          X : CH;
          INCOMPLETE : EXCEPTION;
     BEGIN
          BEGIN
               CREATE (FT, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON SEQUENTIAL " &
                                    "CREATE WITH OUT_FILE MODE - 1");
                    RAISE INCOMPLETE;
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED ON SEQUENTIAL " &
                                    "CREATE WITH OUT_FILE MODE - 2");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON " &
                            "SEQUENTIAL CREATE - 3");
                    RAISE INCOMPLETE;
          END;

          WRITE (FT, 'A');
          WRITE (FT, 'M');
          WRITE (FT, 'B');
          WRITE (FT, 'C');

          CLOSE (FT);

          BEGIN
               OPEN  (FT, IN_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("OPEN WITH IN_FILE MODE IS NOT " &
                                    "SUPPORTED - 4");
               RAISE INCOMPLETE;
          END;

          -- BEGIN TEST

          READ (FT, X);
          IF X /= 'A' THEN
               FAILED ("INCORRECT VALUE FOR READ - 5");
          END IF;

          BEGIN
               READ (FT, X);
               COMMENT ("NO EXCEPTION RAISED FOR READ WITH ELEMENT " &
                       "OUT OF RANGE");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    COMMENT ("CONSTRAINT_ERROR RAISED FOR SCALAR "  &
                             "TYPES - 7");
               WHEN DATA_ERROR =>
                    COMMENT ("DATA_ERROR RAISED FOR SCALAR TYPES - 8");
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - 9");
          END;

          BEGIN
               READ (FT, X);
               IF X /= 'B' THEN
                    FAILED ("INCORRECT VALUE FOR READ - 10");
               END IF;

               READ (FT, X);
               IF X /= 'C' THEN
                    FAILED ("INCORRECT VALUE FOR READ - 11");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("UNABLE TO CONTINUE READING - 12");
                    RAISE INCOMPLETE;
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

END CE2205A;
