-- BD2001B.ADA

-- OBJECTIVE:
--     CHECK THAT THE SYNTAX FOR A LENGTH CLAUSE CANNOT BE USED TO
--     SPECIFY 'FIRST FOR AN INTEGER TYPE.

-- HISTORY:
--     LDC  06/14/88 CREATED ORIGINAL TEST.

PROCEDURE BD2001B IS

     FOR INTEGER'FIRST USE 0;                          -- ERROR: 'FIRST
                                                       -- INVALID

     SUBTYPE SUB_INT_TYPE IS INTEGER RANGE 16..32;
     FOR SUB_INT_TYPE'FIRST USE 16;                    -- ERROR: 'FIRST
                                                       -- INVALID

     FOR NATURAL'FIRST USE 1;                          -- ERROR: 'FIRST
                                                       -- INVALID

     SUBTYPE SUB_NAT_TYPE IS NATURAL RANGE 1..32;
     FOR SUB_NAT_TYPE'FIRST USE 1;                     -- ERROR: 'FIRST
                                                       -- INVALID

     TYPE DRV_INT_TYPE IS NEW INTEGER;
     FOR DRV_INT_TYPE'FIRST USE 2;                     -- ERROR: 'FIRST
                                                       -- INVALID

     TYPE DRV_INT_RNG_TYPE IS NEW INTEGER RANGE 1..32;
     FOR DRV_INT_RNG_TYPE'FIRST USE 1;                 -- ERROR: 'FIRST
                                                       -- INVALID

     TYPE INT_RNG_TYPE IS RANGE 1..64;
     FOR INT_RNG_TYPE'FIRST USE 1;                     -- ERROR: 'FIRST
                                                       -- INVALID
BEGIN
     NULL;
END BD2001B;
