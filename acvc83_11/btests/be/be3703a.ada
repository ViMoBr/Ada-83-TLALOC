-- BE3703A.ADA

-- CHECK THAT GET AND PUT FOR INTEGER TYPES ARE NOT AVAILABLE WITHOUT
-- INSTANTIATING INTEGER_IO FOR THAT TYPE.

-- SPS 10/1/82

WITH TEXT_IO;
USE TEXT_IO;

PROCEDURE BE3703A IS

     FT : FILE_TYPE;
     TYPE NI IS NEW INTEGER RANGE 0 .. 6;
     TYPE SI IS NEW INTEGER RANGE 1 .. 50;
     X : NI;
     Y : SI;
     Z : INTEGER;

     PACKAGE NIO IS NEW INTEGER_IO (NI);
     USE NIO;

BEGIN
     GET (FT, X);             -- OK.
     GET (FT, Y);             -- ERROR: Y.
     GET (FT, Z);             -- ERROR: Z.

     GET (X);                 -- OK.
     GET (Y);                 -- ERROR: Y.
     GET (Z);                 -- ERROR: Z.

     PUT (FT, X);             -- OK.
     PUT (FT, Y);             -- ERROR: Y.
     PUT (FT, Z);             -- ERROR: Z.

     PUT (X);                 -- OK.
     PUT (Y);                 -- ERROR: Y.
     PUT (Z);                 -- ERROR: Z.

END BE3703A;
