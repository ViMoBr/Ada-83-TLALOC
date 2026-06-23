-- B22004B.ADA

-- CHECK THAT FLOATING POINT LITERALS CANNOT CONTAIN SPACES.

-- JRK 4/18/80
-- JWC 6/28/85   RENAMED TO -AB

PROCEDURE B22004B IS

        F1 : FLOAT := 35. 5;            -- ERROR: 35. 5
        F2 : FLOAT := 16.2 E1;          -- ERROR: 16.2 E1
        F3 : FLOAT := 23.0E +1;         -- ERROR: 23.0E +1
        F4 : FLOAT := 8#2.3 #E1;        -- ERROR: 8#2.3 #E1

BEGIN
        NULL;
END B22004B;
