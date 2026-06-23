-- C83033A.ADA

-- OBJECTIVE:
--     CHECK THAT AN IMPLICIT DECLARATION OF A BLOCK NAME, A LOOP NAME,
--     OR A STATEMENT LABEL HIDES THE DECLARATION OF AN ENUMERATION
--     LITERAL OR OF A DERIVED SUBPROGRAM DECLARED BY A DERIVED TYPE
--     DEFINITION.

-- HISTORY:
--     DHH 09/21/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE C83033A IS

     PACKAGE BASE_P IS
          TYPE A IS (RED, BLUE, YELO);
          FUNCTION RED(T : INTEGER; X : A) RETURN A;
          FUNCTION BLUE(T : INTEGER; X : A) RETURN A;
          FUNCTION YELO(T : INTEGER; X : A) RETURN A;
     END BASE_P;

     PACKAGE BODY BASE_P IS
          FUNCTION RED(T : INTEGER; X : A) RETURN A IS
          BEGIN
               IF EQUAL(T, T) THEN
                    RETURN X;
               ELSE
                    RETURN YELO;
               END IF;
          END RED;

          FUNCTION BLUE(T : INTEGER; X : A) RETURN A IS
          BEGIN
               IF EQUAL(T, T) THEN
                    RETURN X;
               ELSE
                    RETURN YELO;
               END IF;
          END BLUE;

          FUNCTION YELO(T : INTEGER; X : A) RETURN A IS
          BEGIN
               IF EQUAL(T, T) THEN
                    RETURN X;
               ELSE
                    RETURN YELO;
               END IF;
          END YELO;

     END BASE_P;
BEGIN
     TEST ("C83033A", "CHECK THAT AN IMPLICIT DECLARATION OF A BLOCK " &
                      "NAME, A LOOP NAME, OR A STATEMENT LABEL HIDES " &
                      "THE DECLARATION OF AN ENUMERATION LITERAL OR " &
                      "OF A DERIVED SUBPROGRAM DECLARED BY A DERIVED " &
                      "TYPE DEFINITION");

     B1:
     DECLARE
          TYPE STMT2 IS NEW BASE_P.A;
     BEGIN

          DECLARE
               C, D : STMT2;
               A : STMT2 := RED;
               B : STMT2 := RED(3, RED);
          BEGIN
               C := C83033A.B1.RED(3, C83033A.B1.RED);
               D := C83033A.B1.RED;

     <<RED>>   NULL;
               IF A /= B AND C /= D AND B /= D THEN
                    FAILED("STATEMENT LABEL");
               END IF;

               IF IDENT_INT(1) = IDENT_INT(3) THEN
                    GOTO RED;
               END IF;
          END;
     END B1;

     B2:
     DECLARE
          TYPE STMT2 IS NEW BASE_P.A;
     BEGIN

          DECLARE
               C, D : STMT2;
               A : STMT2 := BLUE;
               B : STMT2 := BLUE(3, BLUE);
          BEGIN
               C := C83033A.B2.BLUE(3, C83033A.B2.BLUE);
               D := C83033A.B2.BLUE;

               BLUE:
               FOR I IN 1 .. 1 LOOP
                    IF A /= B AND C /= D AND B /= D THEN
                         FAILED("LOOP NAME");
                    END IF;
                    EXIT BLUE;
               END LOOP BLUE;
          END;
     END B2;

     B3:
     DECLARE
          TYPE STMT2 IS NEW BASE_P.A;
     BEGIN

          DECLARE
               C, D : STMT2;
               A : STMT2 := YELO;
               B : STMT2 := YELO(3, YELO);
          BEGIN
               C := C83033A.B3.YELO(3, C83033A.B3.YELO);
               D := C83033A.B3.YELO;

               YELO:
               DECLARE
                    E : STMT2 := STMT2'PRED(C83033A.B3.YELO);
               BEGIN
                    IF A /= B AND C /= D AND B /= D AND A /=
                       STMT2'SUCC(E) THEN
                         FAILED("BLOCK NAME");
                    END IF;
                    YELO.E := RED;
               END YELO;
          END;
     END B3;

     B4:
     DECLARE
          PACKAGE P IS
               GLOBAL : INTEGER := 1;
               TYPE ENUM IS (GREEN, BLUE);
               TYPE PRIV IS PRIVATE;
               FUNCTION GREEN RETURN PRIV;
          PRIVATE
               TYPE PRIV IS NEW ENUM;
               TYPE NT IS NEW PRIV;
          END P;

          PACKAGE BODY P IS
               FUNCTION GREEN RETURN PRIV IS
               BEGIN
                    GLOBAL := GLOBAL + 1;
                    RETURN BLUE;
               END GREEN;
          BEGIN
               NULL;
          END P;
          USE P;
     BEGIN
          GREEN:
          DECLARE
               COLOR : PRIV := C83033A.B4.P.GREEN;
          BEGIN
               GREEN.COLOR := GREEN.COLOR;
          END GREEN;
     END B4;

     RESULT;
END C83033A;
