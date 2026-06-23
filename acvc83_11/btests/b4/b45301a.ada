-- B45301A.ADA

-- CHECK THAT '+' AND '-' ARE NOT PREDEFINED FOR OPERANDS HAVING 
-- DIFFERENT INTEGER TYPES.  INCLUDES A CASE IN WHICH ONE OPERAND IS
-- A NON-INTEGER DISCRETE TYPE.

-- RJW 2/8/86

PROCEDURE B45301A IS
     
BEGIN

     DECLARE
          TYPE N IS NEW INTEGER;

          I1 : INTEGER  := 0;
          I2 : N        := 0;
     BEGIN
          I1 := I1 + I2;         -- ERROR: DIFFERENT TYPES FOR '+'.
          I1 := I1 - I2;         -- ERROR: DIFFERENT TYPES FOR '-'.
     END;

     DECLARE
          TYPE N IS RANGE -100 .. 0;
          
          I1 : INTEGER := 0;
          I2 : N       := 0;
     BEGIN
          I1 := I1 + I2;         -- ERROR: DIFFERENT TYPES FOR '+'.
          I1 := I1 - I2;         -- ERROR: DIFFERENT TYPES FOR '-'.
     END;

     DECLARE
          I : INTEGER   := 0;
          C : CHARACTER := '0';     
     BEGIN
          I := I + C;          -- ERROR: DIFFERENT TYPES FOR '+'.
          I := I - C;          -- ERROR: DIFFERENT TYPES FOR '-'.
     END;

END B45301A;
