-- B95069C.ADA

-- CHECK THAT THE IDENTIFIER OF A SINGLE ENTRY CANNOT BE USED WITHIN
-- ITS FORMAL PART IN AN ACCEPT STATEMENT AS A SELECTOR.

-- TBN 12/20/85
-- RJW 4/14/86     DELETED TASK T2 AND PROCEDURE P2.

PROCEDURE B95069C IS

     TYPE F IS RECORD
          F : INTEGER;
     END RECORD;

     SUBTYPE SF IS F;

     FF : F := (F => 0);

     PROCEDURE P1 IS

          TYPE T IS RANGE 1 .. 10;

          TASK T1 IS
               ENTRY P1 (X : T);
          END T1;

          TASK BODY T1 IS
          BEGIN
               ACCEPT P1 (X : B95069C.P1.T) DO      -- ERROR: NAME IN 
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
               ENTRY F (F : INTEGER);
          END T4;

          TASK BODY T4 IS
          BEGIN
               ACCEPT F (F : INTEGER) DO         -- OK.
                    FF.F := F;
               END F;
          END T4;

          TASK T5 IS
               ENTRY F (X : SF := FF);
          END T5;

          TASK BODY T5 IS
          BEGIN
               ACCEPT F (X : SF := FF) DO        -- OK.
                    FF.F := X.F;
               END F;
          END T5;

     BEGIN
          NULL;
     END P5;

BEGIN
     NULL;
END B95069C;
