-- B83003A.ADA

-- OBJECTIVE:
--     CHECK THAT AN EXPLICIT DECLARATION IN THE DECLARATIVE PART OF A
--     TASK'S BODY CANNOT HAVE THE SAME IDENTIFIER AS THAT OF A SINGLE
--     ENTRY OR AN ENTRY FAMILY.
--     THIS TEST CHECKS THE CASE WHERE THE TASK SPECIFICATION AND BODY
--     ARE IN THE SAME COMPILATION UNIT.

-- HISTORY:
--     VCL  02/04/88  CREATED ORIGINAL TEST.

PROCEDURE B83003A IS
     TYPE FMLY IS (FE1, FE2, FE3);

BEGIN

-- MULTIPLE TASKS ARE USED SO THAT ONLY ONE DECLARATION WHICH REQUIRES
-- A BODY (TASK OR GENERIC UNIT) IS GIVEN IN EACH TASK.

     DECLARE
          TASK TSK1 IS
               ENTRY E1;
               ENTRY E2 (FMLY);
               ENTRY E3;
               ENTRY E4 (FMLY);
               ENTRY E5;
               ENTRY E6 (FMLY);
               ENTRY E7;
               ENTRY E8 (FMLY);
          END TSK1;

          TASK BODY TSK1 IS
               TYPE E1 IS                           -- ERROR: HOMOGRAPH.
                    ARRAY (1..15) OF CHARACTER;
               SUBTYPE E2 IS STRING(1..12);         -- ERROR: HOMOGRAPH.
               E3 : CONSTANT CHARACTER := 'A';      -- ERROR: HOMOGRAPH.
               E4 : CONSTANT := 5.0;                -- ERROR: HOMOGRAPH.
               E5  : STRING(1..10);                 -- ERROR: HOMOGRAPH.
               E6  : EXCEPTION;                     -- ERROR: HOMOGRAPH.

               PACKAGE E7 IS END E7;                -- ERROR: HOMOGRAPH.

               TASK E8;                             -- ERROR: HOMOGRAPH.

          -- BODY FOR THE ABOVE HOMOGRAPH.

               TASK BODY E8 IS                  -- OPTIONAL ERR MESSAGE:
               BEGIN                            --  BODY OF AN INVALID
                    NULL;                       --  TASK OBJECT.
               END E8;

          BEGIN
               NULL;
          END TSK1;
     BEGIN
          NULL;
     END;

     DECLARE
          TASK TSK3 IS
               ENTRY E10 (FMLY);
          END TSK3;

          TASK BODY TSK3 IS
               GENERIC                              -- ERROR: HOMOGRAPH.
               FUNCTION E10 RETURN STRING;

          -- BODY FOR THE ABOVE HOMOGRAPH.

               FUNCTION E10 RETURN STRING IS    -- OPTIONAL ERR MESSAGE:
               BEGIN                            --  BODY OF AN INVALID
                    RETURN "E10";               --  GENERIC FUNCTION.
               END E10;

          BEGIN
               NULL;
          END TSK3;
     BEGIN
          NULL;
     END;

     DECLARE
          TASK TYPE TSK4 IS
               ENTRY E11;
               ENTRY E12 (FMLY);
          END TSK4;

          TASK BODY TSK4 IS
               GENERIC                              -- ERROR: HOMOGRAPH.
               PROCEDURE E11;

               GENERIC                              -- ERROR: HOMOGRAPH.
               PACKAGE E12 IS END E12;

          -- BODY FOR THE ABOVE HOMOGRAPH.

               PROCEDURE E11 IS                 -- OPTIONAL ERR MESSAGE:
               BEGIN                            --  BODY OF AN INVALID
                    NULL;                       --  GENERIC PROCEDURE.
               END E11;

          BEGIN
               NULL;
          END TSK4;
     BEGIN
          NULL;
     END;
END B83003A;
