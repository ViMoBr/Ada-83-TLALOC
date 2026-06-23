-- BC1104B.ADA

-- CHECK THAT GENERIC FORMAL IN PARAMETER DECLARATIONS WITH TASK TYPES
-- OR ARRAYS OR RECORDS WITH TASK COMPONENTS ARE FORBIDDEN.

-- ASL 8/7/81

PROCEDURE BC1104B IS
 
     TASK TYPE T;
     T1 : T;
 
     TYPE ARR_T IS ARRAY(1..2) OF T;

     TYPE REC_T IS 
          RECORD
               COMP : T;
          END RECORD;

     RT : REC_T;

     TASK BODY T IS
     BEGIN
          NULL;
     END T;

     GENERIC
          F1 : T ;                           -- ERROR: LIMITED TYPE.
          F2 : ARR_T ;                       -- ERROR: LIMITED TYPE.
          F3 : REC_T ;                       -- ERROR: LIMITED TYPE.
          F4 : REC_T ;                       -- ERROR: LIMITED TYPE.
     PACKAGE P IS
     END P;
BEGIN 
     NULL;
END BC1104B;
