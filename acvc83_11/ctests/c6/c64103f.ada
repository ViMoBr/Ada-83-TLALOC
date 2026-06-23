-- C64103F.ADA

-- OBJECTIVE:
--     CHECK THAT, FOR OUT PARAMETERS OF AN ACCESS TYPE,
--     CONSTRAINT_ERROR IS RAISED:
--          AFTER A SUBPROGRAM CALL WHEN THE BOUNDS OR DISCRIMINANTS
--          OF THE FORMAL DESIGNATED PARAMETER ARE DIFFERENT FROM
--          THOSE OF THE ACTUAL DESIGNATED PARAMETER.

-- HISTORY:
--     CPP  07/23/84  CREATED ORIGINAL TEST.
--     VCL  10/27/87  MODIFIED THIS HEADER; ADDED STATEMENTS WHICH
--                    REFERENCE THE ACTUAL PARAMETERS.

WITH REPORT;  USE REPORT;
PROCEDURE C64103F IS
BEGIN
     TEST ("C64103F", "FOR OUT PARAMETERS OF AN ACCESS TYPE, " &
                      "CONSTRAINT_ERROR IS RAISED:  AFTER A " &
                      "SUBPROGRAM CALL WHEN THE BOUNDS OR " &
                      "DISCRIMINANTS OF THE FORMAL DESIGNATED " &
                      "PARAMETER ARE DIFFERENT FROM THOSE OF THE " &
                      "ACTUAL DESIGNATED PARAMETER");


     BEGIN
          DECLARE
               TYPE AST IS ACCESS STRING;
               SUBTYPE AST_3 IS AST(IDENT_INT(1)..IDENT_INT(3));
               SUBTYPE AST_5 IS AST(3..5);
               X_3 : AST_3 := NEW STRING'(1..IDENT_INT(3) => 'A');
               CALLED : BOOLEAN := FALSE;

               PROCEDURE P1 (X : OUT AST_5) IS
               BEGIN
                    CALLED := TRUE;
                    X := NEW STRING'(3..5 => 'C');
               END P1;
          BEGIN
               P1 (AST_5 (X_3));
               IF X_3.ALL = STRING'(1 .. 3 => 'A') THEN
                    FAILED ("EXCEPTION NOT RAISED AFTER CALL -P1 (A1)");
               ELSE
                    FAILED ("EXCEPTION NOT RAISED AFTER CALL -P1 (A2)");
               END IF;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    IF NOT CALLED THEN
                         FAILED ("EXCEPTION RAISED BEFORE CALL " &
                                 "-P1 (A)");
                    END IF;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED -P1 (A)");
          END;

          DECLARE
               TYPE ARRAY_TYPE IS ARRAY (INTEGER RANGE <>) OF BOOLEAN;
               TYPE A_ARRAY IS ACCESS ARRAY_TYPE;
               SUBTYPE A1_ARRAY IS A_ARRAY (1..IDENT_INT(3));
               TYPE A2_ARRAY IS NEW A_ARRAY (2..4);
               A0 : A1_ARRAY := NEW ARRAY_TYPE'(1..3 => TRUE);
               CALLED : BOOLEAN := FALSE;

               PROCEDURE P2 (X : OUT A2_ARRAY) IS
               BEGIN
                    CALLED := TRUE;
                    X := NEW ARRAY_TYPE'(2..4 => FALSE);
               END P2;
          BEGIN
               P2 (A2_ARRAY (A0));
               IF A0.ALL = ARRAY_TYPE'(1 .. 3 => TRUE) THEN
                    FAILED ("EXCEPTION NOT RAISED AFTER CALL -P2 (A1)");
               ELSE
                    FAILED ("EXCEPTION NOT RAISED AFTER CALL -P2 (A2)");
               END IF;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    IF NOT CALLED THEN
                         FAILED ("EXCEPTION RAISED BEFORE CALL " &
                                 "-P1 (A)");
                    END IF;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED -P2 (A)");
          END;

          DECLARE
               TYPE SUBINT IS RANGE 0..8;
               TYPE REC1 (DISC : SUBINT := 8) IS
                    RECORD
                         FIELD : SUBINT := DISC;
                    END RECORD;
               TYPE A1_REC IS ACCESS REC1;
               TYPE A2_REC IS NEW A1_REC (3);
               A0 : A1_REC(4) := NEW REC1(4);
               CALLED : BOOLEAN := FALSE;

               PROCEDURE P3 (X : OUT A2_REC) IS
               BEGIN
                    CALLED := TRUE;
                    X := NEW REC1(3);
               END P3;

          BEGIN
               P3 (A2_REC (A0));
               IF A0.ALL = REC1'(4,4) THEN
                    FAILED ("EXCEPTION NOT RAISED AFTER CALL -P3 (A1)");
               ELSE
                    FAILED ("EXCEPTION NOT RAISED AFTER CALL -P3 (A2)");
               END IF;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    IF NOT CALLED THEN
                         FAILED ("EXCEPTION RAISED BEFORE CALL " &
                                 "-P1 (A)");
                    END IF;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED -P3 (A)");
          END;
     END;

     RESULT;
END C64103F;
