-- B74401L.ADA

-- CHECK THAT IN AN ENTRY DECLARATION, A PARAMETER OF MODE OUT MAY
-- NOT BE OF A LIMITED TYPE IF:
--   (A) THE ENTRY DECLARATION OCCURS IN A
--       NESTED PACKAGE, WHERE THE FULL DECLARATION OF THE TYPE DEPENDS 
--       ON A LIMITED TYPE DECLARED IN THE OUTER PACKAGE;
--   (B) THE PARAMETER TYPE IS A COMPOSITE LIMITED TYPE WHOSE FULL
--       DECLARATION OCCURS BEFORE THAT OF ITS LIMITED COMPONENT TYPE,
--       EVEN IF THE FULL COMPONENT DECLARATION DECLARES A NON-LIMITED
--       TYPE. 

-- BHS 7/09/84
-- JBG 5/1/85

PROCEDURE B74401L IS

-- CASE A

     PACKAGE PACK1 IS
          TYPE LP1 IS LIMITED PRIVATE;

          PACKAGE NEST IS
               TYPE NLP2 IS LIMITED PRIVATE;

               TASK P1 IS
                    ENTRY P1 (L : OUT NLP2); 
               END P1;
          PRIVATE
               TYPE NLP2 IS ARRAY (1..2) OF LP1;    -- ERROR: LP1 
                                                    -- STILL LIMITED.
          END NEST; 
     PRIVATE
          TYPE LP1 IS RANGE 1..10;
     END PACK1;

     PACKAGE BODY PACK1 IS
          PACKAGE BODY NEST IS
               TASK BODY P1 IS
               BEGIN  NULL;  END P1;
          END NEST;
     END PACK1;


-- CASE B1 : RECORD TYPE

     PACKAGE PACK2 IS
          TYPE LP3 IS LIMITED PRIVATE;
          TYPE LP4 IS LIMITED PRIVATE;
          TYPE LP5 IS LIMITED PRIVATE;
          TASK P2 IS
               ENTRY P2 (L : OUT LP3; M : LP3);
          END P2;

          TASK P3 IS
               ENTRY P3 (X : OUT LP5; M : LP5);
          END P3;
     PRIVATE
          TYPE LP3 IS
               RECORD
                    C1 : LP4;        -- ERROR: LP4 STILL LIMITED.
               END RECORD;
          TYPE LP4 IS RANGE 1..10;
          TYPE LP5 IS 
               RECORD
                    C2 : LP4;      -- OK; NOT LIMITED.
               END RECORD;
     END PACK2;

     PACKAGE BODY PACK2 IS
          TASK BODY P2 IS
          BEGIN  NULL;  END P2;

          TASK BODY P3 IS
          BEGIN  NULL;  END P3;
     END PACK2;

-- CASE B2: ARRAY TYPE

     PACKAGE PACK3 IS
          TYPE LP3 IS LIMITED PRIVATE;
          TYPE LP4 IS LIMITED PRIVATE;
          TYPE LP5 IS LIMITED PRIVATE;
          TASK P2 IS
               ENTRY P2 (L : OUT LP3; M : LP3);
          END P2;

          TASK P3 IS
               ENTRY P3 (X : OUT LP5; M : LP5);
          END P3;
     PRIVATE
          TYPE LP3 IS
               ARRAY (1..5) OF LP4;  -- ERROR: LP4 STILL LIMITED.
          TYPE LP4 IS RANGE 1..10;
          TYPE LP5 IS 
               ARRAY (1..5) OF LP4;  -- OK; NOT LIMITED.
     END PACK3;

     PACKAGE BODY PACK3 IS
          TASK BODY P2 IS
          BEGIN  NULL;  END P2;

          TASK BODY P3 IS
          BEGIN  NULL;  END P3;
     END PACK3;

BEGIN

     NULL;

END B74401L;
