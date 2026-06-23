-- B83008A.ADA

-- OBJECTIVE:
--     CHECK THAT NONOVERLOADABLE DECLARATIONS, GIVEN IN THE
--     DECLARATIVE PART OF A BLOCK STATEMENT, CANNOT BE HOMOGRAPHS.
--     IN PARTICULAR, CHECK DECLARATIONS FOR VARIABLES, CONSTANTS, NAMED
--     NUMBERS, EXCEPTIONS, TYPES, SUBTYPES, PACKAGES, TASK UNITS, AND
--     GENERIC UNITS.

-- HISTORY:
--     VCL  03/08/88  CREATED ORIGINAL TEST.

PROCEDURE B83008A IS

-- MULTIPLE BLOCKS ARE USED SO THAT ONLY ONE DECLARATION WHICH
-- REQUIRES A BODY (TASK AND GENERIC UNITS) IS GIVEN IN EACH BLOCK.

BEGIN
     DECLARE
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

          TASK BODY D1 IS                       -- OPTIONAL ERR MESSAGE.
          BEGIN
               NULL;
          END D1;

     BEGIN
          NULL;
     END;


     DECLARE
          SUBTYPE D2 IS INTEGER RANGE 1..10;

     --  DECLARATION OF HOMOGRAPH.

          GENERIC
          PACKAGE D2 IS END D2;                     -- ERROR: HOMOGRAPH.

          TASK TYPE D2;                             -- ERROR: HOMOGRAPH.

     -- BODY OF HOMOGRAPH.

          TASK BODY D2 IS                       -- OPTIONAL ERR MESSAGE.
          BEGIN
               NULL;
          END D2;

     BEGIN
          NULL;
     END;


     DECLARE
          D3 : CONSTANT INTEGER := 10;

     --  DECLARATION OF HOMOGRAPH.

          GENERIC
          PROCEDURE D3;                             -- ERROR: HOMOGRAPH.

     -- BODY OF HOMOGRAPH.

          PROCEDURE D3 IS                       -- OPTIONAL ERR MESSAGE.
          BEGIN
               NULL;
          END D3;

     BEGIN
          NULL;
     END;


     DECLARE
          D4 : CONSTANT := 8;

     --  DECLARATION OF HOMOGRAPH.

          GENERIC
          FUNCTION D4 RETURN STRING;                -- ERROR: HOMOGRAPH.

     -- BODY OF HOMOGRAPH.

          FUNCTION D4 RETURN STRING IS          -- OPTIONAL ERR MESSAGE.
          BEGIN
               RETURN "D4";
          END D4;
     BEGIN
          NULL;
     END;
END B83008A;
