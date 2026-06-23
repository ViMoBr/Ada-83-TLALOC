-- B74202B.ADA

-- OBJECTIVE:
--     FOR ARRAYS OF LIMITED PRIVATE TYPES, OPERATIONS WHICH DEPEND
--     ON CHARACTERISTICS OF THE FULL DECLARATION ARE NOT ACCESSIBLE
--     FROM OUTSIDE THE PACKAGE.

-- HISTORY:
--     BCB 07/15/88  CREATED ORIGINAL TEST.

PROCEDURE B74202B IS

     PACKAGE P IS
          TYPE INT IS LIMITED PRIVATE;
          TYPE B IS LIMITED PRIVATE;
          TYPE S IS LIMITED PRIVATE;
          TYPE STR IS ARRAY(1..10) OF S;
          TYPE BOOL IS ARRAY(1..5) OF B;
          TYPE ARR IS ARRAY(1..5) OF INT;
          PROCEDURE CHECK (X : ARR);
          PROCEDURE CHECK_STR (X : STR);
          PROCEDURE INIT_INT (ONE : IN OUT ARR; TWO : ARR);
          PROCEDURE INIT_BOOL (ONE : IN OUT BOOL; TWO : BOOL);
          PROCEDURE INIT_STR (ONE : IN OUT STR; TWO : STR);
     PRIVATE
          TYPE INT IS RANGE 1 .. 100;
          TYPE S IS NEW CHARACTER;
          TYPE B IS NEW BOOLEAN;
     END P;

     USE P;

     AR, BR, ER : ARR;

     CR, DR : BOOL;

     PACKAGE BODY P IS
          PROCEDURE CHECK (X : ARR) IS
          BEGIN
               NULL;
          END CHECK;

          PROCEDURE CHECK_STR (X : STR) IS
          BEGIN
               NULL;
          END CHECK_STR;

          PROCEDURE INIT_INT (ONE : IN OUT ARR; TWO : ARR) IS
          BEGIN
               ONE := TWO;
          END INIT_INT;

          PROCEDURE INIT_BOOL (ONE : IN OUT BOOL; TWO : BOOL) IS
          BEGIN
               ONE := TWO;
          END INIT_BOOL;

          PROCEDURE INIT_STR (ONE : IN OUT STR; TWO : STR) IS
          BEGIN
               ONE := TWO;
          END INIT_STR;
     END P;

BEGIN
     IF AR = BR THEN                       -- ERROR: = OPERATOR.
          NULL;
     END IF;

     IF AR /= BR THEN                      -- ERROR: /= OPERATOR.
          NULL;
     END IF;

     CHECK (AR & BR);                      -- ERROR: CATENATION.

     AR := BR;                             -- ERROR: ASSIGNMENT.

     CHECK ((1,2,3,4,5));                  -- ERROR: AGGREGATE.

     IF AR < BR THEN                       -- ERROR: < OPERATOR.
          NULL;
     END IF;

     IF AR <= BR THEN                      -- ERROR: <= OPERATOR.
          NULL;
     END IF;

     IF AR > BR THEN                       -- ERROR: > OPERATOR.
          NULL;
     END IF;

     IF AR >= BR THEN                      -- ERROR: >= OPERATOR.
          NULL;
     END IF;

     CHECK (CR AND DR);                    -- ERROR: AND OPERATOR.

     CHECK (CR OR DR);                     -- ERROR: OR OPERATOR.

     CHECK (CR XOR DR);                    -- ERROR: XOR OPERATOR.

     CHECK_STR ("MY MESSAGE");             -- ERROR: STRING LITERAL.

END B74202B;
