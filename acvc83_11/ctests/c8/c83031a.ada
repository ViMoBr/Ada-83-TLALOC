-- C83031A.ADA

-- OBJECTIVE:
--     CHECK THAT AN IMPLICIT DECLARATION OF A PREDEFINED OPERATOR OR
--     AN ENUMERATION LITERAL IS HIDDEN BY A SUBPROGRAM DECLARATION OR
--     A RENAMING DECLARATION WHICH DECLARES A HOMOGRAPH OF THE
--     OPERATOR OR LITERAL.

-- HISTORY:
--     VCL  08/10/88  CREATED ORIGINAL TEST.

WITH REPORT;  USE REPORT;
PROCEDURE C83031A IS
BEGIN
     TEST ("C83031A", "AN IMPLICIT DECLARATION OF A PREDEFINED " &
                      "OPERATOR OR AN ENUMERATION LITERAL IS HIDDEN " &
                      "BY A SUBPROGRAM DECLARATION OR A RENAMING " &
                      "DECLARATION WHICH DECLARES A HOMOGRAPH OF THE " &
                      "OPERATOR OR LITERAL");

     DECLARE             -- CHECK SUBPROGRAM DECLARATIONS OF OPERATORS
          PACKAGE P IS
               TYPE INT IS RANGE -20 .. 20;

               M : INT := 3 * INT(IDENT_INT(3));
               N : INT := 4 + INT(IDENT_INT(4));
               O : INT := 7 - INT(IDENT_INT(4));

               FUNCTION "*" (LEFT, RIGHT : INT) RETURN INT;
               FUNCTION "-" (MINUEND, SUBTRAHEND : INT) RETURN INT
                            RENAMES "+";
               TYPE INT2 IS PRIVATE;
               FUNCTION "+" (LEFT, RIGHT : INT2) RETURN INT2;
          PRIVATE
               FUNCTION "+" (LEFT, RIGHT : INT) RETURN INT;

               TYPE INT2 IS RANGE -20 .. 20;
          END P;
          USE P;

          PACKAGE BODY P IS
               FUNCTION "*" (LEFT, RIGHT : INT) RETURN INT IS
               BEGIN
                    RETURN LEFT / RIGHT;
               END "*";

               FUNCTION "+" (LEFT, RIGHT : INT) RETURN INT IS
               BEGIN
                    RETURN INT (INTEGER (LEFT) - INTEGER (RIGHT));
               END "+";

               FUNCTION "+" (LEFT, RIGHT : INT2) RETURN INT2 IS
               BEGIN
                    RETURN LEFT - RIGHT;
               END "+";

          BEGIN
               IF 2 * INT(IDENT_INT(2)) /= 1 THEN
                    FAILED ("INCORRECT VALUE RETURNED IN CALL TO " &
                            "EXPLICIT '*' OPERATOR - 1");
               END IF;

               IF N /= 8 THEN
                    FAILED ("INCORRECT INITIAL VALUE FOR N - 1");
               END IF;
               N := 2 + 2;
               IF N /= INT(IDENT_INT (0)) THEN
               FAILED ("INCORRECT VALUE FOR N AFTER CALL TO " &
                       "EXPLICIT '+' OPERATOR - 1");
               END IF;

               IF O /= 3 THEN
                    FAILED ("INCORRECT INITIAL VALUE FOR O - 1");
               END IF;
               O := 9 - INT(IDENT_INT(2));
               IF O /= 11 THEN
                    FAILED ("INCORRECT VALUE FOR O AFTER CALL TO " &
                            "EXPLICIT '-' OPERATOR - 1");
               END IF;

               DECLARE
                    Q : INT2 := 8 + 9;
               BEGIN
                    IF Q /= -1 THEN
                         FAILED ("INCORRECT VALUE FOR Q");
                    END IF;
               END;
          END P;
     BEGIN
          IF M /= 9 THEN
               FAILED ("INCORRECT INITIAL VALUE FOR M - 2");
          END IF;
          IF 2 * INT(IDENT_INT(2)) /= 1 THEN
               FAILED ("INCORRECT VALUE RETURNED IN CALL TO " &
                       "EXPLICIT '*' OPERATOR - 2");
          END IF;

          N := 2 + 2;
          IF N /= INT(IDENT_INT (4)) THEN
               FAILED ("INCORRECT VALUE FOR N AFTER CALL TO " &
                       "IMPLICIT '+' OPERATOR - 2");
          END IF;

          O := 9 - INT(IDENT_INT(2));
          IF O /= 11 THEN
               FAILED ("INCORRECT VALUE FOR O AFTER CALL TO " &
                       "EXPLICIT '-' OPERATOR - 2");
          END IF;
     END;

     DECLARE   -- CHECK SUBPROGRAM DECLARATIONS OF ENUMERATION LITERALS.

          PACKAGE P1 IS
               TYPE ENUM1 IS (E11, E12, E13);
               TYPE PRIV1 IS PRIVATE;
               FUNCTION E11 RETURN PRIV1;
          PRIVATE
               TYPE PRIV1 IS NEW ENUM1;
               FUNCTION E12 RETURN PRIV1 RENAMES E13;
          END P1;
          USE P1;

          E13 : INTEGER := IDENT_INT (5);

          PACKAGE P2 IS
               TYPE ENUM2 IS (E21, E22, E23);
          END P2;
          USE P2;

          TYPE PRIV2 IS NEW ENUM2;
          FUNCTION E22 RETURN PRIV2 RENAMES E23;

          FUNCTION E21 RETURN PRIV2 IS
          BEGIN
               RETURN E23;
          END E21;

          FUNCTION CHECK (E: ENUM1) RETURN INTEGER IS
          BEGIN
               RETURN ENUM1'POS (E);
          END CHECK;

          FUNCTION CHECK (E: INTEGER) RETURN INTEGER IS
          BEGIN
               RETURN INTEGER'POS (E);
          END CHECK;

          PACKAGE BODY P1 IS
               FUNCTION E11 RETURN PRIV1 IS
               BEGIN
                    RETURN E13;
               END E11;
          BEGIN
               IF PRIV1'(E11) /= E13 THEN
                    FAILED ("INCORRECT VALUE FOR E11");
               END IF;

               IF E12 /= PRIV1'LAST THEN
                    FAILED ("INCORRECT VALUE FOR E12");
               END IF;
          END P1;
     BEGIN
          IF PRIV2'(E21) /= E23 THEN
               FAILED ("INCORRECT VALUE FOR E21");
          END IF;

          IF E22 /= PRIV2'LAST THEN
               FAILED ("INCORRECT VALUE FOR E22");
          END IF;

          IF CHECK (E13) /= 5 THEN
               FAILED ("INCORRECT VALUE FOR E13");
          END IF;
     END;
     RESULT;
END C83031A;
