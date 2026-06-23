-- BE3001A.ADA

-- CHECK THAT TEXT_IO EXISTS AND THAT READ AND WRITE ARE NOT
-- AVAILABLE.

-- ABW  8/23/82
-- SPS  9/16/82
-- SPS  11/9/82
-- TBN  10/3/86     ADDED CHECKS THAT READ AND WRITE ARE NOT AVAILABLE
--                  FOR TYPES COMMONLY USED TO INSTANTIATE GENERIC
--                  PACKAGES IN TEXT_IO.

WITH TEXT_IO; USE TEXT_IO;
PROCEDURE BE3001A IS

     TYPE COLOR IS (WHITE, RED, ORANGE, YELLOW, GREEN, BLUE);
     TYPE FLOAT IS DIGITS 5;
     TYPE FIXED IS DELTA 0.125 RANGE 0.0 .. 10.0;

     PACKAGE COLOR_IO IS NEW ENUMERATION_IO (COLOR);
     USE COLOR_IO;

     PACKAGE NUMBER_IO IS NEW INTEGER_IO (INTEGER);
     USE NUMBER_IO;

     PACKAGE NEW_FLOAT_IO IS NEW FLOAT_IO (FLOAT);
     USE NEW_FLOAT_IO;

     PACKAGE NEW_FIXED_IO IS NEW FIXED_IO (FIXED);
     USE NEW_FIXED_IO;

     FILE : FILE_TYPE;
     INT : INTEGER := 18;
     OBJ_INT : INTEGER;
     OBJ_COLOR : COLOR;
     OBJ_FLOAT : FLOAT;
     OBJ_FIXED : FIXED;
     OBJ_CHAR : CHARACTER;
     OBJ_STR : STRING (1 .. 5);

BEGIN

     WRITE (FILE, INT);                                 -- ERROR: WRITE.
     WRITE (INT);                                       -- ERROR: WRITE.

     READ (FILE, OBJ_INT);                              -- ERROR: READ.
     READ (OBJ_INT);                                    -- ERROR: READ.

     WRITE (FILE, WHITE);                               -- ERROR: WRITE.
     WRITE (ORANGE);                                    -- ERROR: WRITE.

     READ (FILE, OBJ_COLOR);                            -- ERROR: READ.
     READ (OBJ_COLOR);                                  -- ERROR: READ.

     WRITE (FILE, 5.9);                                 -- ERROR: WRITE.
     WRITE (10.1);                                      -- ERROR: WRITE.

     READ (FILE, OBJ_FLOAT);                            -- ERROR: READ.
     READ (OBJ_FLOAT);                                  -- ERROR: READ.

     WRITE (FILE, 6.1);                                 -- ERROR: WRITE.
     WRITE (7.125);                                     -- ERROR: WRITE.

     READ (FILE, OBJ_FIXED);                            -- ERROR: READ.
     READ (OBJ_FIXED);                                  -- ERROR: READ.

     WRITE (FILE, 'A');                                 -- ERROR: WRITE.
     WRITE ('Z');                                       -- ERROR: WRITE.

     READ (FILE, OBJ_CHAR);                             -- ERROR: READ.
     READ (OBJ_CHAR);                                   -- ERROR: READ.

     WRITE (FILE, "WHERE");                             -- ERROR: WRITE.
     WRITE ("WHY");                                     -- ERROR: WRITE.

     READ (FILE, OBJ_STR);                              -- ERROR: READ.
     READ (OBJ_STR);                                    -- ERROR: READ.

END BE3001A ;
