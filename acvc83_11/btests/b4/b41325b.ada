-- B41325B.ADA

-- CHECK THAT THE FOLLOWING IMPLICITLY DECLARED ENTITIES CANNOT BE
-- SELECTED FROM OUTSIDE THE PACKAGE USING AN EXPANDED NAME, FOR AN
-- ARRAY TYPE.
--     CASE 1: CHECK EQUALITY AND INEQUALITY WHEN COMPONENT TYPE IS
--               LIMITED, FOR MULTIDIMENSIONAL ARRAYS.
--     CASE 2: FOR ONE DIMENSIONAL ARRAYS:
--               A) CHECK CATENATION, EQUALITY, AND INEQUALITY WHEN 
--                    COMPONENT TYPE IS LIMITED.
--               B) CHECK ORDERING OPERATORS WHEN COMPONENT TYPE IS 
--                    NON-DISCRETE.
--               C) CHECK THE "NOT" OPERATOR AND THE LOGICAL OPERATORS 
--                    WHEN COMPONENT TYPE IS NON-BOOLEAN.

-- TBN  7/18/86

PROCEDURE B41325B IS

     PACKAGE P IS
          TYPE KEY IS LIMITED PRIVATE;
          TYPE FLOAT IS DIGITS 5;
          TYPE CATARRAY IS ARRAY (INTEGER RANGE <>) OF KEY;
          TYPE ARRAY_1 IS ARRAY (1..10) OF KEY;
          TYPE ARRAY_2 IS ARRAY (1..4, 1..4) OF KEY;
          TYPE ARRAY_3 IS ARRAY (1..2, 1..3, 1..4) OF KEY;
          TYPE ARRAY_4 IS ARRAY (1..10) OF FLOAT;
          TYPE ARRAY_5 IS ARRAY (1..10) OF INTEGER;
     PRIVATE
          TYPE KEY IS NEW NATURAL;
     END P;

     VAR_ARA_1 : P.ARRAY_1;
     VAR_ARA_2 : P.ARRAY_2;
     VAR_ARA_3 : P.ARRAY_3;
     VAR_ARA_4 : P.ARRAY_4;
     VAR_ARA_5 : P.ARRAY_5;
     VAR_ARA_7 : P.CATARRAY (1..10);
     VAR_ARA_20 : P.CATARRAY (1..20);
     VAR_BOOL : BOOLEAN := FALSE;

BEGIN

     -- CASE 1: MULTIDIMENSIONAL ARRAYS.

     VAR_BOOL := P."=" (VAR_ARA_2, VAR_ARA_2);                 -- ERROR:
     VAR_BOOL := P."=" (VAR_ARA_3, VAR_ARA_3);                 -- ERROR:
     VAR_BOOL := P."/=" (VAR_ARA_2, VAR_ARA_2);                -- ERROR:
     VAR_BOOL := P."/=" (VAR_ARA_3, VAR_ARA_3);                -- ERROR:

     -- CASE 2: ONE DIMENSIONAL ARRAYS.

     VAR_BOOL := P."=" (VAR_ARA_1, VAR_ARA_1);                 -- ERROR:
     VAR_BOOL := P."/=" (VAR_ARA_1, VAR_ARA_1);                -- ERROR:

     VAR_ARA_20 := P."&" (VAR_ARA_7, VAR_ARA_7);               -- ERROR:

     VAR_BOOL := P."=" (VAR_ARA_4, VAR_ARA_4);                 -- OK.
     VAR_BOOL := P."/=" (VAR_ARA_4, VAR_ARA_4);                -- OK.
     VAR_BOOL := P."<" (VAR_ARA_4, VAR_ARA_4);                 -- ERROR:
     VAR_BOOL := P."<=" (VAR_ARA_4, VAR_ARA_4);                -- ERROR:
     VAR_BOOL := P.">" (VAR_ARA_4, VAR_ARA_4);                 -- ERROR:
     VAR_BOOL := P.">=" (VAR_ARA_4, VAR_ARA_4);                -- ERROR:

     VAR_ARA_5 := P."NOT" (VAR_ARA_5);                         -- ERROR:
     VAR_ARA_5 := P."AND" (VAR_ARA_5, VAR_ARA_5);              -- ERROR:
     VAR_ARA_5 := P."OR" (VAR_ARA_5, VAR_ARA_5);               -- ERROR:
     VAR_ARA_5 := P."XOR" (VAR_ARA_5, VAR_ARA_5);              -- ERROR:

END B41325B;
