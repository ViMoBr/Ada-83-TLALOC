-- B53009C.ADA

-- CHECK THAT DUPLICATE LABELS ARE NOT ALLOWED IN DIFFERENT ALTERNATIVES
-- OF AN IF STATEMENT.

-- DCB 03/17/80
-- SPS 3/4/83
-- RJK 9/13/83    SPLIT FROM B53009A

PROCEDURE B53009C IS

     I1, I2, I3 : INTEGER;
     B1, B2 : BOOLEAN;
     L1 : CHARACTER;

BEGIN
     B1 := TRUE; B2 := FALSE;
     I1 := 5; I2 := 9; I3 := 0;

     IF B1 THEN
          I3 := 9;
     <<L2>>
          I2 := 8;
     ELSE
          I3 := 8;
     <<L2>>                -- ERROR: LABEL DUPLICATES LABEL IN OTHER
                           --     ALTERNATIVE.
          I2 := 9;
     END IF;

END B53009C;
