-- B52004A.ADA

-- CHECK THAT TYPES OF TARGET VARIABLE AND EXPRESSION MUST MATCH
--    AT COMPILE TIME FOR INTEGER, CHARACTER, ARRAY, RECORD, ACCESS,
--    AND DERIVED TYPES.

-- DCB 2/18/80
-- JRK 7/17/80
-- SPS 12/10/82

PROCEDURE B52004A IS

     TYPE NEW_INT IS NEW INTEGER;

     I1 : INTEGER := 6;
     NI1: NEW_INT := 32;
     C1 : CHARACTER := 'A';

     TYPE TA1 IS ARRAY (1..10) OF INTEGER;
     TYPE TA2 IS ARRAY (1..3,1..2) OF INTEGER;
     TYPE TA3 IS ARRAY (1..4, 1..3, 1..2) OF INTEGER;
     TYPE TA4 IS ARRAY (1..10) OF NEW_INT;

     V1 : TA1 := (1,2,3,4,5,6,7,8,9,0);
     V2 : TA2 := (1..3 => (1,2));
     V3 : TA3 := (1..4 => (1..3 => (1,2)));
     V4 : TA4 := (1..10 => 20);

     TYPE R IS
          RECORD
             I : INTEGER;
          END RECORD;
     TYPE PR IS ACCESS R;

     R1  : R  := (I => 1);
     PR1 : PR := NEW R'(I => 2);

BEGIN

     I1 := NI1;         -- ERROR: TYPES DON'T MATCH.
     NI1 := I1;         -- ERROR: TYPES DON'T MATCH.

     I1 := C1;          -- ERROR: TYPES DON'T MATCH.
     I1 := "ASDF";      -- ERROR: TYPES DON'T MATCH.

     I1 := V1;          -- ERROR: TYPES DON'T MATCH.
     I1 := V2;          -- ERROR: TYPES DON'T MATCH.
     I1 := V3;          -- ERROR: TYPES DON'T MATCH.

     V1 := V2;          -- ERROR: TYPES DON'T MATCH.
     V1 := V3;          -- ERROR: TYPES DON'T MATCH.
     V2 := V1;          -- ERROR: TYPES DON'T MATCH.
     V3 := V2;          -- ERROR: TYPES DON'T MATCH.

     V3 := 9;           -- ERROR: TYPES DON'T MATCH.
     V2 := 9;           -- ERROR: TYPES DON'T MATCH.
     V1 := 9;           -- ERROR: TYPES DON'T MATCH.

     V3 := V1(4);       -- ERROR: TYPES DON'T MATCH.
     V3 := V1(1..3);    -- ERROR: TYPES DON'T MATCH.
     V3 := (1..2 => (1..3 => 1));       -- ERROR: TYPES DON'T MATCH.

     V1(2) := 'A';      -- ERROR: TYPES DON'T MATCH.
     V2(3,1) := 'A';    -- ERROR: TYPES DON'T MATCH.
     V3(2,3,2) := 'A';  -- ERROR: TYPES DON'T MATCH.
     V4 := V1;          -- ERROR: TYPES DON'T MATCH.

     R1 := PR1;         -- ERROR: TYPES DON'T MATCH.
     PR1 := R1;         -- ERROR: TYPES DON'T MATCH.

END B52004A;
