-- B56001A.ADA

-- CHECK THAT A NAMED BLOCK CANNOT BE CLOSED WITHOUT MATCHING END ID.

-- DAT 3/30/81
-- SPS 2/10/83
-- SPS 3/4/83

PROCEDURE B56001A IS
BEGIN

     B1 : BEGIN
          NULL;
     END;                                    -- ERROR: MISSING B1.

     B2 : BEGIN
          NULL;
     END B1;                                 -- ERROR: B1 NOT B2.

     B3 : DECLARE
     BEGIN
          NULL;
     EXCEPTION
          WHEN OTHERS => NULL;
     END B3;                                 -- OK.

     L1 : DECLARE
          BEGIN
               NULL;
          END L2;                            -- ERROR: L2.

     L3 : DECLARE
          BEGIN NULL;
          END;                               -- ERROR: MISSING ID.

END B56001A;
