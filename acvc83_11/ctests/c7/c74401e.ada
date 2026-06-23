-- C74401E.ADA

-- CHECK THAT OUT PARAMETERS HAVING A LIMITED PRIVATE TYPE CAN BE
-- DECLARED IN A PACKAGE SPECIFICATION, INCLUDING WITHIN PACKAGES
-- NESTED IN A VISIBLE PART.

-- CHECK THAT A RENAMING DECLARATION CAN RENAME A PROCEDURE DECLARED
-- WITH AN OUT PARAMETER.

-- JBG 5/1/85

WITH REPORT; USE REPORT;
PROCEDURE C74401E IS

     PACKAGE PKG IS
          TYPE LP IS LIMITED PRIVATE;
          PROCEDURE P20 (X : OUT LP);        -- OK.
          PROCEDURE RESET (X : OUT LP);
          FUNCTION EQ (L, R : LP) RETURN BOOLEAN;
          VAL1 : CONSTANT LP;

          PACKAGE NESTED IS
               PROCEDURE NEST1 (X : OUT LP);
          PRIVATE
               PROCEDURE NEST2 (X : OUT LP);
          END NESTED;
     PRIVATE
          TYPE LP IS NEW INTEGER;
          VAL1 : CONSTANT LP := LP(IDENT_INT(3));
     END PKG;

     VAR : PKG.LP;

     PACKAGE BODY PKG IS
          PROCEDURE P20 (X : OUT LP) IS
          BEGIN
               X := 3;
          END P20;

          PROCEDURE RESET (X : OUT LP) IS
          BEGIN
               X := LP(IDENT_INT(0));
          END RESET;

          FUNCTION EQ (L, R : LP) RETURN BOOLEAN IS
          BEGIN
               RETURN L = R;
          END EQ;

          PACKAGE BODY NESTED IS
               PROCEDURE NEST1 (X : OUT LP) IS
               BEGIN
                    X := 3;
               END NEST1;

               PROCEDURE NEST2 (X : OUT LP) IS
               BEGIN
                    X := LP(IDENT_INT(3));
               END NEST2;
          END NESTED;
     BEGIN
          VAR := LP(IDENT_INT(0));
     END PKG;

     PACKAGE PKG1 IS
          PROCEDURE P21 (X : OUT PKG.LP) RENAMES PKG.P20;   -- OK:
                                                            -- RENAMING.
     END PKG1;

BEGIN

     TEST ("C74401E", "CHECK THAT A PROCEDURE CAN HAVE AN OUT " &
                      "PARAMETER WITH A LIMITED PRIVATE TYPE");

     PKG.RESET (VAR);
     PKG.P20 (VAR);

     IF NOT PKG.EQ (VAR, PKG.VAL1) THEN
          FAILED ("DIRECT CALL NOT CORRECT");
     END IF;

     PKG.RESET (VAR);
     PKG1.P21 (VAR);

     IF NOT PKG.EQ (VAR, PKG.VAL1) THEN
          FAILED ("RENAMED CALL NOT CORRECT");
     END IF;

     PKG.RESET (VAR);
     PKG.NESTED.NEST1 (VAR);

     IF NOT PKG.EQ (VAR, PKG.VAL1) THEN
          FAILED ("NESTED CALL NOT CORRECT");
     END IF;

     RESULT;

END C74401E;
