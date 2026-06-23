PRAGMA MEMORY_SIZE (ONE := 1);                              -- ERROR:
PRAGMA STORAGE_UNIT (COLUMN := 4);                          -- ERROR:
PRAGMA SYSTEM_NAME (INT := A (1));                          -- ERROR:

-- B28003C.ADA

-- CHECK THAT AN ASSIGNMENT STATEMENT MAY NOT BE USED IN PLACE OF AN
-- ARGUMENT FOR A PREDEFINED PRAGMA OR AN UNRECOGNIZED PRAGMA.

-- TBN 2/24/86

WITH SYSTEM;
PRAGMA ELABORATE (MY_INTEGER := 1);                         -- ERROR:

PROCEDURE B28003C IS

     PRAGMA OPTIMIZE (FUN := FUN + 1);                      -- ERROR:
     PRAGMA PRIORITY (TWO := TWO - 1);                      -- ERROR:
     PRAGMA CONTROLLED (T1 (1) := TRUE);                    -- ERROR:
     PRAGMA SHARED (THREE := 0);                            -- ERROR:
     PRAGMA INTERFACE (MY_EXC := 1 * EXC);                  -- ERROR:
     PRAGMA INLINE (PKG2 := NEW PKG1);                      -- ERROR:
     PRAGMA PACK (MY_INT := MY_INTEGER);                    -- ERROR:
     PRAGMA SUPPRESS (NULL_KEY := KEY (2,3));               -- ERROR:
     MY_INT : INTEGER;
     
BEGIN

     PRAGMA LIST (ON := 1.5);                               -- ERROR:
     PRAGMA PAGE (ONE := TRUE > FALSE);                     -- ERROR:
     PRAGMA PHIL_BRASHEAR (PHIL := 1.0);                    -- ERROR:
     PRAGMA ROSA_WILLIAMS (ROSA := TRUE);                   -- ERROR:
     PRAGMA THOMAS_NORRIS (THOMAS := 2.0);                  -- ERROR:
     NULL;

END B28003C;
