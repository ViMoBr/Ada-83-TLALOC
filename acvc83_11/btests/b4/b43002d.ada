-- B43002D.ADA

-- OBJECTIVE:
--     CHECK THAT A RECORD AGGREGATE CANNOT CONTAIN A SINGLE
--     POSITIONAL ASSOCIATION.

-- HISTORY:
--     BCB 07/08/88  CREATED ORIGINAL TEST.

PROCEDURE B43002D IS

     TYPE REC IS RECORD
          COMP1 : INTEGER;
     END RECORD;

     TYPE REC2 (D : INTEGER) IS RECORD
          NULL;
     END RECORD;

     A : REC;

     B : REC2(3);

BEGIN

     A := (5);                                         -- ERROR:

     B := (3);                                         -- ERROR:

END B43002D;
