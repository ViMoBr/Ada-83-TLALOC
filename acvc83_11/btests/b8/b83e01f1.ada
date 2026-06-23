-- B83E01F1.ADA

-- OBJECTIVE:
--     THIS FILE CONTAINS THE BODIES OF THE SUBUNITS FOR THE B83E01F
--     TEST.

-- HISTORY:
--     DHH 09/15/88 CREATED ORIGINAL TEST.

--**********
SEPARATE (B83E01F0M)
PROCEDURE B83E01F_GEN_PROC1(PARAM1, PARAM2, PARAM3, PARAM4, PARAM5,
                            PARAM6, PARAM7 : INTEGER) IS

     PARAM1 : INTEGER;                                   -- ERROR:

     PARAM2 : CONSTANT BOOLEAN := TRUE;                  -- ERROR:

     PARAM3 : CONSTANT := 5;                             -- ERROR:

     TYPE PARAM4 IS ARRAY(1 ..2) OF BOOLEAN;             -- ERROR:

     SUBTYPE PARAM5 IS INTEGER;                          -- ERROR:

     PACKAGE PARAM5 IS                                   -- ERROR:
     END;

BEGIN
    PARAM7:                                              -- ERROR:
     DECLARE
     BEGIN
          NULL;
     END PARAM7;
END B83E01F_GEN_PROC1;
--**********

SEPARATE (B83E01F0M)
PROCEDURE B83E01F_GEN_PROC2(PARAM1, PARAM2, PARAM3,
                            PARAM4 : IN OUT INTEGER) IS

     PARAM1 : EXCEPTION;                                 -- ERROR:

     PROCEDURE PARAM2 IS                                 -- ERROR:
     BEGIN
          NULL;
     END;

     FUNCTION PARAM3 RETURN BOOLEAN IS                   -- ERROR:
     BEGIN
          RETURN TRUE;
     END;

BEGIN
  PARAM4:                                                -- ERROR:
     FOR I IN 1 .. 2 LOOP
          NULL;
     END LOOP PARAM4;

END B83E01F_GEN_PROC2;
--**********

SEPARATE (B83E01F0M)
FUNCTION B83E01F_GEN_PROC3(PARAM1, PARAM2 : INTEGER) RETURN BOOLEAN IS
     TASK PARAM1 IS                                      -- ERROR:
     END;

     TASK BODY PARAM1 IS                  -- OPTIONAL ERR MESSAGE.
     BEGIN
          NULL;
     END;

BEGIN
<<PARAM2>>     RETURN TRUE;                              -- ERROR:
END B83E01F_GEN_PROC3;
--**********

SEPARATE (B83E01F0M)
PROCEDURE B83E01F_GEN_PROC4 IS

     PARAM1 : INTEGER;                                   -- ERROR:

     PARAM2 : CONSTANT BOOLEAN := TRUE;                  -- ERROR:

     PARAM3 : CONSTANT := 5;                             -- ERROR:

     TYPE PARAM4 IS ARRAY(1 ..2) OF BOOLEAN;             -- ERROR:

     SUBTYPE PARAM5 IS INTEGER;                          -- ERROR:

     PACKAGE PARAM6 IS                                   -- ERROR:
     END;

BEGIN
    PARAM7:                                              -- ERROR:
     DECLARE
     BEGIN
          NULL;
     END PARAM7;
END B83E01F_GEN_PROC4;
--**********

SEPARATE (B83E01F0M)
PROCEDURE B83E01F_GEN_PROC5 IS

     PARAM1 : EXCEPTION;                                 -- ERROR:

     PROCEDURE PARAM2 IS                                 -- ERROR:
     BEGIN
          NULL;
     END;

     FUNCTION PARAM3 RETURN BOOLEAN IS                   -- ERROR:
     BEGIN
          RETURN TRUE;
     END;

BEGIN
  PARAM4:                                                -- ERROR:
     FOR I IN 1 .. 2 LOOP
          NULL;
     END LOOP PARAM4;

END B83E01F_GEN_PROC5;
--**********

SEPARATE (B83E01F0M)
FUNCTION B83E01F_GEN_PROC6 RETURN BOOLEAN IS
     TASK PARAM1 IS                                      -- ERROR:
     END;

     TASK BODY PARAM1 IS                  -- OPTIONAL ERR MESSAGE.
     BEGIN
          NULL;
     END;

BEGIN
<<PARAM2>>     RETURN TRUE;                              -- ERROR:
END B83E01F_GEN_PROC6;
