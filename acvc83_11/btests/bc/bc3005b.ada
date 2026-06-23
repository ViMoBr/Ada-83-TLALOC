-- BC3005B.ADA

-- CHECK THAT, IN A GENERIC INSTANTIATION, THE ACTUAL PARAMETER 
-- CORRESPONDING TO A FORMAL TYPE CANNOT BE A SUBTYPE INDICATION 
-- WITH AN EXPLICIT RANGE CONSTRAINT, ACCURACY CONSTRAINT, INDEX 
-- CONSTRAINT, OR DISCRIMINANT CONSTRAINT.

-- PWB  03/06/86

PROCEDURE BC3005B IS

     TYPE FLOATING IS DIGITS 5 RANGE -10.0 .. 10.0;
     TYPE FIXED IS DELTA 0.25 RANGE -10.0 .. 10.0;
     TYPE ENUM IS (ONE, TWO, THREE);
     TYPE LIST IS ARRAY (INTEGER RANGE <>) OF ENUM;
     TYPE REC (DISC : INTEGER) IS RECORD
          NULL;
     END RECORD;

     GENERIC
          TYPE FORMAL IS (<>);
     PACKAGE DISCRETE_PACK IS
     END DISCRETE_PACK;

     GENERIC
          TYPE FORMAL IS DELTA <>;
     PACKAGE FIXED_PACK IS
     END FIXED_PACK;

     GENERIC
          TYPE FORMAL IS ARRAY (INTEGER RANGE <>) OF ENUM;
     PACKAGE ARRAY_PACK IS
     END ARRAY_PACK;

     GENERIC
          TYPE FORMAL IS RANGE <>;
     PROCEDURE INT_PROC;

     GENERIC
          TYPE FORMAL IS PRIVATE;
     PROCEDURE PRIV_PROC;

     GENERIC
          TYPE FORMAL IS DIGITS <>;
     FUNCTION FLOAT_FUNC RETURN BOOLEAN;

     GENERIC
          TYPE FORMAL IS LIMITED PRIVATE;
     FUNCTION LIM_FUNC RETURN BOOLEAN;

     PROCEDURE INT_PROC IS
     BEGIN
          NULL;
     END INT_PROC;

     PROCEDURE PRIV_PROC IS
     BEGIN
          NULL;
     END PRIV_PROC;

     FUNCTION FLOAT_FUNC RETURN BOOLEAN IS
     BEGIN
          RETURN TRUE;
     END FLOAT_FUNC;

     FUNCTION LIM_FUNC RETURN BOOLEAN IS
     BEGIN
          RETURN TRUE;
     END LIM_FUNC;

     PACKAGE DISCRETE_INST IS 
             NEW DISCRETE_PACK (ENUM RANGE ONE..TWO);   -- ERROR:
                                                        -- CONSTRAINT.

     PACKAGE FIXED_INST_1 IS
             NEW FIXED_PACK (FIXED RANGE -1.0..1.0);    -- ERROR:
                                                        -- CONSTRAINT.

     PACKAGE FIXED_INST_2 IS
             NEW FIXED_PACK (FIXED DELTA 0.5);          -- ERROR:
                                                        -- CONSTRAINT.

     PACKAGE ARRAY_INST IS 
             NEW ARRAY_PACK ( LIST(1..6) );             -- ERROR:
                                                        -- CONSTRAINT.

     PROCEDURE INT_INST IS
             NEW INT_PROC (INTEGER RANGE 0..100);       -- ERROR:
                                                        -- CONSTRAINT.

     PROCEDURE PRIV_INST_1 IS
             NEW PRIV_PROC ( REC(DISC=>0) );            -- ERROR:
                                                        -- CONSTRAINT.

     PROCEDURE PRIV_INST_2 IS
             NEW PRIV_PROC (FIXED DELTA 0.5);           -- ERROR:
                                                        -- CONSTRAINT.

     FUNCTION FLOAT_INST IS
             NEW FLOAT_FUNC (FLOATING RANGE -1.0..1.0); -- ERROR:
                                                        -- CONSTRAINT.

     FUNCTION LIM_INST_1 IS
             NEW LIM_FUNC ( REC(1) );                   -- ERROR:
                                                        -- CONSTRAINT.

     FUNCTION LIM_INST_2 IS
             NEW LIM_FUNC (FLOATING DIGITS 4);          -- ERROR:
                                                        -- CONSTRAINT.

BEGIN
     NULL;
END BC3005B;
