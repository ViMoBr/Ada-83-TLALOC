-- B74409A.ADA

-- CHECK THAT IF A COMPOSITE TYPE IS DECLARED IN THE SAME PACKAGE 
-- AS A LIMITED PRIVATE TYPE AND HAS A COMPONENT OF THAT TYPE, 
-- THE COMPOSITE TYPE IS TREATED AS A LIMITED TYPE UNTIL THE 
-- EARLIEST PLACE WITHIN THE IMMEDIATE SCOPE OF THE DECLARATION 
-- OF THE COMPOSITE TYPE AND AFTER THE FULL DECLARATION OF THE 
-- LIMITED PRIVATE TYPE.

-- DSJ 5/5/83
-- JRK 10/26/83

PROCEDURE B74409A IS

     PACKAGE P IS

          TYPE LP IS LIMITED PRIVATE;
          TYPE NP IS PRIVATE;

          PACKAGE Q IS
               TYPE LP_ARRAY IS ARRAY (1 .. 2) OF LP;
          END Q;

     PRIVATE
          TYPE LP IS NEW INTEGER;
          TYPE NP IS NEW Q.LP_ARRAY;    -- ERROR: LP_ARRAY IS LIMITED.
     END P;

     PACKAGE BODY P IS
          USE Q;

          FUNCTION "=" (L, R : LP_ARRAY) RETURN BOOLEAN IS  -- LEGAL.
          BEGIN
               RETURN TRUE;
          END;

          GENERIC
               TYPE T IS PRIVATE;          -- NOTE: NOT LIMITED PRIVATE.
          PACKAGE A IS
               -- IRRELEVANT DETAILS.
          END A;

          PACKAGE NEW_A IS NEW A (LP_ARRAY);      -- ERROR: LP_ARRAY IS
                                                  --        LIMITED.

          PACKAGE BODY Q IS
               FUNCTION "=" (L, R : LP_ARRAY)     -- ERROR: LP_ARRAY IS
                                                  --        NOT LIMITED.
                            RETURN BOOLEAN IS
               BEGIN
                    RETURN TRUE;
               END;

               PACKAGE ANOTHER_NEW_A IS NEW A (LP_ARRAY);   -- LEGAL.
          END Q;
     END P;

BEGIN

     NULL;

END B74409A;
