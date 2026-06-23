-- B74401H.ADA

-- CHECK THAT IN AN ENTRY DECLARATION, A PARAMETER OF MODE OUT MAY
-- NOT BE OF A LIMITED TYPE IF:

--   B) IT IS A LIMITED PRIVATE TYPE AND THE DECLARATION APPEARS IN THE
--      PRIVATE PART OR BODY OF THE PACKAGE DECLARING THE LIMITED
--      PRIVATE TYPE, OR OUTSIDE THE PACKAGE DECLARING THE TYPE;

-- JBG 9/23/83
-- BHS 7/10/84
-- JRK 12/4/84
-- JBG 5/1/85

PROCEDURE B74401H IS

     PACKAGE P IS
          TYPE LP IS LIMITED PRIVATE;
          TASK TYPE TSK;
          TYPE ARR_LP IS ARRAY(1..2) OF P.LP;
          TYPE REC_LP IS
               RECORD
                    LP : P.LP;
               END RECORD;
     PRIVATE
          TYPE LP IS NEW INTEGER;
     END P;

     PACKAGE BODY P IS
          TASK BODY TSK IS
          BEGIN
               NULL;
          END TSK;
     END P;

     PACKAGE CASE_B IS
          TYPE LP2 IS LIMITED PRIVATE;
          TYPE LP3 IS LIMITED PRIVATE;
     PRIVATE
          TASK P12 IS
               ENTRY TP12 (X : OUT LP2);       -- ERROR: NOT VISIBLE
                                               -- PART.
          END P12;

          TYPE LP2 IS NEW INTEGER;
          TYPE LP3 IS NEW P.LP;
     END CASE_B;

     PACKAGE BODY CASE_B IS

          TASK BODY P12 IS
          BEGIN
               NULL;
          END P12;

          TASK P13 IS
               ENTRY TP13 (X : OUT LP3);       -- ERROR: NOT VISIBLE
                                               -- PART.
          END P13;

          TASK BODY P13 IS
          BEGIN
               NULL;
          END P13;

     END CASE_B;

BEGIN
     NULL;
END B74401H;
