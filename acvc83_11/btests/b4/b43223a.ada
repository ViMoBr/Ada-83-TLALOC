-- B43223A.ADA

-- OBJECTIVE:
--     CHECK THAT OVERLOADING RESOLUTION MAY NOT USE THE RESTRICTIONS
--     ON THE CONTEXTS IN WHICH AN ARRAY AGGREGATE WITH AN OTHERS
--     CHOICE MAY APPEAR.

-- HISTORY:
--     DHH 08/12/88 CREATED ORIGINAL TEST.

PROCEDURE B43223A IS

     X : INTEGER;
BEGIN

     DECLARE
          TYPE INT IS NEW INTEGER;

          TYPE A1 IS ARRAY(INTEGER RANGE <>) OF INT;
          TYPE A2 IS ARRAY(INTEGER RANGE 1 .. 4) OF INT;

          PROCEDURE PROC(PARAM : A1) IS
          BEGIN
               NULL;
          END PROC;

          PROCEDURE PROC(PARAM : A2) IS
          BEGIN
               NULL;
          END PROC;

     BEGIN
          PROC((1 .. ABS(2) => 1, OTHERS => 0));    -- ERROR: AMBIGUOUS
     END;

     DECLARE
          TYPE INT IS RANGE 1 .. 4;

          GENERIC
               TYPE ONE IS RANGE <>;
          PROCEDURE GEN_PROC(PAR : ONE);

          PROCEDURE GEN_PROC(PAR : ONE) IS
               TYPE A1 IS ARRAY(ONE) OF INTEGER;
               TYPE A2 IS ARRAY(INT) OF INTEGER;

               PROCEDURE PROC(A : A1) IS
               BEGIN
                    NULL;
               END PROC;

               PROCEDURE PROC(A : A2) IS
               BEGIN
                    NULL;
               END PROC;

          BEGIN
               PROC((1 => 1, OTHERS => 0));   -- ERROR: AMBIGUOUS

          END GEN_PROC;

     BEGIN
          NULL;
     END;

     DECLARE
          P : INTEGER := 1;
          Q : INTEGER := 5;

          SUBTYPE SMALL IS INTEGER RANGE P .. Q;

          TYPE B1 IS ARRAY(1 .. 5) OF INTEGER;
          TYPE B2 IS ARRAY(SMALL) OF INTEGER;

          PROCEDURE PROC(PARAM : B1) IS
          BEGIN
               NULL;
          END PROC;

          PROCEDURE PROC(PARAM : B2) IS
          BEGIN
               NULL;
           END PROC;

     BEGIN
          PROC((1, OTHERS => 2));                   -- ERROR: AMBIGUOUS
     END;

END B43223A;
