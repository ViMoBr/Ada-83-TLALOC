-- B26002A.ADA

-- CHECK THAT (") MUST BE DOUBLED TO BE
-- USED WITHIN STRING LITERALS AS A DATA CHARACTER.

-- DCB 1/16/80
-- JRK 10/29/80
-- TBN 10/14/85     RENAMED FROM B26002A.ADA AND FIXED LINE LENGTH.

PROCEDURE B26002A  IS

        C1 : STRING(1..1);
        C3 : STRING(1..5);

BEGIN
        C1 := """;      -- ERROR: QUOTE MUST BE DOUBLED IN
                        --        STRING LITERALS.
        NULL;

        C3 := "ABCD"";  -- ERROR: QUOTE MUST BE DOUBLED IN
                        --        STRING LITERALS.
        NULL;

        C3 := ""BCDE";  -- ERROR: QUOTE MUST BE DOUBLED IN
                        --        STRING LITERALS.
        NULL;

        C3 := "AB"DE";  -- ERROR: QUOTE MUST BE DOUBLED IN
                        --        STRING LITERALS.
        NULL;

END B26002A;
