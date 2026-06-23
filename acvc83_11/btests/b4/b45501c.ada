-- B45501C.ADA

-- OBJECTIVE:
--     THE OPERATORS MOD AND REM ARE NOT PREDEFINED WHEN BOTH OPERANDS
--     ARE REAL OR WHEN THE FIRST OPERAND IS REAL AND THE SECOND IS
--     AN INTEGER.

-- HISTORY:
--     BCB 07/13/88  CREATED ORIGINAL TEST.

PROCEDURE B45501C IS

     TYPE FIX IS DELTA 2.0**(-1) RANGE -2.0 .. 2.0;

     A : INTEGER := 1;

     B, C, D : FLOAT := 1.0;

     E, F, G : FIX := 1.0;

BEGIN

     D := B REM C;                        -- ERROR: FLOAT REM FLOAT.
     D := B MOD C;                        -- ERROR: FLOAT MOD FLOAT.

     D := B REM A;                        -- ERROR: FLOAT REM INTEGER.
     D := B MOD A;                        -- ERROR: FLOAT MOD INTEGER.

     G := E REM F;                        -- ERROR: FIXED REM FIXED.
     G := E MOD F;                        -- ERROR: FIXED MOD FIXED.

     G := E REM A;                        -- ERROR: FIXED REM INTEGER.
     G := E MOD A;                        -- ERROR: FIXED MOD INTEGER.

END B45501C;
