-- B83026B.ADA

-- OBJECTIVE:
--     IF A DECLARATION IN THE DECLARATIVE REGION OF AN ENTRY HIDES
--     AN OUTER DECLARATION OF A HOMOGRAPH, THEN CHECK THAT A USE OF THE
--     COMMON IDENTIFIER WHICH WOULD BE A LEGAL REFERENCE TO THE OUTER
--     DECLARATION MUST BE REJECTED IF IT IS ILLEGAL AS A REFERENCE TO
--     THE INNER.

-- HISTORY:
--     BCB 09/01/88  CREATED ORIGINAL TEST.

PROCEDURE B83026B IS

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

          TASK INNER IS
               ENTRY HERE (X : INTEGER := F;
                           F : FLOAT);
          END INNER;

          FUNCTION F IS NEW GEN_FUN (FLOAT, FLO);

          TASK BODY INNER IS
          BEGIN
               ACCEPT HERE (X : INTEGER := F;          -- ERROR:
                            F : FLOAT);
          END INNER;

     BEGIN  -- ONE
          NULL;
     END ONE;

     TWO:
     DECLARE
          INT : INTEGER := 1;
          FLO : FLOAT := 6.25;

          FUNCTION F IS NEW GEN_FUN (INTEGER, INT);

          TASK INNER IS
               ENTRY HERE (F : FLOAT;
                           X : INTEGER := F);          -- ERROR:
          END INNER;

          FUNCTION F IS NEW GEN_FUN (FLOAT, FLO);

          TASK BODY INNER IS
          BEGIN
               ACCEPT HERE (F : FLOAT;
                            X : INTEGER := F);-- OPTIONAL ERROR MESSAGE.
          END INNER;

     BEGIN  -- TWO
          NULL;
     END TWO;

     THREE:
     DECLARE
          INT : INTEGER := 1;
          FLO : FLOAT := 6.25;

          FUNCTION F IS NEW GEN_FUN (INTEGER, INT);

          TASK TYPE INNER IS
               ENTRY HERE (F : FLOAT;
                           X : INTEGER := F);          -- ERROR:
          END INNER;

          FUNCTION F IS NEW GEN_FUN (FLOAT, FLO);

          TASK BODY INNER IS
          BEGIN
               ACCEPT HERE (F : FLOAT;
                            X : INTEGER := F);-- OPTIONAL ERROR MESSAGE.
          END INNER;

     BEGIN  -- THREE
          NULL;
     END THREE;

END B83026B;
