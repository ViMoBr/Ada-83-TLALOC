-- B45302A.ADA

-- CHECK THAT '&' IS NOT PREDEFINED FOR MULTIDIMENSIONAL ARRAYS HAVING
-- THE SAME TYPE OR FOR ONE DIMENSIONAL ARRAYS RELATED BY DERIVATION
-- (INCLUDING DERIVED INDEX TYPES).

-- RJW 2/8/86

PROCEDURE B45302A IS
     
BEGIN

     DECLARE
          TYPE ARR IS ARRAY( 1 .. 2, 1 .. 2 ) OF CHARACTER;

          A : ARR := ( OTHERS => ( OTHERS => 'A' ));
          B : ARR := ( OTHERS => ( OTHERS => 'A' ));
     BEGIN
          A := A & B;               -- ERROR : MULTI-DIM TYPES FOR '&'.
     END;

     DECLARE
          TYPE ARR1 IS ARRAY ( 1 .. 1 ) OF CHARACTER;
          TYPE ARR2 IS NEW ARR1;
          TYPE INT  IS  NEW INTEGER RANGE 1 .. 1;          
          TYPE ARR3 IS ARRAY ( INT ) OF CHARACTER;
          TYPE CHAR IS NEW CHARACTER;
          TYPE ARR4 IS ARRAY ( 1 .. 1 ) OF CHAR;
          TYPE ARR5 IS ARRAY ( 1 .. 1 ) OF CHARACTER;
          
          A1 : ARR1 := "A"; 
          A2 : ARR2 := "A";  
          A3 : ARR3 := "A";  
          A4 : ARR4 := "A";  
          A5 : ARR5 := "A";  
     BEGIN
          A1 := A1 & A2;            -- ERROR : DIFFERENT TYPES FOR '&'.
          A1 := A1 & A3;            -- ERROR : DIFFERENT TYPES FOR '&'.
          A1 := A1 & A4;            -- ERROR : DIFFERENT TYPES FOR '&'.
          A1 := A1 & A5;            -- ERROR : DIFFERENT TYPES FOR '&'.
     END;

END B45302A;
