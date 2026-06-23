-- B37106A.ADA

-- CHECK THAT THE TYPE OF A DISCRIMINANT MUST BE SPECIFIED BY A TYPE
-- MARK, NOT A SUBTYPE INDICATION WITH A RANGE CONSTRAINT.

-- RJW 2/27/86 

PROCEDURE B37106A IS
     
     TYPE CHAR1 IS NEW CHARACTER;
     
     TYPE REC1 (DISC : CHAR1 RANGE 'A' .. 'B') IS     -- ERROR: RANGE 
                                                      --   CONSTRAINT.
          RECORD
               NULL;
          END RECORD;
     
     TYPE DAY IS (SUN, MON, TUE, WED, THUR, FRI, SAT);

     TYPE REC2 (DISC1 : DAY;         -- OK.
                DISC2 : DAY RANGE MON .. FRI) IS      -- ERROR: RANGE 
                                                      --   CONSTRAINT.
          RECORD
               NULL;
          END RECORD;
     
     TYPE REC3 (T : BOOLEAN RANGE TRUE .. TRUE) IS    -- ERROR: RANGE 
                                                      --   CONSTRAINT.
          RECORD
               NULL;
          END RECORD;

     TYPE REC4 (I : INTEGER RANGE 0 .. 10) IS         -- ERROR: RANGE
                                                      --   CONSTRAINT.
          RECORD
               NULL;
          END RECORD;

BEGIN
     NULL;          
END B37106A;                                
