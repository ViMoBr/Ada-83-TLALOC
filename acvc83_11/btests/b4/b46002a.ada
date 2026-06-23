-- B46002A.ADA

-- CHECK THAT THE OPERAND OF A TYPE CONVERSION MUST NOT BE THE LITERAL 
-- 'NULL', AN ALLOCATOR, AN AGGREGATE, A STRING LITERAL, OR ANY OF THE
-- PRECEDING ENCLOSED IN ONE OR MORE SETS OF PARENTHESES.

-- R.WILLIAMS 9/5/86

PROCEDURE B46002A IS
     
     TYPE T1 IS ARRAY (POSITIVE RANGE <>) OF INTEGER;
     AT1 : T1 (1 .. 2) := (OTHERS => 0);

     SUBTYPE ST1 IS T1 (1 .. 1);     

     TYPE ACC IS ACCESS T1;
     AC1 : ACC;

     TYPE T2 IS ARRAY (POSITIVE RANGE <>) OF CHARACTER;
     AT2 : T2 (1 .. 2) := (OTHERS => 'A');

BEGIN
     AC1 := ACC (NULL);                         -- ERROR: NULL.
     AC1 := ACC ((NULL));                       -- ERROR: NULL.
     AC1 := ACC (((NULL)));                     -- ERROR: NULL.
     
     AC1 := ACC (NEW ST1);                      -- ERROR: ALLOCATOR.
     AC1 := ACC ((NEW ST1));                    -- ERROR: ALLOCATOR.
     AC1 := ACC (((NEW ST1)));                  -- ERROR: ALLOCATOR.
     AC1 := ACC (NEW ST1'(1 ..1 => 0));         -- ERROR: ALLOCATOR.
     AC1 := ACC ((NEW ST1'(1 ..1 => 0)));       -- ERROR: ALLOCATOR.
     AC1 := ACC (((NEW ST1'(1 ..1 => 0))));     -- ERROR: ALLOCATOR.
     AC1 := ACC (NEW T1 (1 .. 2));              -- ERROR: ALLOCATOR.
     AC1 := ACC ((NEW T1 (1 .. 2)));            -- ERROR: ALLOCATOR.
     AC1 := ACC (((NEW T1 (1 .. 2))));          -- ERROR: ALLOCATOR.
                 
     AT1 := T1 ((1, 2));                        -- ERROR: AGGREGATE.
     AT1 := T1 (((1, 2)));                      -- ERROR: AGGREGATE.
     AT1 := T1 ((((1, 2))));                    -- ERROR: AGGREGATE.
     AT1 := T1 ((1 => 0, 2 => 0));              -- ERROR: AGGREGATE.
     AT1 := T1 (((1 => 0, 2 => 0)));            -- ERROR: AGGREGATE.
     AT1 := T1 ((((1 => 0, 2 => 0))));          -- ERROR: AGGREGATE.

     AT2 := T2 (('A', 'B'));                    -- ERROR: AGGREGATE.
     AT2 := T2 ((('A', 'B')));                  -- ERROR: AGGREGATE.  
     AT2 := T2 (((('A', 'B'))));                -- ERROR: AGGREGATE.
     AT2 := T2 ((1 => 'C', 2 => 'D'));          -- ERROR: AGGREGATE.
     AT2 := T2 (((1 => 'C', 2 => 'D')));        -- ERROR: AGGREGATE.
     AT2 := T2 ((((1 => 'C', 2 => 'D'))));      -- ERROR: AGGREGATE.

     AT2 := T2 ("AB");                          -- ERROR: STRING LIT.
     AT2 := T2 (("AB"));                        -- ERROR: STRING LIT.
     AT2 := T2 ((("AB")));                      -- ERROR: STRING LIT.

END B46002A;
