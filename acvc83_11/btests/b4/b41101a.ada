-- B41101A.ADA

-- CHECK THAT NEITHER TOO FEW NOR TOO MANY INDEX VALUES
--   ARE ACCEPTED IN INDEXED_COMPONENTS.

-- WKB 8/11/81
-- SPS 12/10/82

PROCEDURE B41101A IS

     TYPE T1 IS ARRAY (1..5) OF INTEGER;
     TYPE T2 IS ARRAY (1..5, 1..5) OF INTEGER;
     TYPE T3 IS ACCESS T1;
     TYPE T4 IS ACCESS T2;

     A : T1 := (1,2,3,4,5);
     B : T2 := (1..5 => (1..5 => 2));
     C : T3 := NEW T1 '(1,2,3,4,5);
     D : T4 := NEW T2 '(1..5 => (1..5 => 4));
     I : INTEGER;

BEGIN

     I := A(1,2);             -- ERROR: TOO MANY INDICES.
     NULL;
     I := C(3,1);             -- ERROR: TOO MANY INDICES.
     NULL;
     I := B(1,2,3);           -- ERROR: TOO MANY INDICES.
     NULL;
     I := B(4);               -- ERROR: TOO FEW INDICES.
     NULL;
     I := D(2);               -- ERROR: TOO FEW INDICES.

END B41101A;
