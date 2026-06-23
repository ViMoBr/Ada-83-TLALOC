-- B83024B.ADA

-- OBJECTIVE:
--     IF A DECLARATION IN THE DECLARATIVE REGION OF A GENERIC PACKAGE
--     HIDES AN OUTER DECLARATION OF A HOMOGRAPH, THEN CHECK THAT A USE
--     OF THE COMMON IDENTIFIER WHICH WOULD BE A LEGAL REFERENCE TO THE
--     OUTER DECLARATION MUST BE REJECTED IF IT IS ILLEGAL AS A
--     REFERENCE TO THE INNER.

-- HISTORY:
--     BCB 08/30/88  CREATED ORIGINAL TEST.

PROCEDURE B83024B IS

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

          GENERIC
          PACKAGE INNER IS
               F : FLOAT;
               X : INTEGER := F;                       -- ERROR:
          END INNER;

     BEGIN  -- ONE
          NULL;
     END ONE;

     TWO:
     DECLARE
          A : INTEGER := 2;

          GENERIC
               X : IN INTEGER := A;
               A : IN OUT FLOAT;
          PACKAGE INNER IS
               C : INTEGER := A;                       -- ERROR:
          END INNER;

     BEGIN  -- TWO
          NULL;
     END TWO;

     THREE:
     DECLARE            -- AFTER THE SPECIFICATION OF PACKAGE.
          A : FLOAT := 1.0;

          GENERIC
               X : IN OUT INTEGER;
          PACKAGE INNER IS
               A : INTEGER := 3;
          END INNER;

          B : FLOAT := A;

          PACKAGE BODY INNER IS
               C : FLOAT := A;                         -- ERROR:
          BEGIN
               NULL;
          END INNER;

     BEGIN  -- THREE
          NULL;
     END THREE;

END B83024B;
