-- B22003A.ADA

-- OBJECTIVE:
--     CHECK THAT AT LEAST ONE SPACE MUST SEPARATE ADJACENT IDENTIFIERS
--     (INCLUDING RESERVED WORDS) AND/OR NUMBERS.

-- HISTORY:
--     JRK 12/12/79
--     JWC 06/28/85  RENAMED TO -AB.
--     DWC 10/02/87  SPLIT CHECKS FOR RANGE TO B22003B.ADA.

PROCEDURE B22003A IS

        K : INTEGER := 1;
        B : BOOLEAN := TRUE;

BEGIN

        IFK = 1 THEN            -- ERROR: IFK
                K := 2;
        END IF;

        IF BOR FALSE THEN       -- ERROR: BOR
                K := 3;
        END IF;

        IF K = 1THEN            -- ERROR: 1THEN
                K := 3;
        END IF;

END B22003A;
