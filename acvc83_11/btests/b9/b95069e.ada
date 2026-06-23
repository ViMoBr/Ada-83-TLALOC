-- B95069E.ADA

-- OBJECTIVE:
--     CHECK THAT THE IDENTIFIER OF AN ENTRY FAMILY CANNOT BE USED
--     WITHIN ITS DISCRETE RANGE IN AN ENTRY DECLARATION AS A SELECTOR,
--     COMPONENT SIMPLE NAME IN AN AGGREGATE, PARAMETER NAME IN A NAMED
--     ASSOCIATION, OR AS A SIMPLE NAME IN A RANGE EXPRESSION.

-- HISTORY:
--     JRK 04/24/86
--     JLH 09/25/87  REFORMATTED HEADER.

PROCEDURE B95069E IS

     SUBTYPE INT IS INTEGER RANGE 1 .. 2;

     TYPE F IS RECORD
          F : INTEGER;
     END RECORD;

     SUBTYPE SF IS F;

     FF : F := (F => 0);

     -- AS A SELECTOR.

     PROCEDURE P1 IS

          C : INTEGER := 1;

          TYPE T IS RANGE 1 .. 10;

          TASK T1 IS
               ENTRY P1 (1 .. P1.C) (X : T);           -- ERROR: NAME IN
                                                       -- SELECTOR (P1).
          END T1;

          TASK T2 IS
               ENTRY INT (B95069E.INT) (X : INTEGER);  -- ERROR: NAME IN
                                                       -- SELECTOR(INT).
               ENTRY F (1 .. FF.F) (Y : INTEGER);      -- ERROR: NAME IN
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

          FUNCTION G (R : RC) RETURN INTEGER IS
          BEGIN
               RETURN 1;
          END G;

          TASK T3 IS
               ENTRY P (1 .. G((P => 3, B => TRUE))) (X : INT);-- ERROR:
                                                       -- NAME IN
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
               ENTRY P (1 .. F (P => TRUE)) (X : INTEGER);  -- ERROR:
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

     -- AS A SIMPLE NAME IN A RANGE EXPRESSION.

     PROCEDURE P4 IS

          FUNCTION D RETURN INTEGER IS
          BEGIN
               RETURN 1;
          END D;

          TASK T5 IS
               ENTRY D (1 .. 2 * D / 4) (I : INTEGER); -- ERROR: NAME
                                                       -- IN RANGE
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

BEGIN
     NULL;
END B95069E;
