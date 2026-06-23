-- C87B24B.ADA
 
-- CHECK THAT OVERLOADING RESOLUTION USES THE RULE THAT:
    
-- THE RANGE BOUNDS FOR A SLICE MUST BE DISCRETE AND OF THE SAME BASE
-- TYPE AS THE ARRAY INDEX.
  
-- TRH  15 JULY 82
  
WITH REPORT; USE REPORT;
   
PROCEDURE C87B24B IS
 
     TYPE PIECE IS ARRAY (INTEGER RANGE <>) OF INTEGER;
 
     PI  : PIECE (1 .. 8) := (3, 1, 4, 1, 5, 9, 2, 6);
     S1  : PIECE (1 .. 3);
     S2  : PIECE (4 .. 8);
     ERR : BOOLEAN := FALSE;
       
     FUNCTION F1 (X : INTEGER) RETURN INTEGER IS
     BEGIN 
          RETURN X;
     END F1;
       
     FUNCTION F1 (X : INTEGER) RETURN FLOAT IS
     BEGIN 
          ERR := TRUE;
          RETURN 0.0;
     END F1;
    
     FUNCTION F2 (X : INTEGER) RETURN INTEGER IS
     BEGIN 
          RETURN X;
     END F2;
    
     FUNCTION F2 (X :INTEGER) RETURN CHARACTER IS
     BEGIN 
          ERR := TRUE;
          RETURN 'A';
     END F2;
    
BEGIN
     TEST ("C87B24B","OVERLOADING RESOLUTION OF RANGE " &
           "CONSTRAINTS FOR SLICES");
 
     DECLARE
          FUNCTION "+" (X : INTEGER) RETURN INTEGER 
               RENAMES F1;
   
          FUNCTION "+" (X : INTEGER) RETURN FLOAT 
               RENAMES F1;
   
          FUNCTION "-" (X : INTEGER) RETURN INTEGER 
               RENAMES F2;
 
          FUNCTION "-" (X : INTEGER) RETURN CHARACTER
               RENAMES F2;
  
     BEGIN 
          S1 := PI ("+" (3) .. "-" (5));
          S1 := PI (F2  (2) .. "+" (4));
          S1 := PI ("-" (6) .. F1  (8));
          S1 := PI (F2  (1) .. F2  (3));
          S2 := PI (F2  (4) .. F1  (8));
          S2 := PI (2       .. "+" (6));
          S2 := PI (F1  (1) ..       5);
          S2 := PI ("+" (3) .. "+" (7));
  
          IF ERR THEN
               FAILED (" OVERLOADING RESOLUTION INCORRECT FOR SLICES");
          END IF;
     END;
 
     RESULT;
END C87B24B;
