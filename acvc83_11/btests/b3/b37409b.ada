-- B37409B.ADA

-- OBJECTIVE:
--     CHECK THAT THE ATTRIBUTE 'BASE IS NOT DEFINED FOR OBJECTS OF
--     RECORD TYPES AND SUBTYPES.

-- HISTORY:
--     DHH 03/03/88 CREATED ORIGINAL TEST.

PROCEDURE B37409B IS
     SUBTYPE INT IS INTEGER RANGE 1 .. 10;
     TYPE T(A : INT := 1) IS
          RECORD
               I : INTEGER;
          END RECORD;
     TYPE TA IS
          RECORD
               I : INTEGER;
          END RECORD;
     SUBTYPE SS IS T(6);
     X : SS;
     Y : TA;
BEGIN

     IF X'BASE'SIZE < T'SIZE THEN         -- ERROR: 'BASE APPLIED TO
                                          --         RECORD OBJECT.
          X.I := 1;
     END IF;
     IF Y'BASE'SIZE < T'SIZE THEN         -- ERROR: 'BASE APPLIED TO
                                          --         RECORD OBJECT.
          Y.I := 1;
     END IF;

END B37409B;
