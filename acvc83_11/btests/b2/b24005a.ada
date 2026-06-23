-- B24005A.ADA

-- CHECK THAT LEADING/TRAILING DECIMAL POINTS ARE NOT PERMITTED IN
-- FLOATING POINT LITERALS.

-- JRK 12/12/79
-- JRK 10/27/80
-- JWC 6/28/85   RENAMED TO -AB

PROCEDURE B24005A IS

        FL : FLOAT;

BEGIN

        FL := 35.;      -- ERROR: 35.
        NULL;
        FL := .68;      -- ERROR: .68
        NULL;
        FL := 71.E1;    -- ERROR: 71.E1
        NULL;
        FL := .95E1;    -- ERROR: .95E1
        NULL;
        FL := 16#.A#;   -- ERROR: 16#.A#
        NULL;
        FL := 16#A.#;   -- ERROR: 16#A.#
        NULL;

END B24005A;
