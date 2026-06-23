-- B83E01E1.ADA

-- OBJECTIVE:
--     THIS FILE CONTAINS THE SUBUNIT BODIES FOR THE B83E01E TEST.

-- HISTORY:
--     DHH 09/15/88 CREATED ORIGINAL TEST.

SEPARATE (B83E01E0M)
PROCEDURE B83E01E_PROC1(PARAM1, PARAM2, PARAM3, PARAM4, PARAM5,
                        PARAM6, PARAM7 : INTEGER) IS

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
END B83E01E_PROC1;
--**********

SEPARATE (B83E01E0M)
PROCEDURE B83E01E_PROC2(PARAM1, PARAM2, PARAM3, PARAM4 :
                        IN OUT INTEGER) IS

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

END B83E01E_PROC2;
--**********

SEPARATE (B83E01E0M)
FUNCTION B83E01E_PROC3(PARAM1, PARAM2, PARAM3, PARAM4,
                       PARAM5, PARAM6 : INTEGER) RETURN BOOLEAN IS
     GENERIC
     PROCEDURE PARAM1;                                   -- ERROR:

     GENERIC
     FUNCTION PARAM2 RETURN BOOLEAN;                     -- ERROR:

     GENERIC
     PACKAGE PARAM3 IS                                   -- ERROR:
     END;

     GENERIC
     PROCEDURE PARAM;

     TASK PARAM4 IS                                      -- ERROR:
     END;

     PROCEDURE PARAM IS
     BEGIN
          NULL;
     END;

     PROCEDURE PARAM1 IS                                 -- ERROR:
     BEGIN
          NULL;
     END;

     FUNCTION PARAM2 RETURN BOOLEAN IS                   -- ERROR:
     BEGIN
          RETURN TRUE;
     END;

     PROCEDURE PARAM5 IS NEW PARAM;                      -- ERROR:

     TASK BODY PARAM4 IS                  -- OPTIONAL ERR MESSAGE.
     BEGIN
          NULL;
     END;

BEGIN
<<PARAM6>>     RETURN TRUE;                              -- ERROR:
END B83E01E_PROC3;
