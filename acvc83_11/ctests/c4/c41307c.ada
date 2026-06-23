-- C41307C.ADA

-- CHECK THAT L.R.R.X IS ALLOWED IF L IS A PACKAGE DECLARED BY A
-- RENAMING DECLARATION, D IS THE PACKAGE DENOTED BY L, AND R IS A
-- NAME DECLARED IMMEDIATELY WITHIN D AS A RENAMING OF L.

-- TBN  12/17/86

WITH REPORT; USE REPORT;
PROCEDURE C41307C IS

BEGIN
     TEST ("C41307C", "CHECK THAT L.R.R.X IS ALLOWED IF L IS A " &
                      "PACKAGE DECLARED BY A RENAMING DECLARATION, D " &
                      "IS THE PACKAGE DENOTED BY L, AND R IS A NAME " &
                      "DECLARED IMMEDIATELY WITHIN D AS A RENAMING " &
                      "OF L");
     DECLARE
          PACKAGE D IS
               X : INTEGER := 1;
               PACKAGE L RENAMES D;
               PACKAGE R RENAMES L;
               Z : INTEGER := IDENT_INT(L.R.R.X);
          PRIVATE
               A : INTEGER := IDENT_INT(L.R.R.X) + 1;
          END D;

          INT : INTEGER := IDENT_INT(D.L.R.R.X);

          PACKAGE BODY D IS
               G : INTEGER := IDENT_INT(L.R.R.X);
               H : INTEGER;
          BEGIN
               H := IDENT_INT(L.R.R.Z);
               IF IDENT_INT(G) /= 1 OR IDENT_INT(H) /= 1 OR
                  IDENT_INT(L.R.R.Z) /= 1 OR IDENT_INT(A) /= 2 THEN
                    FAILED ("INCORRECT RESULTS FROM EXPANDED NAME - 1");
               END IF;
          END D;
     BEGIN
          IF IDENT_INT(INT) /= 1 THEN
               FAILED ("INCORRECT RESULTS FROM EXPANDED NAME - 2");
          END IF;
     END;

     RESULT;
END C41307C;
