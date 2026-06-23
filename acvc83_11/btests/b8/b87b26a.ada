-- B87B26A.ADA

-- OBJECTIVE:
--     CHECK THAT THE MEANING OF THE PREFIX OF AN ATTRIBUTE MUST BE
--     DETERMINABLE INDEPENDENTLY OF THE ATTRIBUTE DESIGNATOR AND
--     INDEPENDENTLY OF THE FACT THAT IT IS THE PREFIX OF AN ATTRIBUTE.
--     IN PARTICULAR, CHECK THAT THE FOLLOWING LEGALITY CONSTRAINTS ARE
--     NOT USED FOR OVERLOADING RESOLUTION:
--          (A) FOR 'SIZE, 'FIRST_BIT, 'LAST_BIT, AND 'POSITION, THE
--              REQUIREMENT THAT THE PREFIX DENOTE AN OBJECT RATHER THAN
--              A VALUE IS NOT USED FOR OVERLOADING RESOLUTION.
--              THE ATTRIBUTE 'SIZE IS NOT BEING TESTED YET.
--          (B) FOR 'CALLABLE AND 'TERMINATED, THE REQUIREMENT THAT THE
--              PREFIX BE APPROPRIATE FOR A TASK TYPE IS NOT USED FOR
--              OVERLOADING RESOLUTION.
--          (C) FOR 'FIRST, 'FIRST(N), 'LAST, 'LAST(N), 'LENGTH,
--              'LENGTH(N), 'RANGE, AND 'RANGE(N), THE REQUIREMENT THAT
--              THE PREFIX BE APPROPRIATE FOR AN ARRAY TYPE IS NOT USED
--              FOR OVERLOADING RESOLUTION.
--          (D) EVEN THOUGH THE PREFIX OF THE ATTRIBUTE, 'COUNT MUST
--              DENOTE AN ENTRY OF A TASK, THIS INFORMATION IS NOT
--              USED TO RESOLVE ANY OVERLOADED CONSTITUENTS OF THE
--              PREFIX.

-- HISTORY:
--     LB  10/09/86  CREATED ORIGINAL TEST.
--     RJW 10/13/88  ENTERED INTO ACVC.

PROCEDURE  B87B26A  IS

     INT, I : INTEGER;
     BOL, B : BOOLEAN;

     TYPE REC1 IS
          RECORD
               C1 : INTEGER := 7;
          END RECORD;
     TYPE P_REC1 IS ACCESS REC1;

     FUNCTION F1 RETURN P_REC1;
     FUNCTION F1 RETURN REC1;

     TASK TYPE TT IS
          ENTRY E;
     END TT;
     FUNCTION F2 RETURN BOOLEAN;
     FUNCTION F2 RETURN TT;

     TYPE CARR IS ARRAY(1 .. 2) OF INTEGER;
     TYPE ARR IS ARRAY (INTEGER RANGE <>) OF INTEGER;
     TYPE ARR2 IS ARRAY(1 .. 2, 1 .. 2) OF INTEGER;
     FUNCTION F3 RETURN ARR;
     FUNCTION F3 RETURN CARR;
     FUNCTION F4 RETURN ARR2;
     FUNCTION F4 RETURN ARR;

     TASK BODY TT IS
          ENT : INTEGER;
          FUNCTION E RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END E;
     BEGIN
          ENT := E'COUNT;                                 -- ERROR: (D).
          ACCEPT E;
     END TT;

     FUNCTION F1 RETURN P_REC1 IS
     BEGIN
          RETURN NEW REC1;
     END F1;

     FUNCTION F1 RETURN REC1 IS
     BEGIN
          RETURN (C1 => 13);
     END F1;

     FUNCTION F2 RETURN BOOLEAN IS
     BEGIN
          RETURN TRUE;
     END F2;

     FUNCTION F2 RETURN TT IS
          T : TT;
     BEGIN
          RETURN T;
     END F2;

     FUNCTION F3 RETURN ARR IS
     BEGIN
          RETURN (1, 2);
     END F3;

     FUNCTION F3 RETURN CARR IS
     BEGIN
          RETURN (1, 2);
     END F3;

     FUNCTION F4 RETURN ARR IS
     BEGIN
          RETURN (1, 2);
     END F4;

     FUNCTION F4 RETURN ARR2 IS
     BEGIN
          RETURN ((1, 2), (1, 2));
     END F4;

BEGIN

     INT := F1.C1'FIRST_BIT;                      -- ERROR: (A).
     I   := 4;
     INT := F1.C1'LAST_BIT;                       -- ERROR: (A).
     I   := 6;
     INT := F1.C1'POSITION;                       -- ERROR: (A).
     I   := 8;

     BOL := F2'TERMINATED;                     -- ERROR: (B).
     B   := TRUE;
     BOL := F2'CALLABLE;                       -- ERROR: (B).
     B   := TRUE;

     INT := F3'FIRST;                          -- ERROR: (C).
     INT := F4'FIRST(2);                       -- ERROR: (C).
     I   := 2;
     INT := F3'LAST;                           -- ERROR: (C).
     INT := F4'LAST(2);                        -- ERROR: (C).
     I   := 3;
     INT := F3'LENGTH;                         -- ERROR: (C).
     INT := F4'LENGTH(2);                      -- ERROR: (C).
     I   := 4;

     DECLARE
          I : INTEGER RANGE F3'RANGE;          -- ERROR: (C).
          J : INTEGER RANGE F4'RANGE(2);       -- ERROR: (C).
     BEGIN
          NULL;
     END;

END B87B26A;
