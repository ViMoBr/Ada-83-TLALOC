-- C74409B.ADA

-- CHECK THAT IF A COMPOSITE TYPE IS DECLARED IN THE SAME PACKAGE 
-- AS A LIMITED PRIVATE TYPE AND HAS A COMPONENT OF THAT TYPE, 
-- THE COMPOSITE TYPE IS TREATED AS A LIMITED TYPE UNTIL THE 
-- EARLIEST PLACE WITHIN THE IMMEDIATE SCOPE OF THE DECLARATION 
-- OF THE COMPOSITE TYPE AND AFTER THE FULL DECLARATION OF THE 
-- LIMITED PRIVATE TYPE

-- DSJ 5/5/83
-- JBG 9/23/83

WITH REPORT;
PROCEDURE C74409B IS

     USE REPORT;

BEGIN

     TEST("C74409B", "CHECK THAT A COMPOSITE TYPE WITH A LIMITED " &
                     "PRIVATE COMPONENT IS TREATED AS A LIMITED " &
                     "TYPE UNTIL ASSIGNMENT AND EQUALITY ARE BOTH " &
                     "AVAILABLE FOR THE COMPOSITE TYPE");

     DECLARE

          PACKAGE P IS
               TYPE LP IS LIMITED PRIVATE;
               PACKAGE Q IS
                    TYPE LP_ARRAY IS ARRAY (1 .. 2) OF LP;
               END Q;
          PRIVATE
               TYPE LP IS NEW INTEGER;
          END P;

          PACKAGE BODY P IS
               USE Q;
               FUNCTION "=" (L,R : LP_ARRAY) RETURN BOOLEAN IS  -- LEGAL
               BEGIN
                    RETURN TRUE;
               END;

               GENERIC
                    TYPE T IS PRIVATE;     -- NOTE: NOT LIMITED PRIVATE
                    C, D : T;
               PACKAGE A IS
                    -- IRRELEVANT DETAILS
               END A;

               PACKAGE BODY A IS
               BEGIN
                    IF C = D THEN
                         FAILED ("USED WRONG EQUALITY OPERATOR");
                    END IF;
               END A;

               PACKAGE BODY Q IS
                    PACKAGE ANOTHER_NEW_A IS 
                         NEW A (LP_ARRAY, (2,3), (4,5)); -- LEGAL
               END Q;
          END P;

     BEGIN

          NULL;

     END;

     RESULT;

END C74409B;
