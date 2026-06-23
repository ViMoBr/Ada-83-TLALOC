-- A26004A.ADA

-- CHECK THAT ALL PRINTABLE CHARACTERS ARE PERMITTED IN STRING LITERALS.

-- JRK 12/12/79
-- JRK 1/11/80
-- JRK 12/17/80
-- TBN 1/16/86   RENAMED FROM A26004A.TST. ADDED REPLACEMENT CHARACTERS,
--               FIXED LINE LENGTH, AND REMOVED MACRO CALLS.

WITH REPORT; USE REPORT;
PROCEDURE A26004A IS

BEGIN
     TEST ("A26004A", "ALL PRINTABLE CHARACTERS PERMITTED IN " &
                      "STRING LITERALS");

     DECLARE

          S1 : CONSTANT STRING := "ABCDEFGHIJKLMNOPQRSTUVWXYZ" &
                                  "0123456789" &
                                  """#&'()*+,-./:;<=>_| ";

          S2 : CONSTANT STRING := "abcdefghijklmnopqrstuvwxyz" &
                                  "!$%?@[\]^`{}~";

     BEGIN
          NULL;
     END;

     RESULT;
END A26004A;
