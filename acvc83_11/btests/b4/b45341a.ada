-- B45341A.ADA

-- CHECK THAT '&' IS NOT PREDEFINED FOR MULTIDIMENSIONAL ARRAYS 
-- OR FOR ARRAYS HAVING A LIMITED COMPONENT TYPE.

-- RJW 2/10/86

PROCEDURE B45341A IS
     
BEGIN

     DECLARE
          TYPE ARR IS ARRAY( 1 .. 2, 1 .. 2 ) OF CHARACTER;

          A : ARR := (OTHERS => (OTHERS => 'A'));
          B : ARR := (OTHERS => (OTHERS => 'B'));
     BEGIN
          A := A & B;               -- ERROR: INVALID TYPES FOR '&'.
     END;

     DECLARE
          PACKAGE PKG IS
               TYPE ARR1 IS LIMITED PRIVATE;
               TYPE CHAR IS LIMITED PRIVATE;
               TYPE ARR2 IS ARRAY(1 .. 2) OF CHAR;
          PRIVATE
               TYPE CHAR IS NEW CHARACTER;
               TYPE ARR1 IS ARRAY(1 .. 2) OF CHARACTER;
          END PKG;

          USE PKG;

          A1, B1 : ARR1;
          A2, B2 : ARR2;

     BEGIN
          A1 := A1 & B1;            -- ERROR: INVALID TYPES FOR '&'.
          A2 := A2 & B2;            -- ERROR: INVALID TYPES FOR '&'.
     END;

END B45341A;
