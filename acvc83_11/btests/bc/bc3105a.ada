-- BC3105A.ADA

-- OBJECTIVE:
--     CHECK THAT A SUBCOMPONENT OF A GENERIC IN OUT FORMAL PARAMETER,
--     F, CANNOT BE USED AS AN ACTUAL GENERIC IN OUT PARAMETER IF F'S
--     BASE TYPE IS A RECORD TYPE WITH DISCRIMINANTS (THE EXISTENCE OF
--     DEFAULTS IS IRRELEVANT), AND THE SUBCOMPONENT DEPENDS ON ONE OF
--     F'S DISCRIMINANTS.  THE SUBCOMPONENT SHOULD BE AS FOLLOWS:
--         A) A COMPONENT OF THE VARIABLE AND THE COMPONENT:
--              1) IS IN A VARIANT PART OF THE VARIABLE;
--              2) IS AN ARRAY WITH AT LEAST ONE BOUND SPECIFIED BY A
--                 DISCRIMINANT OF THE VARIABLE;
--              3) HAS A CONSTRAINED RECORD OR PRIVATE TYPE WITH AT
--                 LEAST ONE DISCRIMINANT SPECIFIED BY A DISCRIMINANT OF
--                 THE VARIABLE;
--              4) HAS AN ACCESS TYPE WITH AN EXPLICIT INDEX OR
--                 DISCRIMINANT CONSTRAINT USING A DISCRIMINANT OF THE
--                 VARIABLE;
--         B) A SUBCOMPONENT OF ONE OF THE ABOVE COMPONENTS.

-- HISTORY:
--     TBN  09/25/86  CREATED ORIGINAL TEST.
--     BCB  08/19/87  CHANGED HEADER TO STANDARD HEADER FORMAT.  DELETED
--                    PACKAGE 4.  REMOVED INSTANTIATIONS.

PROCEDURE BC3105A IS

     SUBTYPE INT IS INTEGER RANGE 1 .. 10;
     TYPE ARRAY1 IS ARRAY (INT RANGE <>) OF INTEGER;
     TYPE PTR1 IS ACCESS ARRAY1;

     PACKAGE P IS
          TYPE PRI_REC (D : INT) IS PRIVATE;
     PRIVATE
          TYPE PRI_REC (D : INT) IS
               RECORD
                    A : INTEGER;
               END RECORD;
     END P;

     USE P;

     TYPE REC2 (D : INT := 1) IS
          RECORD
               NAME : STRING (1 .. D);
          END RECORD;

     TYPE PTR2 IS ACCESS REC2;

     TYPE REC1 (D : INT := 2) IS
          RECORD
               ARA1 : ARRAY1 (1 .. D);
               COMP_REC1 : REC2 (D);
               PRI_REC1 : PRI_REC (D);
               ACC_ARA : PTR1 (1 .. D);
               ACC_REC : PTR2 (D);
               SUB_COMP : REC2 (D);
               CASE D IS
                    WHEN 1|2|3|4|5 =>
                         NAME : STRING (1 .. D);
                    WHEN OTHERS =>
                         ADDRESS : STRING (D .. 20);
               END CASE;
          END RECORD;

     TYPE REC4 (D : INT) IS
          RECORD
               NAME : STRING (1 .. D);
          END RECORD;

     TYPE PTR4 IS ACCESS REC4;

     TYPE REC3 (D : INT) IS
          RECORD
               ARA1 : ARRAY1 (1 .. D);
               COMP_REC1 : REC4 (D);
               PRI_REC1 : PRI_REC (D);
               ACC_ARA : PTR1 (1 .. D);
               ACC_REC : PTR4 (D);
               SUB_COMP : REC4 (D);
               CASE D IS
                    WHEN 1|2|3|4|5 =>
                         NAME : STRING (1 .. D);
                    WHEN OTHERS =>
                         ADDRESS : STRING (D .. 20);
               END CASE;
          END RECORD;

     TYPE ARRAY2 IS ARRAY (1 .. 2) OF REC1;
     TYPE ARRAY3 IS ARRAY (1 .. 2) OF REC3 (2);

     OBJ_REC1 : REC1;
     OBJ_REC2 : REC3 (2);
     OBJ_ARA1 : ARRAY2;
     OBJ_ARA2 : ARRAY3;

     GENERIC
          TYPE T IS PRIVATE;
          A : IN OUT T;
     PROCEDURE PROC;

     PROCEDURE PROC IS
          B : INTEGER := 1;
     BEGIN
          IF B /= 1 THEN
               B := B + 1;
          ELSE
               B := 1;
          END IF;
     END PROC;

     GENERIC
          F : IN OUT REC1;
     PACKAGE PAC1 IS
          PROCEDURE PROC1 IS NEW PROC (STRING, F.NAME);        -- ERROR:
          PROCEDURE PROC2 IS NEW PROC (ARRAY1, F.ARA1);        -- ERROR:
          PROCEDURE PROC3 IS NEW PROC (REC2, F.COMP_REC1);     -- ERROR:
          PROCEDURE PROC4 IS
               NEW PROC (PRI_REC, F.PRI_REC1);                 -- ERROR:
          PROCEDURE PROC5 IS NEW PROC (PTR1, F.ACC_ARA);       -- ERROR:
          PROCEDURE PROC6 IS NEW PROC (PTR2, F.ACC_REC);       -- ERROR:
          PROCEDURE PROC7 IS
               NEW PROC (STRING, F.SUB_COMP.NAME);             -- ERROR:
     END PAC1;

     GENERIC
          F : IN OUT REC3;
     PACKAGE PAC2 IS
          PROCEDURE PROC1 IS NEW PROC (STRING, F.NAME);        -- ERROR:
          PROCEDURE PROC2 IS NEW PROC (ARRAY1, F.ARA1);        -- ERROR:
          PROCEDURE PROC3 IS NEW PROC (REC4, F.COMP_REC1);     -- ERROR:
          PROCEDURE PROC4 IS
               NEW PROC (PRI_REC, F.PRI_REC1);                 -- ERROR:
          PROCEDURE PROC5 IS NEW PROC (PTR1, F.ACC_ARA);       -- ERROR:
          PROCEDURE PROC6 IS NEW PROC (PTR4, F.ACC_REC);       -- ERROR:
          PROCEDURE PROC7 IS
               NEW PROC (STRING, F.SUB_COMP.NAME);             -- ERROR:
     END PAC2;

     GENERIC
          F : IN OUT ARRAY2;
     PACKAGE PAC3 IS
          PROCEDURE PROC1 IS NEW PROC (STRING, F(1).NAME);     -- ERROR:
          PROCEDURE PROC2 IS NEW PROC (ARRAY1, F(1).ARA1);     -- ERROR:
          PROCEDURE PROC3 IS
               NEW PROC (REC2, F(1).COMP_REC1);                -- ERROR:
          PROCEDURE PROC4 IS
               NEW PROC (PRI_REC, F(1).PRI_REC1);              -- ERROR:
          PROCEDURE PROC5 IS NEW PROC (PTR1, F(1).ACC_ARA);    -- ERROR:
          PROCEDURE PROC6 IS NEW PROC (PTR2, F(1).ACC_REC);    -- ERROR:
          PROCEDURE PROC7 IS
               NEW PROC (STRING, F(1).SUB_COMP.NAME);          -- ERROR:
     END PAC3;

BEGIN
     NULL;
END BC3105A;
