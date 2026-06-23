-- CB7001B.ADA

-- OBJECTIVE:
--     CHECK THAT IF A "SUPPRESS" PRAGMA  APPEARS IN ANY PLACE WHERE
--     A PRAGMA IS SYNTACTICALLY ACCEPTABLE, BUT NOT IN A PACKAGE
--     SPECIFICATION OR THE DECLARATIVE PART OF A FRAME, THEN THE
--     PRAGMA IS IGNORED.

-- HISTORY:
--     DHH 06/15/88 CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE CB7001B IS

BEGIN
     TEST("CB7001B", "CHECK THAT IF A ""SUPPRESS"" PRAGMA  APPEARS " &
                     "IN ANY PLACE WHERE A PRAGMA IS SYNTACTICALLY " &
                     "ACCEPTABLE, BUT NOT IN A PACKAGE SPECIFICATION " &
                     "OR THE DECLARATIVE PART OF A FRAME, THEN THE " &
                     "PRAGMA IS IGNORED");
---------------------------------------------------------------------
     DECLARE
          T, X : INTEGER := 5;

          PACKAGE FR IS
          END FR;

          PACKAGE PACK IS
          END PACK;

          TASK T1 IS
               ENTRY T1E;
          END T1;

          PACKAGE BODY FR IS
               SUBTYPE FR IS INTEGER RANGE 1 .. 10;
               X : FR;
          BEGIN
               PRAGMA SUPPRESS(DIVISION_CHECK, FR);

               X := X/IDENT_INT(0);
               FAILED("EXCEPTION NOT RAISED ON DIVISION_CHECK -- A");
          EXCEPTION
               WHEN NUMERIC_ERROR =>
                    NULL;
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED("UNEXPECTED EXCEPTION RAISED ON " &
                           "DIVISION_CHECK -- A");
          END FR;
------------------------------------------------------------------------

          PACKAGE BODY PACK IS
               TYPE HEC IS DIGITS 5;
               PACK : HEC;
          BEGIN
               PACK := HEC'LARGE;
               PRAGMA SUPPRESS(OVERFLOW_CHECK, PACK);

               PACK := PACK ** IDENT_INT(2);

               IF HEC'MACHINE_OVERFLOWS THEN
                    FAILED("EXCEPTION NOT RAISED ON OVERFLOW_CHECK");
               END IF;

               IF PACK = 0.0 THEN
                    COMMENT("PACK HAS A VALUE OF 0.0");
               ELSIF PACK = 1.0 THEN
                    COMMENT("PACK HAS A VALUE OF 1.0");
               ELSE
                    COMMENT("PACK HAS BEEN EVALUATED");
               END IF;

          EXCEPTION
               WHEN NUMERIC_ERROR =>
                    NULL;
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED("UNEXPECTED EXCEPTION RAISED ON " &
                           "OVERFLOW_CHECK");
          END PACK;
-----------------------------------------------------------------------
          TASK BODY T1 IS
               SUBTYPE FR IS INTEGER RANGE 1 .. 10;
               X : FR;
          BEGIN
               ACCEPT T1E DO
                    PRAGMA SUPPRESS(DIVISION_CHECK, FR);

                    BEGIN
                         X := X/IDENT_INT(0);
                         FAILED("EXCEPTION NOT RAISED ON " &
                                "DIVISION_CHECK -- B");
                    EXCEPTION
                         WHEN NUMERIC_ERROR =>
                              NULL;
                         WHEN CONSTRAINT_ERROR =>
                              NULL;
                         WHEN OTHERS =>
                              FAILED("UNEXPECTED EXCEPTION RAISED ON " &
                                     "DIVISION_CHECK -- B");
                    END;
               END T1E;
          END T1;
-----------------------------------------------------------------------
     BEGIN
          T1.T1E;

          T := T/IDENT_INT(0);
          FAILED("EXCEPTION NOT RAISED ON DIVIDE BY ZERO");
     EXCEPTION
          WHEN NUMERIC_ERROR|CONSTRAINT_ERROR =>
               PRAGMA SUPPRESS(DIVISION_CHECK, X);
               BEGIN
                    X := X/IDENT_INT(0);
                    FAILED("EXCEPTION NOT RAISED ON DIVISION_CHECK " &
                           "INSIDE EXCEPTION HANDLER");
               EXCEPTION
                    WHEN NUMERIC_ERROR =>
                         NULL;
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED("UNEXPECTED EXCEPTION RAISED ON " &
                                "DIVISION_CHECK -- C");
               END;

          WHEN OTHERS =>
               FAILED("UNEXPECTED EXCEPTION RAISED ON " &
                      "DIVISION_CHECK -- D");
     END;

---------------------------------------------------------------------
     RESULT;
END CB7001B;
