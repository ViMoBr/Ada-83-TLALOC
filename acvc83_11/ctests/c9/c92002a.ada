-- C92002A.ADA

-- CHECK THAT ASSIGNMENT TO A COMPONENT (FOR WHICH ASSIGNMENT IS
--   AVAILABLE) OF A RECORD CONTAINING A TASK IS AVAILABLE.

-- JRK 9/17/81
-- JWC 6/28/85   RENAMED TO -AB

WITH REPORT; USE REPORT;
PROCEDURE C92002A IS

BEGIN
     TEST ("C92002A", "CHECK THAT CAN ASSIGN TO ASSIGNABLE " &
                      "COMPONENTS OF RECORDS WITH TASK " &
                      "COMPONENTS");

     DECLARE

          TASK TYPE TT IS
               ENTRY E;
          END TT;

          TYPE RT IS
               RECORD
                    I : INTEGER := 0;
                    T : TT;
                    J : INTEGER := 0;
               END RECORD;

          R : RT;

          TASK BODY TT IS
          BEGIN
               NULL;
          END TT;

     BEGIN

          R.I := IDENT_INT (7);
          R.J := IDENT_INT (9);

          IF R.I /= 7 AND R.J /= 9 THEN
               FAILED ("WRONG VALUE(S) WHEN ASSIGNING TO " &
                       "INTEGER COMPONENTS OF RECORDS WITH " &
                       "TASK COMPONENTS");
          END IF;

     END;

     RESULT;
END C92002A;
