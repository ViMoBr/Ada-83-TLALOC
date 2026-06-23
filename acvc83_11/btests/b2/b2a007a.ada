-- B2A007A.ADA

-- CHECK THAT UNDERSCORES MAY NOT BE ADJACENT TO THE COLON IN BASED
-- LITERALS, WHEN USING A COLON IN PLACE OF THE SHARP SIGN.

-- TBN 2/27/86

PROCEDURE B2A007A IS

     TYPE FLOAT1 IS DIGITS 5;
     TYPE FLOAT2 IS DIGITS 2_:11: ;                            -- ERROR:
     TYPE MY_INT IS RANGE -10 .. 1_6_:AB:E1;                   -- ERROR:
     TYPE REC1 (DISC: INTEGER := 10:_29_182:) IS               -- ERROR:
          RECORD
               NULL;
          END RECORD;

     TYPE ARRAY1 IS ARRAY (INTEGER RANGE <>) OF BOOLEAN;
     OBJ_ARA1 : ARRAY1 (1 .. 2:1_11_:E1);                      -- ERROR:
     VAR1 : FLOAT1 := 16:F.F_EE_: ;                            -- ERROR:
     CON1 : CONSTANT FLOAT1 := 2:_1.01:E2;                     -- ERROR:
     VAR2 : INTEGER := 4:123:_E2;                              -- ERROR:
     INT1 : INTEGER := 2:1: ;
     FLO1 : FLOAT1 := 10:2.5:E1;
     CHAR1 : CHARACTER;

BEGIN

     IF INT1 > 2:11:_E1 OR                                     -- ERROR:
        FLO1 < 16_:F.F: THEN                                   -- ERROR:
           INT1 := 16:_1: ;                                    -- ERROR:
           FLO1 := 2:1.1:_ ;                                   -- ERROR:
     END IF;

     CASE INT1 IS
          WHEN 2:11:_E1 =>                                     -- ERROR:
               CHAR1 := CHARACTER'VAL(2:111:_E1);              -- ERROR:
          WHEN OTHERS =>
               NULL;
     END CASE;

END B2A007A;
