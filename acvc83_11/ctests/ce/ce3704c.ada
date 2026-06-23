-- CE3704C.ADA

-- OBJECTIVE:
--     CHECK THAT INTEGER_IO GET RAISES CONSTRAINT_ERROR IF THE
--     WIDTH PARAMETER IS NEGATIVE, IF THE WIDTH PARAMETER IS
--     GREATER THAN FIELD'LAST WHEN FIELD'LAST IS LESS THAN
--     INTEGER'LAST, OR THE VALUE READ IS OUT OF THE RANGE OF
--     THE ITEM PARAMETER BUT WITHIN THE RANGE OF INSTANTIATED
--     TYPE.

-- HISTORY:
--     SPS 10/04/82
--     DWC 09/09/87  ADDED CASES FOR WIDTH BEING GREATER THAN
--                   FIELD'LAST AND THE VALUE BEING READ IS OUT
--                   OF ITEM'S RANGE BUT WITHIN INSTANTIATED
--                   RANGE.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;

PROCEDURE CE3704C IS
     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("CE3704C", "CHECK THAT INTEGER_IO GET RAISES " &
                      "CONSTRAINT_ERROR IF THE WIDTH PARAMETER " &
                      "IS NEGATIVE, IF THE WIDTH PARAMETER IS " &
                      "GREATER THAN FIELD'LAST WHEN FIELD'LAST IS " &
                      "LESS THAN INTEGER'LAST, OR THE VALUE READ " &
                      "IS OUT OF THE RANGE OF THE ITEM PARAMETER " &
                      "BUT WITHIN THE RANGE OF INSTANTIATED TYPE");

     DECLARE
          FT : FILE_TYPE;
          TYPE INT IS NEW INTEGER RANGE 1 .. 10;
          PACKAGE IIO IS NEW INTEGER_IO (INT);
          X : INT RANGE 1 .. 5;
          USE IIO;
     BEGIN

          BEGIN
               GET (FT, X, IDENT_INT(-1));
               FAILED ("CONSTRAINT_ERROR NOT RAISED - FILE");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN STATUS_ERROR =>
                    FAILED ("RAISED STATUS_ERROR");
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - FILE");
          END;

          BEGIN
               GET (X, IDENT_INT(-6));
               FAILED ("CONSTRAINT_ERROR NOT RAISED - DEFAULT");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - DEFAULT");
          END;

          BEGIN
               CREATE (FT, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED; TEXT CREATE " &
                                    "WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED; TEXT CREATE " &
                                    "WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
          END;

          PUT (FT, 1);
          NEW_LINE (FT);
          PUT (FT, 8);
          NEW_LINE (FT);
          PUT (FT, 2);

          CLOSE (FT);

          BEGIN
               OPEN (FT, IN_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR FOR OPEN " &
                                    "WITH IN_FILE MODE");
                    RAISE INCOMPLETE;
          END;

          BEGIN
               GET (FT, X, IDENT_INT(-1));
               FAILED ("CONSTRAINT_ERROR NOT RAISED - " &
                       "NEGATIVE WIDTH WITH EXTERNAL FILE");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - " &
                            "NEGATIVE WIDTH WITH EXTERNAL FILE");
          END;

          SKIP_LINE (FT);

          BEGIN
               GET (FT, X);
               FAILED ("CONSTRAINT_ERROR NOT RAISED - " &
                       "OUT OF RANGE");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - " &
                            "OUT OF RANGE");
          END;

          SKIP_LINE (FT);

          IF FIELD'LAST < INTEGER'LAST THEN
               BEGIN
                    GET (FT, X, FIELD'LAST + 1);
                    FAILED ("CONSTRAINT_ERROR NOT RAISED - " &
                            "FIELD'LAST + 1 WIDTH WITH " &
                            "EXTERNAL FILE");
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED - " &
                                 "FIELD'LAST + 1 WIDTH WITH " &
                                 "EXTERNAL FILE");
               END;
          END IF;

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
END CE3704C;
