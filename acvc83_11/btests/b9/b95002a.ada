-- B95002A.ADA

-- CHECK THAT THE NAME OF A SINGLE (NON-FAMILY) ENTRY CAN NOT BE
--   GIVEN AS AN INDEXED COMPONENT IN AN ACCEPT STATEMENT OR IN
--   AN ENTRY CALL.

-- JRK 10/22/81
-- JWC 6/28/85   RENAMED TO -AB

PROCEDURE B95002A IS

     SUBTYPE INT IS INTEGER RANGE 1..5;

     TASK T IS
          ENTRY E0;
          ENTRY E1 (B : BOOLEAN);
          ENTRY E2 (B1, B2 : BOOLEAN);
     END T;

     TASK BODY T IS
     BEGIN
          ACCEPT E0;                    -- OK.
          ACCEPT E0 (1);                -- ERROR: NON-FAMILY INDEXED.
          NULL;

          ACCEPT E1 (B : BOOLEAN);      -- OK.
          ACCEPT E1 (1) (B : BOOLEAN);  -- ERROR: NON-FAMILY INDEXED.
          NULL;

          ACCEPT E2 (B1, B2 : BOOLEAN); -- OK.
          ACCEPT E2 (1) (B1, B2 : BOOLEAN);  -- ERROR: NON-FAMILY
                                             --        INDEXED.
          NULL;
     END T;

BEGIN

     T.E0;                    -- OK.
     T.E0 (1);                -- ERROR: NON-FAMILY INDEXED.
     NULL;

     T.E1 (TRUE);             -- OK.
     T.E1 (1) (TRUE);         -- ERROR: NON-FAMILY INDEXED.
     NULL;

     T.E2 (TRUE,FALSE);       -- OK.
     T.E2 (1) (TRUE,FALSE);   -- ERROR: NON-FAMILY INDEXED.
     NULL;

END B95002A;
