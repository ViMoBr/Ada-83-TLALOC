-- B83A09A.ADA

-- OBJECTIVE:
--     CHECK THAT IN A NESTED BODY, N, AN ATTEMPT TO REFERENCE AN
--     ENTITY, E, DECLARED IN AN ENCLOSING BODY IS NOT LEGAL IF N
--     CONTAINS A LABEL, BLOCK NAME, OR LOOP NAME E.

-- HISTORY:
--     PMW 09/20/88  CREATED ORIGINAL TEST.

PROCEDURE B83A09A IS

BEGIN
     BEGIN
          DECLARE
               FUNCTION E RETURN BOOLEAN IS
               BEGIN
                    RETURN TRUE;
               END;
          BEGIN
               BEGIN
                    E :
                    LOOP
                         IF E THEN      -- ERROR: SHARED NAME ENTITY E.
                              EXIT E;
                         END IF;
                    END LOOP E;
               END;
          END;
     END;

     BEGIN
          DECLARE
               TYPE STUFF IS (C1, D1, E1, F1);
               ITEM : STUFF := E1;
          BEGIN
               BEGIN
                    <<E1>>
                    IF ITEM = E1 THEN  -- ERROR: SHARED NAME ENTITY E1.
                         NULL;
                    ELSE GOTO E1;
                    END IF;
               END;
          END;
     END;

     BEGIN
          DECLARE
               FUNCTION E2 RETURN BOOLEAN IS
               BEGIN
                    RETURN TRUE;
               END;
          BEGIN
               BEGIN
                    E2 :
                    BEGIN
                         LOOP
                              IF E2 THEN       -- ERROR: SHARED NAME E2.
                                   NULL;
                              END IF;
                         END LOOP;
                    END E2;
               END;
               NULL;
          END;
     END;

     NULL;

END B83A09A;
