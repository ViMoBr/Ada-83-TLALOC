-- BC3016A.ADA

-- OBJECTIVE:
--     CHECK THAT AN INSTANCE OF A GENERIC PACKAGE MUST DECLARE A
--     PACKAGE.

-- HISTORY:
--     BCB 03/28/88  CREATED ORIGINAL TEST.

PROCEDURE BC3016A IS

     GENERIC
     PACKAGE P IS
     END P;

     PACKAGE PACK IS NEW P;                      -- OK.
     PROCEDURE PROC IS NEW P;                    -- ERROR: NOT A GENERIC
                                                 --        PROCEDURE.
     FUNCTION FUNC IS NEW P;                     -- ERROR: NOT A GENERIC
                                                 --        FUNCTION.

BEGIN
     NULL;
END BC3016A;
