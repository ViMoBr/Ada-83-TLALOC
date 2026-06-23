-- A83A08A.ADA

-- OBJECTIVE:
--     A STATEMENT LABEL DECLARED OUTSIDE A BLOCK CAN HAVE THE SAME
--     IDENTIFIER AS AN ENTITY DECLARED IN THE BLOCK, AND A GOTO
--     STATEMENT USING THE LABEL IS LEGAL OUTSIDE THE BLOCK.

-- HISTORY:
--     PMW 09/20/88  CREATED ORIGINAL TEST.

WITH REPORT;  USE REPORT;
WITH SYSTEM;

PROCEDURE A83A08A IS

     PASSES : INTEGER := 0;

BEGIN
     TEST ("A83A08A", "A STATEMENT LABEL DECLARED OUTSIDE A BLOCK " &
                      "CAN HAVE THE SAME IDENTIFIER AS AN ENTITY " &
                      "DECLARED IN THE BLOCK, AND A GOTO STATEMENT " &
                      "USING THE LABEL IS LEGAL OUTSIDE THE BLOCK");

     GOTO LBLS;

     <<LBL>>

     DECLARE
          LBL : INTEGER := 1;
     BEGIN
          LBL := IDENT_INT (LBL);
          PASSES := PASSES + 1;
     END;

     <<LBLS>>

     BEGIN
          DECLARE
               TYPE STUFF IS (LBL, LBL_ONE, LBL_TWO);
               ITEM : STUFF := LBL;

               FUNCTION LBLS (ITEM : STUFF) RETURN BOOLEAN IS
               BEGIN
                    <<LBL_2>>
                    CASE ITEM IS
                         WHEN LBL => RETURN TRUE;
                         WHEN LBL_ONE => PASSES := PASSES + 1;
                         WHEN LBL_TWO => RETURN FALSE;
                    END CASE;
                    IF PASSES < 2 THEN
                         PASSES := PASSES + 1;
                         GOTO LBL_2;
                    ELSE
                         RETURN TRUE;
                    END IF;
               END LBLS;

          BEGIN
               CASE PASSES IS
                    WHEN 0 => ITEM := LBL;
                    WHEN 1 => ITEM := LBL_ONE;
                    WHEN OTHERS => ITEM := LBL_TWO;
               END CASE;
               IF NOT LBLS (ITEM) THEN
                    COMMENT ("IRRELEVANT");
               END IF;
          END;
     END;


     IF PASSES > 1 THEN
          GOTO ENOUGH;
     END IF;
     GOTO LBL;

     <<ENOUGH>>

     RESULT;

END A83A08A;
