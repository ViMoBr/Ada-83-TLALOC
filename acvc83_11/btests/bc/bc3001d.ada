-- BC3001D.ADA

-- CHECK THAT THE NAME OF A SUBPROGRAM CREATED BY A GENERIC INSTANTIA-
-- TION CANNOT BE USED WITHIN ITS FORMAL PART AS A SELECTOR, COMPONENT
-- SIMPLE NAME IN AN AGGREGATE, OR PARAMETER NAME IN A NAMED ASSOCIATION
-- (SEE 8.3(16)).

-- BASED ON B61012A.

-- SPS 2/22/84
-- JRK 5/22/84
-- JBG 11/16/85

PROCEDURE BC3001D IS

     TYPE F IS RECORD
          F1 : INTEGER;
     END RECORD;

     FF : F := (F1 => 0);

     GENERIC
          TYPE T IS PRIVATE;
     PROCEDURE GEN_TYPE;

     PROCEDURE GEN_TYPE IS
     BEGIN
          NULL;
     END GEN_TYPE;

     GENERIC
          X : INTEGER;
     FUNCTION GEN_INT RETURN INTEGER;

     FUNCTION GEN_INT RETURN INTEGER IS
     BEGIN
          RETURN 0;
     END GEN_INT;

     PROCEDURE P1 IS

          TYPE T IS RANGE 1 .. 10;

          PROCEDURE P1 IS NEW GEN_TYPE (P1.T);    -- ERROR: NAME IN
                                                  -- PREFIX (P1).

          PROCEDURE F IS NEW GEN_TYPE (BC3001D.F);     -- ERROR: NAME IN
                                                       -- SELECTOR (F).
          FUNCTION F1 IS NEW GEN_INT (FF.F1);     -- ERROR: NAME IN
                                                  -- SELECTOR (F1).
          PROCEDURE GEN_TYPE IS
               NEW BC3001D.GEN_TYPE (INTEGER);    -- ERROR: NAME IN
                                                  -- SELECTOR (GEN_TYPE)
          FUNCTION X IS NEW GEN_INT (X => 3);     -- ERROR: NAME IN
                                                  -- FORMAL PARAM (X).

     BEGIN
          NULL;
     END P1;

     -- AS A SIMPLE NAME IN AN AGGREGATE.

     PROCEDURE P2 IS

          TYPE RC IS RECORD
               P : INTEGER;
               B : BOOLEAN;
          END RECORD;

          GENERIC
               X : RC;
          PROCEDURE GEN_RC;

          PROCEDURE GEN_RC IS
          BEGIN
               NULL;
          END GEN_RC;

          FUNCTION P RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END P;

          PROCEDURE P IS NEW GEN_RC ((P => 3, B => TRUE)); -- ERROR:
                                                           -- NAME IN
                                                           -- AGGREGATE
                                                           -- (P).
     BEGIN
          NULL;
     END P2;

     -- IN A PARAMETER NAME IN A NAMED ASSOCIATION.

     PROCEDURE P3 IS

          FUNCTION F (P: BOOLEAN) RETURN INTEGER IS
          BEGIN
               RETURN 25;
          END F;

          FUNCTION P IS NEW GEN_INT (F(P => TRUE));    -- ERROR: NAME IN
                                                       -- PARAMETER
                                                       -- ASSOCIATION
                                                       -- (P).
     BEGIN
          NULL;
     END P3;

     -- LEGAL CASES.

     PROCEDURE P5 IS

          GENERIC
          PROCEDURE F (F : INTEGER);

          PROCEDURE F (F : INTEGER) IS                 -- OK.
          BEGIN
               NULL;
          END F;

     BEGIN
          NULL;
     END P5;

BEGIN
     NULL;
END BC3001D;
