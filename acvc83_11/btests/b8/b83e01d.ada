-- B83E01D.ADA

-- OBJECTIVE:
--     CHECK THAT A FORMAL PARAMETER OF A SUBPROGRAM SUBUNIT AND A
--     GENERIC SUBPROGRAM SUBUNIT CANNOT  BE IDENTICAL TO ANY OTHER
--     IDENTIFIERS DECLARED IN THE SUBPROGRAM.

-- HISTORY:
--     DHH 09/13/88  CREATED ORIGINAL TEST.

PROCEDURE B83E01D IS

     GENERIC
     PROCEDURE B83E01D_GEN_PROC1(PARAM1, PARAM2, PARAM3, PARAM4,
                                 PARAM5, PARAM6, PARAM7 : INTEGER);

     GENERIC
     PROCEDURE B83E01D_GEN_PROC2(PARAM1, PARAM2, PARAM3,
                                 PARAM4 : INTEGER);

     GENERIC
     FUNCTION B83E01D_GEN_PROC3(PARAM1, PARAM2 : INTEGER)
                                                         RETURN BOOLEAN;

     GENERIC
          TYPE PARAM1 IS (<>);
          TYPE PARAM2 IS (<>);
          TYPE PARAM3 IS (<>);
          TYPE PARAM4 IS (<>);
          TYPE PARAM5 IS (<>);
          TYPE PARAM6 IS (<>);
          TYPE PARAM7 IS (<>);
     PROCEDURE B83E01D_GEN_PROC4;

     GENERIC
          TYPE PARAM1 IS (<>);
          TYPE PARAM2 IS (<>);
          TYPE PARAM3 IS (<>);
          TYPE PARAM4 IS (<>);
     PROCEDURE B83E01D_GEN_PROC5;

     GENERIC
          TYPE PARAM1 IS (<>);
          TYPE PARAM2 IS (<>);
     FUNCTION B83E01D_GEN_PROC6 RETURN BOOLEAN;

     PROCEDURE B83E01D_GEN_PROC1(PARAM1, PARAM2, PARAM3, PARAM4,
                                 PARAM5, PARAM6, PARAM7 : INTEGER)
                                                           IS SEPARATE;

     PROCEDURE B83E01D_GEN_PROC2(PARAM1, PARAM2, PARAM3,
                                 PARAM4 : INTEGER) IS SEPARATE;

     FUNCTION B83E01D_GEN_PROC3(PARAM1, PARAM2 : INTEGER) RETURN BOOLEAN
                                                           IS SEPARATE;

     PROCEDURE B83E01D_GEN_PROC4 IS SEPARATE;

     PROCEDURE B83E01D_GEN_PROC5 IS SEPARATE;

     FUNCTION B83E01D_GEN_PROC6 RETURN BOOLEAN IS SEPARATE;

     PROCEDURE B83E01D_PROC1(PARAM1, PARAM2, PARAM3, PARAM4,
                                 PARAM5, PARAM6, PARAM7 : INTEGER)
                                                           IS SEPARATE;

     PROCEDURE B83E01D_PROC2(PARAM1, PARAM2, PARAM3, PARAM4 : INTEGER)
                                                           IS SEPARATE;

     FUNCTION B83E01D_PROC3(PARAM1, PARAM2, PARAM3, PARAM4, PARAM5 :
                                   INTEGER) RETURN BOOLEAN IS SEPARATE;
BEGIN
     NULL;
END B83E01D;

--**********
SEPARATE (B83E01D)
PROCEDURE B83E01D_GEN_PROC1(PARAM1, PARAM2, PARAM3, PARAM4,
                            PARAM5, PARAM6, PARAM7 : INTEGER) IS

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
END B83E01D_GEN_PROC1;
--**********

SEPARATE (B83E01D)
PROCEDURE B83E01D_GEN_PROC2(PARAM1, PARAM2, PARAM3, PARAM4 : INTEGER) IS

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

END B83E01D_GEN_PROC2;
--**********

SEPARATE (B83E01D)
FUNCTION B83E01D_GEN_PROC3(PARAM1, PARAM2 : INTEGER) RETURN BOOLEAN IS

     TASK PARAM1 IS                                      -- ERROR:
     END;

     TASK BODY PARAM1 IS                  -- OPTIONAL ERR MESSAGE.
     BEGIN
          NULL;
     END;

BEGIN
<<PARAM2>>     RETURN TRUE;                              -- ERROR:
END B83E01D_GEN_PROC3;
--**********

SEPARATE (B83E01D)
PROCEDURE B83E01D_GEN_PROC4 IS

     PARAM1 : INTEGER;                                   -- ERROR:

     PARAM1 : CONSTANT BOOLEAN := TRUE;                  -- ERROR:

     PARAM1 : CONSTANT := 5;                             -- ERROR:

     TYPE PARAM1 IS ARRAY(1 ..2) OF BOOLEAN;             -- ERROR:

     SUBTYPE PARAM1 IS INTEGER;                          -- ERROR:

     PACKAGE PARAM1 IS                                   -- ERROR:
     END;

BEGIN
    PARAM1:                                              -- ERROR:
     DECLARE
     BEGIN
          NULL;
     END PARAM1;
END B83E01D_GEN_PROC4;
--**********

SEPARATE (B83E01D)
PROCEDURE B83E01D_GEN_PROC5 IS

     PARAM1 : EXCEPTION;                                 -- ERROR:

     PROCEDURE PARAM1 IS                                 -- ERROR:
     BEGIN
          NULL;
     END;

     FUNCTION PARAM1 RETURN BOOLEAN IS                   -- ERROR:
     BEGIN
          RETURN TRUE;
     END;

BEGIN
  PARAM1:                                                -- ERROR:
     FOR I IN 1 .. 2 LOOP
          NULL;
     END LOOP PARAM1;

END B83E01D_GEN_PROC5;
--**********

SEPARATE (B83E01D)
FUNCTION B83E01D_GEN_PROC6 RETURN BOOLEAN IS
     TASK PARAM1 IS                                      -- ERROR:
     END;

     TASK BODY PARAM1 IS                  -- OPTIONAL ERR MESSAGE.
     BEGIN
          NULL;
     END;

BEGIN
<<PARAM1>>     RETURN TRUE;                              -- ERROR:
END B83E01D_GEN_PROC6;
--**********

SEPARATE (B83E01D)
PROCEDURE B83E01D_PROC1(PARAM1, PARAM2, PARAM3, PARAM4,
                                 PARAM5, PARAM6, PARAM7 : INTEGER) IS

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
END B83E01D_PROC1;
--**********

SEPARATE (B83E01D)
PROCEDURE B83E01D_PROC2(PARAM1, PARAM2, PARAM3, PARAM4 : INTEGER) IS

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

END B83E01D_PROC2;
--**********

SEPARATE (B83E01D)
FUNCTION B83E01D_PROC3(PARAM1,PARAM2, PARAM3, PARAM4, PARAM5 :
                                              INTEGER) RETURN BOOLEAN IS
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

     PROCEDURE PARAM3 IS NEW PARAM;                      -- ERROR:

     TASK BODY PARAM4 IS                  -- OPTIONAL ERR MESSAGE.
     BEGIN
          NULL;
     END;

BEGIN
<<PARAM5>>     RETURN TRUE;                              -- ERROR:
END B83E01D_PROC3;
