-- C41307A.ADA

-- CHECK THAT IF L IS A PACKAGE DECLARED BY A RENAMING DECLARATION, D IS
-- THE PACKAGE DENOTED BY L, AND R IS A NAME DECLARED IMMEDIATELY WITHIN
-- THE VISIBLE PART OF D:
--      A) L.R IS LEGAL WHETHER L.R OCCURS OUTSIDE D, INSIDE D'S VISIBLE
--         PART, INSIDE D'S PRIVATE PART, OR INSIDE D'S BODY.

-- TBN  12/16/86

WITH REPORT; USE REPORT;
PROCEDURE C41307A IS

BEGIN
     TEST ("C41307A", "CHECK THAT EXPANDED NAMES FOR A RENAMED " &
                      "PACKAGE ARE ALLOWED");

     DECLARE
          PACKAGE D IS
               R : INTEGER := IDENT_INT(0);
          END D;

          PACKAGE L RENAMES D;

          INT : INTEGER := IDENT_INT(L.R) + 1;

          PACKAGE BODY D IS
               A : INTEGER := IDENT_INT(L.R);
               B : INTEGER;
          BEGIN
               B := IDENT_INT(L.R);
               IF IDENT_INT(A) /= 0 OR IDENT_INT(B) /= 0 THEN
                    FAILED ("INCORRECT RESULTS FROM EXPANDED NAME - 1");
               END IF;
          END D;
     BEGIN
          IF IDENT_INT(INT) /= 1 THEN
               FAILED ("INCORRECT RESULTS FROM EXPANDED NAME - 2");
          END IF;
     END;
     -------------------------------------------------------------------

     DECLARE
          PACKAGE D IS
               R : INTEGER := IDENT_INT(1);
               PACKAGE L RENAMES D;
               Y : INTEGER := IDENT_INT(D.R);
               Z : INTEGER := IDENT_INT(L.R);
          PRIVATE
               A : INTEGER := IDENT_INT(D.Z) + 1;
               B : INTEGER := IDENT_INT(L.Y) + 2;
          END D;

          INT : INTEGER := IDENT_INT(D.L.R);

          PACKAGE BODY D IS
               G : INTEGER := IDENT_INT(L.R);
               H : INTEGER;
          BEGIN
               H := IDENT_INT(L.Z);
               IF IDENT_INT(G) /= 1 OR IDENT_INT(H) /= 1 OR
                  IDENT_INT(L.Y) /= 1 OR IDENT_INT(A) /= 2 OR
                  IDENT_INT(B) /= 3 THEN
                    FAILED ("INCORRECT RESULTS FROM EXPANDED NAME - 3");
               END IF;
          END D;
     BEGIN
          IF IDENT_INT(INT) /= 1 THEN
               FAILED ("INCORRECT RESULTS FROM EXPANDED NAME - 4");
          END IF;
     END;

     RESULT;
END C41307A;
