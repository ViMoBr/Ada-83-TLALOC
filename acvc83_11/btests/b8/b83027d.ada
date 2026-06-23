-- B83027D.ADA

-- OBJECTIVE:
--     IF A DECLARATION IN THE DISCRIMINANT PART OF:  A PRIVATE TYPE
--     DECLARATION, AN INCOMPLETE TYPE DECLARATION, OR A GENERIC FORMAL
--     TYPE DECLARATION HIDES AN OUTER DECLARATION OF A HOMOGRAPH, THEN
--     CHECK THAT A USE OF THE COMMON IDENTIFIER WHICH WOULD BE A LEGAL
--     REFERENCE TO THE OUTER DECLARATION MUST BE REJECTED IF IT IS
--     ILLEGAL AS A REFERENCE TO THE INNER.

-- HISTORY:
--     BCB 09/06/88  CREATED ORIGINAL TEST.

PROCEDURE B83027D IS

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
     DECLARE             -- PRIVATE TYPE DECLARATION.
          INT : INTEGER := 1;

          TYPE ENUM IS (ONE, TWO, THREE, FOUR);

          FUNCTION F IS NEW GEN_FUN (INTEGER, INT);

          PACKAGE P_ONE IS
               TYPE INNER (F : ENUM := ONE;
                           Y : INTEGER := F) IS PRIVATE;  -- ERROR:
          PRIVATE
               TYPE INNER (F : ENUM := ONE; Y : INTEGER := F) IS RECORD
                                         -- OPTIONAL ERROR MESSAGE.
                    NULL;
               END RECORD;
          END P_ONE;

     BEGIN  -- ONE
          NULL;
     END ONE;

     TWO:
     DECLARE             -- INCOMPLETE TYPE DECLARATION.
          INT : INTEGER := 1;

          TYPE ENUM IS (ONE, TWO, THREE, FOUR);

          FUNCTION F IS NEW GEN_FUN (INTEGER, INT);

          TYPE INNER (F : ENUM := ONE;
                      Y : INTEGER := F);               -- ERROR:

          TYPE INNER (F : ENUM := ONE; Y : INTEGER := F) IS RECORD
                                      -- OPTIONAL ERROR MESSAGE.
               NULL;
          END RECORD;

     BEGIN  -- TWO
          NULL;
     END TWO;

     THREE:
     DECLARE             -- GENERIC FORMAL TYPE DECLARATION.
          INT : INTEGER := 1;

          TYPE ENUM IS (ONE, TWO, THREE, FOUR);

          TYPE F IS NEW INTEGER;

          GENERIC
               TYPE INNER (F : ENUM;
                           Y : F) IS PRIVATE;          -- ERROR:
          PACKAGE P_THREE IS
          END P_THREE;

     BEGIN  -- THREE
          NULL;
     END THREE;

END B83027D;
