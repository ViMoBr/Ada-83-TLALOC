-- C85014A.ADA

-- OBJECTIVE:
--     CHECK THAT THE NUMBER OF FORMAL PARAMETERS IS USED TO DETERMINE
--     WHICH SUBPROGRAM OR ENTRY IS BEING RENAMED.

-- HISTORY:
--     JET 03/24/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE C85014A IS

     TASK TYPE T1 IS
          ENTRY ENTER (I1: IN OUT INTEGER);
          ENTRY STOP;
     END T1;

     TASK TYPE T2 IS
          ENTRY ENTER (I1, I2: IN OUT INTEGER);
          ENTRY STOP;
     END T2;

     TASK1 : T1;
     TASK2 : T2;

     FUNCTION F RETURN T1 IS
     BEGIN
          RETURN TASK1;
     END F;

     FUNCTION F RETURN T2 IS
     BEGIN
          RETURN TASK2;
     END F;

     PROCEDURE PROC (I1: IN OUT INTEGER) IS
     BEGIN
          I1 := I1 + 1;
     END PROC;

     PROCEDURE PROC (I1, I2: IN OUT INTEGER) IS
     BEGIN
          I1 := I1 + 2;
          I2 := I2 + 2;
     END PROC;

     TASK BODY T1 IS
          ACCEPTING_ENTRIES : BOOLEAN := TRUE;
     BEGIN
          WHILE ACCEPTING_ENTRIES LOOP
               SELECT
                    ACCEPT ENTER (I1 : IN OUT INTEGER) DO
                         I1 := I1 + 1;
                    END ENTER;
               OR
                    ACCEPT STOP DO
                         ACCEPTING_ENTRIES := FALSE;
                    END STOP;
               END SELECT;
          END LOOP;
     END T1;

     TASK BODY T2 IS
          ACCEPTING_ENTRIES : BOOLEAN := TRUE;
     BEGIN
          WHILE ACCEPTING_ENTRIES LOOP
               SELECT
                    ACCEPT ENTER (I1, I2 : IN OUT INTEGER) DO
                         I1 := I1 + 2;
                         I2 := I2 + 2;
                    END ENTER;
               OR
                    ACCEPT STOP DO
                         ACCEPTING_ENTRIES := FALSE;
                    END STOP;
               END SELECT;
          END LOOP;
     END T2;

BEGIN
     TEST ("C85014A", "CHECK THAT THE NUMBER OF FORMAL PARAMETERS IS " &
                      "USED TO DETERMINE WHICH SUBPROGRAM OR ENTRY " &
                      "IS BEING RENAMED");

     DECLARE
          PROCEDURE PROC1 (J1: IN OUT INTEGER) RENAMES PROC;
          PROCEDURE PROC2 (J1, J2: IN OUT INTEGER) RENAMES PROC;

          PROCEDURE ENTRY1 (J1: IN OUT INTEGER) RENAMES F.ENTER;
          PROCEDURE ENTRY2 (J1, J2: IN OUT INTEGER) RENAMES F.ENTER;

          K1, K2 : INTEGER := 0;
     BEGIN
          PROC1(K1);
          IF K1 /= IDENT_INT(1) THEN
               FAILED("INCORRECT RETURN VALUE FROM PROC1");
          END IF;

          ENTRY1(K2);
          IF K2 /= IDENT_INT(1) THEN
               FAILED("INCORRECT RETURN VALUE FROM ENTRY1");
          END IF;

          PROC2(K1, K2);
          IF K1 /= IDENT_INT(3) OR K2 /= IDENT_INT(3) THEN
               FAILED("INCORRECT RETURN VALUE FROM PROC2");
          END IF;

          ENTRY2(K1, K2);
          IF K1 /= IDENT_INT(5) OR K2 /= IDENT_INT(5) THEN
               FAILED("INCORRECT RETURN VALUE FROM PROC2");
          END IF;
     END;

     TASK1.STOP;
     TASK2.STOP;

     RESULT;
END C85014A;
