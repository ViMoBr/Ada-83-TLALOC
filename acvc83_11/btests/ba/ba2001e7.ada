-- BA2001E7.ADA

-- EG  11/18/85  ALLOW SUBUNIT DUPLICATION TO BE DETECTED WHEN SUBUNIT
--               IS COMPILED.

SEPARATE (BA2001E0M.BA2001E2)      -- OPTIONAL ERROR: PARENT IS MISSING.

FUNCTION BA2001E4 RETURN INTEGER IS     -- ERROR: REPEATED SUBUNIT
                                        --        IDENTIFIER. THIS
                                        --        ERROR CASE MUST BE
                                        --        DETECTED EITHER
                                        --        HERE OR IN FILE
                                        --        BA2001E2-AB.ADA.

BEGIN

     RETURN 1;

END BA2001E4;
