-- C74401K.ADA

-- CHECK THAT OUT PARAMETERS OF AN ENTRY DECLARATION CAN HAVE A LIMITED
-- PRIVATE TYPE IF THE ENTRY DECLARATION OCCURS IN THE VISIBLE PART OF A
-- PACKAGE SPECIFICATION, INCLUDING WITHIN PACKAGES NESTED IN A VISIBLE
-- PART.

-- CHECK THAT A RENAMING DECLARATION CAN RENAME AN ENTRY DECLARED
-- WITH AN OUT PARAMETER.

-- JBG 5/1/85

WITH REPORT; USE REPORT;
PROCEDURE C74401K IS

     PACKAGE PKG IS
          TYPE LP IS LIMITED PRIVATE;
          TASK P20 IS
               ENTRY TP20 (X : OUT LP);        -- OK.
               ENTRY RESET (X : OUT LP);
          END P20;
          FUNCTION EQ (L, R : LP) RETURN BOOLEAN;
          VAL1 : CONSTANT LP;

          PACKAGE NESTED IS
               TASK NEST1 IS
                    ENTRY TNEST1 (X : OUT LP);
               END NEST1;
          PRIVATE
               TASK NEST2 IS
                    ENTRY TNEST2 (X : OUT LP);
               END NEST2;
          END NESTED;
     PRIVATE
          TYPE LP IS NEW INTEGER;
          VAL1 : CONSTANT LP := LP(IDENT_INT(3));
     END PKG;

     VAR : PKG.LP;

     PACKAGE BODY PKG IS
          TASK BODY P20 IS
          BEGIN
               LOOP
                    SELECT
                         ACCEPT TP20 (X : OUT LP) DO
                              X := 3;
                         END TP20;
                    OR   
                         ACCEPT RESET (X : OUT LP) DO
                              X := 0;
                         END RESET;
                    OR
                         TERMINATE;
                    END SELECT;
               END LOOP;
          END P20;

          FUNCTION EQ (L, R : LP) RETURN BOOLEAN IS
          BEGIN
               RETURN L = R;
          END EQ;

          PACKAGE BODY NESTED IS
               TASK BODY NEST1 IS
               BEGIN
                    ACCEPT TNEST1 (X : OUT LP) DO
                         X := 3;
                    END TNEST1;
               END NEST1;

               TASK BODY NEST2 IS
               BEGIN
                    NULL;
               END NEST2;
          END NESTED;
     BEGIN
          VAR := LP(IDENT_INT(0));
     END PKG;

     PACKAGE PKG1 IS
          PROCEDURE P21 (X : OUT PKG.LP) RENAMES PKG.P20.TP20;   -- OK:
                                                            -- RENAMING.
     END PKG1;

BEGIN

     TEST ("C74401K", "CHECK THAT A PROCEDURE CAN HAVE AN OUT " &
                      "PARAMETER WITH A LIMITED PRIVATE TYPE");

     PKG.P20.RESET (VAR);
     PKG.P20.TP20 (VAR);

     IF NOT PKG.EQ (VAR, PKG.VAL1) THEN
          FAILED ("DIRECT CALL NOT CORRECT");
     END IF;

     PKG.P20.RESET (VAR);
     PKG1.P21 (VAR);

     IF NOT PKG.EQ (VAR, PKG.VAL1) THEN
          FAILED ("RENAMED CALL NOT CORRECT");
     END IF;

     PKG.P20.RESET (VAR);
     PKG.NESTED.NEST1.TNEST1 (VAR);

     IF NOT PKG.EQ (VAR, PKG.VAL1) THEN
          FAILED ("NESTED CALL NOT CORRECT");
     END IF;

     RESULT;

END C74401K;
