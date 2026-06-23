-- B45501B.ADA

-- OBJECTIVE:
--     THE OPERATORS * AND / ARE NOT PREDEFINED WHEN THE OPERANDS ARE
--     OF AN INTEGER AND A FLOATING POINT TYPE, OR WHEN ONE OR BOTH
--     OPERANDS ARE ARRAYS OF INTEGERS.

-- HISTORY:
--     BCB 07/14/88  CREATED ORIGINAL TEST.

PROCEDURE B45501B IS

     TYPE ARR IS ARRAY(1..5) OF INTEGER;

     A : FLOAT := 1.0;

     B, C : INTEGER := 1;

     D, E, F : ARR := (1,2,3,4,5);

BEGIN

     C := A / B;                  -- ERROR: FLOAT DIVIDED BY INTEGER.
     C := B / A;                  -- ERROR: INTEGER DIVIDED BY FLOAT.
     C := A * B;                  -- ERROR: FLOAT MULTIPLIED BY INTEGER.
     C := B * A;                  -- ERROR: INTEGER MULTIPLIED BY FLOAT.

     C := B / D;                  -- ERROR: INTEGER DIVIDED BY ARRAY.
     C := D / B;                  -- ERROR: ARRAY DIVIDED BY INTEGER.
     C := B * D;                  -- ERROR: INTEGER MULTIPLIED BY ARRAY.
     C := D * B;                  -- ERROR: ARRAY MULTIPLIED BY INTEGER.

     F := D / E;                  -- ERROR: ARRAY DIVIDED BY ARRAY.
     F := D * E;                  -- ERROR: ARRAY MULTIPLIED BY ARRAY.

END B45501B;
