-- B91003C.ADA

-- CHECK THAT A TASK SPECIFICATION AND THE CORRESPONDING BODY MUST
-- OCCUR IN THE SAME DECLARATIVE PART.

-- WEI  3/ 4/82
-- RJK  2/ 1/84     ADDED TO ACVC
-- JWC 6/28/85   RENAMED FROM B910AEA-B.ADA

PROCEDURE B91003C IS

     TASK T1;
     TASK T5;
     TASK T6;
     TASK T8;

     PACKAGE PACK IS
          TASK T2;
     END PACK;

     PACKAGE BODY PACK IS
          TASK T3;       -- NO TASK BODY HERE

          TASK BODY T2 IS
          BEGIN
               NULL;
          END T2;

          TASK BODY T1 IS
          BEGIN
               NULL;
          END T1;        -- ERROR: BODY NOT IN SAME DECL.PART.

     END PACK;           -- ERROR: NO BODY FOR T3.

     PROCEDURE PROC IS
          TASK T4;       -- NO BODY HERE.

          TASK BODY T3 IS
          BEGIN
               NULL;
          END T3;        -- ERROR: SPECIFICATION NOT IN SAME DECL.PART

          TASK BODY T5 IS
          BEGIN
               NULL;
          END T5;        -- ERROR: SPEC. NOT IN SAME DECL.PART.

     BEGIN               -- ERROR: NO BODY FOR T4.
          NULL;
     END PROC;

BEGIN                    -- ERROR: NO BODIES FOR T1, T5, T6, T8.

BLOCK1 :
     DECLARE
          TASK T7;       -- NO BODY GIVEN HERE.

          TASK BODY T6 IS
          BEGIN
               NULL;
          END T6;        -- ERROR: SPEC. NOT IN SAME DECL.PART.

          TASK BODY T4 IS
          BEGIN
               NULL;
          END T4;        -- ERROR: SPEC. NOT IN SAME DECL.PART.

     BEGIN               -- ERROR: NO BODY FOR T7.
          NULL;
     END BLOCK1;

BLOCK2 :
     DECLARE
          TASK T13 IS
               ENTRY E;
          END T13;

          TASK BODY T7 IS
          BEGIN
               NULL;
          END T7;        -- ERROR: SPEC. NOT IN SAME DECL.PART.

          TASK BODY T8 IS
          BEGIN
               NULL;
          END T8;        -- ERROR: SPEC. NOT IN SAME DECL.PART.

          TASK BODY T13 IS
          BEGIN
               ACCEPT E;
          END T13;       -- OK. IN SPITE OF 13.

     BEGIN
          T13.E;         -- OK. IF TASK 13 IS RECOGNIZED.
     END BLOCK2;

END B91003C;
