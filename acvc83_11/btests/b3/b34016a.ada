-- B34016A.ADA

-- OBJECTIVE:
--     CHECK THAT A SUBPROGRAM DECLARED IN THE VISIBLE PART OF A PACKAGE
--     SPECIFICATION CANNOT BE DERIVED UNTIL THE END OF THE VISIBLE
--     PART.

-- HISTORY:
--     JET 01/22/88  CREATED ORIGINAL TEST.

PROCEDURE B34016A IS

     PACKAGE PACK1 IS
          TYPE T0 IS (ZERO, ONE, TWO, THREE);
          PROCEDURE PROC1 (A : T0);
          TYPE T1 IS NEW T0;
     PRIVATE
          TYPE T2 IS NEW T0;             -- OK.
     END PACK1;

     PACKAGE BODY PACK1 IS
          TYPE T3 IS NEW T0;             -- OK.
          A1 : T1 := ONE;
          A2 : T2 := TWO;
          A3 : T3 := THREE;

          PROCEDURE PROC1 (A : T0) IS
          BEGIN
               NULL;
          END PROC1;

     BEGIN
          PROC1(A1);                     -- ERROR: PROC1 DERIVED.
          PROC1(A2);                     -- OK, T2 IN PRIVATE.
          PROC1(A3);                     -- OK, T3 IN BODY.
     END PACK1;

BEGIN
     NULL;
END B34016A;
