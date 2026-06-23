-- BD3001C.ADA

-- OBJECTIVE:
--     CHECK THAT AN ENUMERATION REPRESENTATION SPECIFICATION CANNOT
--     BE GIVEN FOR A GENERIC FORMAL DISCRETE TYPE OR FOR A TYPE THAT
--     IS NOT AN ENUMERATION TYPE.

-- HISTORY:
--     DHH 09/07/88  CREATED ORIGINAL TEST.

PROCEDURE BD3001C IS

     TYPE ENUM IS (A, B);
     GENERIC
          TYPE ENUM1 IS (<>);
     PACKAGE P IS
          FOR ENUM1 USE (1, 2);                                -- ERROR:
     END P;

     PACKAGE P1 IS NEW P(ENUM);

     GENERIC
          TYPE ENUM2 IS (<>);
     PACKAGE P3 IS
          TYPE ENUM3 IS NEW ENUM2;
          FOR ENUM3 USE (1, 2);                               -- ERROR:
     END P3;

     PACKAGE P4 IS NEW P(ENUM);

     TYPE FLOAT IS DIGITS 5 RANGE 1.0 .. 2.0;
     FOR FLOAT USE (1, 2);                                    -- ERROR:

     TYPE FIXED IS DELTA 0.125 RANGE 1.0 .. 10.0;
     FOR FIXED USE (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);           -- ERROR:

-- COMPOSITE
     TYPE REC IS
          RECORD
               X : INTEGER;
               Y : INTEGER;
          END RECORD;
     FOR REC USE (1, 2);                                      -- ERROR:

     TYPE ARR IS ARRAY(1 .. 2) OF BOOLEAN;
     FOR ARR USE (1, 2);                                      -- ERROR:

-- DISCRIMINANT
     TYPE REC1(DIS : INTEGER) IS
          RECORD
               X : INTEGER;
          END RECORD;
     FOR REC1 USE (1, 2);                                     -- ERROR:

BEGIN
     NULL;
END BD3001C;
