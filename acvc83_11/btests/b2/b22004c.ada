-- B22004C.ADA

-- CHECK THAT FIXED POINT LITERALS CANNOT CONTAIN SPACES.

-- JRK 4/18/80
-- JWC 6/28/85   RENAMED TO -AB

PROCEDURE B22004C IS

        TYPE FIXED IS DELTA 0.1 RANGE 0.0 .. 99.9;

        F1 : FIXED := 35. 5;            -- ERROR: 35. 5
        F2 : FIXED := 1.62 E1;          -- ERROR: 1.62 E1
        F3 : FIXED := 2.30E +1;         -- ERROR: 2.30E +1
        F4 : FIXED := 8#2.3 #E1;        -- ERROR: 8#2.3 #E1

BEGIN
        NULL;
END B22004C;
