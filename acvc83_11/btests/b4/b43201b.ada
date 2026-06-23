-- B43201B.ADA

-- CHECK THAT:
--   A) A CHOICE MUST NOT BE A NON-STATIC EXPRESSION IN AN
--      AGGREGATE WITH MORE THAN ONE COMPONENT ASSOCIATION OR
--      MORE THAN ONE CHOICE.
--   B) A CHOICE MUST NOT BE A STATIC NULL DISCRETE RANGE IN AN
--      AGGREGATE WITH MORE THAN ONE COMPONENT ASSOCIATION OR
--      MORE THAN ONE CHOICE.
--   C) IF AN AGGREGATE HAS MORE THAN ONE CHOICE OR COMPONENT 
--      ASSOCIATION AND ONE CHOICE IS OTHERS, THE CORRESPONDING
--      INDEX CONSTRAINT MUST BE STATIC.

-- EG  12/30/83

PROCEDURE B43201B IS
     
     TYPE TC IS (WHITE, RED, YELLOW, GREEN, BLUE, BROWN, BLACK);
     SUBTYPE STC IS TC RANGE RED .. BLUE;                 -- STATIC.
     TYPE T1 IS ARRAY(TC) OF INTEGER;                     -- STATIC.
     TYPE T2 IS ARRAY(TC, TC) OF INTEGER;                 -- STATIC.

     L : TC := RED;                                       -- NON-STATIC.
     R : TC := BLUE;                                      -- NON-STATIC.
     E : CONSTANT TC := L;                                -- NON-STATIC.
     F : CONSTANT TC := TC'SUCC(RED);                     -- STATIC.
     G : TC := BLUE;                                      -- NON-STATIC.

     AA1 : T1 := T1'(E => 0, YELLOW | WHITE => 1,         -- ERROR: A.
                  GREEN .. BLACK => 2);
     AB1 : T1 := T1'(L .. R => 1, OTHERS => 1);           -- ERROR: A.
     AC1 : T1 := T1'(STC => 0, OTHERS => 1);              -- OK.
     AD1 : T1 := T1'(STC RANGE RED .. GREEN => 0,
                     OTHERS => 1);                        -- OK.
     AE1 : T1 := T1'(STC RANGE L .. GREEN => 0, BROWN => 1, -- ERROR: A.
                     OTHERS => 2);       
     AF1 : T1 := T1'(BROWN .. GREEN => 0, OTHERS => 1);   -- ERROR: B.
     AG1 : T1 := T1'(F .. G => 0,                         -- ERROR: A.
                     WHITE .. RED | BROWN .. BLACK => 1);
     AH1 : T1;

     AA2 : T2 := T2'(RED => (L .. R => 1, OTHERS => 2),   -- ERROR: A.
                     OTHERS => (TC => 0));    
     AB2, AC2 : T2;

     TYPE NT1 IS ARRAY(L .. R) OF INTEGER;                -- NON-STATIC.
     TYPE NT2 IS ARRAY(STC, F .. G) OF INTEGER;           -- NON-STATIC.
     SUBTYPE NTC IS TC RANGE L .. BLUE;                   -- NON-STATIC.
     TYPE NT3 IS ARRAY(1 .. 3, NTC RANGE YELLOW .. BLUE) OF INTEGER;
                                                          -- NON-STATIC.

     BA1 : NT1 := NT1'(YELLOW => -5, OTHERS => -4);       -- ERROR: C.
     BB1 : NT1 := NT1'(-4, 3, 15, OTHERS => 0);           -- ERROR: C.

     BA2, BB2 : NT2;

     BA3, BB3 : NT3;

BEGIN
     AH1 := T1'(NTC => -2, OTHERS => -1);                 -- ERROR: A.
     AB2 := T2'(OTHERS =>
                   (BLUE .. WHITE => 0, OTHERS => 1));    -- ERROR: B.
     AC2 := T2'(TC => (E => 2, OTHERS => 1));             -- ERROR: A.
     AC2 := T2'(TC => (NTC => 1, OTHERS => 0));           -- ERROR: A.
     BA2 := NT2'(YELLOW => (OTHERS => 1),                 -- OK.
                 OTHERS => (F .. G => 2));                -- OK.
     BA2 := NT2'(RED | BLUE => (YELLOW .. BLUE => 15),
                 YELLOW .. GREEN =>
                           (GREEN => 7, OTHERS => 5));    -- ERROR: C.
     BB2 := NT2'(STC => (15, 14, OTHERS => 12));          -- ERROR: C.
     BA3 := NT3'((YELLOW .. BLUE => 5), (OTHERS => -2),   -- OK.
                 (GREEN => 4, OTHERS => -1));             -- ERROR: C.
     BB3 := NT3'(1 .. 3 => (16, 17, OTHERS => 18));       -- ERROR: C.
END B43201B;
