-- BC1102A.ADA

-- CHECK THAT GENERIC FORMAL IN OUT PARAMETER DECLARATIONS CANNOT HAVE
-- INITIALIZATIONS.

-- ASL 8/7/81
-- SPS 4/14/82

PROCEDURE BC1102A IS
 
     TYPE ENUM IS (X);
     E_CONST : CONSTANT ENUM := X;

     TYPE ARR_ENUM IS ARRAY(1..2) OF ENUM;
 
     TYPE REC_ENUM IS 
          RECORD
               COMP : ENUM;
          END RECORD;

     TASK TYPE T;
     T_OBJ : T;

     TYPE REC_TSK IS
          RECORD
               C : T;
          END RECORD;

     TYPE REC_2 IS
          RECORD
               C : REC_TSK;
          END RECORD;

     TYPE REC_2A IS
          RECORD
               D : REC_ENUM;
          END RECORD;

     TASK BODY T IS
     BEGIN
          NULL;
     END T;

     GENERIC
          F1 : IN OUT INTEGER := 5;                         -- ERROR: 
                                                   -- INITIALIZATION.
          F2 : IN OUT ENUM := E_CONST;                      -- ERROR:
                                                   -- INITIALIZATION.
          F3 : IN OUT ARR_ENUM := (1..2 => E_CONST);        -- ERROR: 
                                                   -- INITIALIZATION.
          F4 : IN OUT REC_ENUM := (COMP => E_CONST);        -- ERROR: 
                                                   -- INITIALIZATION.
          F5 : IN OUT T := T_OBJ;                           -- ERROR: 
                                                   -- INITIALIZATION.
          F6 : IN OUT REC_TSK := (C => T_OBJ);              -- ERROR: 
                                                   -- INITIALIZATION.
          F7 : IN OUT REC_2 := (C => (C => T_OBJ));         -- ERROR: 
                                                   -- INITIALIZATION.
          F8 : IN OUT REC_2A := (D => (COMP => E_CONST));   -- ERROR: 
                                                   -- INITIALIZATION.
     PACKAGE Q IS
     END Q;
BEGIN
     NULL;
END BC1102A;
