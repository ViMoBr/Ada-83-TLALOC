-- B36201A.ADA

-- CHECK THAT ARRAY ATTRIBUTES FIRST, FIRST(#), LAST,
-- LAST(#), LENGTH, LENGTH(#), RANGE, RANGE(#) CANNOT BE
-- APPLIED TO UNCONSTRAINED ARRAY TYPES, OR TO RECORD
-- OR PRIVATE TYPES, AND THAT NO PARAMETER CAN BE PRESENT
-- WHEN AN ATTRIBUTE IS APPLIED TO A SCALAR TYPE OR SCALAR 
-- OBJECT.  
-- ALSO, CHECK THAT ONLY ONE ARGUMENT IS PERMITTED
-- (WHICH MUST BE UNIVERSAL INTEGER STATIC AND IN RANGE).

-- DAT 2/11/81
-- ABW 6/9/82
-- JBG 6/9/83
-- RJW 1/21/86 REVISED.  ADDED TESTS FOR A2'BASE'FIRST, ETC.

PROCEDURE B36201A IS

     TYPE I_1 IS NEW INTEGER RANGE 1 .. 1;
     TYPE UA IS ARRAY (I_1 RANGE <> ) OF I_1;
     I1 : I_1 := 1;
     C1 : CONSTANT I_1 := 1;
     TYPE A2 IS ARRAY (I_1, I_1) OF I_1;    
     B : BOOLEAN;
     I : INTEGER;

     TYPE R IS RECORD
          E : A2;
     END RECORD;

     PACKAGE P IS
          TYPE PVT IS PRIVATE;
     PRIVATE
          TYPE PVT IS NEW A2;
     END P;

     USE P;

BEGIN

     I1 := A2'LENGTH;                        -- OK.
     I1 := A2'FIRST;                         -- OK.
     I1 := UA'LENGTH;                        -- ERROR: UNCONSTRAINED.
     I1 := UA'FIRST;                         -- ERROR: UNCONSTRAINED.
     I1 := UA'LAST;                          -- ERROR: UNCONSTRAINED.
     I1 := A2'BASE'FIRST;                    -- ERROR: UNCONSTRAINED.
     I1 := A2'BASE'LAST;                     -- ERROR: UNCONSTRAINED.
     I1 := A2'BASE'LENGTH;                   -- ERROR: UNCONSTRAINED.  
     I1 := 1;
     I := 1;
     IF I1 IN UA'RANGE THEN                  -- ERROR: UNCONSTRAINED.
          NULL;
     END IF;
     IF I1 = UA'FIRST(1) THEN                -- ERROR: UNCONSTRAINED.
          NULL;
     END IF;
     IF I1 IN A2'BASE'RANGE THEN             -- ERROR: UNCONSTRAINED.
          NULL;
     END IF;
     IF I1 = I1'FIRST THEN                   -- ERROR: I1 SCALAR.
          NULL;
     END IF;
     IF 6 IN INTEGER'RANGE THEN              -- ERROR: SCALAR.
          NULL;
     END IF;
     IF 6 = INTEGER'FIRST(1) THEN            -- ERROR: SCALAR.
          NULL;
     END IF;
     IF 1 = INTEGER'LENGTH THEN              -- ERROR: SCALAR.
          NULL;
     END IF;
     B := I1 = I_1'FIRST;                    -- OK.
     B := I1 = I_1'LAST;                     -- OK.
     B := I1 = I_1'FIRST(1);                 -- ERROR: I_1 SCALAR.
     B := I1 = I_1'LAST(1);                  -- ERROR: I_1 SCALAR.
     B := I = I_1'LENGTH;                    -- ERROR: I_1 SCALAR.
     B := I = I_1'LENGTH(1);                 -- ERROR: I_1 SCALAR.
     B := I1 IN I_1'RANGE;                   -- ERROR: I_1 SCALAR.
     B := I1 IN I_1'RANGE(1);                -- ERROR: I_1 SCALAR.
     B := I = I'LAST;                        -- ERROR: I SCALAR.
     B := I IN I'RANGE;                      -- ERROR: I IS SCALAR.
     B := I = I'LENGTH;                      -- ERROR: I IS SCALAR.
     I := STRING'FIRST;                      -- ERROR: UNCONSTRAINED.
     I := R'FIRST;                           -- ERROR: R RECORD.
     B := R'FIRST IN R'RANGE;                -- ERROR: R RECORD.
     B := I = R'LENGTH(1);                   -- ERROR: R RECORD.
     B := I IN PVT'RANGE;                    -- ERROR: PVT PRIVATE.
     B := I < PVT'LENGTH;                    -- ERROR: PVT PRIVATE.
     I := A2'RANGE(1,1);                     -- ERROR: 2 ARGS.
     I := A2'LENGTH(I1);                     -- ERROR: NOT STATIC/UNIV.
     I1 := A2'FIRST(A2'LENGTH);              -- ERROR: UNIV/NOT STATIC.
     I1 := A2'FIRST(C1 + 1);                 -- ERROR: NOT UNIV
     I1 := A2'FIRST(I_1'POS(C1 + 1));        -- OK.
     B := I1 = A2'LAST(0);                   -- ERROR: 0 ILLEGAL.
     B := I1 = A2'LAST(2);                   -- OK.
     B := I1 = A2'LAST(3);                   -- ERROR: 3 ILLEGAL.
     B := I1 IN A2'RANGE(0);                 -- ERROR: 0 ILLEGAL.
     I := A2'LENGTH(-1);                     -- ERROR: -1 ILLEGAL.

END B36201A;
