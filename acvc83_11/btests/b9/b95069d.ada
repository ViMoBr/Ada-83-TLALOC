-- B95069D.ADA

-- OBJECTIVE:
--     CHECK THAT THE IDENTIFIER OF AN ENTRY FAMILY CANNOT BE USED
--     WITHIN ITS FORMAL PART IN AN ACCEPT STATEMENT AS A SELECTOR.

-- HISTORY;
--     TBN 12/30/85
--     RJW 04/11/86  DELETED TASK T2 AND PROCEDURE P2.
--     JLH 09/25/87  REFORMATTED HEADER.

PROCEDURE B95069D IS

     SUBTYPE INT IS INTEGER RANGE 1 .. 2;

     TYPE F IS RECORD
          F : INTEGER;
     END RECORD;

     SUBTYPE SF IS F;

     FF : F := (F => 0);

     PROCEDURE P1 IS

          TYPE T IS RANGE 1 .. 10;

          TASK T1 IS
               ENTRY P1 (INT) (X : T);
          END T1;

          TASK BODY T1 IS
          BEGIN
               ACCEPT P1 (1) (X : B95069D.P1.T) DO    -- ERROR: NAME IN
                                                      -- SELECTOR (P1).
                    NULL;
               END P1;
          END T1;

     BEGIN
          NULL;
     END P1;

     -- LEGAL CASES.

     PROCEDURE P5 IS

          TASK T4 IS
               ENTRY F (INT) (F : INTEGER);
          END T4;

          TASK BODY T4 IS
          BEGIN
               ACCEPT F (2) (F : INTEGER) DO          -- OK.
                    FF.F := F;
               END F;
          END T4;

          TASK T5 IS
               ENTRY F (INT) (X : SF := FF);
          END T5;

          TASK BODY T5 IS
          BEGIN
               ACCEPT F (1) (X : SF := FF) DO         -- OK.
                    FF.F := X.F;
               END F;
          END T5;

     BEGIN
          NULL;
     END P5;

BEGIN
     NULL;
END B95069D;
