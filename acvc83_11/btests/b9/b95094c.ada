-- B95094C.ADA

-- CHECK THAT DECLARATION OF AN ENTRY FAMILY HIDES OUTER DECLARATIONS
-- OF SUBPROGRAMS AND OTHER ENTITIES HAVING THE SAME IDENTIFIER.
-- SUBTESTS ARE:
--   (A)  OBJECT DECLARATION.
--   (B)  FUNCTION DECLARATION.
--   (C)  PROCEDURE DECLARATION.
--   (D)  TYPE DECLARATION.

-- JWC 7/24/85
-- JRK 10/2/85

PROCEDURE B95094C IS

BEGIN

     --------------------------------------------------

     DECLARE  -- (A)

          TYPE ARR IS ARRAY (1 .. 10) OF INTEGER;

          E : ARR;

          TASK T IS
               ENTRY E (1 .. 2);
          END T;

          TASK BODY T IS
          BEGIN
               ACCEPT E (1);  -- OK.
               E (1) := 1;    -- ERROR: OUTER DECL. OF E IS HIDDEN.
          END T;

     BEGIN  -- (A)

          E (1) := 1;         -- OK.

     END;  -- (A)

     --------------------------------------------------

     DECLARE  -- (B)

          TYPE ARR IS ARRAY (1 .. 10) OF INTEGER;

          X : INTEGER;

          FUNCTION E RETURN ARR IS
               Z : ARR := (OTHERS => 0);
          BEGIN
               RETURN Z;
          END E;

          TASK T IS
               ENTRY E (1 .. 2);
          END T;

          TASK BODY T IS
          BEGIN
               ACCEPT E (1);  -- OK.
               X := E (1);    -- ERROR: OUTER DECL. OF E IS HIDDEN.
          END T;

     BEGIN  -- (B)

          X := E (1);         -- OK.

     END;  -- (B)

     --------------------------------------------------

     DECLARE  -- (C)

          PROCEDURE E (X : CHARACTER) IS
          BEGIN
               NULL;
          END E;

          TASK T IS
               ENTRY E (1 .. 2);
          END T;

          TASK BODY T IS
          BEGIN
               ACCEPT E (1);  -- OK.
               E (1);         -- OK: ENTRY CALL.
               E ('A');       -- ERROR: OUTER DECL. OF E IS HIDDEN.
          END T;

     BEGIN  -- (C)

          E ('A');            -- OK.

     END;  -- (C)

     --------------------------------------------------

     DECLARE  -- (D)

          TYPE E (D : INTEGER) IS
               RECORD
                    C : INTEGER;
               END RECORD;

          TASK T IS
               ENTRY E (1 .. 2);
          END T;

          X : E (1);          -- OK.

          TASK BODY T IS
               X : E (1);     -- ERROR: OUTER DECL. OF E IS HIDDEN.
          BEGIN
               ACCEPT E (1);  -- OK.
          END T;

     BEGIN  -- (D)

          NULL;

     END;  -- (D)

END B95094C;
