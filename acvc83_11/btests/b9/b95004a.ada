-- B95004A.ADA

-- CHECK THAT AN ACCEPT STATEMENT MAY NOT APPEAR OUTSIDE OF A TASK
--   BODY.

-- JRK 10/26/81

PROCEDURE B95004A IS

     TASK T IS
          ENTRY E0;
          ENTRY E1 (I : INTEGER);
          ENTRY E2 (BOOLEAN) (I : INTEGER);
     END T;

     TASK BODY T IS
     BEGIN
          NULL;
     END T;

     PROCEDURE P IS
     BEGIN
          ACCEPT T.E0;                            -- ERROR: NOT IN TASK.
     END P;

     FUNCTION F RETURN INTEGER IS
     BEGIN
          ACCEPT T.E1 (I : INTEGER);              -- ERROR: NOT IN TASK.
          RETURN 0;
     END F;

     PACKAGE PKG IS
     END PKG;

     PACKAGE BODY PKG IS
     BEGIN
          ACCEPT T.E2 (TRUE) (I : INTEGER);       -- ERROR: NOT IN TASK.
     END PKG;

     TASK T1 IS
          ENTRY E;
     END T1;

     TASK BODY T1 IS
     BEGIN
          ACCEPT E;                               -- OK.
          ACCEPT T.E0;                            -- ERROR: NOT IN
                                                  --   CORRECT TASK.
     END T1;

BEGIN

     T.E0;                                        -- OK.
     T.E1 (1);                                    -- OK.
     T.E2 (TRUE) (2);                             -- OK.

     ACCEPT T.E1 (I : INTEGER);                   -- ERROR: NOT IN TASK.

     DECLARE
          I : INTEGER;
     BEGIN
          ACCEPT T.E2 (TRUE) (I : INTEGER);       -- ERROR: NOT IN TASK.
     END;

END B95004A;
