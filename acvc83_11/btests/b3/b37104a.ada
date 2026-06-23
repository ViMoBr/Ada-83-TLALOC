-- B37104A.ADA

-- CHECK THAT A DISCRIMINANT'S DEFAULT INITIAL VALUE MUST HAVE THE
-- SAME TYPE AS THE DISCRIMINANT.

-- RJW 2/27/86 

PROCEDURE B37104A IS
     
     TYPE CHAR1 IS NEW CHARACTER;
     TYPE CHAR2 IS NEW CHARACTER;
     
     C1 : CHAR1 := 'A';
     C2 : CHAR2 := 'A';

     TYPE REC1 (DISC1 : CHAR1 := C2;        -- ERROR: DIFFERENT TYPES.
                DISC2 : CHAR2 := C1) IS     -- ERROR: DIFFERENT TYPES.
          RECORD
               NULL;
          END RECORD;
     
     TYPE INT IS RANGE 1 .. 10;
     I : INT := 1;

     TYPE REC2 (DISC : INTEGER := I) IS     -- ERROR: DIFFERENT TYPES.
          RECORD
               NULL;
          END RECORD;
     
     TYPE TBOOL IS NEW BOOLEAN;
     
     TYPE REC3 (T : TBOOL := BOOLEAN'(FALSE)) IS  -- ERROR: DIFFERENT 
                                                  --        TYPES.
          RECORD
               NULL;
          END RECORD;

     TYPE ENUM1 IS (A, B, C);
     TYPE ENUM2 IS (C, D, E);

     E1 : ENUM1 := A;
     E2 : ENUM2 := E;

     TYPE REC4 (DISC1 : ENUM1 := E2;        -- ERROR: DIFFERENT TYPES.
                DISC2 : ENUM2 := E1) IS     -- ERROR: DIFFERENT TYPES.
          RECORD
               NULL;
          END RECORD;
BEGIN
     NULL;          
END B37104A;                                
