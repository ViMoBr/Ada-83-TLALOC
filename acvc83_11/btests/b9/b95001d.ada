-- B95001D.ADA

-- OBJECTIVE:
--     CHECK THAT THE NAME OF AN ENTRY FAMILY MUST BE SPECIFIED AS A
--     SINGLY INDEXED COMPONENT IN AN ENTRY CALL OR IN AN ACCEPT
--     STATEMENT.

-- HISTORY:
--     RJW 09/06/88  CREATED ORIGINAL TEST BY RENAMING B95001C.ADA.

PROCEDURE B95001D IS

     SUBTYPE INT IS INTEGER RANGE 1..5;

     TASK T IS
          ENTRY E0 (INT);
          ENTRY E1 (INT) (B : BOOLEAN);
          ENTRY E2 (INT) (B1, B2 : BOOLEAN);
     END T;

     TASK BODY T IS
     BEGIN
          ACCEPT E0 (1,2);                   -- ERROR: FAMILY REQUIRES
                                             --        1 INDEX.
          NULL;
          ACCEPT E0 (1..2);                  -- ERROR: FAMILY SLICE
                                             --        PROHIBITED.
          NULL;

          ACCEPT E1 (1,2) (B : BOOLEAN);     -- ERROR: FAMILY REQUIRES
                                             --        1 INDEX.
          NULL;
          ACCEPT E1 (1..2) (B : BOOLEAN);    -- ERROR: FAMILY SLICE
                                             --        PROHIBITED.
          NULL;

          ACCEPT E2 (1,2) (B1, B2 : BOOLEAN);  -- ERROR: FAMILY REQUIRES
                                               --        1 INDEX.
          NULL;
          ACCEPT E2 (1..2) (B1, B2 : BOOLEAN); -- ERROR: FAMILY SLICE
                                               --        PROHIBITED.
          NULL;
     END T;

BEGIN

     NULL;

END B95001D;
