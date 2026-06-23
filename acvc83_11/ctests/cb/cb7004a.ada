-- CB7004A.ADA

-- OBJECTIVE:
--     FOR SUPPRESS PRAGMAS WITH A FIRST ARGUMENT OF DIVISION_CHECK,
--     OR OVERFLOW_CHECK, CHECK THAT THE SECOND ARGUMENT MUST BE THE
--     NAME OF A NUMERIC TYPE (ELSE THE PRAGMA IS IGNORED).

-- HISTORY:
--     DHH 03/31/88 CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE CB7004A IS

BEGIN
     TEST("CB7004A", "FOR SUPPRESS PRAGMAS WITH A FIRST ARGUMENT " &
                     "OF DIVISION_CHECK, OR OVERFLOW_CHECK, CHECK " &
                     "THAT THE SECOND ARGUMENT MUST BE THE NAME OF " &
                     "A NUMERIC TYPE (ELSE THE PRAGMA IS IGNORED)");

     DECLARE
-----------------------------------------------------------------------

          PACKAGE FR IS
          END FR;

          PRAGMA SUPPRESS(DIVISION_CHECK, FR);

          PACKAGE PACK IS
          END PACK;

          PRAGMA SUPPRESS(OVERFLOW_CHECK, PACK);

          PACKAGE BODY FR IS
               SUBTYPE FR IS INTEGER RANGE 1 .. 10;
               X : FR;
          BEGIN
               X := X/IDENT_INT(0);
               FAILED("EXCEPTION NOT RAISED ON DIVISION_CHECK");
               COMMENT(INTEGER'IMAGE(X));
          EXCEPTION
               WHEN NUMERIC_ERROR =>
                    NULL;
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED("UNEXPECTED EXCEPTION RAISED ON " &
                           "DIVISION_CHECK - 1");
          END FR;
------------------------------------------------------------------------

          PACKAGE BODY PACK IS
               TYPE HEC IS DIGITS 5;
               PACK : HEC := HEC'LARGE;
          BEGIN
               PACK := HEC'(2.0) ** (HEC'MACHINE_EMAX + 1);

               IF HEC'MACHINE_OVERFLOWS THEN
                    FAILED("EXCEPTION NOT RAISED ON OVERFLOW_CHECK");
               END IF;

               IF PACK = 0.0 THEN
                    COMMENT("PACK HAS VALUE OF 0.0");
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

     BEGIN
          NULL;
     END;
-----------------------------------------------------------------------

     DECLARE
          TYPE INT IS
               RECORD
                    REC : INTEGER := IDENT_INT(1);
               END RECORD;

          PRAGMA SUPPRESS(DIVISION_CHECK, INT);

          X : INT;
          Y : INT := (REC => IDENT_INT(0));

          FUNCTION "/"(L,R : INT) RETURN INTEGER IS
          BEGIN
               RETURN L.REC/R.REC;
          END;

     BEGIN
          X.REC := X/Y;
          FAILED("EXCEPTION NOT RAISED ON DIVISION_CHECK");
          COMMENT(INTEGER'IMAGE(X.REC));

     EXCEPTION
          WHEN NUMERIC_ERROR =>
               NULL;
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED("UNEXPECTED EXCEPTION RAISED ON " &
                      "DIVISION_CHECK");
     END;

     RESULT;
END CB7004A;
