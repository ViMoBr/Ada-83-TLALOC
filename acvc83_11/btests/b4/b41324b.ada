-- B41324B.ADA

-- CHECK THAT THE OPERATIONS FOR MULTIPLYING AND DIVIDING TWO FIXED
-- POINT OPERANDS ARE NOT IMPLICITLY DECLARED IN THE PACKAGE WHERE THE
-- TYPE IS DECLARED.  CHECK THAT THE FIRST OPERAND FOR DIVISION CANNOT
-- BE AN INTEGER.

-- TBN  7/17/86

PROCEDURE B41324B IS

     PACKAGE P IS
          TYPE FIXED IS DELTA 0.125 RANGE -1.0E1 .. 1.0E1;
          OBJ_FIX_2 : FIXED := 1.5;
     END P;

     FIX_VAR_1 : P.FIXED := P."-" (P.FIXED (9.0));
     FIX_VAR_2 : P.FIXED := 1.5;
     FIX_VAR_3 : P.FIXED := 1.0E1;

BEGIN

     FIX_VAR_1 := P."*" (FIX_VAR_2, P.FIXED (2.1));            -- ERROR:
     NULL;
     FIX_VAR_1 := P."*" (P.OBJ_FIX_2, P.FIXED (2.1));          -- ERROR:
     NULL;
     FIX_VAR_1 := P."*" (3, FIX_VAR_2);                        -- OK.

     FIX_VAR_1 := P."/" (FIX_VAR_3, P.OBJ_FIX_2);              -- ERROR:
     NULL;
     FIX_VAR_1 := P."/" (FIX_VAR_3, FIX_VAR_2);                -- ERROR:
     NULL;
     FIX_VAR_1 := P."/" (FIX_VAR_3, 2);                        -- OK.

     FIX_VAR_1 := P."/" (2, P.FIXED (10.0));                   -- ERROR:
     NULL;
     FIX_VAR_1 := P."/" (2, FIX_VAR_3);                        -- ERROR:

END B41324B;
