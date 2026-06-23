-- C34011B.ADA

-- OBJECTIVE:
--     CHECK THAT A DERIVED TYPE DECLARATION IS NOT CONSIDERED EXACTLY
--     EQUIVALENT TO AN ANONYMOUS DECLARATION OF THE DERIVED TYPE
--     FOLLOWED BY A SUBTYPE DECLARATION OF THE DERIVED SUBTYPE.  IN
--     PARTICULAR, CHECK THAT CONSTRAINT_ERROR CAN BE RAISED WHEN THE
--     SUBTYPE INDICATION OF THE DERIVED TYPE DECLARATION IS ELABORATED
--     (EVEN THOUGH THE CONSTRAINT WOULD SATISFY THE DERIVED (BASE)
--     TYPE).

-- HISTORY:
--     JRK 09/04/87  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C34011B IS

     SUBTYPE BOOL IS BOOLEAN RANGE FALSE .. FALSE;

     SUBTYPE FLT IS FLOAT RANGE -10.0 .. 10.0;

     SUBTYPE DUR IS DURATION RANGE 0.0 .. 10.0;

     SUBTYPE INT IS INTEGER RANGE 0 .. 10;

     TYPE ARR IS ARRAY (INT RANGE <>) OF INTEGER;

     TYPE REC (D : INT := 0) IS
          RECORD
               I : INTEGER;
          END RECORD;

     PACKAGE PT IS
          TYPE PRIV (D : POSITIVE := 1) IS PRIVATE;
     PRIVATE
          TYPE PRIV (D : POSITIVE := 1) IS
               RECORD
                    I : INTEGER;
               END RECORD;
     END PT;

     USE PT;

     TYPE ACC_ARR IS ACCESS ARR;

     TYPE ACC_REC IS ACCESS REC;

BEGIN
     TEST ("C34011B", "CHECK THAT CONSTRAINT_ERROR CAN BE RAISED " &
                      "WHEN THE SUBTYPE INDICATION OF A DERIVED TYPE " &
                      "DECLARATION IS ELABORATED");

     BEGIN
          DECLARE

               TYPE T IS NEW BOOL RANGE FALSE .. IDENT_BOOL (TRUE);

          BEGIN
               FAILED ("EXCEPTION NOT RAISED - BOOL");
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("WRONG HANDLER ENTERED - BOOL");
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - BOOL");
     END;

     BEGIN
          DECLARE

               TYPE T IS NEW POSITIVE RANGE IDENT_INT (0) .. 10;

          BEGIN
               FAILED ("EXCEPTION NOT RAISED - POSITIVE");
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("WRONG HANDLER ENTERED - POSITIVE");
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - POSITIVE");
     END;

     BEGIN
          DECLARE

               TYPE T IS NEW FLT RANGE 0.0 .. 20.0;

          BEGIN
               FAILED ("EXCEPTION NOT RAISED - FLT");
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("WRONG HANDLER ENTERED - FLT");
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - FLT");
     END;

     BEGIN
          DECLARE

               TYPE T IS NEW DUR RANGE -1.0 .. 5.0;

          BEGIN
               FAILED ("EXCEPTION NOT RAISED - DUR");
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("WRONG HANDLER ENTERED - DUR");
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - DUR");
     END;

     BEGIN
          DECLARE

               TYPE T IS NEW ARR (IDENT_INT (-1) .. 10);

          BEGIN
               FAILED ("EXCEPTION NOT RAISED - ARR");
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("WRONG HANDLER ENTERED - ARR");
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - ARR");
     END;

     BEGIN
          DECLARE

               TYPE T IS NEW REC (IDENT_INT (11));

          BEGIN
               FAILED ("EXCEPTION NOT RAISED - REC");
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("WRONG HANDLER ENTERED - REC");
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - REC");
     END;

     BEGIN
          DECLARE

               TYPE T IS NEW PRIV (IDENT_INT (0));

          BEGIN
               FAILED ("EXCEPTION NOT RAISED - PRIV");
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("WRONG HANDLER ENTERED - PRIV");
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - PRIV");
     END;

     BEGIN
          DECLARE

               TYPE T IS NEW ACC_ARR (0 .. IDENT_INT (11));

          BEGIN
               FAILED ("EXCEPTION NOT RAISED - ACC_ARR");
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("WRONG HANDLER ENTERED - ACC_ARR");
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - ACC_ARR");
     END;

     BEGIN
          DECLARE

               TYPE T IS NEW ACC_REC (IDENT_INT (-1));

          BEGIN
               FAILED ("EXCEPTION NOT RAISED - ACC_REC");
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("WRONG HANDLER ENTERED - ACC_REC");
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - ACC_REC");
     END;

     RESULT;
END C34011B;
