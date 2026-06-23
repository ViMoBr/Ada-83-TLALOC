-- B74103H.ADA

-- OBJECTIVE:
--     CHECK THAT BEFORE THE FULL DECLARATION OF A PRIVATE TYPE,
--        A NAME DENOTING THE PRIVATE TYPE,
--        A NAME THAT DENOTES A SUBTYPE OF THE PRIVATE TYPE, AND
--        A NAME THAT DENOTES A COMPOSITE TYPE WITH A SUBCOMPONENT OF
--          THE PRIVATE TYPE OR SUBTYPE
--     MAY NOT BE USED IN A EXPRESSION AS THE TYPE MARK IN A CONVERSION,
--     QUALIFICATION, MEMBERSHIP TEST, OR ATTRIBUTE ('SIZE,
--     'CONSTRAINED, OR 'BASE).

-- HISTORY:
--     BCB 08/24/88  CREATED ORIGINAL TEST.

PROCEDURE B74103H IS

     PACKAGE P IS
          TYPE P1 IS PRIVATE;
          TYPE LP2 IS LIMITED PRIVATE;

          CP1 : CONSTANT P1;
          CLP2 : CONSTANT LP2;

          SUBTYPE SP1 IS P1;
          SUBTYPE SLP2 IS LP2;

          TYPE ARR1_P1 IS ARRAY ( 1 .. 2 ) OF P1;
          TYPE ARR2_LP2 IS ARRAY ( 1 .. 2 ) OF LP2;
          TYPE ARR3_SP1 IS ARRAY ( 1 .. 2 ) OF SP1;
          TYPE ARR4_SLP2 IS ARRAY ( 1 .. 2 ) OF SLP2;
          TYPE ARR51 IS ARRAY ( 1 .. 2 ) OF ARR1_P1;
          TYPE ARR52 IS ARRAY ( 1 .. 2 ) OF ARR2_LP2;
          TYPE ARR53 IS ARRAY ( 1 .. 2 ) OF ARR3_SP1;
          TYPE ARR54 IS ARRAY ( 1 .. 2 ) OF ARR4_SLP2;

          FUNCTION F_ARR51 RETURN ARR51;
          FUNCTION F_ARR54 RETURN ARR54;

          TYPE REC1 IS
               RECORD
                    C1 : P1;
               END RECORD;

          TYPE REC2 IS
               RECORD
                    C2 : LP2;
               END RECORD;

          TYPE REC3 IS
               RECORD
                    C3 : SP1;
               END RECORD;

          TYPE REC4 IS
               RECORD
                    C4 : SLP2;
               END RECORD;

          TYPE REC51 IS
               RECORD
                    C5 : REC1;
               END RECORD;

          TYPE REC52 IS
               RECORD
                    C6 : REC2;
               END RECORD;

          TYPE REC53 IS
               RECORD
                    C7 : REC3;
               END RECORD;

          TYPE REC54 IS
               RECORD
                    C8 : REC4;
               END RECORD;

          FUNCTION F_REC52 RETURN REC52;
          FUNCTION F_REC53 RETURN REC53;

          PROCEDURE A1 (X1 : P1 := P1(CP1));             -- ERROR:
          PROCEDURE A2 (X2 : LP2 := LP2(CLP2));          -- ERROR:
          PROCEDURE A3 (X3 : SP1 := SP1(CP1));           -- ERROR:
          PROCEDURE A4 (X4 : SLP2 := SLP2(CLP2));        -- ERROR:
          PROCEDURE A5 (X5 : ARR51 := ARR51((F_ARR51))); -- ERROR:
          PROCEDURE A6 (X6 : ARR54 := ARR54((F_ARR54))); -- ERROR:
          PROCEDURE A7 (X7 : REC52 := REC52((F_REC52))); -- ERROR:
          PROCEDURE A8 (X8 : REC53 := REC53((F_REC53))); -- ERROR:

          PROCEDURE B1 (Y1 : P1 := P1'(CP1));            -- ERROR:
          PROCEDURE B2 (Y2 : LP2 := LP2'(CLP2));         -- ERROR:
          PROCEDURE B3 (Y3 : SP1 := SP1'(CP1));          -- ERROR:
          PROCEDURE B4 (Y4 : SLP2 := SLP2'(CLP2));       -- ERROR:
          PROCEDURE B5 (Y5 : ARR51 := ARR51'((CP1,CP1),(CP1,CP1)));
                                                         -- ERROR:
          PROCEDURE B6 (Y6 : ARR52 := ARR52'((CLP2,CLP2),(CLP2,CLP2)));
                                                         -- ERROR:
          PROCEDURE B7 (Y7 : ARR53 := ARR53'((CP1,CP1),(CP1,CP1)));
                                                         -- ERROR:
          PROCEDURE B8 (Y8 : ARR54 := ARR54'((CLP2,CLP2),(CLP2,CLP2)));
                                                         -- ERROR:
          PROCEDURE B9 (Y9 : REC51 := REC51'(C5 => (C1 => CP1)));
                                                         -- ERROR:
          PROCEDURE B10 (Y10 : REC52 := REC52'(C6 => (C2 => CLP2)));
                                                         -- ERROR:
          PROCEDURE B11 (Y11 : REC53 := REC53'(C7 => (C3 => CP1)));
                                                         -- ERROR:
          PROCEDURE B12 (Y12 : REC54 := REC54'(C8 => (C4 => CLP2)));
                                                         -- ERROR:

          Z1 : BOOLEAN := (CP1 IN P1);                    -- ERROR:
          Z2 : BOOLEAN := (CLP2 IN LP2);                  -- ERROR:
          Z3 : BOOLEAN := (CP1 IN SP1);                   -- ERROR:
          Z4 : BOOLEAN := (CLP2 IN SLP2);                 -- ERROR:
          Z5 : BOOLEAN := ((CP1,CP1),(CP1,CP1)) IN ARR51; -- ERROR:
          Z6 : BOOLEAN := ((CLP2,CLP2),(CLP2,CLP2)) IN ARR52;-- ERROR:
          Z7 : BOOLEAN := ((CP1,CP1),(CP1,CP1)) IN ARR53;    -- ERROR:
          Z8 : BOOLEAN := ((CLP2,CLP2),(CLP2,CLP2)) IN ARR54;-- ERROR:
          Z9 : BOOLEAN := (C5 => (C1 => CP1)) IN REC51;   -- ERROR:
          Z11 : BOOLEAN := (C7 => (C3 => CP1)) IN REC53;  -- ERROR:

          XX1 : INTEGER := P1'SIZE;                       -- ERROR:
          XX2 : INTEGER := LP2'SIZE;                      -- ERROR:
          XX3 : INTEGER := SP1'SIZE;                      -- ERROR:
          XX4 : INTEGER := SLP2'SIZE;                     -- ERROR:

          YY5 : BOOLEAN := ARR51'CONSTRAINED;             -- ERROR:
          YY6 : BOOLEAN := ARR52'CONSTRAINED;             -- ERROR:
          YY7 : BOOLEAN := ARR53'CONSTRAINED;             -- ERROR:
          YY8 : BOOLEAN := ARR54'CONSTRAINED;             -- ERROR:

          ZZ9 : INTEGER := REC51'BASE'SIZE;               -- ERROR:
          ZZ10 : INTEGER := REC52'BASE'SIZE;              -- ERROR:
          ZZ11 : INTEGER := REC53'BASE'SIZE;              -- ERROR:
          ZZ12 : INTEGER := REC54'BASE'SIZE;              -- ERROR:

     PRIVATE
          TYPE P1 IS NEW INTEGER;
          TYPE LP2 IS NEW INTEGER;

          CP1 : CONSTANT P1 := 3;
          CLP2 : CONSTANT LP2 := 4;
     END P;

     PACKAGE BODY P IS
          FUNCTION F_ARR51 RETURN ARR51 IS
               Z : ARR51 := ((CP1,CP1),(CP1,CP1));
          BEGIN
               RETURN Z;
          END F_ARR51;

          FUNCTION F_ARR54 RETURN ARR54 IS
               Z : ARR54 := ((CLP2,CLP2),(CLP2,CLP2));
          BEGIN
               RETURN Z;
          END F_ARR54;

          FUNCTION F_REC52 RETURN REC52 IS
               Z : REC52 := (C6 => (C2 => CLP2));
          BEGIN
               RETURN Z;
          END F_REC52;

          FUNCTION F_REC53 RETURN REC53 IS
               Z : REC53 := (C7 => (C3 => CP1));
          BEGIN
               RETURN Z;
          END F_REC53;

          PROCEDURE A1 (X1 : P1 := P1(CP1)) IS
               BEGIN NULL; END;
          PROCEDURE A2 (X2 : LP2 := LP2(CLP2)) IS
               BEGIN NULL; END;
          PROCEDURE A3 (X3 : SP1 := SP1(CP1)) IS
               BEGIN NULL; END;
          PROCEDURE A4 (X4 : SLP2 := SLP2(CLP2)) IS
               BEGIN NULL; END;
          PROCEDURE A5 (X5 : ARR51 := ARR51((F_ARR51))) IS
               BEGIN NULL; END;
          PROCEDURE A6 (X6 : ARR54 := ARR54((F_ARR54))) IS
               BEGIN NULL; END;
          PROCEDURE A7 (X7 : REC52 := REC52((F_REC52))) IS
               BEGIN NULL; END;
          PROCEDURE A8 (X8 : REC53 := REC53((F_REC53))) IS
               BEGIN NULL; END;

          PROCEDURE B1 (Y1 : P1 := P1'(CP1)) IS
               BEGIN NULL; END;
          PROCEDURE B2 (Y2 : LP2 := LP2'(CLP2)) IS
               BEGIN NULL; END;
          PROCEDURE B3 (Y3 : SP1 := SP1'(CP1)) IS
               BEGIN NULL; END;
          PROCEDURE B4 (Y4 : SLP2 := SLP2'(CLP2)) IS
               BEGIN NULL; END;
          PROCEDURE B5 (Y5 : ARR51 := ARR51'((CP1,CP1),(CP1,CP1))) IS
               BEGIN NULL; END;
          PROCEDURE B6 (Y6 : ARR52 := ARR52'((CLP2,CLP2),(CLP2,CLP2)))
               IS BEGIN NULL; END;
          PROCEDURE B7 (Y7 : ARR53 := ARR53'((CP1,CP1),(CP1,CP1))) IS
               BEGIN NULL; END;
          PROCEDURE B8 (Y8 : ARR54 := ARR54'((CLP2,CLP2),(CLP2,CLP2)))
               IS BEGIN NULL; END;
          PROCEDURE B9 (Y9 : REC51 := REC51'(C5 => (C1 => CP1))) IS
               BEGIN NULL; END;
          PROCEDURE B10 (Y10 : REC52 := REC52'(C6 => (C2 => CLP2))) IS
               BEGIN NULL; END;
          PROCEDURE B11 (Y11 : REC53 := REC53'(C7 => (C3 => CP1))) IS
               BEGIN NULL; END;
          PROCEDURE B12 (Y12 : REC54 := REC54'(C8 => (C4 => CLP2))) IS
               BEGIN NULL; END;
     END P;

BEGIN
     NULL;
END B74103H;
