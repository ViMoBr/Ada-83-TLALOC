-- BE3002A.ADA

-- CHECK THAT FILE_MODE IS VISIBLE AND HAS LITERAL IN_FILE AND OUT_FILE,
-- NOT INOUT_FILE.

-- CHECK THAT FILE_TYPE IS LIMITED PRIVATE.

-- SPS 9/30/82
-- SPS 11/9/82
-- JBG 3/16/83

WITH TEXT_IO;
USE TEXT_IO;

PROCEDURE BE3002A IS

     FT   : FILE_TYPE;
     MODE : FILE_MODE;
     FT2  : FILE_TYPE;

BEGIN

     FT2 := FT;                              -- ERROR: LIMITED PRIVATE.

     MODE := IN_FILE;                        -- OK.
     MODE := OUT_FILE;                       -- OK.
     MODE := INOUT_FILE;                     -- ERROR: INOUT_FILE.

     CREATE (FT, IN_FILE);                   -- OK.
     CREATE (FT, OUT_FILE);                  -- OK.
     CREATE (FT, INOUT_FILE);                -- ERROR: INOUT_FILE.

     OPEN (FT, IN_FILE, "X3002A");           -- OK.
     OPEN (FT, OUT_FILE, "X3002A");          -- OK.
     OPEN (FT, INOUT_FILE, "X3002A");        -- ERROR: INOUT_FILE.

     RESET (FT, IN_FILE);                    -- OK.
     RESET (FT, OUT_FILE);                   -- OK.
     RESET (FT, INOUT_FILE);                 -- ERROR: INOUT_FILE.

END BE3002A;
