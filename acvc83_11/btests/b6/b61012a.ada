-- B61012A.ADA

-- CHECK THAT THE NAME OF A SUBPROGRAM CANNOT BE USED WITHIN ITS FORMAL
-- PART AS A SELECTOR, COMPONENT SIMPLE NAME IN AN AGGREGATE, PARAMETER
-- NAME IN A NAMED ASSOCIATION, OR AS A SIMPLE NAME IN A DEFAULT
-- EXPRESSION. 

-- SPS 2/22/84
-- JRK 5/22/84

PROCEDURE B61012A IS

     TYPE F IS RECORD
          F : INTEGER;
     END RECORD;
     
     SUBTYPE SF IS F;
     
     FF : F := (F => 0);

     PROCEDURE P1 IS

          TYPE T IS RANGE 1 .. 10;

          PROCEDURE P1 (X : P1.T) IS                   -- ERROR: NAME IN
                                                       -- SELECTOR (P1).
          BEGIN
               NULL;
          END P1;

          PROCEDURE F (X : B61012A.F;                  -- ERROR: NAME IN
                                                       -- SELECTOR (F).
                       Y : INTEGER := FF.F) IS         -- ERROR: NAME IN
                                                       -- SELECTOR (F).
          BEGIN
               NULL;
          END F;

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

          PROCEDURE P (X : RC := (P => 3, B => TRUE);  -- ERROR: NAME IN
                                                       -- AGGREGATE (P).
                       Y : RC := (10, P)) IS           -- ERROR: NAME IN
                                                       -- AGGREGATE (P).
          BEGIN
               NULL;
          END P;

     BEGIN
          NULL;
     END P2;

     -- IN A PARAMETER NAME IN A NAMED ASSOCIATION.

     PROCEDURE P3 IS

          FUNCTION F (P: BOOLEAN) RETURN INTEGER IS
          BEGIN
               RETURN 25;
          END F;

          PROCEDURE P (X : INTEGER := 
                         F (P => TRUE)) IS             -- ERROR: NAME IN
                                                       -- PARAMETER
                                                       -- ASSOCIATION
                                                       -- (P).
          BEGIN
               NULL;
          END P;

     BEGIN
          NULL;
     END P3;

     -- AS A SIMPLE NAME IN A DEFAULT EXPRESSION.

     PROCEDURE P4 IS

          FUNCTION D RETURN INTEGER IS
          BEGIN
               RETURN 1;
          END D;

          PROCEDURE D (I : INTEGER := 2 * D / 4) IS    -- ERROR: NAME 
                                                       -- IN DEFAULT
                                                       -- EXPRESSION
                                                       -- (D).
          BEGIN
               NULL;
          END D;

     BEGIN
          NULL;
     END P4;

     -- LEGAL CASES.

     PROCEDURE P5 IS

          PROCEDURE F (F : INTEGER) IS                 -- OK.
          BEGIN
               NULL;
          END F;

          PROCEDURE F (X : SF := FF) IS                -- OK.
          BEGIN
               NULL;
          END F;

     BEGIN
          NULL;
     END P5;

BEGIN
     NULL;
END B61012A;
