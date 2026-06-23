-- B32104A.ADA

-- OBJECTIVE:
--     CHECK THAT UNCONSTRAINED ARRAY DEFINITIONS ARE NOT PERMITTED
--     IN OBJECT DECLARATIONS.

-- HISTORY:
--     BCB 01/20/88  CREATED ORIGINAL TEST.

PROCEDURE B32104A IS

     TYPE INT IS (JOHN, VINCE, DAVE, TOM, MIKE);

     V1 : ARRAY(INTEGER RANGE <>) OF FLOAT;     -- ERROR: UNCONSTRAINED
                                                -- ARRAY DEFINITION IN
                                                -- OBJECT DECLARATION.

     V2 : CONSTANT ARRAY(INT RANGE <>) OF INTEGER := (1,2,3,4,5);
                                                -- ERROR: UNCONSTRAINED
                                                -- ARRAY DEFINITION IN
                                                -- CONSTANT DECLARATION.

     V3 : CONSTANT ARRAY(INTEGER RANGE <>) OF INTEGER := (1,2);
                                                -- ERROR: UNCONSTRAINED
                                                -- ARRAY DEFINITION IN
                                                -- CONSTANT DECLARATION.

     V4 : ARRAY(INT RANGE <>) OF INTEGER;       -- ERROR: UNCONSTRAINED
                                                -- ARRAY DEFINITION IN
                                                -- OBJECT DECLARATION.

BEGIN
     NULL;
END B32104A;
