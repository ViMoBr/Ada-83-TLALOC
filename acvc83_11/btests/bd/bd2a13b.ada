-- BD2A13B.ADA

-- OBJECTIVE:
--     CHECK THAT A SIZE SPECIFICATION CANNOT BE GIVEN FOR A RECORD
--     TYPE THAT HAS A NONSTATIC COMPONENT OR SUBCOMPONENT CONSTRAINT,
--     OR A SUBCOMPONENT CONSTRAINT THAT DEPENDS ON A DISCRIMINANT.

-- HISTORY:
--     JKC 03/17/88  CREATED ORIGINAL TEST.

PROCEDURE BD2A13B IS

     L : INTEGER := 0;
     R : INTEGER := 10;
     TYPE R_TYPE IS
          RECORD
               I1 : INTEGER;
               I2 : INTEGER RANGE L..R;
               I3 : INTEGER := 33;
               I4 : INTEGER;
          END RECORD;
     FOR R_TYPE'SIZE USE 6*INTEGER'SIZE;      -- ERROR: NONSTATIC
                                              --        COMPONENT
                                              --        CONSTRAINT.

     TYPE SUBCOMP IS
          RECORD
               I5 : INTEGER RANGE L..R;
          END RECORD;

     TYPE R2_TYPE IS
          RECORD
               I6 : SUBCOMP;
     END RECORD;
     FOR R2_TYPE'SIZE USE 6*INTEGER'SIZE;     -- ERROR: NONSTATIC
                                              --        SUBCOMPONENT
                                              --        CONSTRAINT.

     SUBTYPE SMALL IS INTEGER RANGE 1..10;

     TYPE ARRY IS ARRAY (SMALL RANGE <>) OF INTEGER;

     TYPE DISC (D : SMALL) IS
          RECORD
               AR : ARRY (1..D);
          END RECORD;

     FOR DISC'SIZE USE 12*INTEGER'SIZE;       -- ERROR: SUBCOMPONENT
                                              --        CONSTRAINT
                                              --        DEPENDS ON
                                              --        DISCRIMINANT.
BEGIN
     NULL;
END BD2A13B;
