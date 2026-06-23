-- C37005A.ADA

-- CHECK THAT SCALAR RECORD COMPONENTS MAY HAVE NON-STATIC
-- RANGE CONSTRAINTS OR DEFAULT INITIAL VALUES.

-- DAT 3/6/81
-- JWC 6/28/85   RENAMED TO -AB

WITH REPORT;
PROCEDURE C37005A IS

     USE REPORT;

BEGIN
     TEST ("C37005A", "SCALAR RECORD COMPONENTS MAY HAVE NON-STATIC"
                    & " RANGE CONSTRAINTS OR DEFAULT INITIAL VALUES");

     DECLARE
          SUBTYPE DT IS INTEGER RANGE IDENT_INT (1) .. IDENT_INT (5);
          L : INTEGER := IDENT_INT (DT'FIRST);
          R : INTEGER := IDENT_INT (DT'LAST);
          SUBTYPE DT2 IS INTEGER RANGE L .. R;
          M : INTEGER := (L + R) / 2;

          TYPE REC IS
               RECORD
                    C1 : INTEGER := M;
                    C2 : DT2 := (L + R) / 2;
                    C3 : BOOLEAN RANGE (L < M) .. (R > M)
                         := IDENT_BOOL (TRUE);
                    C4 : INTEGER RANGE L .. R := DT'FIRST;
               END RECORD;

          R1, R2 : REC := ((L+R)/2, M, M IN DT, L);
          R3 : REC;
     BEGIN
          IF R3 /= R1
          THEN
               FAILED ("INCORRECT RECORD VALUES");
          END IF;

          R3 := (R2.C2, R2.C1, R3.C3, R);  -- CONSTRAINTS CHECKED BY :=

          BEGIN
               R3 := (M, M, IDENT_BOOL (FALSE), M); -- RAISES CON_ERR.
               FAILED ("CONSTRAINT ERROR NOT RAISED");
          EXCEPTION
               WHEN CONSTRAINT_ERROR => NULL;
               WHEN OTHERS => FAILED ("WRONG EXCEPTION");
          END;

          FOR I IN DT LOOP
               R3 := (I, I, I /= 100, I);
               R1.C2 := I;
          END LOOP;

     EXCEPTION
          WHEN OTHERS => FAILED ("INVALID EXCEPTION");
     END;

     RESULT;
END C37005A;
