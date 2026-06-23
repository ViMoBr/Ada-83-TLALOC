-- BD2C14A.TST

-- OBJECTIVE:
--     CHECK THAT THE EXPRESSION IN A TASK STORAGE_SIZE SPECIFICATION
--     MUST BE A SIMPLE EXPRESSION.

-- MACRO SUBSTITUTION:
--     $TASK_STORAGE_SIZE IS THE NUMBER OF STORAGE_UNITS REQUIRED FOR
--     THE ACTIVATION OF A TASK.

-- HISTORY:
--     BCB 04/05/88  CREATED ORIGINAL TEST.
--     BCB 04/17/89  CHANGED EXTENSION TO '.TST'.  ADDED A MACRO TO
--                   TASK STORAGE_SIZE CLAUSES.

PROCEDURE BD2C14A IS

     PACKAGE P IS
          TYPE TT IS NEW INTEGER;
          FUNCTION "<" (L, R : TT) RETURN TT;
          FUNCTION ">" (L, R : TT) RETURN TT;
          FUNCTION "OR" (L, R : TT) RETURN TT;
          FUNCTION "AND" (L, R : TT) RETURN TT;
     END P;

     PACKAGE BODY P IS
          FUNCTION "<" (L, R : TT) RETURN TT IS
          BEGIN
               RETURN $TASK_STORAGE_SIZE;
          END "<";

          FUNCTION ">" (L, R : TT) RETURN TT IS
          BEGIN
               RETURN $TASK_STORAGE_SIZE;
          END ">";

          FUNCTION "OR" (L, R : TT) RETURN TT IS
          BEGIN
               RETURN $TASK_STORAGE_SIZE;
          END "OR";

          FUNCTION "AND" (L, R : TT) RETURN TT IS
          BEGIN
               RETURN $TASK_STORAGE_SIZE;
          END "AND";
     BEGIN
          NULL;
     END P;

     USE P;

BEGIN
     DECLARE
          TASK TYPE T IS
          END T;

          TASK TYPE U IS
          END U;

          TASK TYPE V IS
          END V;

          TASK TYPE W IS
          END W;

          FOR T'STORAGE_SIZE USE TT'(5) < 3; -- ERROR: NOT A SIMPLE
                                             --        EXPRESSION.

          FOR U'STORAGE_SIZE USE TT'(5) > 3; -- ERROR: NOT A SIMPLE
                                             --        EXPRESSION.

          FOR V'STORAGE_SIZE USE TT'(5) OR TT'(3);
                                             -- ERROR: NOT A SIMPLE
                                             --        EXPRESSION.

          FOR W'STORAGE_SIZE USE TT'(5) AND TT'(3);
                                             -- ERROR: NOT A SIMPLE
                                             --        EXPRESSION.

          TASK BODY T IS
          BEGIN
               NULL;
          END T;

          TASK BODY U IS
          BEGIN
               NULL;
          END U;

          TASK BODY V IS
          BEGIN
               NULL;
          END V;

          TASK BODY W IS
          BEGIN
               NULL;
          END W;

     BEGIN
          NULL;
     END;

     NULL;
END BD2C14A;
