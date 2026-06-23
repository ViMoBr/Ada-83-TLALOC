-- BA2001E4.ADA

-- EG  11/18/85  ALLOW SUBUNIT DUPLICATION TO BE DETECTED WHEN SUBUNIT
--               IS COMPILED.

SEPARATE (BA2001E0M.BA2001E1)

FUNCTION BA2001E4 RETURN INTEGER IS     -- OPTIONAL ERROR: REPEATED
                                        --                 SUBUNIT
                                        --                 IDENTIFIER.

BEGIN

     RETURN 1;

END BA2001E4;
