-- C39006F2.ADA

-- THIS LIBRARY PACKAGE BODY IS USED BY C39006F3M.ADA.

-- TBN  8/22/86

WITH C39006F0;
WITH REPORT; USE REPORT;
PRAGMA ELABORATE (C39006F0, REPORT);

PACKAGE BODY C39006F1 IS

BEGIN
     TEST ("C39006F3M", "CHECK THAT NO PROGRAM_ERROR IS RAISED IF A " &
                        "SUBPROGRAM'S BODY HAS BEEN ELABORATED " &
                        "BEFORE IT IS CALLED, WHEN A SUBPROGRAM " &
                        "LIBRARY UNIT IS USED IN ANOTHER UNIT AND " &
                        "PRAGMA ELABORATE IS USED");
     BEGIN
          DECLARE
               VAR1 : INTEGER := C39006F0 (IDENT_INT(1));
          BEGIN
               IF VAR1 /= IDENT_INT(1) THEN
                    FAILED ("INCORRECT RESULTS - 1");
               END IF;
          END;
     EXCEPTION
          WHEN PROGRAM_ERROR =>
               FAILED ("PROGRAM_ERROR RAISED - 1");
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED - 1");
     END;

     DECLARE
          VAR2 : INTEGER := 1;

          PROCEDURE CHECK (B : IN OUT INTEGER) IS
          BEGIN
               B := C39006F0 (IDENT_INT(2));
          EXCEPTION
               WHEN PROGRAM_ERROR =>
                    FAILED ("PROGRAM_ERROR RAISED - 2");
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - 2");
          END CHECK;
     BEGIN
          CHECK (VAR2);
          IF VAR2 /= IDENT_INT(2) THEN
               FAILED ("INCORRECT RESULTS - 2");
          END IF;
     END;

     DECLARE
          PACKAGE P IS
               VAR3 : INTEGER;
          END P;

          PACKAGE BODY P IS
          BEGIN
               VAR3 := C39006F0 (IDENT_INT(3));
               IF VAR3 /= IDENT_INT(3) THEN
                    FAILED ("INCORRECT RESULTS - 3");
               END IF;
          EXCEPTION
               WHEN PROGRAM_ERROR =>
                    FAILED ("PROGRAM_ERROR RAISED - 3");
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION - 3");
          END P;
     BEGIN
          NULL;
     END;

     DECLARE
          GENERIC
               VAR4 : INTEGER := 1;
          PACKAGE Q IS
               TYPE ARRAY_TYP1 IS ARRAY (1 .. VAR4) OF INTEGER;
               ARRAY_1 : ARRAY_TYP1;
          END Q;

          PACKAGE NEW_Q IS NEW Q (C39006F0 (IDENT_INT(4)));

          USE NEW_Q;

     BEGIN
          IF ARRAY_1'LAST /= IDENT_INT(4) THEN
               FAILED ("INCORRECT RESULTS - 4");
          END IF;
     END;

END C39006F1;
