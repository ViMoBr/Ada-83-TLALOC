-- BC3104A.ADA

-- CHECK THAT AN ACTUAL IN OUT PARAMETER CANNOT BE A SUBCOMPONENT OF AN
-- UNCONSTRAINED IN OUT FORMAL PARAMETER OF A SUBPROGRAM OR ENTRY, IF
-- THE SUBPROGRAM OR ENTRY PARAMETER HAS A RECORD TYPE WITH DEFAULT
-- DISCRIMINANTS AND THE SUBCOMPONENT DEPENDS ON A DISCRIMINANT OF THE
-- PARAMETER'S TYPE.  THE SUBCOMPONENT SHOULD BE AS FOLLOWS:
--     A) A COMPONENT OF THE VARIABLE AND THE COMPONENT:
--          1) IS IN A VARIANT PART OF THE VARIABLE;
--          2) IS AN ARRAY WITH AT LEAST ONE BOUND SPECIFIED BY A
--             DISCRIMINANT OF THE VARIABLE;
--          3) HAS A CONSTRAINED RECORD OR PRIVATE TYPE WITH AT LEAST
--             ONE DISCRIMINANT SPECIFIED BY A DISCRIMINANT OF THE
--             VARIABLE;
--          4) HAS AN ACCESS TYPE WITH AN EXPLICIT INDEX OR DISCRIMINANT
--             CONSTRAINT USING A DISCRIMINANT OF THE VARIABLE;
--     B) A SUBCOMPONENT OF ONE OF THE ABOVE COMPONENTS.

-- TBN  9/24/86

PROCEDURE BC3104A IS

     SUBTYPE INT IS INTEGER RANGE 1 .. 10;
     TYPE ARRAY1 IS ARRAY (INT RANGE <>) OF INTEGER;
     TYPE PTR1 IS ACCESS ARRAY1;

     PACKAGE PAC IS
          TYPE PRI_REC (D : INT) IS PRIVATE;
     PRIVATE
          TYPE PRI_REC (D : INT) IS
               RECORD
                    A : INTEGER;
               END RECORD;
     END PAC;

     USE PAC;

     TYPE REC3 (D : INT := 1) IS
          RECORD
               NAME : STRING (1 .. D);
          END RECORD;

     TYPE PTR2 IS ACCESS REC3;

     TYPE REC1 (D : INT := 2) IS
          RECORD
               ARA1 : ARRAY1 (1 .. D);
               COMP_REC1 : REC3 (D);
               PRI_REC1 : PRI_REC (D);
               ACC_ARA : PTR1 (1 .. D);
               ACC_REC : PTR2 (D);
               SUB_COMP : REC3 (D);
               CASE D IS
                    WHEN 1|2|3|4|5 =>
                         NAME : STRING (1 .. D);
                    WHEN OTHERS =>
                         ADDRESS : STRING (D .. 20);
               END CASE;
          END RECORD;

     GENERIC
          TYPE T IS PRIVATE;
          A : IN OUT T;
     PROCEDURE PROC (B : IN OUT INTEGER);

     PROCEDURE PROC (B : IN OUT INTEGER) IS
     BEGIN
          IF B /= 1 THEN
               B := B + 1;
          ELSE
               B := 1;
          END IF;
     END PROC;

     PROCEDURE FRED (A : IN OUT REC1) IS
          PROCEDURE PROC1 IS NEW PROC (STRING, A.NAME);        -- ERROR:
          PROCEDURE PROC2 IS NEW PROC (ARRAY1, A.ARA1);        -- ERROR:
          PROCEDURE PROC3 IS NEW PROC (REC3, A.COMP_REC1);     -- ERROR:
          PROCEDURE PROC4 IS
               NEW PROC (PRI_REC, A.PRI_REC1);                 -- ERROR:
          PROCEDURE PROC5 IS NEW PROC (PTR1, A.ACC_ARA);       -- ERROR:
          PROCEDURE PROC6 IS NEW PROC (PTR2, A.ACC_REC);       -- ERROR:
          PROCEDURE PROC7 IS
               NEW PROC (STRING, A.SUB_COMP.NAME);             -- ERROR:
     BEGIN
          NULL;
     END FRED;

     TASK T1 IS
          ENTRY E (A : IN OUT REC1);
     END T1;

     TASK BODY T1 IS
     BEGIN
          ACCEPT E (A : IN OUT REC1) DO
               DECLARE
                    PROCEDURE PROC1 IS
                         NEW PROC (STRING, A.NAME);            -- ERROR:
                    PROCEDURE PROC2 IS
                         NEW PROC (ARRAY1, A.ARA1);            -- ERROR:
                    PROCEDURE PROC3 IS
                         NEW PROC (REC3, A.COMP_REC1);         -- ERROR:
                    PROCEDURE PROC4 IS
                         NEW PROC (PRI_REC, A.PRI_REC1);       -- ERROR:
                    PROCEDURE PROC5 IS
                         NEW PROC (PTR1, A.ACC_ARA);           -- ERROR:
                    PROCEDURE PROC6 IS
                         NEW PROC (PTR2, A.ACC_REC);           -- ERROR:
                    PROCEDURE PROC7 IS
                         NEW PROC (STRING, A.SUB_COMP.NAME);   -- ERROR:
               BEGIN
                    NULL;
               END;
          END E;
     END T1;

BEGIN
     NULL;
END BC3104A;
