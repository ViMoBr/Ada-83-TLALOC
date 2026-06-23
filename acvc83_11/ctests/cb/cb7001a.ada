-- CB7001A.ADA

-- OBJECTIVE:
--     CHECK THAT IF THE FIRST ARGUMENT TO A "SUPPRESS" PRAGMA HAS THE
--     FORM XXX_CHECK, BUT IS NOT ONE OF THE PREDEFINED CHECK NAMES,
--     THEN THE PRAGMA IS IGNORED.

-- HISTORY:
--     DHH 03/31/88 CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE CB7001A IS

     SUBTYPE INT1 IS INTEGER RANGE 1 .. 10;
     INT : INT1;

     PRAGMA SUPPRESS(HAT_CHECK, INT);

     TYPE ARRY IS ARRAY(1 .. 3) OF INTEGER;
     ARR : ARRY;

     TYPE ACC IS ACCESS ARRY;
     ACC_ARRY : ACC;

     TYPE REC(X : INT1 := 1) IS
          RECORD
               ARR : ARRY := (1 .. 3 => (X));
          END RECORD;
     REC1 : REC;

     TYPE REAL_TYPE IS DIGITS 6;
     REAL : REAL_TYPE := 2.0;

     PROCEDURE NEW_ARR(X : IN OUT ACC) IS
     BEGIN
          IF EQUAL(X(IDENT_INT(1)), X(IDENT_INT(2))) THEN
               X := NEW ARRY;
          END IF;
     END NEW_ARR;

     FUNCTION IDENT(X : REAL_TYPE) RETURN REAL_TYPE IS
     BEGIN
          IF EQUAL(3,3) THEN
               RETURN X;
          ELSE
               RETURN 0.0;
          END IF;
     END IDENT;

