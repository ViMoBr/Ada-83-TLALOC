-- BC1104A.ADA

-- CHECK THAT GENERIC FORMAL IN PARAMETER
-- DECLARATIONS WITH LIMITED PRIVATE TYPES OR ARRAYS OR RECORDS WITH
-- LIMITED PRIVATE TYPES ARE FORBIDDEN.
 
-- ASL 8/7/81
-- SPS 10/21/82

PROCEDURE BC1104A IS
 
     PACKAGE P IS
          TYPE LP IS LIMITED PRIVATE;
     PRIVATE
          TYPE LP IS (X);
     END P;
 
     USE P;
 
     TYPE ARR_LP IS ARRAY(1..2) OF LP;
 
     TYPE REC_LP IS 
          RECORD
               COMP : LP;
          END RECORD;

     TYPE REC_2A IS
          RECORD
               D : REC_LP;
          END RECORD;

     GENERIC
          F1 : IN INTEGER ;                  -- OK
          F2 : LP ;                          -- ERROR: LIM PRIV.
          F3 : ARR_LP ;                      -- ERROR: LIM PRIV.
          F4 : REC_LP ;                      -- ERROR: LIM PRIV.
         
     PACKAGE Q IS
     END Q;

BEGIN
     NULL;
END BC1104A;
