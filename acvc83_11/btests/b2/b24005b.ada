-- B24005B.ADA

-- CHECK THAT LEADING/TRAILING DECIMAL POINTS ARE NOT PERMITTED IN
-- FIXED POINT LITERALS.

-- JRK 4/21/80
-- JRK 10/27/80
-- JWC 6/28/85   RENAMED TO -AB

PROCEDURE B24005B IS

        TYPE FIXED IS DELTA 0.1 RANGE 0.0 .. 100.0;

        FX : FIXED;

BEGIN

        FX := 35.;      -- ERROR: 35.
        NULL;
        FX := .68;      -- ERROR: .68
        NULL;
        FX := 71.E1;    -- ERROR: 71.E1
        NULL;
        FX := .95E1;    -- ERROR: .95E1
        NULL;
        FX := 16#.A#;   -- ERROR: 16#.A#
        NULL;
        FX := 16#A.#;   -- ERROR: 16#A.#
        NULL;

END B24005B;
