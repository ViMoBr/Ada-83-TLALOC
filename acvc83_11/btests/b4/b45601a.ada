-- B45601A.ADA

-- CHECK THAT FIXED POINT VALUES CAN NOT BE EXPONENTIATED.  INCLUDES 
-- CHECK THAT REAL EXPONENTS ARE NOT ALLOWED.

-- RJW 2/26/86

PROCEDURE B45601A IS

     TYPE FIXED IS DELTA 1.0 RANGE -1.0 .. 1.0;

     F : FIXED := 1.0;

     G : FLOAT := 1.0;

BEGIN
     F := F ** 2;               -- ERROR: ** NOT ALLOWED FOR FIXED.
     F := F ** 1;               -- ERROR: ** NOT ALLOWED FOR FIXED.
     F := F ** 0;               -- ERROR: ** NOT ALLOWED FOR FIXED.

     F := F ** 1.0;             -- ERROR: ** NOT ALLOWED FOR FIXED.
     F := F ** F;               -- ERROR: ** NOT ALLOWED FOR FIXED.

     G := G ** F;               -- ERROR: REAL EXPONENT NOT ALLOWED.
     G := G ** 1.0;             -- ERROR: REAL EXPONENT NOT ALLOWED.
     G := G ** G;               -- ERROR: REAL EXPONENT NOT ALLOWED.
END B45601A;
