-- B83022B.ADA

-- OBJECTIVE:
--     IF A DECLARATION IN THE DECLARATIVE REGION OF A SUBPROGRAM HIDES
--     AN OUTER DECLARATION OF A HOMOGRAPH, THEN CHECK THAT A USE OF THE
--     COMMON IDENTIFIER WHICH WOULD BE A LEGAL REFERENCE TO THE OUTER
--     DECLARATION MUST BE REJECTED IF IT IS ILLEGAL AS A REFERENCE TO
--     THE INNER.

-- HISTORY:
--     TBN 08/01/88  CREATED ORIGINAL TEST.

PROCEDURE B83022B IS

     GENERIC
          TYPE T IS PRIVATE;
          X : T;
     FUNCTION GEN_FUN RETURN T;

     FUNCTION GEN_FUN RETURN T IS
     BEGIN
          RETURN X;
     END GEN_FUN;

BEGIN

     ONE:
     DECLARE             -- SUBPROGRAM FORMAL DECLARATIVE REGION.
          INT : INTEGER := 1;
          FLO : FLOAT := 6.25;

          FUNCTION F IS NEW GEN_FUN (INTEGER, INT);

          PROCEDURE INNER (X : INTEGER := F;
                           F : FLOAT);

          FUNCTION F IS NEW GEN_FUN (FLOAT, FLO);

          PROCEDURE INNER (X : INTEGER := F;                   -- ERROR:
                           F : FLOAT) IS
               Y : INTEGER;
          BEGIN
               Y := INTEGER(F);
               IF X /= Y THEN
                    NULL;
               END IF;
          END INNER;

     BEGIN  -- ONE
          NULL;
     END ONE;

     TWO:
     DECLARE             -- SUBPROGRAM DECLARATIVE REGION.
          INT : INTEGER := 1;
          FLO : FLOAT := 6.25;

          FUNCTION F IS NEW GEN_FUN (INTEGER, INT);

          FUNCTION F IS NEW GEN_FUN (FLOAT, FLO);

          PROCEDURE INNER (X : INTEGER := F) IS
               F : FLOAT := 3.5;
               Y : INTEGER := F;                               -- ERROR:
          BEGIN
               Y := INTEGER(F);
               IF X /= Y THEN
                    NULL;
               END IF;
          END INNER;

     BEGIN  -- TWO
          NULL;
     END TWO;

END B83022B;
