-- CE3804K.ADA

-- OBJECTIVE:
--     CHECK THAT FLOAT_IO RAISES DATA_ERROR WHEN:

--     (1) THERE IS NO DECIMAL POINT IN THE INPUT.
--     (2) DECIMAL POINT IS NOT PRECEDED OR FOLLOWED
--         BY A DIGIT.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH
--     SUPPORT TEXT FILES.

-- HISTORY:
--     VKG 02/04/83
--     CPP 07/30/84
--     RJW 11/04/86  REVISED TEST TO OUTPUT A NON_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     DWC 09/14/87  SPLIT CASE FOR FIXED_IO INTO CE3804L.ADA AND
--                   CORRECTED EXCEPTION HANDLING.

WITH TEXT_IO; USE TEXT_IO;
WITH REPORT; USE REPORT;

PROCEDURE CE3804K IS

     INCOMPLETE : EXCEPTION;

BEGIN
     TEST ("CE3804K","CHECK THAT DATA_ERROR IS RAISED BY FLOAT_IO " &
                     "GET WHEN THERE IS NO DECIMAL POINT IN THE " &
                     "INPUT OR THE DECIMAL POINT IS NOT " &
                     "PRECEDED OR FOLLOWED BY A DIGIT");

     DECLARE
          FT : FILE_TYPE;
     BEGIN

          BEGIN
               CREATE (FT, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED; TEXT " &
                                    "CREATE WITH OUT_FILE MODE - 1");
                    RAISE INCOMPLETE;
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED; TEXT " &
                                    "CREATE WITH OUT_FILE MODE - 1");
                    RAISE INCOMPLETE;
          END;

          PUT (FT, "2343E+2");
          NEW_LINE (FT);
          PUT (FT, ".21E-2");
          NEW_LINE (FT);
          PUT (FT, "234.E-12");
          NEW_LINE (FT);
          CLOSE (FT);

          DECLARE
               PACKAGE FL_IO IS NEW FLOAT_IO(FLOAT);
               USE FL_IO;
               X : FLOAT := 11.0;
               CH : CHARACTER;
          BEGIN

               BEGIN
                    OPEN (FT, IN_FILE, LEGAL_FILE_NAME);
               EXCEPTION
                    WHEN USE_ERROR =>
                         NOT_APPLICABLE ("USE_ERROR RAISED; TEXT " &
                                         "OPEN WITH IN_FILE MODE - 1");
                         RAISE INCOMPLETE;
               END;

               BEGIN
                    GET (FT, X);
                    FAILED ("DATA_ERROR NOT RAISED - (1)");
               EXCEPTION
                    WHEN DATA_ERROR =>
                         IF X /= 11.0 THEN
                              FAILED ("ACTUAL PARAMETER TO GET " &
                                      "AFFECTED ON DATA_ERROR");
                         END IF;
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED - (1)");
               END;

               BEGIN
                    IF END_OF_LINE (FT) THEN
                         FAILED ("GET STOPPED AT END OF LINE - (1)");
                    ELSE
                         GET (FT, CH);
                         IF CH /= 'E' THEN
                              FAILED ("GET STOPPED AT WRONG POSITION " &
                                      "- (1) : CHAR IS " & CH);
                         END IF;
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("GET AFTER (1) RAISED EXCEPTION");
               END;

               SKIP_LINE (FT);

               BEGIN
                    GET (FT, X);
                    FAILED ("DATA_ERROR NOT RAISED - (2)");
               EXCEPTION
                    WHEN DATA_ERROR =>
                         IF X /= 11.0 THEN
                              FAILED ("ACTUAL PARAMETER TO GET " &
                                      "AFFECTED ON DATA_ERROR");
                         END IF;
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED - (2)");
               END;

               BEGIN
                    IF END_OF_LINE (FT) THEN
                         FAILED ("GET STOPPED AT END OF LINE - (2)");
                    ELSE
                         GET (FT, CH);
                         IF CH /= '.' THEN
                              FAILED ("GET STOPPED AT WRONG POSITION " &
                                      "- (2): CHAR IS " & CH);
                         END IF;
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("GET AFTER (2) RAISED EXCEPTION");
               END;

               SKIP_LINE (FT);

               BEGIN
                    GET (FT, X);
                    FAILED ("DATA_ERROR NOT RAISED - (3)");
               EXCEPTION
                    WHEN DATA_ERROR =>
                         IF X /= 11.0 THEN
                              FAILED ("ACTUAL PARAMETER TO GET " &
                                      "AFFECTED ON DATA_ERROR");
                         END IF;
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED - (3)");
               END;

               BEGIN
                    IF END_OF_LINE (FT) THEN
                         FAILED ("GET STOPPED AT END OF LINE - (3)");
                    ELSE
                         GET (FT, CH);
                         IF CH /= 'E' THEN
                              FAILED ("GET STOPPED AT WRONG POSITION " &
                                      "- (3): CHAR IS " & CH);
                         END IF;
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("GET AFTER (3) RAISED EXCEPTION");
               END;

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

END CE3804K;
