-- B74401M.ADA

-- CHECK THAT IN A GENERIC SUBPROGRAM DECLARATION, A PARAMETER OF MODE
-- OUT MAY NOT BE OF A LIMITED TYPE IF:

--   A) THE LIMITED TYPE IS A TASK TYPE, COMPOSITE LIMITED TYPE, OR
--      DERIVED LIMITED PRIVATE TYPE;
--          A1) INSIDE THE VISIBLE PART OF THE PACKAGE DECLARING THE
--              LIMITED TYPE.
--          A2) OUTSIDE THE PACKAGE DECLARING THE LIMITED TYPE.

-- JBG 9/23/83
-- BHS 7/10/84
-- JRK 12/4/84
-- JBG 5/1/85

PROCEDURE B74401M IS

     PACKAGE P IS
          TYPE LP IS LIMITED PRIVATE;
          TASK TYPE TSK;
          TYPE ARR_LP IS ARRAY(1..2) OF P.LP;
          TYPE REC_LP IS
               RECORD
                    LP : P.LP;
               END RECORD;
-- CASE A1
          GENERIC
          PROCEDURE P1 (X : OUT TSK);        -- ERROR: TASK TYPE.

          GENERIC
          PROCEDURE P2 (X : OUT ARR_LP);     -- ERROR: COMPOSITE TYPE.

          GENERIC
          PROCEDURE P3 (X : OUT REC_LP);     -- ERROR: COMPOSITE TYPE.
     PRIVATE
          TYPE LP IS NEW INTEGER;

          GENERIC
          PROCEDURE P4 (X : OUT TSK);        -- ERROR: TASK TYPE.

          GENERIC
          PROCEDURE P5 (X : OUT ARR_LP);     -- OK: AFTER FULL DECL.

          GENERIC
          PROCEDURE P6 (X : OUT REC_LP);     -- OK: AFTER FULL DECL.
     END P;

     PACKAGE BODY P IS

          TASK BODY TSK IS
          BEGIN
               NULL;
          END TSK;

          PROCEDURE P1 (X : OUT TSK) IS      -- ERR MSG OPTIONAL.
          BEGIN
               NULL;
          END P1;

          PROCEDURE P2 (X : OUT ARR_LP) IS   -- ERR MSG OPTIONAL.
          BEGIN
               NULL;
          END P2;

          PROCEDURE P3 (X : OUT REC_LP) IS   -- ERR MSG OPTIONAL.
          BEGIN
               NULL;
          END P3;

          PROCEDURE P4 (X : OUT TSK) IS      -- ERR MSG OPTIONAL.
          BEGIN
               NULL;
          END P4;

          PROCEDURE P5 (X : OUT ARR_LP) IS
          BEGIN
               NULL;
          END P5;

          PROCEDURE P6 (X : OUT REC_LP) IS
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

          GENERIC
          PROCEDURE P7 (X : OUT TSK);        -- ERROR: TASK TYPE.

          GENERIC
          PROCEDURE P8 (X : OUT DLP);        -- ERROR: DERIVED LP.

          GENERIC
          PROCEDURE P9 (X : OUT ARR_LP);     -- ERROR: COMPOSITE TYPE.

          GENERIC
          PROCEDURE P10(X : OUT REC_LP);     -- ERROR: COMPOSITE TYPE.

     END CASE_A;

     PACKAGE BODY CASE_A IS

          TASK BODY TSK IS
          BEGIN
               NULL;
          END TSK;

          PROCEDURE P7 (X : OUT TSK) IS      -- ERR MSG OPTIONAL.
          BEGIN
               NULL;
          END P7;

          PROCEDURE P8 (X : OUT DLP) IS      -- ERR MSG OPTIONAL.
          BEGIN
               NULL;
          END P8;

          PROCEDURE P9 (X : OUT ARR_LP) IS   -- ERR MSG OPTIONAL.
          BEGIN
               NULL;
          END P9;

          PROCEDURE P10 (X : OUT REC_LP) IS  -- ERR MSG OPTIONAL.
          BEGIN
               NULL;
          END P10;

     END CASE_A;

     GENERIC
     PROCEDURE P11 (X : OUT P.LP);           -- ERROR: OUTSIDE P.
     PROCEDURE P11 (X : OUT P.LP) IS         -- ERR MSG OPTIONAL.
     BEGIN
          NULL;
     END P11;

     GENERIC
     PROCEDURE P11A(X : OUT P.ARR_LP);       -- ERROR: COMPOSITE.
     PROCEDURE P11A(X : OUT P.ARR_LP) IS     -- ERR MSG OPTIONAL.
     BEGIN
          NULL;
     END P11A;

     GENERIC
     PROCEDURE P11B(X : OUT P.REC_LP);       -- ERROR: COMPOSITE.
     PROCEDURE P11B(X : OUT P.REC_LP) IS     -- ERR MSG OPTIONAL.
     BEGIN
          NULL;
     END P11B;

     GENERIC
     PROCEDURE P11C(X : OUT P.TSK);          -- ERROR: TASK.
     PROCEDURE P11C(X : OUT P.TSK) IS        -- ERR MSG OPTIONAL.
     BEGIN
          NULL;
     END P11C;

BEGIN
     NULL;
END B74401M;
