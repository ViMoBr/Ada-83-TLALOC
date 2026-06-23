-- B41201A.ADA

-- CHECK THAT MORE THAN ONE DISCRETE RANGE IS FORBIDDEN IN SLICES,
--   EVEN FOR MULTIDIMENSIONAL ARRAYS.
-- CHECK THAT ONE DISCRETE RANGE CANNOT BE GIVEN FOR A 
--   MULTIDIMENSIONAL ARRAY.

-- WKB 8/10/81
-- SPS 11/23/82

PROCEDURE B41201A IS

     TYPE T IS ARRAY (INTEGER RANGE <> ) OF INTEGER;
     SUBTYPE T1 IS T(1..10);
     A : T1 := (1..10 => 1);

     TYPE U IS ACCESS T1;
     B : U := NEW T1 '(1..10 => 2);

     TYPE V IS ARRAY (INTEGER RANGE <>, INTEGER RANGE <> ) OF INTEGER;
     C : V(1..10, 1..10) := (1..10 => (1..10 => 3));

     TYPE W IS ACCESS V;
     D : W := NEW V' (1..10 => (1..10 => 4));

     I : T(1..5);
     J : V(1..5, 1..5);
     K : V(1..5, 1..10);

     FUNCTION F RETURN T1 IS
     BEGIN
          RETURN (1..10 => 5);
     END F;

     FUNCTION G RETURN V IS
     BEGIN
          RETURN (1..10 => (1..10 => 5));
     END G;

BEGIN

     I := A (1..5, 9);             -- ERROR: IMPROPER SLICE.
     NULL;
     I := A (5, 3..7);             -- ERROR: IMPROPER SLICE.
     NULL;
     I := A (6..10, 3..7);         -- ERROR: IMPROPER SLICE.
     NULL;
     I := B (1..5, 9);             -- ERROR: IMPROPER SLICE.
     NULL;
     I := B (5, 3..7);             -- ERROR: IMPROPER SLICE.
     NULL;
     I := B (6..10, 3..7);         -- ERROR: IMPROPER SLICE.
     NULL;
     I := F(1..5, 9);            -- ERROR: IMPROPER SLICE.
     NULL;
     I := F(5, 3..7);            -- ERROR: IMPROPER SLICE.
     NULL;
     I := F(6..10, 3..7);        -- ERROR: IMPROPER SLICE.
     NULL;
     K := C (2..6);                -- ERROR: IMPROPER SLICE.
     NULL;
     I := C (4..8, 8);             -- ERROR: IMPROPER SLICE.
     NULL;
     I := C (4, 6..10);            -- ERROR: IMPROPER SLICE.
     NULL;
     J := C (3..7, 1..5);          -- ERROR: IMPROPER SLICE.
     NULL;
     K := D (2..6);                -- ERROR: IMPROPER SLICE.
     NULL;
     I := D (4..8, 8);             -- ERROR: IMPROPER SLICE.
     NULL;
     I := D (4, 6..10);            -- ERROR: IMPROPER SLICE.
     NULL;
     J := D (3..7, 1..5);          -- ERROR: IMPROPER SLICE.
     NULL;
     K := G(2..6);               -- ERROR: IMPROPER SLICE.
     NULL;
     I := G(4..8, 8);            -- ERROR: IMPROPER SLICE.
     NULL;
     I := G(4, 6..10);           -- ERROR: IMPROPER SLICE.
     NULL;
     J := G(3..7, 1..5);         -- ERROR: IMPROPER SLICE.

END B41201A;
