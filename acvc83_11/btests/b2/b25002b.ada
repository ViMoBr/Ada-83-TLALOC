-- B25002B.ADA

-- CHECK THAT THE FORMAT EFFECTORS CANNOT
-- APPEAR IN CHARACTER LITERALS:
--     HORIZONTAL TAB,
--     VERTICAL TAB,
--     CARRIAGE RETURN,
--     LINE FEED,
--     FORM FEED.

-- PWB  2/14/86

PROCEDURE B25002B IS

     LINE : STRING (1..3);
     CHAR : CHARACTER;

     HT : CONSTANT CHARACTER := '	';    -- ERROR: HT.
     C1 : CHARACTER;  -- TO AID RECOVERY
                                              -- ERROR: VT NEXT LINE.
     VT : CONSTANT CHARACTER := '';
     C2 : CHARACTER;  -- TO AID RECOVERY
                                              -- ERROR: CR NEXT LINE;
     CR : CHARACTER := '';
     C3 : CHARACTER;  -- TO AID RECOVERY

     BAD_LINE : STRING(1..3) := "LF" &        -- ERROR: LF NEXT LINE.
                               '
';

     C4 : CHARACTER;  -- TO AID RECOVERY
     FORM : STRING(1..3) :=                  -- ERROR: FF NEXT LINE.
                           '' & "FF";
     C5 : CHARACTER;  -- TO AID RECOVERY

BEGIN

     CHAR := '	';                            -- ERROR: HT.
     CHAR := 'A';  -- TO AID RECOVERY

     LINE := LINE(1..2) &                     -- ERROR: VT NEXT LINE.
             '';
     CHAR := 'A';  -- TO AID RECOVERY

                                              -- ERROR: CR NEXT LINE.
     LINE := '' 
             & LINE(2..3);
     CHAR := 'A';  -- TO AID RECOVERY

     LINE := LINE(1..1) &                     -- ERROR: FF NEXT LINE.
             '' 
             & LINE(3..3);
     CHAR := 'A';  -- TO AID RECOVERY

     CHAR :=                                  -- ERROR: LF NEXT LINE.
             '
';
     CHAR := 'A';  -- TO AID RECOVERY

END B25002B;
