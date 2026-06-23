-- CE3401A.ADA

-- OBJECTIVE:
--     CHECK THAT THE FORMAL PARAMETERS OF EACH COLUMN, LINE, AND
--     PAGE OPERATION ARE NAMED CORRECTLY.

-- HISTORY:
--     JET 08/17/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;
PROCEDURE CE3401A IS

     FIN, FOUT : FILE_TYPE;
     B : BOOLEAN;
     C : COUNT;
     FILE_OK : BOOLEAN := FALSE;

BEGIN
     TEST ("CE3401A", "CHECK THAT THE FORMAL PARAMETERS OF EACH " &
                      "COLUMN, LINE, AND PAGE OPERATION ARE NAMED " &
                      "CORRECTLY");

     BEGIN
          CREATE(FOUT, OUT_FILE, LEGAL_FILE_NAME);
          FILE_OK := TRUE;
     EXCEPTION
          WHEN OTHERS =>
               NOT_APPLICABLE("OUTPUT FILE COULD NOT BE CREATED");
     END;

     IF FILE_OK THEN
          NEW_LINE(FILE => FOUT, SPACING => 1);
          NEW_PAGE(FILE => FOUT);
          SET_COL(FILE => FOUT, TO => 1);
          SET_LINE(FILE => FOUT, TO => 1);
          C := COL(FILE => FOUT);
          C := LINE(FILE => FOUT);
          C := PAGE(FILE => FOUT);

          NEW_PAGE(FOUT);

          BEGIN
               CLOSE(FOUT);
          EXCEPTION
               WHEN OTHERS =>
                    FAILED("OUTPUT FILE COULD NOT BE CLOSED");
                    FILE_OK := FALSE;
          END;
     END IF;

     IF FILE_OK THEN
          BEGIN
               OPEN(FIN, IN_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN OTHERS =>
                    FAILED("INPUT FILE COULD NOT BE OPENED");
                    FILE_OK := FALSE;
          END;
     END IF;

     IF FILE_OK THEN
          SKIP_LINE(FILE => FIN, SPACING => 1);
          SKIP_PAGE(FILE => FIN);
          B := END_OF_LINE(FILE => FIN);
          B := END_OF_PAGE(FILE => FIN);
          B := END_OF_FILE(FILE => FIN);

          BEGIN
               DELETE(FIN);
          EXCEPTION
               WHEN USE_ERROR =>
                    COMMENT("FILE COULD NOT BE DELETED");
               WHEN OTHERS =>
                    FAILED("UNEXPECTED ERROR AT DELETION");
          END;
     END IF;

     RESULT;
EXCEPTION
     WHEN OTHERS =>
          FAILED("UNEXPECTED EXCEPTION RAISED");
END CE3401A;
