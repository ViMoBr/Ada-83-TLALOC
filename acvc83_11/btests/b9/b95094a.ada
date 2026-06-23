-- B95094A.ADA

-- CHECK THAT AN ENTRY FAMILY NAME IS NOT OVERLOADABLE.

-- JWC 7/22/85
-- JRK 10/1/85

PROCEDURE B95094A IS

     TYPE NEWINT IS NEW INTEGER;

     TASK T IS

          ENTRY E (1 .. 10) (X : IN INTEGER);      -- OK: INITIAL
                                                   --     DECLARATION.

          ENTRY E (1 .. 10) (X : OUT INTEGER);     -- ERROR: ILLEGAL
                                                   --        OVERLOAD.
          ENTRY E (1 .. 10) (X : IN OUT INTEGER);  -- ERROR: ILLEGAL
                                                   --        OVERLOAD.
          ENTRY E (0 .. 5) (X : IN INTEGER);       -- ERROR: ILLEGAL
                                                   --        OVERLOAD.
          ENTRY E (1 .. 10) (X : IN NEWINT);       -- ERROR: ILLEGAL
                                                   --        OVERLOAD.
          ENTRY E (1 .. 10) (X : IN INTEGER;
                             Y : IN OUT INTEGER);  -- ERROR: ILLEGAL
                                                   --        OVERLOAD.
          ENTRY E ('A' .. 'Z') (Y : IN CHARACTER); -- ERROR: ILLEGAL
                                                   --        OVERLOAD.
          ENTRY E (Z : IN BOOLEAN);                -- ERROR: ILLEGAL
                                                   --        OVERLOAD.

     END T;

     TASK BODY T IS
     BEGIN
          NULL;
     END T;

BEGIN
     NULL;
END B95094A;
