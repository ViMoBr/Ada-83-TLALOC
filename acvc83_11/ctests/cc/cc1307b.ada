-- CC1307B.ADA

-- OBJECTIVE:
--     CHECK THAT AN ENUMERATION LITERAL (BOTH AN IDENTIFIER AND A
--     CHARACTER LITERAL) MAY BE USED AS A DEFAULT SUBPROGRAM NAME
--     AND AS A DEFAULT INITIAL VALUE FOR AN OBJECT PARAMETER.

-- HISTORY:
--     BCB 08/09/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE CC1307B IS

     TYPE ENUM IS (R, 'S', R1);

BEGIN
     TEST ("CC1307B", "CHECK THAT AN ENUMERATION LITERAL (BOTH AN " &
                      "IDENTIFIER AND A CHARACTER LITERAL) MAY BE " &
                      "USED AS A DEFAULT SUBPROGRAM NAME AND AS A " &
                      "DEFAULT INITIAL VALUE FOR AN OBJECT PARAMETER");

     DECLARE
          GENERIC
               WITH FUNCTION J RETURN ENUM IS R;
               WITH FUNCTION K RETURN ENUM IS 'S';
               OBJ1 : ENUM := R;
               OBJ2 : ENUM := 'S';
          PACKAGE P IS
          END P;

          PACKAGE BODY P IS
               VAR1, VAR2 : ENUM := R1;
          BEGIN
               VAR1 := J;

               IF VAR1 /= R THEN
                    FAILED ("WRONG VALUE FOR DEFAULT SUBPROGRAM " &
                            "NAME - IDENTIFIER");
               END IF;

               VAR2 := K;

               IF VAR2 /= 'S' THEN
                    FAILED ("WRONG VALUE FOR DEFAULT SUBPROGRAM " &
                            "NAME - CHARACTER LITERAL");
               END IF;

               IF OBJ1 /= R THEN
                    FAILED ("WRONG VALUE FOR OBJECT PARAMETER - " &
                            "IDENTIFIER");
               END IF;

               IF OBJ2 /= 'S' THEN
                    FAILED ("WRONG VALUE FOR OBJECT PARAMETER - " &
                            "CHARACTER LITERAL");
               END IF;
          END P;

          PACKAGE NEW_P IS NEW P;
     BEGIN
          NULL;
     END;

     RESULT;
END CC1307B;
