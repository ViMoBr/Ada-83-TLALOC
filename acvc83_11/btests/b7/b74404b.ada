-- B74404B.ADA

-- OBJECTIVE:
--     CHECK THAT ASSIGNMENT, EQUALITY, AND INITIAL VALUES ARE NOT
--     AVAILABLE FOR LIMITED COMPOSITE TYPES.

-- HISTORY:
--     BCB 07/15/88  CREATED ORIGINAL TEST.

PROCEDURE B74404B IS

     PACKAGE P IS
          TYPE LP IS LIMITED PRIVATE;
          C1, C2, C3, C4, C5 : CONSTANT LP;

          TYPE ARR IS ARRAY(1..5) OF LP;

          TYPE REC (D : INTEGER := 0) IS RECORD
               COMP1 : LP;
               COMP2 : INTEGER;
               COMP3 : BOOLEAN;
          END RECORD;

          PROCEDURE INIT (ONE : IN OUT ARR);

          FUNCTION INIT RETURN REC;
     PRIVATE
          TYPE LP IS RANGE 1 .. 100;
          C1 : CONSTANT LP := 1;
          C2 : CONSTANT LP := 2;
          C3 : CONSTANT LP := 3;
          C4 : CONSTANT LP := 4;
          C5 : CONSTANT LP := 5;
     END P;

     USE P;

     A, B : ARR;

     C : ARR := (1,2,3,4,5);            -- ERROR: ARRAY INITIAL VALUES.

     R, S : REC;

     T : REC := (0,1,2,TRUE);           -- ERROR: RECORD INITIAL VALUES.

     PACKAGE BODY P IS
          PROCEDURE INIT (ONE : IN OUT ARR) IS
          BEGIN
               ONE := (1,2,3,4,5);
          END INIT;

          FUNCTION INIT RETURN REC IS
          BEGIN
               RETURN (0,1,0,TRUE);
          END INIT;
     BEGIN
          NULL;
     END P;

BEGIN

     A := (1,2,3,4,5);                  -- ERROR: ARRAY ASSIGNMENT.

     A := (C1,C2,C3,C4,C5);             -- ERROR: ARRAY ASSIGNMENT.

     INIT(B);

     A := B;                            -- ERROR: ARRAY ASSIGNMENT.

     R := INIT;                         -- ERROR: RECORD ASSIGNMENT.

     R := (0,1,2,TRUE);                 -- ERROR: RECORD ASSIGNMENT.

     IF A = B THEN                      -- ERROR: ARRAY EQUALITY.
          NULL;
     END IF;

     IF A /= B THEN                     -- ERROR: ARRAY INEQUALITY.
          NULL;
     END IF;

     IF R = S THEN                      -- ERROR: RECORD EQUALITY.
          NULL;
     END IF;

     IF R /= S THEN                     -- ERROR: RECORD INEQUALITY.
          NULL;
     END IF;

END B74404B;
