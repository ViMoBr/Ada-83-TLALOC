-- C26006A.ADA

-- CHECK THAT ALL ASCII CHARACTERS CAN APPEAR IN THE MIDDLE OF A STRING
-- (I.E., NONE ARE USED IN THE INTERNAL REPRESENTATION TO TERMINATE THE
-- STRING).

-- JRK 12/12/79

WITH REPORT;
PROCEDURE C26006A IS

        USE REPORT;

        S1 : STRING (1..3) := "A 1";
        S2 : STRING (1..3) := "A 2";

BEGIN
        TEST ("C26006A", "ALL ASCII CHARACTERS CAN APPEAR IN MIDDLE " &
              "OF STRINGS");

        FOR C IN CHARACTER'FIRST .. CHARACTER'LAST LOOP
                S1 (2) := C;
                S2 (2) := C;
                IF S1 = S2 THEN
                        FAILED (CHARACTER'IMAGE(C) & " TERMINATED A " &
                                "STRING = COMPARISON");
                END IF;
        END LOOP;

        RESULT;
END C26006A;
