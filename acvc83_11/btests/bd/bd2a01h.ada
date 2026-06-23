-- BD2A01H.ADA

-- OBJECTIVE:
--     A SIZE SPECIFICATION CANNOT BE GIVEN FOR A TYPE DECLARED BY
--     AN INCOMPLETE TYPE DECLARATION, PRIOR TO ITS FULL
--     DECLARATION.

-- HISTORY:
--     LDC  06/14/88 CREATED ORIGINAL TEST.


PROCEDURE BD2A01H IS

     TYPE TYP1;
     FOR TYP1'SIZE USE INTEGER'SIZE;                   -- ERROR: LENGTH
                                                       -- SPECIFIED
                                                       -- BEFORE FULL
                                                       -- DECLARATION.
     TYPE TYP2;
     TYPE TYP3 IS ACCESS TYP2;
     FOR TYP2'SIZE USE INTEGER'SIZE;                   -- ERROR: LENGTH
                                                       -- SPECIFIED
                                                       -- BEFORE FULL
                                                       -- DECLARATION.

     PACKAGE PCK IS
          TYPE TYP4 (DISC : INTEGER);
          FOR TYP4'SIZE USE (INTEGER'SIZE*2);          -- ERROR: LENGTH
                                                       -- SPECIFIED
                                                       -- BEFORE FULL
                                                       -- DECLARATION.
          TYPE TYP4 (DISC : INTEGER) IS RECORD
               ELEM : INTEGER;
          END RECORD;
     END PCK;

     TYPE TYP5;
     FOR TYP5'SIZE USE 4;                             -- ERROR: LENGTH
                                                       -- SPECIFIED
                                                       -- BEFORE FULL
                                                       -- DECLARATION.

-- FULL DECLARATIONS FOR THE ABOVE TYPES

     TYPE TYP1 IS NEW INTEGER;

     TYPE TYP2 IS RECORD
          ELEM : INTEGER;
     END RECORD;

     TYPE TYP5 IS (TERESA, BRIAN, PHIL, JOLEEN, LYNN, DOUG, JODIE,
                   VINCE, TOM, DAVE, JOHN, ROSA);


BEGIN
     NULL;
END BD2A01H;
