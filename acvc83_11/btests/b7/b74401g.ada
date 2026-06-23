-- B74401G.ADA

-- CHECK THAT IN AN ENTRY DECLARATION, A PARAMETER OF MODE OUT MAY
-- NOT BE OF A LIMITED TYPE IF:

--   A) THE LIMITED TYPE IS A TASK TYPE, COMPOSITE LIMITED TYPE, OR
--      DERIVED LIMITED PRIVATE TYPE;
--          A1) INSIDE THE VISIBLE PART OF THE PACKAGE DECLARING THE
--              LIMITED TYPE.
--          A2) OUTSIDE THE PACKAGE DECLARING THE LIMITED TYPE.

-- JBG 9/23/83
-- BHS 7/10/84
-- JRK 12/4/84
-- JBG 5/1/85

PROCEDURE B74401G IS

     PACKAGE P IS
          TYPE LP IS LIMITED PRIVATE;
          TASK TYPE TSK;
          TYPE ARR_LP IS ARRAY(1..2) OF P.LP;
          TYPE REC_LP IS
               RECORD
                    LP : P.LP;
               END RECORD;
-- CASE A1
          TASK P1 IS
               ENTRY TP1 (X : OUT TSK);        -- ERROR: TASK TYPE.
          END P1;

          TASK P2 IS
               ENTRY TP2 (X : OUT ARR_LP);     -- ERROR: COMPOSITE TYPE.
          END P2;

          TASK P3 IS
               ENTRY TP3 (X : OUT REC_LP);     -- ERROR: COMPOSITE TYPE.
          END P3;
     PRIVATE
          TYPE LP IS NEW INTEGER;

          TASK P4 IS
               ENTRY TP4 (X : OUT TSK);        -- ERROR: TASK TYPE.
          END P4;

          TASK P5 IS
               ENTRY TP5 (X : OUT ARR_LP);     -- OK: AFTER FULL DECL.
          END P5;

          TASK P6 IS
               ENTRY TP6 (X : OUT REC_LP);     -- OK: AFTER FULL DECL.
          END P6;
     END P;

     PACKAGE BODY P IS

          TASK BODY TSK IS
          BEGIN
               NULL;
          END TSK;

          TASK BODY P1 IS
          BEGIN
               NULL;
          END P1;

          TASK BODY P2 IS
          BEGIN
               NULL;
          END P2;

          TASK BODY P3 IS
          BEGIN
               NULL;
          END P3;

          TASK BODY P4 IS
          BEGIN
               NULL;
          END P4;

          TASK BODY P5 IS
          BEGIN
               NULL;
          END P5;

          TASK BODY P6 IS
          BEGIN
               NULL;
          END P6;
     END P;

     PACKAGE CASE_A IS

          TASK TYPE TSK;
          TYPE DLP IS NEW P.LP;
          TYPE ARR_LP IS ARRAY(1..2) OF P.LP;
          TYPE REC_LP IS
               RECORD
                    LP : P.LP;
               END RECORD;

          TASK TYPE P7 IS
               ENTRY TP7 (X : OUT TSK);        -- ERROR: TASK TYPE.
          END P7;

          TASK P8 IS
               ENTRY TP8 (X : OUT DLP);        -- ERROR: DERIVED LP.
          END P8;

          TASK TYPE P9 IS
               ENTRY TP9 (X : OUT ARR_LP);     -- ERROR: COMPOSITE TYPE.
          END P9;

          TASK P10 IS
               ENTRY TP10(X : OUT REC_LP);     -- ERROR: COMPOSITE TYPE.
          END P10;

     END CASE_A;

     PACKAGE BODY CASE_A IS

          TASK BODY TSK IS
          BEGIN
               NULL;
          END TSK;

          TASK BODY P7 IS
          BEGIN
               NULL;
          END P7;

          TASK BODY P8 IS
          BEGIN
               NULL;
          END P8;

          TASK BODY P9 IS
          BEGIN
               NULL;
          END P9;

          TASK BODY P10 IS
          BEGIN
               NULL;
          END P10;

     END CASE_A;

     TASK P11 IS
          ENTRY TP11 (X : OUT P.LP);           -- ERROR: OUTSIDE P.
     END P11;

     TASK P11A IS
          ENTRY TP11A(X : OUT P.ARR_LP);       -- ERROR: COMPOSITE.
     END P11A;

     TASK P11B IS
          ENTRY TP11B(X : OUT P.REC_LP);       -- ERROR: COMPOSITE.
     END P11B;

     TASK P11C IS
          ENTRY TP11C(X : OUT P.TSK);          -- ERROR: TASK.
     END P11C;

     TASK BODY P11 IS
     BEGIN
          NULL;
     END P11;

     TASK BODY P11A IS
     BEGIN
          NULL;
     END P11A;

     TASK BODY P11B IS
     BEGIN
          NULL;
     END P11B;

     TASK BODY P11C IS
     BEGIN
          NULL;
     END P11C;

BEGIN
     NULL;
END B74401G;
