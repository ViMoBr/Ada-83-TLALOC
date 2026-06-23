-- B49009A.ADA

-- OBJECTIVE:
--     CHECK THAT CERTAIN ATTRIBUTES ARE NOT ALLOWED IN STATIC
--     EXPRESSIONS, SUCH AS: 'ADDRESS, 'CALLABLE, 'CONSTRAINED, 'COUNT,
--     'FIRST(FOR AN ARRAY PREFIX), 'FIRST(N), 'FIRST_BIT, 'LAST(FOR
--     ARRAYS), 'LAST(N), 'LAST_BIT, 'LENGTH, 'LENGTH(N), 'POSITION,
--     'RANGE, 'RANGE(N), 'SIZE(WHEN THE PREFIX DENOTES AN OBJECT OR A
--     NON-SCALAR TYPE), 'STORAGE_SIZE, 'TERMINATED, AND 'VALUE.

-- HISTORY:
--     LB  08/28/86 CREATED ORIGINAL TEST.
--     DHH 10/19/87 SHORTENED LINES CONTAINING MORE THAN 72 CHARACTERS.

WITH SYSTEM; USE SYSTEM;
PROCEDURE  B49009A  IS

BEGIN
     DECLARE
          OBJ1 : BOOLEAN := TRUE;
          TASK TSK IS
               ENTRY ENT;
          END TSK;
          TASK BODY TSK IS
          BEGIN
               ACCEPT ENT DO
                    NULL;
               END ENT;
          END TSK;
     BEGIN
          TSK.ENT;
          CASE OBJ1 IS
               WHEN TSK'CALLABLE =>                            -- ERROR:
                    OBJ1 := FALSE;
               WHEN OTHERS =>
                    NULL;
          END CASE;
          CASE OBJ1 IS
               WHEN TSK'TERMINATED =>                          -- ERROR:
                    OBJ1 := FALSE;
               WHEN OTHERS =>
                    NULL;
          END CASE;
     END;

     DECLARE
          TYPE ER_REC1(AINT : INTEGER := 4) IS RECORD
               AANT : INTEGER RANGE 1 .. 10 := 2;
               CASE AINT IS
                    WHEN 4 =>
                         X : CHARACTER RANGE 'A' .. 'C';
                    WHEN OTHERS =>
                         Y : POSITIVE RANGE 1 .. 10;
               END CASE;
          END RECORD;
          OBJ1 : BOOLEAN := TRUE;
          OBJ_REC : ER_REC1(10);
     BEGIN
          CASE OBJ1 IS
               WHEN OBJ_REC'CONSTRAINED =>                     -- ERROR:
                    OBJ1 := FALSE;
               WHEN OTHERS =>
                    NULL;
          END CASE;
     END;

     DECLARE
          TASK TSK IS
               ENTRY ENT;
          END TSK;
          TASK BODY TSK IS
          BEGIN
               ACCEPT ENT DO
                    DECLARE
                         TYPE INT IS RANGE 1 .. ENT'COUNT;    -- ERROR:
                    BEGIN
                         NULL;
                    END;
               END ENT;
          END TSK;
     BEGIN
          TSK.ENT;
     END;

     DECLARE
          TASK TSK IS
               ENTRY ENT;
          END TSK;
          TASK BODY TSK IS
          BEGIN
               ACCEPT ENT DO
                    NULL;
               END ENT;
          END TSK;
     BEGIN
          DECLARE
               CON : CONSTANT := TSK'STORAGE_SIZE;             -- ERROR:
          BEGIN
               NULL;
          END;
          TSK.ENT;
     END;

     DECLARE
          TYPE PTR IS ACCESS INTEGER;
          CON : CONSTANT := PTR'STORAGE_SIZE;                  -- ERROR:
     BEGIN
          NULL;
     END;

     DECLARE
          OBJ1 : INTEGER := 10;
          TYPE ARR IS ARRAY(1 .. 5,1 .. 2) OF BOOLEAN;
     BEGIN
          CASE OBJ1 IS
               WHEN ARR'FIRST =>                               -- ERROR:
                    OBJ1 := 5;
               WHEN OTHERS =>
                    NULL;
          END CASE;
          CASE OBJ1 IS
               WHEN ARR'FIRST(2) =>                            -- ERROR:
                    OBJ1 := 5;
               WHEN OTHERS =>
                    NULL;
          END CASE;
          CASE OBJ1 IS
               WHEN ARR'LAST =>                                -- ERROR:
                    OBJ1 := 4;
               WHEN OTHERS =>
                    NULL;
          END CASE;
          CASE OBJ1 IS
               WHEN ARR'LAST(2) =>                             -- ERROR:
                    OBJ1 := 6;
               WHEN OTHERS =>
                    NULL;
          END CASE;
          CASE OBJ1 IS
               WHEN ARR'LENGTH =>                              -- ERROR:
                    OBJ1 := 7;
               WHEN OTHERS =>
                    NULL;
          END CASE;
          CASE OBJ1 IS
               WHEN ARR'LENGTH(2) =>                           -- ERROR:
                    OBJ1 := 5;
               WHEN OTHERS =>
                    NULL;
          END CASE;
     END;

     DECLARE
          TYPE ER_REC1 IS RECORD
               AANT : INTEGER RANGE 1 .. 10 := 2;
          END RECORD;
          OBJ : ER_REC1;
          NAMED_NUM : CONSTANT := OBJ.AANT'FIRST_BIT;          -- ERROR:
          TYPE INT IS RANGE 1 .. OBJ.AANT'LAST_BIT;            -- ERROR:
          CON : CONSTANT := OBJ.AANT'POSITION;                 -- ERROR:
     BEGIN
          NULL;
     END;

     DECLARE
          TYPE ARR IS ARRAY(1 .. 5,1 .. 3) OF INTEGER;
          OBJ1 : INTEGER := 10;
          TYPE INT IS RANGE 1 .. OBJ1'SIZE;                    -- ERROR:
          CON : CONSTANT := ARR'SIZE;                          -- ERROR:
     BEGIN
          CASE OBJ1 IS
               WHEN ARR'RANGE =>                               -- ERROR:
                    OBJ1 := 3;
               WHEN OTHERS =>
                    NULL;
          END CASE;
          CASE OBJ1 IS
               WHEN ARR'RANGE(2) =>                            -- ERROR:
                    OBJ1 := 4;
               WHEN OTHERS =>
                    NULL;
          END CASE;
     END;

     DECLARE
          OBJ1 : INTEGER := 4;
     BEGIN
          CASE OBJ1 IS
               WHEN INTEGER'VALUE(4) =>                       -- ERROR:
                    OBJ1 := 2;
               WHEN OTHERS =>
                    NULL;
          END CASE;
     END;
END B49009A;