BEGIN
     TEST("CB7001A", "CHECK THAT IF THE FIRST ARGUMENT TO A " &
                     """SUPPRESS"" PRAGMA HAS THE FORM XXX_CHECK, " &
                     "BUT IS NOT ONE OF THE PREDEFINED CHECK NAMES, " &
                     "THEN THE PRAGMA IS IGNORED");

     DECLARE  -- 1
          PRAGMA SUPPRESS(ALL_CHECK);
     BEGIN
          INT := IDENT_INT(11);
          FAILED("CONSTRAINT_ERROR NOT RAISED - ALL_CHECK INT");

     EXCEPTION
         WHEN CONSTRAINT_ERROR =>
              NULL;
         WHEN OTHERS =>
              FAILED("WRONG EXCEPTION RAISED - ALL_CHECK INT");
     END;

     DECLARE  -- 2
          PRAGMA SUPPRESS(ALL_CHECK);
     BEGIN
          FOR I IN 1 .. 4 LOOP
               ARR(I) := IDENT_INT(I);
          END LOOP;
          FAILED("CONSTRAINT_ERROR NOT RAISED - ALL_CHECK ARR");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED("WRONG EXCEPTION RAISED - ALL_CHECK ARR");
     END;

     DECLARE  -- 3
          PRAGMA SUPPRESS(ALL_CHECK);
     BEGIN
          INT := IDENT_INT(12)/IDENT_INT(0);
          FAILED("CONSTRAINT_|NUMERIC_ERROR NOT RAISED " &
                 "- ALL_CHECK ZERO");

     EXCEPTION
          WHEN CONSTRAINT_ERROR|NUMERIC_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED("WRONG EXCEPTION RAISED - ALL_CHECK ZERO");
     END;

     DECLARE  -- 4
          PRAGMA SUPPRESS(ACC_CHECK, ACC);
     BEGIN
          ACC_ARRY.ALL := ARR;
          FAILED("CONSTRAINT_ERROR NOT RAISED - ACC_CHECK");
          NEW_ARR(ACC_ARRY);
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED("WRONG EXCEPTION RAISED - ACC_CHECK");
     END;

     DECLARE  -- 5
          PRAGMA SUPPRESS(DIV_CHECK);
     BEGIN
          INT := IDENT_INT(12)/IDENT_INT(0);
          FAILED("CONSTRAINT_|NUMERIC_ERROR NOT RAISED - DIV_CHECK");

     EXCEPTION
          WHEN CONSTRAINT_ERROR|NUMERIC_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED("WRONG EXCEPTION RAISED - DIV_CHECK");
     END;

     DECLARE  -- 6
          PRAGMA SUPPRESS(DISC_CHECK, REC);
     BEGIN
          REC1 := (X => (INT1'(IDENT_INT(12))), ARR => (1 .. 3 => (3)));
          FAILED("CONSTRAINT_ERROR NOT RAISED - DISC_CHECK");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED("WRONG EXCEPTION RAISED - DISC_CHECK");
     END;

     DECLARE  -- 8
          PRAGMA SUPPRESS(BOUNDS_CHECK, ARR);
     BEGIN
          ARR := (IDENT_INT(1), IDENT_INT(2), IDENT_INT(3), 4);
          FAILED("CONSTRAINT_ERROR NOT RAISED - BOUNDS_CHECK");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED("WRONG EXCEPTION RAISED - BOUNDS_CHECK");
     END;

     DECLARE  -- 9
          PRAGMA SUPPRESS(RAN_CHECK);
     BEGIN
          INT := IDENT_INT(11);
          FAILED("CONSTRAINT_ERROR NOT RAISED - RAN_CHECK");

     EXCEPTION
         WHEN CONSTRAINT_ERROR =>
              NULL;
         WHEN OTHERS =>
              FAILED("WRONG EXCEPTION RAISED - RAN_CHECK");
     END;

     DECLARE  -- 10
          PRAGMA SUPPRESS(OVER_CHECK, REAL);
     BEGIN
          REAL := IDENT((REAL) ** (REAL_TYPE'MACHINE_EMAX + 1));
          FAILED("CONSTRAINT/NUMERIC_ERROR NOT RAISED - OVER_CHECK");

     EXCEPTION
         WHEN CONSTRAINT_ERROR|NUMERIC_ERROR =>
              NULL;
         WHEN OTHERS =>
              FAILED("WRONG EXCEPTION RAISED - OVER_CHECK");
     END;

     DECLARE  -- 11

          TASK TYPE PROG_ERR IS
               ENTRY START;
          END PROG_ERR;

          PRAGMA SUPPRESS(ELAB_CHECK, PROG_ERR);

          TYPE REC IS
               RECORD
                    B : PROG_ERR;
               END RECORD;

          TYPE ACC IS ACCESS PROG_ERR;

          PACKAGE P IS
               OBJ : REC;
          END P;

          PACKAGE BODY P IS
          BEGIN
               FAILED("EXCEPTION NOT RAISED - 1");
               OBJ.B.START;
          EXCEPTION
               WHEN PROGRAM_ERROR =>
                    NULL;
               WHEN TASKING_ERROR =>
                    FAILED("TASKING ERROR RAISED INCORRECTLY");
               WHEN OTHERS =>
                    FAILED("UNEXPECTED EXCEPTION RAISED");
          END P;

          PACKAGE Q IS
               OBJ : ACC;
          END Q;

          PACKAGE BODY Q IS
          BEGIN
               OBJ := NEW PROG_ERR;
               FAILED("EXCEPTION NOT RAISED - 2");
               OBJ.START;
          EXCEPTION
               WHEN PROGRAM_ERROR =>
                    NULL;
               WHEN TASKING_ERROR =>
                    FAILED("ACCESS TASKING ERROR RAISED INCORRECTLY");
               WHEN OTHERS =>
                    FAILED("ACCESS UNEXPECTED EXCEPTION RAISED");
          END;

          TASK BODY PROG_ERR IS
          BEGIN
               ACCEPT START DO
                    IF TRUE THEN
                         COMMENT("IRRELEVANT");
                    END IF;
               END START;
          END PROG_ERR;
     BEGIN
          NULL;
     END;

     RESULT;

EXCEPTION
     WHEN OTHERS =>
          FAILED("UNEXPECTED EXCEPTION RAISED OUTSIDE BLOCK " &
                 "STATEMENTS");
          RESULT;

END CB7001A;
