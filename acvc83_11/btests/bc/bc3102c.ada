-- BC3102C.ADA

-- CHECK THAT A SUBCOMPONENT OF A SUBPROGRAM OR ENTRY PARAMETER OF MODE
-- "OUT" CANNOT BE USED AS A GENERIC ACTUAL "IN OUT" PARAMETER.

-- TBN  11/17/86

PROCEDURE BC3102C IS

     SUBTYPE SUBSTR IS STRING (1 .. 10);
     TYPE ARA_TYP IS ARRAY (1 .. 2) OF INTEGER;

     TYPE REC1 IS
          RECORD
               ANS : BOOLEAN := TRUE;
               ARA : ARA_TYP := (3, 4);
          END RECORD;

     TYPE REC2 IS
          RECORD
               INT : INTEGER := 1;
               STR : SUBSTR := "0123456789";
               SUB : REC1;
          END RECORD;

     TYPE ARA IS ARRAY (1 .. 5) OF REC2;

     GENERIC
          TYPE T IS PRIVATE;
          OBJ_T : IN OUT T;
     PACKAGE P IS
          PAC_T : T;
     END P;

     PROCEDURE PROC (A : OUT REC2; B : OUT ARA) IS
          PACKAGE P1 IS NEW P (INTEGER, A.INT);                -- ERROR:
          PACKAGE P2 IS NEW P (SUBSTR, A.STR);                 -- ERROR:
          PACKAGE P3 IS NEW P (CHARACTER, A.STR(2));           -- ERROR:
          PACKAGE P4 IS NEW P (BOOLEAN, A.SUB.ANS);            -- ERROR:
          PACKAGE P5 IS NEW P (INTEGER, A.SUB.ARA(1));         -- ERROR:
          PACKAGE P6 IS NEW P (INTEGER, B(1).INT);             -- ERROR:
          PACKAGE P7 IS NEW P (SUBSTR, B(3).STR);              -- ERROR:
          PACKAGE P8 IS NEW P (CHARACTER, B(4).STR(9));        -- ERROR:
          PACKAGE P9 IS NEW P (BOOLEAN, B(5).SUB.ANS);         -- ERROR:
          PACKAGE P10 IS NEW P (INTEGER, B(2).SUB.ARA(2));     -- ERROR:
     BEGIN
          A := (2, "WHO? WHAT?", SUB => (TRUE, (1, 2)));
     END PROC;

     TASK TT IS
          ENTRY E1 (A : OUT REC2; B : OUT ARA);
     END TT;

     TASK BODY TT IS

     BEGIN
          ACCEPT E1 (A : OUT REC2; B : OUT ARA) DO
               DECLARE
                    PACKAGE P11 IS NEW P (INTEGER, A.INT);     -- ERROR:
                    PACKAGE P12 IS NEW P (SUBSTR, A.STR);      -- ERROR:
                    PACKAGE P13 IS
                         NEW P (CHARACTER, A.STR(2));          -- ERROR:
                    PACKAGE P14 IS
                         NEW P (BOOLEAN, A.SUB.ANS);           -- ERROR:
                    PACKAGE P15 IS
                         NEW P (INTEGER, A.SUB.ARA(1));        -- ERROR:
                    PACKAGE P16 IS
                         NEW P (INTEGER, B(1).INT);            -- ERROR:
                    PACKAGE P17 IS
                         NEW P (SUBSTR, B(3).STR);             -- ERROR:
                    PACKAGE P18 IS
                         NEW P (CHARACTER, B(4).STR(9));       -- ERROR:
                    PACKAGE P19 IS
                         NEW P (BOOLEAN, B(5).SUB.ANS);        -- ERROR:
                    PACKAGE P20 IS
                         NEW P (INTEGER, B(2).SUB.ARA(2));     -- ERROR:
               BEGIN
                    NULL;
               END;
          END E1;
     END TT;

BEGIN
     NULL;
END BC3102C;
