-- B43005A.ADA

-- OBJECTIVE:
--     CHECK THAT THE NUMBER OF ARRAY DIMENSIONS IS NOT USED IN
--     RESOLVING THE TYPE OF AN AGGREGATE.

-- HISTORY:
--     BCB 01/22/88  CREATED ORIGINAL TEST.

PROCEDURE B43005A IS

     TYPE ARR1 IS ARRAY (1..2) OF INTEGER;
     TYPE ARR2 IS ARRAY (1..2, 1..2) OF INTEGER;

     PROCEDURE P (X : ARR1) IS
     BEGIN
          NULL;
     END P;

     PROCEDURE P (X : ARR2) IS
     BEGIN
          NULL;
     END P;

BEGIN

     P (ARR1'(3,4));                                   -- OK.
     P (ARR2'((3,4), (5,6)));                          -- OK.

     P ((3,4));                                        -- ERROR.
     P (((3,4), (5,6)));                               -- ERROR.

END B43005A;
