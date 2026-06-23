-- B48003E.ADA

-- CHECK THAT ILLEGAL FORMS OF ALLOCATORS ARE FORBIDDEN. IN PARTICULAR,
-- FOR ALLOCATORS OF THE FORM "NEW T'(X)", CHECK THAT IF T IS AN
-- ARRAY TYPE, CHECK ALL FORMS OF ILLEGAL ARRAY AGGREGATE.

-- EG  08/27/84

WITH REPORT;

PROCEDURE B48003E IS

     USE REPORT;

     TYPE T IS (A, B, C, D);
     TYPE CA IS ARRAY(1 .. 4) OF INTEGER;
     TYPE A_CA IS ACCESS CA;

     V1, V2, V3, V4, V5, V6, V7, V8 : A_CA;

BEGIN

     V1 := NEW CA'(1, 2, 3 => 3, 4 => 4);                   -- ERROR:
     V2 := NEW CA'(4 .. 2 => 3, 1 => 2);                    -- ERROR:
     V3 := NEW CA'(IDENT_INT(1) .. IDENT_INT(3) => 2,
                  OTHERS => 1);                             -- ERROR:
     V4 := NEW CA'(2 => 1, 4 => 2, 1 => 3);                 -- ERROR:
     V5 := NEW CA'(2 => 1, 4 => 2, 1 => 3, 2 => 1);         -- ERROR:
     V6 := NEW CA'(2 => 1, A => 2, 3 => 4, 4 => 3);         -- ERROR:
     V7 := NEW CA'(1 .. 4 => B);                            -- ERROR:
     V8 := NEW CA'(IDENT_INT(1) .. IDENT_INT(2) => 2,
                   IDENT_INT(3) .. IDENT_INT(4) => 3);      -- ERROR:

END B48003E;
