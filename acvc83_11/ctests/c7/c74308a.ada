-- C74308A.ADA

-- OBJECTIVE:
--     CHECK THAT AN ATTEMPT TO USE THE VALUE OF A DEFERRED CONSTANT
--     PRIOR TO THE END OF ITS FULL DECLARATION IS NOT ILLEGAL.  CHECK
--     WHETHER SUCH AN ATTEMPT RAISES PROGRAM_ERROR.

-- HISTORY:
--     BCB 03/09/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C74308A IS

BEGIN
     TEST ("C74308A", "CHECK THAT AN ATTEMPT TO USE THE VALUE OF A " &
                      "DEFERRED CONSTANT PRIOR TO THE END OF ITS " &
                      "FULL DECLARATION IS NOT ILLEGAL.  CHECK " &
                      "WHETHER SUCH AN ATTEMPT RAISES PROGRAM_ERROR");

     BEGIN
          DECLARE
               PACKAGE P IS
                    TYPE T IS PRIVATE;
                    C : CONSTANT T;
               PRIVATE
                    TYPE T IS RANGE 1 .. 10;
                    TYPE U (D : T := C) IS
                         RECORD
                              A : T := C - 2;
                         END RECORD;
                    R : U;
                    C : CONSTANT T := 8;
                    FUNCTION IDENT(X : T) RETURN T;
               END P;
               PACKAGE BODY P IS
                    FUNCTION IDENT(X : T) RETURN T IS
                         Y : T := 5;
                    BEGIN
                         IF EQUAL(3,3) THEN
                              RETURN X;
                         END IF;
                         RETURN Y;
                    END IDENT;
               BEGIN
                    COMMENT ("NO EXCEPTION WAS RAISED");
                    IF R.D /= IDENT(C) THEN
                         FAILED ("INCORRECT VALUE FOR R.D");
                    END IF;
               END P;
          BEGIN
               NULL;
          END;
     EXCEPTION
          WHEN PROGRAM_ERROR =>
               COMMENT ("PROGRAM_ERROR WAS RAISED");
          WHEN OTHERS =>
               FAILED ("AN EXCEPTION OTHER THAN PROGRAM_ERROR WAS " &
                       "RAISED");
     END;

     RESULT;
END C74308A;
