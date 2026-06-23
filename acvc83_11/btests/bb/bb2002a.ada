-- BB2002A.ADA

-- CHECK THAT AN EXCEPTION CANNOT BE REFERRED TO MORE THAN ONCE
--    IN A SINGLE HANDLER OR A SEQUENCE OF HANDLERS.

-- DCB 05/07/80
-- JRK 11/17/80
-- SPS 3/23/83

PROCEDURE BB2002A IS

     I1 : INTEGER;

     PROCEDURE P IS
          SINGULAR : EXCEPTION;
          PLURAL   : EXCEPTION;
          I1 : INTEGER;
     BEGIN
          I1 := 1;
     EXCEPTION
          WHEN SINGULAR =>
               NULL;
          WHEN PLURAL |
                 CONSTRAINT_ERROR |
                 PLURAL =>           -- ERROR: EXCEPTION USED TWICE IN 
                                     -- HANDLER.
               NULL;
          WHEN P.SINGULAR =>         -- ERROR: 2ND HANDLER FOR SINGULAR.
               NULL;
          WHEN SINGULAR   =>         -- ERROR: 3RD HANDLER FOR SINGULAR.
               NULL;
     END P;

BEGIN
     I1 := 2;
EXCEPTION
     WHEN CONSTRAINT_ERROR =>
          NULL;
     WHEN NUMERIC_ERROR |
            NUMERIC_ERROR  =>        -- ERROR: EXCEPTION USED TWICE IN 
                                     -- HANDLER.
          NULL;
     WHEN STORAGE_ERROR =>
          NULL;
     WHEN CONSTRAINT_ERROR =>        -- ERROR: 2ND HANDLER FOR
                                     -- CONSTRAINT_ERROR.
          NULL;
     WHEN STANDARD.STORAGE_ERROR =>  -- ERROR: 2ND HANDLER FOR
                                     -- STORAGE_ERROR.
          NULL;
END BB2002A;
