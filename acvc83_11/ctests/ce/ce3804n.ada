-- CE3804N.ADA

-- OBJECTIVE:
--     CHECK THAT FIXED_IO GET WILL RAISE DATA_ERROR IF THE
--     USE OF # AND : IN BASED LITERALS IS MIXED.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH
--     SUPPORT TEXT FILES.

-- HISTORY:
--     DWC 09/14/87  CREATED ORIGINAL TEST.

WITH TEXT_IO; USE TEXT_IO;
WITH REPORT; USE REPORT;

PROCEDURE CE3804N IS

     INCOMPLETE : EXCEPTION;

BEGIN
     TEST ("CE3804N", "CHECK THAT FIXED_IO GET WILL RAISE " &
                      "DATA_ERROR IF THE USE OF # AND : IN " &
                      "BASED LITERALS IS MIXED");

     DECLARE
          FT : FILE_TYPE;
     BEGIN

          BEGIN
               CREATE (FT, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED; TEXT " &
                                    "CREATE WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED; TEXT " &
                                    "CREATE WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
          END;

          PUT_LINE (FT, "2#1.1#E+2");   -- 2#1.1#E+2
          PUT_LINE (FT, "8:1.1:E-2");   -- 8:1.1:E-2
          PUT (FT, "4#1.001:");
          NEW_LINE (FT);
          PUT (FT, "3:2.341#");
          NEW_LINE (FT);
          PUT (FT, "2#1.0#E+1");
          NEW_LINE (FT);
          CLOSE (FT);

          DECLARE
               TYPE FX IS DELTA 0.001 RANGE 0.0 .. 6.0;
               PACKAGE FX_IO IS NEW FIXED_IO(FX);
               USE FX_IO;
               X : FX := 1.500;
          BEGIN

               BEGIN
                    OPEN (FT, IN_FILE, LEGAL_FILE_NAME);
               EXCEPTION
                    WHEN USE_ERROR =>
                         NOT_APPLICABLE ("USE_ERROR RAISED; TEXT " &
                                         "OPEN WITH IN_FILE MODE");
                         RAISE INCOMPLETE;
               END;

               GET (FT, X);
               IF X /= 2#1.1#E+2 THEN
                    FAILED ("DID NOT GET RIGHT VALUE - 1");
               END IF;

               GET (FT, X);
               IF X /= 8#1.1#E-2 THEN
                    FAILED ("DID NOT GET RIGHT VALUE - 2");
               END IF;

               BEGIN
                    X := 1.5;
                    GET (FT,X);
                    FAILED ("DATA_ERROR NOT RAISED - 1");
               EXCEPTION
                    WHEN DATA_ERROR =>
                         IF X /= 1.500 THEN
                              FAILED ("ACTUAL PARAMETER TO GET " &
                                      "AFFECTED ON DATA_ERROR - 1");
                         END IF;
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED - 1");
               END;

               SKIP_LINE (FT);

               BEGIN
                    GET (FT,X);
                    FAILED ("DATA_ERROR NOT RAISED - 2");
               EXCEPTION
                    WHEN DATA_ERROR =>
                         IF X /= 1.500 THEN
                              FAILED ("ACTUAL PARAMETER TO GET " &
                                      "AFFECTED ON DATA_ERROR - 2");
                         END IF;
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED - 2");
               END;

               SKIP_LINE (FT);

               GET (FT, X);
               IF X /= 2#1.0#E+1 THEN
                    FAILED ("DID NOT GET RIGHT VALUE - 3");
               END IF;

               BEGIN
                    DELETE (FT);
               EXCEPTION
                    WHEN USE_ERROR =>
                         NULL;
               END;
          END;

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE3804N;
