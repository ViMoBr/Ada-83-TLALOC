-- B74202A.ADA

-- OBJECTIVE:
--     FOR ARRAYS OF NON-LIMITED PRIVATE TYPES, OPERATIONS WHICH DEPEND
--     ON CHARACTERISTICS OF THE FULL DECLARATION ARE NOT ACCESSIBLE
--     FROM OUTSIDE THE PACKAGE.

-- HISTORY:
--     BCB 03/10/88  CREATED ORIGINAL TEST.

PROCEDURE B74202A IS

     PACKAGE P IS
          TYPE INT IS PRIVATE;
          TYPE B IS PRIVATE;
          TYPE S IS PRIVATE;
          TYPE STR IS ARRAY(1..10) OF S;
          TYPE BOOL IS ARRAY(1..5) OF B;
          TYPE ARR IS ARRAY(1..5) OF INT;
     PRIVATE
          TYPE INT IS RANGE 1 .. 100;
          TYPE S IS NEW CHARACTER;
          TYPE B IS NEW BOOLEAN;
     END P;

     USE P;

     AR, BR : ARR;

     CR, DR : BOOL;

     ST : STR;

BEGIN
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

     IF CR AND DR THEN                     -- ERROR: AND OPERATOR.
          NULL;
     END IF;

     IF CR OR DR THEN                      -- ERROR: OR OPERATOR.
          NULL;
     END IF;

     IF CR XOR DR THEN                     -- ERROR: XOR OPERATOR.
          NULL;
     END IF;

     ST := "MY MESSAGE";                   -- ERROR: STRING LITERAL.

END B74202A;
