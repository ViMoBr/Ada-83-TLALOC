-- C83030A.ADA

-- OBJECTIVE:
--     CHECK THAT WITHIN A GENERIC SUBPROGRAM BODY, NO SUBPROGRAM
--     DECLARED IN AN OUTER DECLARATIVE REGION IS HIDDEN (UNLESS THE
--     SUBPROGRAM IS A HOMOGRAPH OF THE GENERIC SUBPROGRAM).

-- HISTORY:
--     TBN 08/03/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE C83030A IS

     GLOBAL : INTEGER := IDENT_INT(INTEGER'FIRST);
     SWITCH1 : BOOLEAN := TRUE;

     PROCEDURE P IS
     BEGIN
          GLOBAL := IDENT_INT(1);
     END P;

     PROCEDURE P (X : INTEGER) IS
     BEGIN
          GLOBAL := IDENT_INT(X);
     END P;

BEGIN
     TEST ("C83030A", "CHECK THAT WITHIN A GENERIC SUBPROGRAM BODY, " &
                      "NO SUBPROGRAM DECLARED IN AN OUTER " &
                      "DECLARATIVE REGION IS HIDDEN " &
                      "(UNLESS THE SUBPROGRAM IS A HOMOGRAPH OF THE " &
                      "GENERIC SUBPROGRAM)");

     ONE:
     DECLARE
          GENERIC
          PROCEDURE P;

          PROCEDURE P IS
               A : INTEGER := IDENT_INT(2);
          BEGIN
               IF SWITCH1 THEN
                    SWITCH1 := FALSE;
                    P;
                    IF GLOBAL /= IDENT_INT(3) THEN
                         FAILED ("INCORRECT VALUE FOR PROCEDURE CALL " &
                                 "- 1");
                    END IF;
               END IF;
               P(A);
               IF GLOBAL /= IDENT_INT(2) THEN
                    FAILED ("INCORRECT VALUE FOR PROCEDURE CALL - 2");
               END IF;
               GLOBAL := IDENT_INT(3);
          END P;

          PROCEDURE NEW_P IS NEW P;

     BEGIN
          IF GLOBAL /= IDENT_INT(INTEGER'FIRST) THEN
               FAILED ("INCORRECT VALUE FOR START OF TEST ONE");
          END IF;
          NEW_P;
          IF GLOBAL /= IDENT_INT(3) THEN
               FAILED ("INCORRECT VALUE FOR END OF TEST ONE");
          END IF;
     END ONE;


     TWO:
     DECLARE
          GLOBAL : INTEGER := IDENT_INT(INTEGER'FIRST);
          SWITCH : BOOLEAN := TRUE;

          GENERIC
               TYPE T IS (<>);
          PROCEDURE P (X : T);

          PROCEDURE P (X : T) IS
               A : T := T'FIRST;
          BEGIN
               IF SWITCH THEN
                    SWITCH := FALSE;
                    P (X);
                    IF GLOBAL /= IDENT_INT(2) THEN
                         FAILED ("INCORRECT VALUE FOR PROCEDURE CALL " &
                                 "- 20");
                    END IF;
                    GLOBAL := IDENT_INT(3);
               ELSE
                    GLOBAL := IDENT_INT(2);
               END IF;
          END P;

          PROCEDURE NEW_P IS NEW P (INTEGER);

     BEGIN
          IF GLOBAL /= IDENT_INT(INTEGER'FIRST) THEN
               FAILED ("INCORRECT VALUE FOR START OF TEST TWO");
          END IF;
          NEW_P (1);
          IF GLOBAL /= IDENT_INT(3) THEN
               FAILED ("INCORRECT VALUE FOR END OF TEST TWO");
          END IF;
     END TWO;


     THREE:
     DECLARE
          SWITCH : BOOLEAN := TRUE;

          FUNCTION F RETURN INTEGER IS
          BEGIN
               RETURN IDENT_INT(1);
          END F;

          FUNCTION F RETURN BOOLEAN IS
          BEGIN
               RETURN IDENT_BOOL(FALSE);
          END F;

          FUNCTION F (X : INTEGER) RETURN INTEGER IS
          BEGIN
               RETURN IDENT_INT(X);
          END F;

     BEGIN
          DECLARE
               GENERIC
               FUNCTION F RETURN INTEGER;

               FUNCTION F RETURN INTEGER IS
                    A : INTEGER := INTEGER'LAST;
               BEGIN
                    IF SWITCH THEN
                         SWITCH := FALSE;
                         IF F /= IDENT_INT(3) THEN
                              FAILED ("INCORRECT VALUE FROM FUNCTION " &
                                      "CALL - 30");
                         END IF;
                    END IF;
                    IF F(A) /= IDENT_INT(INTEGER'LAST) THEN
                         FAILED ("INCORRECT VALUE FROM FUNCTION CALL " &
                                 "- 31");
                    END IF;
                    IF F THEN
                         FAILED ("INCORRECT VALUE FROM FUNCTION CALL " &
                                 "- 32");
                    END IF;
                    RETURN IDENT_INT(3);
               END F;

               FUNCTION NEW_F IS NEW F;

          BEGIN
               IF NEW_F /= IDENT_INT(3) THEN
                    FAILED ("INCORRECT VALUE FOR END OF TEST THREE");
               END IF;
          END;
     END THREE;


     FOUR:
     DECLARE
          SWITCH : BOOLEAN := TRUE;

          FUNCTION F RETURN INTEGER IS
          BEGIN
               RETURN IDENT_INT(1);
          END F;

          FUNCTION F RETURN BOOLEAN IS
          BEGIN
               RETURN IDENT_BOOL(FALSE);
          END F;

     BEGIN
          DECLARE
               GENERIC
                    TYPE T IS (<>);
               FUNCTION F RETURN T;

               FUNCTION F RETURN T IS
                    A : T := T'LAST;
               BEGIN
                    IF SWITCH THEN
                         SWITCH := FALSE;
                         IF F /= T'LAST THEN
                              FAILED ("INCORRECT VALUE FROM FUNCTION " &
                                      "CALL - 40");
                         END IF;
                         RETURN T'FIRST;
                    ELSE
                         IF F THEN
                              FAILED ("INCORRECT VALUE FROM FUNCTION " &
                                      "CALL - 41");
                         END IF;
                         RETURN T'LAST;
                    END IF;
               END F;

               FUNCTION NEW_F IS NEW F (INTEGER);

          BEGIN
               IF NEW_F /= IDENT_INT(INTEGER'FIRST) THEN
                    FAILED ("INCORRECT VALUE FOR END OF TEST FOUR");
               END IF;
          END;
     END FOUR;

     RESULT;
END C83030A;
