-- B95069B.ADA

-- CHECK THAT THE IDENTIFIER OF AN ENTRY FAMILY CANNOT BE USED WITHIN
-- ITS FORMAL PART IN AN ENTRY DECLARATION AS A SELECTOR, COMPONENT
-- SIMPLE NAME IN AN AGGREGATE, PARAMETER NAME IN A NAMED ASSOCIATION,
-- OR AS A SIMPLE NAME IN A DEFAULT EXPRESSION.

-- JRK 8/2/85

PROCEDURE B95069B IS

     SUBTYPE INT IS INTEGER RANGE 1 .. 2;

     TYPE F IS RECORD
          F : INTEGER;
     END RECORD;

     SUBTYPE SF IS F;

     FF : F := (F => 0);

     -- AS A SELECTOR.

     PROCEDURE P1 IS

          TYPE T IS RANGE 1 .. 10;

          TASK T1 IS
               ENTRY P1 (INT) (X : P1.T);              -- ERROR: NAME IN
                                                       -- SELECTOR (P1).
          END T1;

          TASK T2 IS
               ENTRY F (INT) (X : B95069B.F;           -- ERROR: NAME IN
                                                       -- SELECTOR (F).
                              Y : INTEGER := FF.F);    -- ERROR: NAME IN
                                                       -- SELECTOR (F).
          END T2;

          TASK BODY T1 IS
          BEGIN
               NULL;
          END T1;

          TASK BODY T2 IS
          BEGIN
               NULL;
          END T2;

     BEGIN
          NULL;
     END P1;

     -- AS A SIMPLE NAME IN AN AGGREGATE.

     PROCEDURE P2 IS

          TYPE RC IS RECORD
               P : INTEGER;
               B : BOOLEAN;
          END RECORD;

          FUNCTION P RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END P;

          TASK T3 IS
               ENTRY P (INT) (X : RC := (P => 3, B => TRUE); -- ERROR:
                                                       -- NAME IN
                                                       -- AGGREGATE (P).
                              Y : RC := (10, P));      -- ERROR: NAME IN
                                                       -- AGGREGATE (P).
          END T3;

          TASK BODY T3 IS
          BEGIN
               NULL;
          END T3;

     BEGIN
          NULL;
     END P2;

     -- IN A PARAMETER NAME IN A NAMED ASSOCIATION.

     PROCEDURE P3 IS

          FUNCTION F (P: BOOLEAN) RETURN INTEGER IS
          BEGIN
               RETURN 25;
          END F;

          TASK T4 IS
               ENTRY P (INT) (X : INTEGER := F (P => TRUE)); -- ERROR:
                                                       -- NAME IN
                                                       -- PARAMETER
                                                       -- ASSOCIATION
                                                       -- (P).
          END T4;

          TASK BODY T4 IS
          BEGIN
               NULL;
          END T4;

     BEGIN
          NULL;
     END P3;

     -- AS A SIMPLE NAME IN A DEFAULT EXPRESSION.

     PROCEDURE P4 IS

          FUNCTION D RETURN INTEGER IS
          BEGIN
               RETURN 1;
          END D;

          TASK T5 IS
               ENTRY D (INT) (I : INTEGER := 2 * D / 4); -- ERROR: NAME
                                                       -- IN DEFAULT
                                                       -- EXPRESSION
                                                       -- (D).
          END T5;

          TASK BODY T5 IS
          BEGIN
               NULL;
          END T5;

     BEGIN
          NULL;
     END P4;

     -- LEGAL CASES.

     PROCEDURE P5 IS

          TASK T6 IS
               ENTRY F (INT) (F : INTEGER);            -- OK.
          END T6;

          TASK T7 IS
               ENTRY F (INT) (X : SF := FF);           -- OK.
          END T7;

          TASK BODY T6 IS
          BEGIN
               NULL;
          END T6;

          TASK BODY T7 IS
          BEGIN
               NULL;
          END T7;

     BEGIN
          NULL;
     END P5;

BEGIN
     NULL;
END B95069B;
