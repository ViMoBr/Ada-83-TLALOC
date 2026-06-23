-- B83A08B.ADA

-- OBJECTIVE:
--     A STATEMENT LABEL DECLARED OUTSIDE A BLOCK AND HAVING THE SAME
--     IDENTIFIER AS AN ENTITY DECLARED IN THE BLOCK IS ILLEGAL AS THE
--     TARGET OF A GOTO STATEMENT INSIDE THE BLOCK.

-- HISTORY:
--     PMW 09/07/88  CREATED ORIGINAL TEST.

PROCEDURE B83A08B IS

     PASSES : INTEGER := 0;

BEGIN

     <<LBL>>

     IF PASSES > 0 THEN
          GOTO ENOUGH;
     END IF;

     BEGIN
          DECLARE
               LBL : INTEGER := 1;
          BEGIN
               PASSES := PASSES + 1;

               GOTO LBL;            -- ERROR: LABEL OUTSIDE BLOCK
          END;
     END;

     PASSES := 0;

     <<LBL2>>

     IF PASSES > 0 THEN
          GOTO ENOUGH;
     END IF;

     BEGIN
          DECLARE
              FUNCTION LBL2 RETURN BOOLEAN IS
              BEGIN
                   RETURN TRUE;
              END;
          BEGIN
               PASSES := PASSES + 1;

               GOTO LBL2;          -- ERROR: LABEL #2 OUTSIDE BLOCK
          END;
     END;
     PASSES := 0;

     <<ENOUGH>>

     NULL;

END B83A08B;
