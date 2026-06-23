-- C41309A.ADA

-- CHECK THAT AN EXPANDED NAME IS ALLOWED EVEN IF A USE CLAUSE MAKES THE
-- EXPANDED NAME UNNECESSARY.

-- TBN  12/15/86

WITH REPORT; USE REPORT;
PROCEDURE C41309A IS

BEGIN
     TEST ("C41309A", "CHECK THAT AN EXPANDED NAME IS ALLOWED EVEN " &
                      "IF A USE CLAUSE MAKES THE EXPANDED NAME " &
                      "UNNECESSARY");
     DECLARE
          PACKAGE P IS
               PACKAGE Q IS
                    PACKAGE R IS
                         TYPE REC IS
                              RECORD
                                   A : INTEGER := 5;
                                   B : BOOLEAN := TRUE;
                              END RECORD;
                         REC1 : REC;
                    END R;

                    USE R;

                    REC2 : R.REC := R.REC1;
               END Q;

               USE Q; USE R;

               REC3 : Q.R.REC := Q.REC2;
          END P;

          USE P; USE Q; USE R;

          REC4 : P.Q.R.REC := P.REC3;
     BEGIN
          IF REC4 /= (IDENT_INT(5), IDENT_BOOL(TRUE)) THEN
               FAILED ("INCORRECT RESULTS FROM EXPANDED NAME");
          END IF;
     END;

     RESULT;
END C41309A;
