-- CE2202A.ADA

-- OBJECTIVE:
--     CHECK THAT READ, WRITE, AND END_OF_FILE RAISE STATUS_ERROR
--     WHEN APPLIED TO A NON-OPEN SEQUENTIAL FILE.  USE_ERROR IS
--     NOT PERMITTED.

-- HISTORY:
--     ABW 08/17/82
--     SPS 09/13/82
--     SPS 11/09/82
--     EG  11/26/84
--     EG  05/16/85
--     GMT 07/24/87  REPLACED CALL TO REPORT.COMMENT WITH "NULL;".

WITH REPORT; USE REPORT;
WITH SEQUENTIAL_IO;

PROCEDURE CE2202A IS

     PACKAGE SEQ IS NEW SEQUENTIAL_IO (INTEGER);
     USE SEQ;
     FILE1, FILE2 : FILE_TYPE;
     CNST : CONSTANT INTEGER := 101;
     IVAL : INTEGER;
     BOOL : BOOLEAN;

BEGIN
     TEST ("CE2202A","CHECK THAT READ, WRITE, AND "    &
                     "END_OF_FILE RAISE STATUS_ERROR " &
                     "WHEN APPLIED TO A NON-OPEN "     &
                     "SEQUENTIAL FILE");
     BEGIN
          BEGIN
               WRITE (FILE1,CNST);
               FAILED ("STATUS_ERROR NOT RAISED WHEN WRITE APPLIED " &
                       "TO NON-EXISTENT FILE");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED WHEN WRITE " &
                            "APPLIED TO NON-EXISTENT FILE");
          END;

          BEGIN
               READ (FILE1,IVAL);
               FAILED ("STATUS_ERROR NOT RAISED WHEN READ APPLIED " &
                       "TO NON-EXISTENT FILE");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED WHEN READ " &
                            "APPLIED TO NON-EXISTENT FILE");
          END;

          BEGIN
               BOOL := END_OF_FILE (FILE1);
               FAILED ("STATUS_ERROR NOT RAISED WHEN END_OF_FILE " &
                       "APPLIED TO NON-EXISTENT FILE");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED WHEN END_OF_FILE " &
                            "APPLIED TO NON-EXISTENT FILE");
          END;
     END;

     BEGIN
          BEGIN
               CREATE (FILE2);
               CLOSE (FILE2);
          EXCEPTION
               WHEN USE_ERROR =>
                    NULL; -- IF FILE2 CANNOT BE CREATED THEN WE WILL
                          -- BE REPEATING EARLIER TESTS, BUT THAT'S OK.
          END;

          BEGIN
               WRITE (FILE2,CNST);
               FAILED ("STATUS_ERROR NOT RAISED WHEN WRITE APPLIED " &
                       "TO FILE2");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED WHEN WRITE " &
                            "APPLIED TO FILE2");
          END;

          BEGIN
               READ (FILE2,IVAL);
               FAILED ("STATUS_ERROR NOT RAISED WHEN READ APPLIED " &
                       "TO FILE2");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED WHEN READ " &
                            "APPLIED TO FILE2");
          END;

          BEGIN
               BOOL := END_OF_FILE (FILE2);
               FAILED ("STATUS_ERROR NOT RAISED WHEN END_OF_FILE " &
                       "APPLIED TO FILE2");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED WHEN END_OF_FILE " &
                            "APPLIED TO FILE2");
          END;

     END;

     RESULT;

END CE2202A;
