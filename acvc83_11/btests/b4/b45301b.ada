-- B45301B.ADA

-- CHECK THAT '+' AND '-' ARE NOT PREDEFINED FOR OPERANDS HAVING 
-- DIFFERENT FLOATING POINT TYPES OR FOR OPERANDS OF MIXED FLOATING
-- AND INTEGER TYPES.

-- RJW 2/8/86

PROCEDURE B45301B IS
     
BEGIN

     DECLARE
          TYPE T1 IS DIGITS 3 RANGE -1.0 .. 1.0;
          TYPE T2 IS DIGITS 3 RANGE -1.0 .. 1.0;

          F1 : T1 := 0.0;
          F2 : T2 := 0.0;
     BEGIN
          F1  := F1 + F2;          -- ERROR: DIFFERENT TYPES FOR '+'.
          F1  := F1 - F2;          -- ERROR: DIFFERENT TYPES FOR '-'.
          F1  := F1 + 1;           -- ERROR: DIFFERENT TYPES FOR '+'.
          F1  := F1 - 1;           -- ERROR: DIFFERENT TYPES FOR '-'.
     END;

     DECLARE

          TYPE T1 IS DIGITS 3 RANGE -1.0 .. 1.0;
          TYPE T2 IS NEW T1;

          F1 : T1 := 0.0;
          F2 : T2 := 0.0;
     BEGIN
          F1 := F1 + F2;         -- ERROR: DIFFERENT TYPES FOR '+'.
          F1 := F1 - F2;         -- ERROR: DIFFERENT TYPES FOR '-'.
     END;

END B45301B;
