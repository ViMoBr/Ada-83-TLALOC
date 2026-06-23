-- BC3017A.ADA

-- OBJECTIVE:
--     CHECK THAT AN INSTANCE OF A GENERIC PROCEDURE MUST DECLARE A
--     PROCEDURE AND THAT AN INSTANCE OF A GENERIC FUNCTION MUST
--     DECLARE A FUNCTION.

-- HISTORY:
--     BCB 03/28/88  CREATED ORIGINAL TEST.

PROCEDURE BC3017A IS

     GENERIC
     PROCEDURE P;

     PROCEDURE P IS
     BEGIN
          NULL;
     END P;

     GENERIC
     FUNCTION F RETURN BOOLEAN;

     FUNCTION F RETURN BOOLEAN IS
     BEGIN
          RETURN TRUE;
     END F;

     PROCEDURE PROC IS NEW P;                    -- OK.
     FUNCTION FUNC IS NEW P;                     -- ERROR: NOT A GENERIC
                                                 --        FUNCTION.
     PACKAGE PACK IS NEW P;                      -- ERROR: NOT A GENERIC
                                                 --        PACKAGE.

     FUNCTION FUNC1 IS NEW F;                    -- OK.
     PROCEDURE PROC1 IS NEW F;                   -- ERROR: NOT A GENERIC
                                                 --        PROCEDURE.
     PACKAGE PACK1 IS NEW F;                     -- ERROR: NOT A GENERIC
                                                 --        PACKAGE.

BEGIN
     NULL;
END BC3017A;
