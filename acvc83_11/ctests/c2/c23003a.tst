-- C23003A.TST

-- CHECK THAT VARIABLE IDENTIFIERS CAN BE AS LONG AS THE MAXIMUM INPUT
-- LINE LENGTH PERMITTED AND THAT ALL CHARACTERS ARE SIGNIFICANT.

-- JRK 12/12/79
-- JRK 1/11/80
-- JWC 6/28/85   RENAMED TO -AB

WITH REPORT;
PROCEDURE C23003A IS

        USE REPORT;

BEGIN
        TEST ("C23003A", "MAXIMUM LENGTH VARIABLE IDENTIFIERS");

        -- BIG_ID1 AND BIG_ID2 ARE TWO MAXIMUM LENGTH IDENTIFIERS THAT
        -- DIFFER ONLY IN THEIR LAST CHARACTER.

        DECLARE
$BIG_ID1
                                        -- BIG_ID1
                        : INTEGER := 1;
        BEGIN
                DECLARE
$BIG_ID2
                                                -- BIG_ID2
                                : INTEGER := 2;
                BEGIN

                        IF
$BIG_ID1
                                                -- BIG_ID1
                                +
$BIG_ID2
                                                -- BIG_ID2
                                        /= 3 THEN
                                FAILED ("IDENTIFIERS AS LONG AS " &
                                        "MAXIMUM INPUT LINE LENGTH " &
                                        "NOT PERMITTED OR NOT " &
                                        "DISTINGUISHED BY DISTINCT " &
                                        "SUFFIXES");
                        END IF;

                END;
        END;

        -- BIG_ID3 AND BIG_ID4 ARE TWO MAXIMUM LENGTH IDENTIFIERS THAT
        -- DIFFER ONLY IN THEIR MIDDLE CHARACTER.

        DECLARE
$BIG_ID3
                                        -- BIG_ID3
                        : INTEGER := 3;
        BEGIN
                DECLARE
$BIG_ID4
                                                -- BIG_ID4
                                : INTEGER := 4;
                BEGIN

                        IF
$BIG_ID3
                                                -- BIG_ID3
                                +
$BIG_ID4
                                                -- BIG_ID4
                                        /= 7 THEN
                                FAILED ("IDENTIFIERS AS LONG AS " &
                                        "MAXIMUM INPUT LINE LENGTH " &
                                        "NOT PERMITTED OR NOT " &
                                        "DISTINGUISHED BY DISTINCT " &
                                        "MIDDLES");
                        END IF;

                END;
        END;

        RESULT;
END C23003A;
