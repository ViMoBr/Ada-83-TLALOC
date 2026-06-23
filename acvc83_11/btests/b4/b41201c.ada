-- B41201C.ADA

-- CHECK THAT THE BASE TYPE OF THE DISCRETE RANGE OF A SLICE MUST BE
--   THE SAME AS THE BASE TYPE OF THE INDEX OF THE ARRAY TYPE.

-- WKB 8/10/81
-- JWC 6/28/85   RENAMED TO -AB

PROCEDURE B41201C IS

     SUBTYPE S IS INTEGER RANGE 5..50;
     TYPE S1 IS NEW S;
     X : S1 := 6;
     Y : S1 := 9;

     TYPE T IS ARRAY (INTEGER RANGE <> ) OF INTEGER;
     A : T(0..50) := (0..50 => 1);
     B : T(1..4);
     C : T(1..2);

     TYPE U IS (E1,E2,E3,E4);
     TYPE U1 IS ARRAY (U RANGE <> ) OF INTEGER;
     D : U1(E1..E4) := (E1..E4 => 3);
     E : U1(E2..E3);

BEGIN

     B := A (X..Y);                    -- ERROR: DIFFERENT BASE TYPES.
     NULL;
     B := A (ASCII.LF .. ASCII.CR);    -- ERROR: DIFFERENT BASE TYPES.
     NULL;
     C := A (FALSE..TRUE);             -- ERROR: DIFFERENT BASE TYPES.
     NULL;
     C := A (E2..E3);                  -- ERROR: DIFFERENT BASE TYPES.
     NULL;
     E := D (2..3);                    -- ERROR: DIFFERENT BASE TYPES.

END B41201C;
