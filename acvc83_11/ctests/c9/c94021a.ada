-- C94021A.ADA

-- CHECK THAT A TASK IS ACCESSIBLE FROM OUTSIDE ITS MASTER.

-- JEAN-PIERRE ROSEN 30-MAR-1984
-- JBG 6/1/84

WITH REPORT; USE REPORT;
PROCEDURE C94021A IS

     TASK TYPE TT IS
          ENTRY E;
     END TT;

     TYPE ATT IS ACCESS TT;   -- MASTER IS C94021A

     TASK BODY TT IS
     BEGIN
          SELECT              -- THIS SELECT TO KEEP F2.LOCAL_ATT ACTIVE
               ACCEPT E;      -- UNTIL THE END OF C94021A.
          OR TERMINATE;
          END SELECT;
     END;

     FUNCTION F1 RETURN TT IS
          LOCAL_T : TT;       -- MASTER IS F1.
     BEGIN
          RETURN LOCAL_T;
     END;

     FUNCTION F2(ARG_T : TT) RETURN TT IS
          LOCAL_ATT : ATT := NEW TT;    -- IF SPACE OF F1.LOCAL_T HAS 
                                        -- BEEN (INCORRECTLY) RELEASED,
                                        -- LOCAL_ATT WILL PROBABLY REUSE
                                        -- IT.
     BEGIN
          RETURN ARG_T;
     END;

BEGIN

     TEST("C94021A", "CHECK THAT A TASK MAY BE ACCESSED FROM OUTSIDE " &
                               "ITS MASTER");

     BEGIN
          IF NOT F2(F1)'TERMINATED THEN
               FAILED ("LOCAL TASK NOT TERMINATED OR RELEASED");
          END IF;
     EXCEPTION
          WHEN OTHERS => FAILED ("SOME EXCEPTION RAISED");
     END;
     
     RESULT;

END C94021A;
