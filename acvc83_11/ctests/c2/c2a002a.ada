-- C2A002A.ADA

-- CHECK THAT BASED INTEGER LITERALS WITH BASES 2 THROUGH 16 ALL
-- YIELD CORRECT VALUES WHEN COLONS ARE USED INSTEAD OF SHARPS.

-- JRK 12/12/79
-- JRK 10/27/80
-- JBG 5/28/85

WITH REPORT;
PROCEDURE C2A002A IS

        USE REPORT;

        I : INTEGER := 200;

BEGIN
        TEST ("C2A002A", "VALUES OF BASED INTEGER LITERALS WITH " &
                         "COLONS");

        IF 2:11: /= 3 THEN
                FAILED ("INCORRECT VALUE FOR BASE 2 INTEGER");
        END IF;

        IF 3:22: /= 8 THEN
                FAILED ("INCORRECT VALUE FOR BASE 3 INTEGER");
        END IF;

        IF 4:33: /= 15 THEN
                FAILED ("INCORRECT VALUE FOR BASE 4 INTEGER");
        END IF;

        IF 5:44: /= 24 THEN
                FAILED ("INCORRECT VALUE FOR BASE 5 INTEGER");
        END IF;

        IF 6:55: /= 35 THEN
                FAILED ("INCORRECT VALUE FOR BASE 6 INTEGER");
        END IF;

        IF 7:66: /= 48 THEN
                FAILED ("INCORRECT VALUE FOR BASE 7 INTEGER");
        END IF;

        IF 8:77: /= 63 THEN
                FAILED ("INCORRECT VALUE FOR BASE 8 INTEGER");
        END IF;

        IF 9:88: /= 80 THEN
                FAILED ("INCORRECT VALUE FOR BASE 9 INTEGER");
        END IF;

        IF 10:99: /= 99 THEN
                FAILED ("INCORRECT VALUE FOR BASE 10 INTEGER");
        END IF;

        IF 11:AA: /= 120 THEN
                FAILED ("INCORRECT VALUE FOR BASE 11 INTEGER");
        END IF;

        IF 12:BB: /= 143 THEN
                FAILED ("INCORRECT VALUE FOR BASE 12 INTEGER");
        END IF;

        IF 13:CC: /= 168 THEN
                FAILED ("INCORRECT VALUE FOR BASE 13 INTEGER");
        END IF;

        IF 14:DD: /= 195 THEN
                FAILED ("INCORRECT VALUE FOR BASE 14 INTEGER");
        END IF;

        IF 15:EE: /= 224 THEN
                FAILED ("INCORRECT VALUE FOR BASE 15 INTEGER");
        END IF;

        IF 16:FF: /= 255 THEN
                FAILED ("INCORRECT VALUE FOR BASE 16 INTEGER");
        END IF;

        ----------------------------------------

        IF 7:66:E1 /= 336 THEN
                FAILED ("INCORRECT VALUE FOR BASE 7 INTEGER " &
                        "WITH EXPONENT");
        END IF;

        RESULT;
END C2A002A; 
