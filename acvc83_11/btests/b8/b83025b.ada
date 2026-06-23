-- B83025B.ADA

-- OBJECTIVE:
--     IF A DECLARATION IN THE DECLARATIVE REGION OF A GENERIC
--     SUBPROGRAM HIDES AN OUTER DECLARATION OF A HOMOGRAPH, THEN CHECK
--     THAT A USE OF THE COMMON IDENTIFIER WHICH WOULD BE A LEGAL
--     REFERENCE TO THE OUTER DECLARATION MUST BE REJECTED IF IT IS
--     ILLEGAL AS A REFERENCE TO THE INNER.

-- HISTORY:
--     BCB 08/31/88  CREATED ORIGINAL TEST.

PROCEDURE B83025B IS

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

          GENERIC
          PROCEDURE INNER (X : INTEGER := F;
                           F : FLOAT);

          FUNCTION F IS NEW GEN_FUN (FLOAT, FLO);

          PROCEDURE INNER (X : INTEGER := F;                   -- ERROR:
                           F : FLOAT) IS
               Y : INTEGER := 1;
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

          GENERIC
          PROCEDURE INNER (X : INTEGER := F);

          FUNCTION F IS NEW GEN_FUN (FLOAT, FLO);

          PROCEDURE INNER (X : INTEGER := F) IS
               F : FLOAT := 6.25;
               Y : INTEGER := 1;
          BEGIN
               Y := F;                                -- ERROR:
               IF X /= Y THEN
                    NULL;
               END IF;
          END INNER;

     BEGIN  -- TWO
          NULL;
     END TWO;

     THREE:
     DECLARE
          INT : INTEGER := 1;

          FUNCTION F IS NEW GEN_FUN (INTEGER, INT);

          GENERIC
               F : FLOAT;
          FUNCTION INNER (Y : INTEGER := F) RETURN INTEGER;  -- ERROR:

          FUNCTION INNER (Y : INTEGER := F) RETURN INTEGER IS -- ERROR:
          BEGIN
               RETURN 0;
          END INNER;

     BEGIN  -- THREE
          NULL;
     END THREE;

     FOUR:
     DECLARE
          INT : INTEGER := 1;

          FUNCTION F IS NEW GEN_FUN (INTEGER, INT);

          GENERIC
               X : INTEGER := F;
               F : FLOAT := 6.25;
               Y : INTEGER := F;                       -- ERROR:
          PROCEDURE INNER;

          PROCEDURE INNER IS
          BEGIN
               NULL;
          END INNER;

     BEGIN -- FOUR
          NULL;
     END FOUR;

     FIVE:
     DECLARE
          A : FLOAT := 2.0;

          GENERIC
               A : INTEGER := 3;
          FUNCTION INNER (X : INTEGER) RETURN INTEGER;

          B : FLOAT := A;

          FUNCTION INNER (X : INTEGER) RETURN INTEGER IS
               C : FLOAT := A;                         -- ERROR:
          BEGIN
               RETURN 0;
          END INNER;

     BEGIN  -- FIVE
          NULL;
     END FIVE;

END B83025B;
