-- BA2001E2.ADA

-- WKB 06/25/81
-- JRK 06/26/81
-- EG  11/18/85  ALLOW SUBUNIT DUPLICATION TO BE DETECTED WHEN SUBUNIT
--               IS COMPILED.

SEPARATE (BA2001E0M)

PROCEDURE BA2001E2 IS

     PROCEDURE BA2001E3 IS SEPARATE;    -- ERROR: REPEATED SUBUNIT
                                        --        IDENTIFIER. THIS
                                        --        ERROR CASE MUST BE
                                        --        DETECTED EITHER
                                        --        HERE OR IN FILE
                                        --        BA2001E6-AB.ADA.

     FUNCTION BA2001E4 RETURN INTEGER
                          IS SEPARATE;  -- ERROR: REPEATED SUBUNIT
                                        --        IDENTIFIER. THIS
                                        --        ERROR CASE MUST BE
                                        --        DETECTED EITHER
                                        --        HERE OR IN FILE
                                        --        BA2001E7-AB.ADA.

     PACKAGE BA2001E5 IS
          I : INTEGER;
     END BA2001E5;

     PACKAGE BODY BA2001E5 IS SEPARATE; -- ERROR: REPEATED SUBUNIT
                                        --        IDENTIFIER. THIS
                                        --        ERROR CASE MUST BE
                                        --        DETECTED EITHER
                                        --        HERE OR IN FILE
                                        --        BA2001E8-AB.ADA.

BEGIN
     NULL;
END BA2001E2;
