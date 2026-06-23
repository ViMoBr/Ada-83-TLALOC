-- B35302A.ADA

-- CHECK THAT A TYPE HAVING JUST THE ENUMERATION LITERALS 'TRUE' AND
-- 'FALSE' IS NOT CONSIDERED TO BE A BOOLEAN TYPE.

-- RJW 2/14/86

PROCEDURE B35302A IS

     TYPE BOOL IS (FALSE, TRUE);
     B : BOOL :=FALSE;

BEGIN
     IF BOOL'(TRUE) THEN                     -- ERROR: INVALID TYPE 
                                             --        FOR CONDITION.
          NULL;
     ELSIF BOOL'(FALSE) THEN                 -- ERROR: INVALID TYPE 
                                             --        FOR CONDITION.
          NULL;
     END IF;
          
     WHILE BOOL'(TRUE) LOOP                  -- ERROR: INVALID TYPE 
                                             --        FOR CONDITION.
          EXIT WHEN BOOL'(FALSE);            -- ERROR: INVALID TYPE 
                                             --        FOR CONDITION.
     END LOOP;

     B := BOOL'(TRUE) AND BOOL'(FALSE);      -- ERROR: INVALID TYPES 
                                             --        FOR 'AND'.
     B := BOOL'(TRUE) OR  BOOL'(FALSE);      -- ERROR: INVALID TYPES 
                                             --        FOR 'OR'.
     B := BOOL'(TRUE) XOR BOOL'(FALSE);      -- ERROR: INVALID TYPES 
                                             --        FOR 'XOR'.
     B := NOT BOOL'(TRUE);                   -- ERROR: INVALID TYPES 
                                             --        FOR 'NOT'.
     B := BOOL'(TRUE) AND THEN BOOL'(FALSE); -- ERROR: INVALID TYPES 
                                             --        FOR 'AND THEN'.
     B := BOOL'(TRUE) OR ELSE BOOL'(FALSE);  -- ERROR: INVALID TYPES 
                                             --        FOR 'OR ELSE'.
     
     B := (B = B);                           -- ERROR: 'B' NOT BOOLEAN.
     B := (2 >= 1);                          -- ERROR: 'B' NOT BOOLEAN.
     B := (TRUE IN BOOL);                    -- ERROR: 'B' NOT BOOLEAN.

END B35302A;
