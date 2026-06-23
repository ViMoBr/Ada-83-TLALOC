-- B83033B.ADA

-- OBJECTIVE:
--     CHECK THAT AN IMPLICIT DECLARATION OF A BLOCK NAME, A LOOP NAME,
--     OR A STATEMENT LABEL HIDES THE DECLARATION OF AN ENUMERATION
--     LITERAL OR OF A DERIVED SUBPROGRAM DECLARED BY A DERIVED TYPE
--     DEFINITION, SO THAT THE USE OF THE COMMON IDENTIFIER MUST
--     BE REJECTED IF IT WOULD BE LEGAL FOR THE HIDDEN LITERAL OR
--     SUBPROGRAM BUT AN ILLEGAL REFERENCE TO THE IMPLICITLY DECLARED
--     NAME OR LABEL.

-- HISTORY:
--     DHH 09/21/88  CREATED ORIGINAL TEST.

PROCEDURE B83033B IS
     PACKAGE GEN_P IS
          TYPE A IS (RED, BLUE, YELO);
          FUNCTION NEXT(X : A) RETURN A;
          FUNCTION RED(X : A) RETURN A;
          FUNCTION BLUE(X : A) RETURN A;
          FUNCTION YELO(X : A) RETURN A;
     END GEN_P;

     PACKAGE BODY GEN_P IS
          FUNCTION NEXT(X : A) RETURN A IS
          BEGIN
               RETURN X;
          END NEXT;

          FUNCTION RED(X : A) RETURN A IS
          BEGIN
               RETURN X;
          END RED;

          FUNCTION BLUE(X : A) RETURN A IS
          BEGIN
               RETURN X;
          END BLUE;

          FUNCTION YELO(X : A) RETURN A IS
          BEGIN
               RETURN X;
          END YELO;

     END GEN_P;

BEGIN

B1:  DECLARE
          TYPE STMT2 IS NEW GEN_P.A;
     BEGIN

          DECLARE
               C, D : STMT2;
          BEGIN
               C := NEXT(RED);                                -- ERROR:
               D := RED;                                      -- ERROR:
               C := RED(YELO);                                -- ERROR:

     <<RED>>   NULL;
          END;
     END B1;

B2:  DECLARE
          TYPE STMT2 IS NEW GEN_P.A;
     BEGIN

          DECLARE
               C, D : STMT2;
          BEGIN
               C := NEXT(BLUE);                               -- ERROR:
               D := BLUE;                                     -- ERROR:
               C := BLUE(RED);                                -- ERROR:

               BLUE:
               FOR I IN 1 .. 1 LOOP
                    NULL;
               END LOOP BLUE;
          END;
     END B2;

B3:  DECLARE
          TYPE STMT2 IS NEW GEN_P.A;
     BEGIN

          DECLARE
               C, D : STMT2;
          BEGIN
               C := NEXT(YELO);                               -- ERROR:
               D := YELO;                                     -- ERROR:
               C := YELO(RED);                                -- ERROR:

     YELO:     DECLARE
               BEGIN
                    NULL;
               END YELO;
          END;
     END B3;

END B83033B;
