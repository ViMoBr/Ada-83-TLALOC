-- BC2001D.ADA

-- CHECK THAT A TASK TYPE DECLARATION CANNOT BE PRECEDED BY A
-- GENERIC FORMAL PART.

-- PWB  2/12/86

PROCEDURE BC2001D IS

BEGIN  -- BC2001D

     DECLARE  -- (A)

          GENERIC
          TASK TYPE TT;                       -- ERROR: GENERIC
                                              --        TASK TYPE.

          TASK BODY TT IS
          BEGIN
               NULL;
          END TT;

     BEGIN    -- (A)
          NULL;
     END;     -- (A)

     DECLARE  -- (B)

          GENERIC
                X : INTEGER;
          TASK TYPE TT2 IS                         -- ERROR: GENERIC
                                                   --        TASK TYPE.
               ENTRY E;
          END TT2;

          TASK BODY TT2 IS
          BEGIN
               NULL;
          END TT2;

     BEGIN   -- (B)
          NULL;
     END;    -- (B)

     DECLARE -- (C)

          SUBTYPE BASE IS INTEGER RANGE 1..5;

          GENERIC
               TYPE BASE IS RANGE <>;
          TASK TYPE TT3 IS                         -- ERROR: GENERIC
                                                   --        TASK TYPE.
               ENTRY E (BASE) (X : IN OUT INTEGER);
          END TT3;

          TASK BODY TT3 IS
          BEGIN
               NULL;
          END TT3;

     BEGIN   -- (C)
          NULL;
     END;    -- (C)

END BC2001D;
