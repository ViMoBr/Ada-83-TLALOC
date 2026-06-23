-- C39007B.ADA

-- OBJECTIVE:
--     CHECK THAT PROGRAM_ERROR IS RAISED BY AN ATTEMPT TO INSTANTIATE
--     A GENERIC UNIT WHOSE BODY IS NOT YET ELABORATED.  USE A GENERIC
--     UNIT THAT IS DECLARED AND INSTANTIATED IN A PACKAGE
--     SPECIFICATION.

-- HISTORY:
--     BCB 08/01/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C39007B IS

BEGIN
     TEST ("C39007B", "CHECK THAT PROGRAM_ERROR IS RAISED BY AN " &
                      "ATTEMPT TO INSTANTIATE A GENERIC UNIT WHOSE " &
                      "BODY IS NOT YET ELABORATED.  USE A GENERIC " &
                      "UNIT THAT IS DECLARED AND INSTANTIATED IN A " &
                      "PACKAGE SPECIFICATION");

     DECLARE
     BEGIN
          DECLARE
               PACKAGE P IS
                    GENERIC
                    FUNCTION F RETURN BOOLEAN;

                    FUNCTION NEW_F IS NEW F;
               END P;

               PACKAGE BODY P IS
                    FUNCTION F RETURN BOOLEAN IS
                    BEGIN
                         RETURN TRUE;
                    END F;
               END P;
          BEGIN
               FAILED ("NO EXCEPTION RAISED");
               DECLARE
                    X : BOOLEAN := IDENT_BOOL(FALSE);
               BEGIN
                    X := P.NEW_F;
                    IF X /= IDENT_BOOL(TRUE) THEN
                         COMMENT ("NOT RELEVANT");
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("EXCEPTION RAISED TOO LATE");
               END;
          END;
     EXCEPTION
          WHEN PROGRAM_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED");
     END;

     RESULT;
END C39007B;
