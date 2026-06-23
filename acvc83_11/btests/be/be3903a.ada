-- BE3903A.ADA

-- CHECK THAT GET AND PUT FOR ENUMERATION TYPES ARE NOT AVAILABLE
-- WITHOUT INSTANTIATING ENUMERATION_IO;

-- SPS 10/7/82
-- SPS 12/7/83

WITH TEXT_IO;
USE TEXT_IO;

PROCEDURE BE3903A IS

     TYPE COLOR IS (RED, BLUE, YELLOW);
     TYPE WEEKEND IS (SATURDAY, SUNDAY);
     FT : FILE_TYPE;
     C : CHARACTER := 'A';
     X : COLOR := BLUE;
     Y : WEEKEND := SATURDAY;
     ST : STRING (1 .. 10);
     L : POSITIVE;
BEGIN

     PUT (FT, C);             -- OK.
     PUT (FT, X);             -- ERROR: X.
     PUT (FT, Y);             -- ERROR: Y.
     PUT (C);                 -- OK.
     PUT (X);                 -- ERROR: X.
     PUT (Y);                 -- ERROR: Y.
     PUT (ST, X);             -- ERROR: X.
     PUT (ST, Y);             -- ERROR: Y.

     GET (FT, C);             -- OK.
     GET (FT, X);             -- ERROR: X.
     GET (FT, Y);             -- ERROR: Y.
     GET (C);                 -- OK.
     GET (X);                 -- ERROR: X.
     GET (Y);                 -- ERROR: Y.
     GET (" YELLOW", X, L);   -- ERROR: X.
     GET ("SUNDAY ", Y, L);   -- ERROR: Y.

END BE3903A;
