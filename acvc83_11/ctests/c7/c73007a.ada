-- C73007A.ADA

-- OBJECTIVE:
--     FOR PACKAGE ENTITIES REQUIRING BODIES, CHECK THAT THE ORDER OF
--     DECLARATIONS REQUIRED IN THE PACKAGE BODY NEED NOT BE THE SAME AS
--     THE ORDER OF THEIR DECLARATIONS IN THE PACKAGE SPECIFICATION.

-- HISTORY:
--     DHH 03/11/88 CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C73007A IS
     A,B,C,D : INTEGER := 1;
     PACKAGE PACK IS
          PROCEDURE PROC(X : IN INTEGER; Y : OUT INTEGER);
          FUNCTION FUNC(X : INTEGER) RETURN INTEGER;

          TASK TASK1 IS
               ENTRY PROC1(X : IN INTEGER; Y : OUT INTEGER);
               ENTRY FUNC1(X : IN INTEGER; Y : OUT INTEGER);
          END TASK1;

          PACKAGE PACK1 IS
               FUNCTION FUNC1(X : INTEGER) RETURN INTEGER;
               PROCEDURE PROC1(X : IN INTEGER; Y : OUT INTEGER);
          END PACK1;
     END PACK;

     PACKAGE BODY PACK IS
          FUNCTION FUNC(X : INTEGER) RETURN INTEGER IS
               Z : INTEGER;
          BEGIN
               Z := X;
               Z := IDENT_INT(Z + 5);
               RETURN Z;
          END;

          PROCEDURE PROC(X : IN INTEGER; Y : OUT INTEGER)IS
               Z : INTEGER;
          BEGIN
               Z := X;
               Z := IDENT_INT(Z + 6);
               Y := Z;
          END;

          PACKAGE BODY PACK1 IS

               PROCEDURE PROC1(X : IN INTEGER; Y : OUT INTEGER) IS
               BEGIN
                    Y := IDENT_INT(2) + X;
               END PROC1;

               FUNCTION FUNC1(X : INTEGER) RETURN INTEGER IS
                    Y : INTEGER;
               BEGIN
                    Y := IDENT_INT(7) + X;
                    RETURN Y;
               END FUNC1;
          END PACK1;

          TASK BODY TASK1 IS
               T : INTEGER;
          BEGIN
               ACCEPT FUNC1(X : IN INTEGER ; Y : OUT INTEGER) DO
                    Y := IDENT_INT(4) + X;
               END FUNC1;

               ACCEPT PROC1(X : IN INTEGER ; Y : OUT INTEGER) DO
                    Y := IDENT_INT(3) + X;
               END PROC1;
          END TASK1;
     END PACK;

USE PACK;
BEGIN
     TEST ("C73007A", "FOR PACKAGE ENTITIES REQUIRING BODIES, CHECK " &
                      "THAT THE ORDER OF DECLARATIONS REQUIRED IN " &
                      "THE PACKAGE BODY NEED NOT BE THE SAME AS THE " &
                      "ORDER OF THEIR DECLARATIONS IN THE PACKAGE " &
                      "SPECIFICATION");
     TASK1.FUNC1(1, D);
     TASK1.PROC1(1, C);

     IF FUNC(1) /= IDENT_INT(6) THEN
          FAILED("FUNCTION VALUE INCORRECT");
     END IF;

     PROC(1, A);
     IF A /= IDENT_INT(7) THEN
          FAILED("PROCEDURE VALUE INCORRECT");
     END IF;

     IF PACK1.FUNC1(1) /= IDENT_INT(8) THEN
          FAILED("PACK1 FUNCTION VALUE INCORRECT");
     END IF;

     PACK1.PROC1(1, B);
     IF B /= IDENT_INT(3) THEN
          FAILED("PACK1 PROCEDURE VALUE INCORRECT");
     END IF;

     IF C /= IDENT_INT(4) THEN
          FAILED("TASK ENTRY PROC1 VALUE INCORRECT");
     END IF;

     IF D /= IDENT_INT(5) THEN
          FAILED("TASK ENTRY FUNC1 VALUE INCORRECT");
     END IF;

     RESULT;

END C73007A;
