-- CC3123B.ADA

-- CHECK THAT DEFAULT EXPRESSIONS FOR GENERIC IN PARAMETERS ARE
-- EVALUATED IN THE ORDER GIVEN BY THE DECLARATION.

-- TBN  12/03/86

WITH REPORT; USE REPORT;
PROCEDURE CC3123B IS

     FUNCTION_CALL_COUNT : INTEGER := 0;

     FUNCTION F RETURN INTEGER IS
     BEGIN
          FUNCTION_CALL_COUNT := FUNCTION_CALL_COUNT + IDENT_INT(1);
          RETURN (FUNCTION_CALL_COUNT);
     END;

BEGIN
     TEST ("CC3123B", "CHECK THAT DEFAULT EXPRESSIONS FOR GENERIC " &
                      "IN PARAMETERS ARE EVALUATED IN THE ORDER " &
                      "GIVEN BY THE DECLARATION");
     DECLARE
          TYPE ARA1 IS ARRAY (1 .. 5) OF INTEGER;
          TYPE REC IS
               RECORD
                    A : INTEGER;
                    B : ARA1;
               END RECORD;
          TYPE ARA2 IS ARRAY (1 .. 2) OF REC;

          GENERIC
               GEN_INT1 : IN ARA2 := (1..2 => (F, (1, 2, 3, 4, 5)));
               GEN_INT2 : IN INTEGER := F;
               GEN_INT3 : IN REC := (1, (F, 2, 3, 4, 5));
               GEN_INT4 : IN ARA1 := (1, 2, 3, 4, F);
          PACKAGE P IS
               PAC_INT2 : INTEGER := GEN_INT2;
               PAC_INT4 : ARA1 := GEN_INT4;
               PAC_INT3 : REC := GEN_INT3;
               PAC_INT1 : ARA2 := GEN_INT1;
          END P;

          PACKAGE NEW_P IS NEW P;
          USE NEW_P;
     BEGIN
          IF PAC_INT1(1) /= (IDENT_INT(1), (1, 2, 3, 4, 5)) OR
               PAC_INT1(2) /= (IDENT_INT(2), (1, 2, 3, 4, 5)) THEN
               FAILED ("DEFAULTS NOT EVALUATED IN CORRECT ORDER - 1");
          END IF;
          IF PAC_INT2 /= IDENT_INT(3) THEN
               FAILED ("DEFAULTS NOT EVALUATED IN CORRECT ORDER - 2");
          END IF;
          IF PAC_INT3 /= (1, (IDENT_INT(4), 2, 3, 4, 5)) THEN
               FAILED ("DEFAULTS NOT EVALUATED IN CORRECT ORDER - 3");
          END IF;
          IF PAC_INT4 /= (1, 2, 3, 4, IDENT_INT(5)) THEN
               FAILED ("DEFAULTS NOT EVALUATED IN CORRECT ORDER - 4");
          END IF;
     END;

     -------------------------------------------------------------------
     DECLARE
          TYPE COLOR IS (R, W, B, G, Y, P);
          CALL_COLOR : COLOR := R;

          TYPE ARA1 IS ARRAY (1 .. 5) OF COLOR;
          TYPE REC IS
               RECORD
                    A : COLOR;
                    B : ARA1;
               END RECORD;
          TYPE ARA2 IS ARRAY (1 .. 2) OF REC;

          FUNCTION FC RETURN COLOR;

          GENERIC
               GEN_COL1 : IN ARA2 := (1..2 => (FC, (1..5 => R)));
               GEN_COL2 : IN COLOR := FC;
               GEN_COL3 : IN REC := (R, (FC, G, Y, R, P));
               GEN_COL4 : IN ARA1 := (R, G, W, B, FC);
          PACKAGE Q IS
               PAC_COL2 : COLOR := GEN_COL2;
               PAC_COL4 : ARA1 := GEN_COL4;
               PAC_COL3 : REC := GEN_COL3;
               PAC_COL1 : ARA2 := GEN_COL1;
          END Q;

          FUNCTION FC RETURN COLOR IS
          BEGIN
               CALL_COLOR := COLOR'SUCC(CALL_COLOR);
               RETURN CALL_COLOR;
          END FC;

          PACKAGE NEW_Q IS NEW Q;
          USE NEW_Q;
     BEGIN
          IF PAC_COL1(1) /= (W, (1..5 => R)) OR
               PAC_COL1(2) /= (B, (1..5 => R)) THEN
               FAILED ("DEFAULTS NOT EVALUATED IN CORRECT ORDER - 5");
          END IF;
          IF PAC_COL2 /= G THEN
               FAILED ("DEFAULTS NOT EVALUATED IN CORRECT ORDER - 6");
          END IF;
          IF PAC_COL3 /= (R, (Y, G, Y, R, P)) THEN
               FAILED ("DEFAULTS NOT EVALUATED IN CORRECT ORDER - 7");
          END IF;
          IF PAC_COL4 /= (R, G, W, B, P) THEN
               FAILED ("DEFAULTS NOT EVALUATED IN CORRECT ORDER - 8");
          END IF;
     END;

     -------------------------------------------------------------------
     FUNCTION_CALL_COUNT := 0;

     DECLARE
          TYPE ARA1 IS ARRAY (1 .. 5) OF INTEGER;
          TYPE REC IS
               RECORD
                    A : INTEGER;
                    B : ARA1;
               END RECORD;
          TYPE ARA2 IS ARRAY (1 .. 2) OF REC;

          OBJ_INT : INTEGER := 1;

          GENERIC
               GEN_INT1 : IN ARA1 := (1, 2, 3, 4, F);
               GEN_INT2 : IN ARA2 := (1..2 => (F, GEN_INT1));
               GEN_INT3 : IN INTEGER := F;
               GEN_INT4 : IN REC := (1, (GEN_INT3, 2, 3, 4, F));
          PACKAGE P IS
               PAC_INT3 : INTEGER := GEN_INT3;
               PAC_INT1 : ARA1 := GEN_INT1;
               PAC_INT4 : REC := GEN_INT4;
               PAC_INT2 : ARA2 := GEN_INT2;
          END P;

          PACKAGE NEW_P IS NEW P(GEN_INT3 => F);
          USE NEW_P;
     BEGIN
          IF PAC_INT1 /= (1, 2, 3, 4, IDENT_INT(2)) THEN
               FAILED ("DEFAULTS NOT EVALUATED IN CORRECT ORDER - 9");
          END IF;
          IF PAC_INT2(1) /= (IDENT_INT(3), (1, 2, 3, 4, 2)) OR
               PAC_INT2(2) /= (IDENT_INT(4), (1, 2, 3, 4, 2)) THEN
               FAILED ("DEFAULTS NOT EVALUATED IN CORRECT ORDER - 10");
          END IF;
          IF PAC_INT3 /= IDENT_INT(1) THEN
               FAILED ("ACTUAL EXPRESSION NOT EVALUATED FIRST - 11");
          END IF;
          IF PAC_INT4 /= (1, (1, 2, 3, 4, IDENT_INT(5))) THEN
               FAILED ("DEFAULTS NOT EVALUATED IN CORRECT ORDER - 12");
          END IF;
     END;

     RESULT;
END CC3123B;
