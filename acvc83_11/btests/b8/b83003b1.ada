-- B83003B1.ADA

-- OBJECTIVE:
--     CHECK THAT AN EXPLICIT DECLARATION IN THE DECLARATIVE PART OF A
--     TASK'S BODY CANNOT HAVE THE SAME IDENTIFIER AS THAT OF A SINGLE
--     ENTRY OR AN ENTRY FAMILY.
--     THIS TEST CHECKS THE CASE WHERE THE TASK SPECIFICATION AND BODY
--     ARE IN SEPARATE COMPILATIONS (TASKS BODIES AS SUBUNITS).

-- SEPARATE FILES:
--     B83003B0M     CONTAINS THE DECLARATIONS OF THE TASKS AND THE
--                   TASK BODY STUBS.
--
--     B83003B1      CONTAINS SEPARATE TASK BODIES.
--
--     B83003B2      CONTAINS SEPARATE TASK BODIES.

-- HISTORY:
--     VCL  02/04/88  CREATED ORIGINAL TEST.

-- MULTIPLE TASKS ARE USED SO THAT ONLY ONE DECLARATION WHICH REQUIRES
-- A BODY (TASK AND GENERIC UNITS) IS GIVEN IN EACH TASK.

SEPARATE (B83003B0M)
TASK BODY TSK1 IS
     TYPE E1 IS                                     -- ERROR: HOMOGRAPH.
          ARRAY (1..15) OF CHARACTER;
     SUBTYPE E2 IS STRING(1..12);                   -- ERROR: HOMOGRAPH.
     E3 : CONSTANT CHARACTER := 'A';                -- ERROR: HOMOGRAPH.
     E4 : CONSTANT := 5.0;                          -- ERROR: HOMOGRAPH.
     E5  : STRING(1..10);                           -- ERROR: HOMOGRAPH.
     E6  : EXCEPTION;                               -- ERROR: HOMOGRAPH.

     PACKAGE E7 IS END E7;                          -- ERROR: HOMOGRAPH.

     TASK E8;                                       -- ERROR: HOMOGRAPH.

     -- BODY FOR THE ABOVE HOMOGRAPH.

     TASK BODY E8 IS                            -- OPTIONAL ERR MESSAGE:
     BEGIN                                      --  BODY OF AN INVALID
          NULL;                                 --  TASK OBJECT.
     END E8;
BEGIN
     NULL;
END TSK1;

SEPARATE (B83003B0M)
TASK BODY TSK2 IS
     TASK TYPE E9;                                 -- ERROR: HOMOGRAPH.

-- BODY FOR THE ABOVE HOMOGRAPH.

     TASK BODY E9 IS                            -- OPTIONAL ERR MESSAGE:
     BEGIN                                      --  BODY OF AN INVALID
          NULL;                                 --  TASK TYPE.
     END E9;
BEGIN
     NULL;
END TSK2;
