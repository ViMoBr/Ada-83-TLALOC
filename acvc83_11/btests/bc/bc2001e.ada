-- BC2001E.ADA

-- CHECK THAT A TASK DECLARATION CANNOT BE PRECEDED BY A
-- GENERIC FORMAL PART.

-- PWB  2/12/86

PROCEDURE BC2001E IS

BEGIN  -- BC2001E

     DECLARE  -- (A)

          GENERIC                                   -- ERROR: GENERIC
                                                    --        TASK.
          TASK TT;

          TASK BODY TT IS
          BEGIN
               NULL;
          END TT;

     BEGIN    -- (A)
          NULL;
     END;     -- (A)

     DECLARE  -- (B)

          GENERIC
                X : INTEGER;                        -- ERROR: GENERIC 
                                                    --        TASK.
          TASK TT2 IS
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
          TASK TT3 IS                               -- ERROR: GENERIC 
                                                    --        TASK.
               ENTRY E (BASE) (X : IN OUT INTEGER);
          END TT3;

          TASK BODY TT3 IS
          BEGIN
               NULL;
          END TT3;

     BEGIN   -- (C)
          NULL;
     END;    -- (C)

END BC2001E;
