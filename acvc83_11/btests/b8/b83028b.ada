-- B83028B.ADA

-- OBJECTIVE:
--     IF A DECLARATION IN THE DECLARATIVE REGION OF A BLOCK STATEMENT
--     HIDES AN OUTER DECLARATION OF A HOMOGRAPH, THEN CHECK THAT A USE
--     OF THE COMMON IDENTIFIER WHICH WOULD BE A LEGAL REFERENCE TO THE
--     OUTER DECLARATION MUST BE REJECTED IF IT IS ILLEGAL AS A
--     REFERENCE TO THE INNER.

-- HISTORY:
--     BCB 09/06/88  CREATED ORIGINAL TEST.

PROCEDURE B83028B IS

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
     DECLARE
          INT : INTEGER := 1;
          FLO : FLOAT := 6.25;

          FUNCTION F IS NEW GEN_FUN (INTEGER, INT);

          FUNCTION F IS NEW GEN_FUN (FLOAT, FLO);

     BEGIN  -- ONE
          DECLARE
               X : INTEGER := F;
               F : FLOAT;
               Y : INTEGER := F;                   -- ERROR:
          BEGIN
               Y := INTEGER(F);
               IF X /= Y THEN
                    NULL;
               END IF;
          END;

          NULL;
     END ONE;

     TWO:
     DECLARE
          INT : INTEGER := 1;
          FLO : FLOAT := 6.25;

          FUNCTION F IS NEW GEN_FUN (INTEGER, INT);

          FUNCTION F IS NEW GEN_FUN (FLOAT, FLO);

     BEGIN  -- TWO
          DECLARE
               X : INTEGER := F;
               F : FLOAT;
               Y : INTEGER;
          BEGIN
               Y := F;                                -- ERROR:
               IF X /= Y THEN
                    NULL;
               END IF;
          END;

          NULL;
     END TWO;

END B83028B;
