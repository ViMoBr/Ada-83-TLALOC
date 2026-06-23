-- C95092A.ADA

-- OBJECTIVE:
--     CHECK THAT FOR ENTRIES OF TASKS, DEFAULT VALUES OF ALL TYPES CAN
--     BE GIVEN FOR A FORMAL PARAMETER.

-- HISTORY:
--     DHH 03/22/88 CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE C95092A IS

     SUBTYPE INT IS INTEGER RANGE 1 ..10;
     TYPE FLT IS DIGITS 5;
     TYPE FIX IS DELTA 0.125 RANGE 0.0 .. 10.0;
     TYPE ENUM IS (RED, BLUE, YELLOW);
     SUBTYPE CHAR IS CHARACTER RANGE 'A' .. 'F';
     TYPE ARR IS ARRAY(1 .. 3) OF INTEGER;
     TYPE REC IS
          RECORD
               A : INT;
               B : ENUM;
               C : CHAR;
          END RECORD;

     FUNCTION IDENT_FLT(E : FLT) RETURN FLT IS
     BEGIN
          IF EQUAL(3,3) THEN
               RETURN E;
          ELSE
               RETURN 0.0;
          END IF;
     END IDENT_FLT;

     FUNCTION IDENT_FIX(E : FIX) RETURN FIX IS
     BEGIN
          IF EQUAL(3,3) THEN
               RETURN E;
          ELSE
               RETURN 0.0;
          END IF;
     END IDENT_FIX;

     FUNCTION IDENT_ENUM(E : ENUM) RETURN ENUM IS
     BEGIN
          IF EQUAL(3,3) THEN
               RETURN E;
          ELSE
               RETURN YELLOW;
          END IF;
     END IDENT_ENUM;

     FUNCTION IDENT_CHAR(E : CHAR) RETURN CHAR IS
     BEGIN
          IF EQUAL(3,3) THEN
               RETURN E;
          ELSE
               RETURN 'F';
          END IF;
     END IDENT_CHAR;

     FUNCTION IDENT_ARR(E : ARR) RETURN ARR IS
          Z : ARR := (3,2,1);
     BEGIN
          IF EQUAL(3,3) THEN
               RETURN E;
          ELSE
               RETURN Z;
          END IF;
     END IDENT_ARR;

     FUNCTION IDENT_REC(E : REC) RETURN REC IS
          Z : REC := (10, YELLOW, 'F');
     BEGIN
          IF EQUAL(3,3) THEN
               RETURN E;
          ELSE
               RETURN Z;
          END IF;
     END IDENT_REC;

     TASK TEST_DEFAULTS IS
          ENTRY BOOL(G : BOOLEAN := TRUE);
          ENTRY INTEGR(X : IN INT := 5);
          ENTRY FLOAT(Y : IN FLT := 1.25);
          ENTRY FIXED(Z : IN FIX := 1.0);
          ENTRY ENUMERAT(A : IN ENUM := RED);
          ENTRY CHARACTR(B : IN CHAR := 'A');
          ENTRY ARRY(C : IN ARR := (1, 2, 3));
          ENTRY RECD(D : IN REC := (5, RED, 'A'));
     END TEST_DEFAULTS;

     TASK BODY TEST_DEFAULTS IS
     BEGIN

          ACCEPT BOOL(G : BOOLEAN := TRUE) DO
               IF G /= IDENT_BOOL(TRUE) THEN
                    FAILED("BOOLEAN DEFAULT FAILED");
               END IF;
          END BOOL;

          ACCEPT INTEGR(X : IN INT := 5) DO
               IF X /= IDENT_INT(5) THEN
                    FAILED("INTEGER DEFAULT FAILED");
               END IF;
          END INTEGR;

          ACCEPT FLOAT(Y : IN FLT := 1.25) DO
               IF Y /= IDENT_FLT(1.25) THEN
                    FAILED("FLOAT DEFAULT FAILED");
               END IF;
          END FLOAT;

          ACCEPT FIXED(Z : IN FIX := 1.0) DO
               IF Z /= IDENT_FIX(1.0) THEN
                    FAILED("FIXED DEFAULT FAILED");
               END IF;
          END FIXED;

          ACCEPT ENUMERAT(A : IN ENUM := RED) DO
               IF A /= IDENT_ENUM(RED) THEN
                    FAILED("ENUMERATION DEFAULT FAILED");
               END IF;
          END ENUMERAT;

          ACCEPT CHARACTR(B : IN CHAR := 'A') DO
               IF B /= IDENT_CHAR('A') THEN
                    FAILED("CHARACTER DEFAULT FAILED");
               END IF;
          END CHARACTR;

          ACCEPT ARRY(C : IN ARR := (1, 2, 3)) DO
               FOR I IN 1 ..3 LOOP
                    IF C(I) /= IDENT_INT(I) THEN
                         FAILED("ARRAY " & INTEGER'IMAGE(I) &
                                "DEFAULT FAILED");
                    END IF;
               END LOOP;
          END ARRY;

          ACCEPT RECD(D : IN REC := (5, RED, 'A')) DO
               IF D.A /= IDENT_INT(5) THEN
                    FAILED("RECORD INTEGER DEFAULT FAILED");
               END IF;
               IF D.B /= IDENT_ENUM(RED) THEN
                    FAILED("RECORD ENUMERATION DEFAULT FAILED");
               END IF;
               IF D.C /= IDENT_CHAR('A') THEN
                    FAILED("RECORD CHARACTER DEFAULT FAILED");
               END IF;
          END RECD;

     END TEST_DEFAULTS;

BEGIN

     TEST("C95092A", "CHECK THAT FOR ENTRIES OF TASKS, DEFAULT " &
                     "VALUES OF ALL TYPES CAN BE GIVEN FOR A FORMAL " &
                     "PARAMETER");

          TEST_DEFAULTS.BOOL;
          TEST_DEFAULTS.INTEGR;
          TEST_DEFAULTS.FLOAT;
          TEST_DEFAULTS.FIXED;
          TEST_DEFAULTS.ENUMERAT;
          TEST_DEFAULTS.CHARACTR;
          TEST_DEFAULTS.ARRY;
          TEST_DEFAULTS.RECD;

     RESULT;
END C95092A;
