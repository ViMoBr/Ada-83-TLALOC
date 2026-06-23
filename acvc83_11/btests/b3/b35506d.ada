-- B35506D.ADA

-- CHECK THAT THE ARGUMENT TO T'VAL MUST BE AN INTEGER TYPE.

-- RJW 2/26/86

PROCEDURE  B35506D  IS
     
     I1 : INTEGER := 0;

     TYPE INT1 IS RANGE 0 .. 2;
     I2 : INT1 := 0;

     TYPE INT2 IS NEW INTEGER;
     I3 : INT2 := 0;

     F : FLOAT := 0.0;
     
     TYPE FIX IS DELTA 1.0 RANGE 0.0 .. 2.0;
     FX : FIX := 0.0;

     R : CONSTANT := 0.0;
     
     TYPE T IS (A, B, C);
     T1 : T;

BEGIN
     T1 := T'VAL (I1);                   -- OK.
     T1 := T'VAL (I2);                   -- OK.
     T1 := T'VAL (I3);                   -- OK.
     T1 := T'VAL (0);                    -- OK.
     T1 := T'VAL (F);                    -- ERROR: F.
     T1 := T'VAL (FX);                   -- ERROR: FX.
     T1 := T'VAL (R);                    -- ERROR: R.
     T1 := T'VAL (A);                    -- ERROR: A.
     T1 := T'VAL (TRUE);                 -- ERROR: TRUE.
     T1 := T'VAL ('0');                  -- ERROR: '0'.
END B35506D ;
