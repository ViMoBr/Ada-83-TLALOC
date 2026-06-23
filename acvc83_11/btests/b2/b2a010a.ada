-- B2A010A.ADA

-- CHECK THAT A BASED LITERAL CANNOT START WITH A SHARP SIGN AND END 
-- WITH A COLON OR VICE VERSA.

-- TBN 2/27/86

PROCEDURE B2A010A IS

     TYPE FLOAT1 IS DIGITS 5;
     TYPE FLOAT2 IS DIGITS 2#11: ;                             -- ERROR:
     TYPE MY_INT IS RANGE -10 .. 1_6:AB#E1;                    -- ERROR:
     TYPE REC1 (DISC: INTEGER := 10#29_182:) IS                -- ERROR:
          RECORD
               NULL;
          END RECORD;

     TYPE ARRAY1 IS ARRAY (INTEGER RANGE <>) OF BOOLEAN;
     OBJ_ARA1 : ARRAY1 (1 .. 2:1_11#E1);                       -- ERROR:
     VAR1 : FLOAT1 := 16#F.F_EE: ;                             -- ERROR:
     CON1 : CONSTANT FLOAT1 := 2:1.01#E2;                      -- ERROR:
     VAR2 : INTEGER := 4#123:E2;                               -- ERROR:
     INT1 : INTEGER := 2#1# ;
     FLO1 : FLOAT1 := 10:2.5:E1;
     CHAR1 : CHARACTER;

BEGIN

     IF INT1 > 2:11#E1 OR                                      -- ERROR:
        FLO1 < 16#F.F: THEN                                    -- ERROR:
          INT1 := 16#1: ;                                      -- ERROR:
          FLO1 := 2:1.1# ;                                     -- ERROR:
     END IF;

     CASE INT1 IS
          WHEN 2:11# =>                                        -- ERROR:
               CHAR1 := CHARACTER'VAL(2#111:E1);               -- ERROR:
          WHEN OTHERS =>
               NULL;
     END CASE;

END B2A010A;
