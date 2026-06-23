-- B45537A.ADA

-- CHECK THAT FIXED POINT MULTIPLICATION AND DIVISION ARE NOT 
-- PREDEFINED WHEN ONE OF THE OPERANDS IS AN INTEGER TYPE OTHER
-- THAN PREDEFINED INTEGER.

-- RJW 2/28/86

PROCEDURE B45537A IS

     TYPE FIXED IS DELTA 1.0 RANGE -1.0 .. 1.0;
     F : FIXED := 0.0;

     I : INTEGER := 1;
     
     TYPE INT1 IS NEW INTEGER;
     I1 : INT1 := 1;

     TYPE INT2 IS RANGE 1 .. 5;
     I2 : INT2 := 1;

BEGIN
     F := F * I;                    -- OK.
     F := I * F;                    -- OK.
     F := F / I;                    -- OK.

     F := F * I1;                   -- ERROR: INVALID TYPES FOR '*'.
     F := I1 * F;                   -- ERROR: INVALID TYPES FOR '*'.
     F := F / I1;                   -- ERROR: INVALID TYPES FOR '/'.

     F := F * I2;                   -- ERROR: INVALID TYPES FOR '*'.
     F := I2 * F;                   -- ERROR: INVALID TYPES FOR '*'.
     F := F / I2;                   -- ERROR: INVALID TYPES FOR '/'.
END B45537A;
