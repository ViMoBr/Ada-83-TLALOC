-- B83001A.ADA

-- OBJECTIVE:
--     CHECK THAT TWO NONOVERLOADABLE DECLARATIONS, GIVEN IN THE
--     DECLARATIVE PART OF A SUBPROGRAM'S BODY, CANNOT BE HOMOGRAPHS.
--     IN PARTICULAR, CHECK DECLARATIONS FOR VARIABLES, CONSTANTS, NAMED
--     NUMBERS, EXCEPTIONS, TYPES, SUBTYPES, PACKAGES, TASK UNITS, AND
--     GENERIC UNITS.

-- HISTORY:
--     VCL  02/02/88  CREATED ORIGINAL TEST.

PROCEDURE B83001A IS

-- MULTIPLE SUBPROGRAMS ARE USED SO THAT ONLY ONE DECLARATION WHICH
-- REQUIRES A BODY (TASK AND GENERIC UNITS) IS GIVEN IN EACH SUBPROGRAM.

     PROCEDURE A IS
          TYPE D1 IS RANGE 1..10;

     --  DECLARATIONS OF HOMOGRAPHS.

          TYPE D1 IS ARRAY (1..15) OF CHARACTER;    -- ERROR: HOMOGRAPH.
          SUBTYPE D1 IS STRING(1..12);              -- ERROR: HOMOGRAPH.
          D1 : CONSTANT CHARACTER := 'A';           -- ERROR: HOMOGRAPH.
          D1 : CONSTANT := 5.0;                     -- ERROR: HOMOGRAPH.
          D1 : STRING(1..10);                       -- ERROR: HOMOGRAPH.
          D1 : EXCEPTION;                           -- ERROR: HOMOGRAPH.

          PACKAGE D1 IS END D1;                     -- ERROR: HOMOGRAPH.

          TASK D1;                                  -- ERROR: HOMOGRAPH.

     -- BODY OF HOMOGRAPH.

          TASK BODY D1 IS                       -- OPTIONAL ERR MESSAGE:
          BEGIN                                 --  BODY OF AN INVALID
               NULL;                            --  TASK OBJECT.
          END D1;


     BEGIN
          NULL;
     END A;


     FUNCTION B RETURN BOOLEAN IS
          SUBTYPE D2 IS INTEGER RANGE 1..10;

     --  DECLARATION OF HOMOGRAPH.

          GENERIC                                   -- ERROR: HOMOGRAPH.
          PACKAGE D2 IS END D2;

          TASK TYPE D2;                             -- ERROR: HOMOGRAPH.

     -- BODY OF HOMOGRAPH.

          TASK BODY D2 IS                       -- OPTIONAL ERR MESSAGE:
          BEGIN                                 --  BODY OF AN INVALID
               NULL;                            --  TASK TYPE.
          END D2;


     BEGIN
          RETURN FALSE;
     END B;


     PROCEDURE C IS
          D3 : CONSTANT INTEGER := 10;

     --  DECLARATION OF HOMOGRAPH.

          GENERIC                                   -- ERROR: HOMOGRAPH.
          PROCEDURE D3;

     -- BODY OF HOMOGRAPH.

          PROCEDURE D3 IS                       -- OPTIONAL ERR MESSAGE:
          BEGIN                                 --  BODY OF AN INVALID
               NULL;                            --  GENERIC PROCEDURE.
          END D3;


     BEGIN
          NULL;
     END C;


     FUNCTION D RETURN BOOLEAN IS
          D4 : CONSTANT := 8;

     --  DECLARATION OF HOMOGRAPH.

          GENERIC                                   -- ERROR: HOMOGRAPH.
          FUNCTION D4 RETURN STRING;

     -- BODY OF HOMOGRAPH.

          FUNCTION D4 RETURN STRING IS          -- OPTIONAL ERR MESSAGE:
          BEGIN                                 --  BODY OF AN INVALID
               RETURN "D4";                     --  GENERIC FUNCTION.
          END D4;

     BEGIN
          RETURN FALSE;
     END D;

BEGIN
     NULL;
END B83001A;
