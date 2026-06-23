-- B52002C.ADA

-- CHECK THAT ENTRIES, TASKS, AND AGGREGATES WITH TASK COMPONENTS CANNOT
--   BE ASSIGNED TO.

-- JRK 9/17/81
-- SPS 3/21/83

PROCEDURE B52002C IS

     TASK TYPE TT IS
          ENTRY E;
     END TT;

     TYPE A IS ARRAY (1..3) OF TT;

     TYPE R IS
          RECORD
               I : INTEGER := 0;
               T : TT;
          END RECORD;

     TYPE AR IS ARRAY (1..3) OF R;

     TYPE DT IS NEW TT;

     TYPE DAR IS NEW AR;

     T1, T2 : TT;
     A1, A2 : A;
     R1, R2 : R;
     AR1, AR2 : AR;
     DT1, DT2 : DT;
     DAR1, DAR2 : DAR;

     TASK BODY TT IS
     BEGIN
          NULL;
     END TT;

BEGIN

     T1.E := T2.E;       -- ERROR: NO := FOR ENTRIES.

     T1 := T2;           -- ERROR: NO := FOR TASKS.

     A1 := A2;           -- ERROR: NO := FOR TASK AGGREGATES.

     R1 := R2;           -- ERROR: NO := FOR TASK AGGREGATES.

     AR1 := AR2;         -- ERROR: NO := FOR TASK AGGREGATES.

     DT1.E := DT2.E;     -- ERROR: NO := FOR DERIVED ENTRIES.

     DT1 := DT2;         -- ERROR: NO := FOR DERIVED TASKS.

     DAR1 := DAR2;       -- ERROR: NO := FOR DERIVED TASK AGGREGATES.

END B52002C;
