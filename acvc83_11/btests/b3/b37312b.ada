-- B37312B.ADA

-- OBJECTIVE:
--     CHECK THAT A DISCRIMINANT WHICH GOVERNS A VARIANT PART CANNOT
--     BE A GENERIC FORMAL TYPE.

-- HISTORY:
--     AH  08/21/86  CREATED ORIGINAL TEST.
--     JET 08/13/87  ADDED PACKAGE P2 FOR DISCRETE TYPES.

PROCEDURE B37312B IS
     TYPE T IS RANGE 1 .. 5;

     GENERIC
          TYPE G1 IS RANGE <>;
     PACKAGE P1 IS
          TYPE G2 (D1 : G1) IS
               RECORD
                    R1 : G1;
                    R2 : BOOLEAN;
                    CASE D1 IS            -- ERROR: GENERIC FORMAL TYPE.
                         WHEN G1'FIRST =>
                              V1 : INTEGER;
                         WHEN OTHERS =>
                              V2 : INTEGER;
                    END CASE;
               END RECORD;
     END P1;

     GENERIC
          TYPE G1 IS (<>);
     PACKAGE P2 IS
          TYPE G2 (D1 : G1) IS
               RECORD
                    R1 : G1;
                    R2 : BOOLEAN;
                    CASE D1 IS            -- ERROR: GENERIC FORMAL TYPE.
                         WHEN G1'FIRST =>
                              V1 : INTEGER;
                         WHEN OTHERS =>
                              V2 : INTEGER;
                    END CASE;
               END RECORD;
     END P2;

BEGIN
     NULL;
END B37312B;
