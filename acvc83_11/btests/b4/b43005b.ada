-- B43005B.ADA

-- OBJECTIVE:
--     CHECK THAT THE NUMBER OF COMPONENT ASSOCIATIONS IS NOT USED IN
--     RESOLVING THE TYPE OF AN AGGREGATE.

-- HISTORY:
--     BCB 07/14/88  CREATED ORIGINAL TEST.

PROCEDURE B43005B IS

     TYPE REC1 IS RECORD
          COMP1 : INTEGER;
          COMP2 : INTEGER;
          COMP3 : INTEGER;
     END RECORD;

     TYPE REC2 IS RECORD
          COMP1 : INTEGER;
          COMP2 : INTEGER;
          COMP3 : INTEGER;
          COMP4 : INTEGER;
          COMP5 : INTEGER;
     END RECORD;

     PROCEDURE P (X : REC1) IS
     BEGIN
          NULL;
     END P;

     PROCEDURE P (X : REC2) IS
     BEGIN
          NULL;
     END P;

BEGIN

     P (REC1'(1,2,3));                                 -- OK.
     P (REC2'(1,2,3,4,5));                             -- OK.

     P ((1,2,3));                                      -- ERROR:
     P ((1,2,3,4,5));                                  -- ERROR:

END B43005B;
