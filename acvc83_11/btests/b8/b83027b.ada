-- B83027B.ADA

-- OBJECTIVE:
--     IF A DECLARATION IN A RECORD DECLARATION HIDES AN OUTER
--     DECLARATION OF A HOMOGRAPH, THEN CHECK THAT A USE OF THE COMMON
--     IDENTIFIER WHICH WOULD BE A LEGAL REFERENCE TO THE OUTER
--     DECLARATION MUST BE REJECTED IF IT IS ILLEGAL AS A REFERENCE TO
--     THE INNER.

-- HISTORY:
--     BCB 09/02/88  CREATED ORIGINAL TEST.

PROCEDURE B83027B IS

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

          TYPE INNER IS RECORD
               X : INTEGER := F;
               F : FLOAT;
               G : INTEGER := F;                       -- ERROR:
          END RECORD;

     BEGIN  -- ONE
          NULL;
     END ONE;

     TWO:
     DECLARE
          INT : INTEGER := 1;

          TYPE ENUM IS (ONE, TWO, THREE, FOUR);

          FUNCTION F IS NEW GEN_FUN (INTEGER, INT);

          TYPE INNER (F : ENUM) IS RECORD
               Y : INTEGER := F;                       -- ERROR:
          END RECORD;

     BEGIN  -- TWO
          NULL;
     END TWO;

     THREE:
     DECLARE
          INT : INTEGER := 1;

          TYPE ENUM IS (ONE, TWO, THREE, FOUR);

          FUNCTION F IS NEW GEN_FUN (INTEGER, INT);

          TYPE INNER (F : ENUM;
                      Y : INTEGER := F) IS RECORD           -- ERROR:
               NULL;
          END RECORD;

     BEGIN  -- THREE
          NULL;
     END THREE;

END B83027B;
