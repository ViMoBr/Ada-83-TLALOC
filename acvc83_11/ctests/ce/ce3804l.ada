-- CE3804L.ADA

-- OBJECTIVE:
--     CHECK THAT FIXED_IO RAISES DATA_ERROR WHEN:

--     (1) THERE IS NO DECIMAL POINT IN THE INPUT.
--     (2) DECIMAL POINT IS NOT PRECEDED OR FOLLOWED
--         BY A DIGIT.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH
--     SUPPORT TEXT FILES.

-- HISTORY:
--     DWC 09/14/87  CREATED ORIGINAL TEST.

WITH TEXT_IO; USE TEXT_IO;
WITH REPORT; USE REPORT;

PROCEDURE CE3804L IS

     INCOMPLETE : EXCEPTION;

BEGIN
     TEST ("CE3804L","CHECK THAT DATA_ERROR IS RAISED BY FIXED_IO " &
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
               TYPE FX IS DELTA 0.01 RANGE 100.00 .. 300.00;
               PACKAGE FX_IO IS NEW FIXED_IO (FX);
               USE FX_IO;
               X : FX := 150.00;
               CH : CHARACTER;
          BEGIN

               BEGIN
                    OPEN (FT, IN_FILE, LEGAL_FILE_NAME);
               EXCEPTION
                    WHEN USE_ERROR =>
                         NOT_APPLICABLE ("USE_ERROR RAISED; TEXT " &
                                         "OPEN WITH IN_FILE MODE");
                         RAISE INCOMPLETE;
               END;

               BEGIN
                    GET (FT,  X);
                    FAILED ("DATA_ERROR NOT RAISED - (1)");
               EXCEPTION
                    WHEN DATA_ERROR =>
                         IF X /= 150.00 THEN
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
                                      "- (1): CHAR IS " & CH);
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
                         IF X /= 150.00 THEN
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
                    FAILED ("DATA_ERROR NOT RAISED - (2)");
               EXCEPTION
                    WHEN DATA_ERROR =>
                         IF X /= 150.00 THEN
                              FAILED ("ACTUAL PARAMETER TO GET " &
                                      "AFFECTED ON DATA_ERROR");
                         END IF;
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED - (2)");
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

END CE3804L;
