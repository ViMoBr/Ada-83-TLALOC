-- BE3803A.ADA

-- CHECK THAT GET AND PUT FOR FLOAT AND FIXED POINT NUMBERS ARE NOT
-- AVAILABLE WITHOUT INSTANTIATING FIXED_IO OR FLOAT_IO.

-- SPS 10/6/82
-- EG  05/30/84

WITH TEXT_IO;
USE TEXT_IO;

PROCEDURE BE3803A IS

     TYPE FIX IS DELTA 0.2 RANGE 1.0 .. 10.0;
     TYPE FL IS NEW FLOAT RANGE 1.0 .. 10.0;

     A : FIX;
     B : FL;
     C : CHARACTER;
     D : FLOAT;
     FT :FILE_TYPE;
     P : POSITIVE;
     ST : STRING (1..10);

BEGIN

     PUT (A);            -- ERROR: A.
     PUT (B);            -- ERROR: B.
     PUT (C);            -- OK.
     PUT (D);            -- ERROR: D.

     PUT (ST, A);        -- ERROR: A.
     PUT (ST, B);        -- ERROR: B.
     PUT (ST, D);        -- ERROR: D.

     PUT (FT, A);        -- ERROR: A.
     PUT (FT, B);        -- ERROR: B.
     PUT (FT, C);        -- OK.
     PUT (FT, D);        -- ERROR: D.

     GET (A);            -- ERROR: A.
     GET (B);            -- ERROR: B.
     GET (C);            -- OK.
     GET (D);            -- ERROR: D.

     GET (ST, A, P);     -- ERROR: A.
     GET (ST, B, P);     -- ERROR: B.
     GET (ST, D, P);     -- ERROR: D.

     GET (FT, A);        -- ERROR: A.
     GET (FT, B);        -- ERROR: B.
     GET (FT, C);        -- OK.
     GET (FT, D);        -- ERROR: D.

END BE3803A;
