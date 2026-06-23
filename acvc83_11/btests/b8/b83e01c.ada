-- B83E01C.ADA

-- OBJECTIVE:
--     CHECK THAT A FORMAL PARAMETER OF A SUBPROGRAM AND A GENERIC
--     SUBPROGRAM CANNOT BE IDENTICAL TO ANY OTHER IDENTIFIERS DECLARED
--     IN THE SUBPROGRAM.

-- HISTORY:
--     DHH 09/08/88  CREATED ORIGINAL TEST.

PROCEDURE B83E01C IS

     GENERIC
     PROCEDURE GEN_PROC1(PARAM1, PARAM2, PARAM3, PARAM4, PARAM5,
                         PARAM6, PARAM7 : INTEGER);

     GENERIC
     PROCEDURE GEN_PROC2(PARAM1, PARAM2, PARAM3, PARAM4 : INTEGER);

     GENERIC
     PROCEDURE GEN_PROC3(PARAM1, PARAM2 : INTEGER);

     PROCEDURE GEN_PROC1(PARAM1, PARAM2, PARAM3, PARAM4, PARAM5,
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
     END GEN_PROC1;

     PROCEDURE GEN_PROC2(PARAM1, PARAM2, PARAM3, PARAM4 : INTEGER)IS

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

     END GEN_PROC2;

     PROCEDURE GEN_PROC3(PARAM1, PARAM2 : INTEGER)IS
          TASK PARAM1 IS                                      -- ERROR:
          END;

          TASK BODY PARAM1 IS                  -- OPTIONAL ERR MESSAGE.
          BEGIN
               NULL;
          END;

     BEGIN
<<PARAM2>>     NULL;                                          -- ERROR:
     END GEN_PROC3;

     PROCEDURE PROC1(PARAM1, PARAM2, PARAM3, PARAM4, PARAM5,
                         PARAM6, PARAM7 : INTEGER)IS

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
     END PROC1;

     PROCEDURE PROC2(PARAM1, PARAM2, PARAM3, PARAM4 : INTEGER)IS

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

     END PROC2;

     PROCEDURE PROC3(PARAM1, PARAM2, PARAM3, PARAM4,
                     PARAM5 : INTEGER) IS
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
<<PARAM5>>     NULL;                                          -- ERROR:
     END PROC3;

BEGIN
     NULL;
END B83E01C;
