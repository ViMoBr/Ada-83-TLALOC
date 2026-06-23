-- B24204A.ADA

-- OBJECTIVE:
--     CHECK THAT THE DIGITS AND EXTENDED_DIGITS OF AN INTEGER LITERAL
--     ARE WITHIN THE CORRECT RANGE FOR THE NUMBER'S BASE.

-- HISTORY:
--     JRK 12/12/79
--     JRK 10/27/80
--     JWC 06/28/85  RENAMED FROM B24104A.ADA.
--     DWC 09/22/87  MOVED SOME OF THE CHECKS FOR BASE 10 LITERALS
--                   TO B24204D.ADA.

PROCEDURE B24204A IS

        I  : INTEGER;

BEGIN

        I := 2#2#;              -- ERROR: 2#2#
        I := 3#3#;              -- ERROR: 3#3#
        I := 4#4#;              -- ERROR: 4#4#
        I := 5#5#;              -- ERROR: 5#5#
        I := 6#6#;              -- ERROR: 6#6#
        I := 7#7#;              -- ERROR: 7#7#
        I := 8#8#;              -- ERROR: 8#8#
        I := 9#9#;              -- ERROR: 9#9#
        I := 10#A#;             -- ERROR: 10#A#
        I := 11#B#;             -- ERROR: 11#B#
        I := 12#C#;             -- ERROR: 12#C#
        I := 13#D#;             -- ERROR: 13#D#
        I := 14#E#;             -- ERROR: 14#E#
        I := 15#F#;             -- ERROR: 15#F#
        I := 16#G#;             -- ERROR: 16#G#

END B24204A;
