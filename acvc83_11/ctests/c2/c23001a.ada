-- C23001A.ADA

-- CHECK THAT UPPER AND LOWER CASE LETTERS ARE EQUIVALENT IN IDENTIFIERS
-- (INCLUDING RESERVED WORDS).

-- JRK 12/12/79
-- JWC 6/28/85   RENAMED TO -AB

WITH REPORT;
PROCEDURE C23001A IS

        USE REPORT;

        AN_IDENTIFIER : INTEGER := 1;

BEGIN
        TEST ("C23001A", "UPPER/LOWER CASE EQUIVALENCE IN IDENTIFIERS");

        DECLARE
                an_identifier : INTEGER := 3;
        BEGIN
                IF an_identifier /= AN_IDENTIFIER THEN
                        FAILED ("LOWER CASE NOT EQUIVALENT TO UPPER " &
                                "IN DECLARABLE IDENTIFIERS");
                END IF;
        END;

        IF An_IdEnTIfieR /= AN_IDENTIFIER THEN
                FAILED ("MIXED CASE NOT EQUIVALENT TO UPPER IN " &
                        "DECLARABLE IDENTIFIERS");
        END IF;

        if AN_IDENTIFIER = 1 ThEn
                AN_IDENTIFIER := 2;
        END IF;
        IF AN_IDENTIFIER /= 2 THEN
                FAILED ("LOWER AND/OR MIXED CASE NOT EQUIVALENT TO " &
                        "UPPER IN RESERVED WORDS");
        END IF;

        RESULT;
END C23001A;
