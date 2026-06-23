-- C95078A.ADA

-- OBJECTIVE:
--     CHECK THAT AN EXCEPTION RAISED DURING THE EXECUTION OF AN ACCEPT
--     STATEMENT CAN BE HANDLED WITHIN THE ACCEPT BODY.

-- HISTORY:
--     DHH 03/21/88 CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE C95078A IS

BEGIN

     TEST("C95078A", "CHECK THAT AN EXCEPTION RAISED DURING THE " &
                     "EXECUTION OF AN ACCEPT STATEMENT CAN BE " &
                     "HANDLED WITHIN THE ACCEPT BODY");

     DECLARE
          O,PT,QT,R,S,TP,B,C,D :INTEGER := 0;
          TASK TYPE PROG_ERR IS
               ENTRY START(M,N,A : IN OUT INTEGER);
               ENTRY STOP;
          END PROG_ERR;

          TASK T IS
               ENTRY START(M,N,A : IN OUT INTEGER);
               ENTRY STOP;
          END T;

          TYPE REC IS
               RECORD
                    B : PROG_ERR;
               END RECORD;

          TYPE ACC IS ACCESS PROG_ERR;

          SUBTYPE X IS INTEGER RANGE 1 .. 10;

          PACKAGE P IS
               OBJ : REC;
          END P;

          TASK BODY PROG_ERR IS
               FAULT : X;
          BEGIN
               ACCEPT START(M,N,A : IN OUT INTEGER) DO
                    BEGIN
                         M := IDENT_INT(1);
                         FAULT := IDENT_INT(11);
                         FAULT := IDENT_INT(FAULT);
                    EXCEPTION
                         WHEN CONSTRAINT_ERROR =>
                              NULL;
                         WHEN OTHERS =>
                              FAILED("UNEXPECTED ERROR RAISED - " &
                                     "CONSTRAINT - TASK TYPE");
                    END; -- EXCEPTION
                    BEGIN
                         N := IDENT_INT(1);
                         FAULT := IDENT_INT(5);
                         FAULT := FAULT/IDENT_INT(0);
                         FAULT := IDENT_INT(FAULT);
                    EXCEPTION
                         WHEN NUMERIC_ERROR|CONSTRAINT_ERROR =>
                              NULL;
                         WHEN OTHERS =>
                              FAILED("UNEXPECTED ERROR RAISED - " &
                                     "NUMERIC/CONSTRAINT - TASK TYPE");
                    END; -- EXCEPTION
                    A := IDENT_INT(1);
               END START;

               ACCEPT STOP;
          END PROG_ERR;

          TASK BODY T IS
               FAULT : X;
          BEGIN
               ACCEPT START(M,N,A : IN OUT INTEGER) DO
                    BEGIN
                         M := IDENT_INT(1);
                         FAULT := IDENT_INT(11);
                         FAULT := IDENT_INT(FAULT);
                    EXCEPTION
                         WHEN CONSTRAINT_ERROR =>
                              NULL;
                         WHEN OTHERS =>
                              FAILED("UNEXPECTED ERROR RAISED - " &
                                     "CONSTRAINT - TASK");
                    END; -- EXCEPTION
                    BEGIN
                         N := IDENT_INT(1);
                         FAULT := IDENT_INT(5);
                         FAULT := FAULT/IDENT_INT(0);
                         FAULT := IDENT_INT(FAULT);
                    EXCEPTION
                         WHEN NUMERIC_ERROR|CONSTRAINT_ERROR =>
                              NULL;
                         WHEN OTHERS =>
                              FAILED("UNEXPECTED ERROR RAISED - " &
                                     "NUMERIC/CONSTRAINT - TASK");
                    END; -- EXCEPTION
                    A := IDENT_INT(1);
               END START;

               ACCEPT STOP;
          END T;

          PACKAGE BODY P IS
          BEGIN
               OBJ.B.START(O,PT,B);
               OBJ.B.STOP;

               IF O /= IDENT_INT(1) OR PT /= IDENT_INT(1) THEN
                    FAILED("EXCEPTION HANDLER NEVER ENTERED " &
                           "PROPERLY - TASK TYPE OBJECT");
               END IF;

               IF B /= IDENT_INT(1) THEN
                    FAILED("TASK NOT EXITED PROPERLY - TASK TYPE " &
                           "OBJECT");
               END IF;
          END P;

          PACKAGE Q IS
               OBJ : ACC;
          END Q;

          PACKAGE BODY Q IS
          BEGIN
               OBJ := NEW PROG_ERR;
               OBJ.START(QT,R,C);
               OBJ.STOP;

               IF QT /= IDENT_INT(1) OR R /= IDENT_INT(1) THEN
                    FAILED("EXCEPTION HANDLER NEVER ENTERED " &
                           "PROPERLY - ACCESS TASK TYPE");
               END IF;

               IF C /= IDENT_INT(1) THEN
                    FAILED("TASK NOT EXITED PROPERLY - ACCESS TASK " &
                           "TYPE");
               END IF;
          END;

     BEGIN
          T.START(S,TP,D);
          T.STOP;

          IF S /= IDENT_INT(1) OR TP /= IDENT_INT(1) THEN
               FAILED("EXCEPTION HANDLER NEVER ENTERED PROPERLY " &
                      "- TASK");
          END IF;

          IF D /= IDENT_INT(1) THEN
               FAILED("TASK NOT EXITED PROPERLY - TASK");
          END IF;
     END; -- DECLARE

     RESULT;

EXCEPTION
     WHEN OTHERS =>
          FAILED("EXCEPTION NOT HANDLED INSIDE ACCEPT BODY");
          RESULT;
END C95078A;
