-- BC3001A.ADA

-- OBJECTIVE:
--     CHECK THAT A REFERENCE TO AN INSTANTIATION CANNOT PRECEDE THE
--     INSTANTIATION ITSELF.

-- HISTORY:
--     BCB 03/28/88  CREATED ORIGINAL TEST.

PROCEDURE BC3001A IS

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

     GENERIC
     PACKAGE PACK IS
          INT : INTEGER;
     END PACK;

     PACKAGE TEST IS
          B : BOOLEAN := NEWF;                -- ERROR: NEWF NOT
                                              -- INSTANTIATED YET.
          C : INTEGER := NEWPACK.INT;         -- ERROR: NEWPACK NOT
                                              -- INSTANTIATED YET.
     END TEST;

     PACKAGE BODY TEST IS
     BEGIN
          NEWP;                               -- ERROR: NEWP NOT
                                              -- INSTANTIATED YET.
     END TEST;

     PROCEDURE NEWP IS NEW P;
     FUNCTION NEWF IS NEW F;
     PACKAGE NEWPACK IS NEW PACK;

BEGIN
     NULL;
END BC3001A;
