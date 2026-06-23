-- BC3201C.ADA

-- CHECK THAT WHEN A GENERIC UNIT HAS A NON-LIMITED GENERIC FORMAL
-- PRIVATE TYPE, THE ACTUAL PARAMETER MUST NOT BE A LIMITED TYPE.

-- CHECK WHEN THE ACTUAL PARAMETER IS A FORMAL LIMITED PRIVATE TYPE
-- DECLARED IN AN ENCLOSING GENERIC UNIT.

-- SPS 7/8/82
-- SPS 12/10/82

PROCEDURE BC3201C IS
     GENERIC
          TYPE LP IS LIMITED PRIVATE;
          TYPE ARLP IS ARRAY (INTEGER) OF LP;
     PACKAGE PK IS
          GENERIC
               TYPE PV IS PRIVATE;
          PACKAGE P IS END P;

          TYPE NLP IS NEW LP;

          TYPE REC IS RECORD
               C1 : ARLP;
               C2 : LP;
          END RECORD;

          SUBTYPE INT IS INTEGER RANGE 1 .. 10;
          TYPE VREC (D : INT) IS
          RECORD
               CASE D IS
                    WHEN 1..3 =>
                         C1 : ARLP;
                    WHEN 4..9 =>
                         C2 : LP;
                    WHEN OTHERS =>
                         C3 : INTEGER := 3;
               END CASE;
          END RECORD;

          SUBTYPE CVREC IS VREC (D => 10);

          PACKAGE P1 IS NEW P(LP);     -- ERROR: LP.
          PACKAGE P2 IS NEW P(NLP);    -- ERROR: NLP.
          PACKAGE P3 IS NEW P(ARLP);   -- ERROR: ARLP.
          PACKAGE P4 IS NEW P(REC);    -- ERROR: REC.
          PACKAGE P5 IS NEW P(VREC);   -- ERROR: VREC.
          PACKAGE P6 IS NEW P(CVREC);  -- ERROR: CVREC.
     END PK;

BEGIN
     NULL;
END BC3201C;
