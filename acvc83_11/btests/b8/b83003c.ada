-- B83003C.ADA

-- OBJECTIVE:
--     CHECK THAT AN INNER TASK DECLARATION IN THE DECLARATIVE PART OF
--     AN OUTER TASK'S BODY CANNOT HAVE THE SAME IDENTIFIER AS THAT OF
--     AN ENTRY.

-- HISTORY:
--     VCL  02/04/88  CREATED ORIGINAL TEST.

PROCEDURE B83003C IS

BEGIN
     DECLARE
          TASK TYPE TSK2 IS
               ENTRY E9;
          END TSK2;

          TASK BODY TSK2 IS
               TASK TYPE E9;                        -- ERROR: HOMOGRAPH.

          -- BODY FOR THE ABOVE HOMOGRAPH.

               TASK BODY E9 IS                  -- OPTIONAL ERR MESSAGE:
               BEGIN                            --  BODY OF AN INVALID
                    NULL;                       --  TASK TYPE.
               END E9;

          BEGIN
               NULL;
          END TSK2;
     BEGIN
          NULL;
     END;

END B83003C;
