-- B25004B.ADA

-- CHECK THAT THE TYPE OF AN OVERLOADED CHARACTER LITERAL IS CORRECTLY 
-- DETERMINED, USING THE VISIBILITY OF ENUMERATION TYPES AND OPERATIONS
-- ON THESE TYPES.

-- TBN 3/20/86

PROCEDURE B25004B IS

     TYPE ENUM IS ('A', 'B', 'C');

     V_ENUM : ENUM := 'A';
     CHAR : CHARACTER := 'A';
     BOOL_1 : BOOLEAN := 'A' = 'D';
     BOOL_2 : BOOLEAN := 'A' = 'A';                 -- ERROR: AMBIGUITY.
     BOOL_3 : BOOLEAN := 'C' < 'D';
     BOOL_4 : BOOLEAN := 'B' > 'C';                 -- ERROR: AMBIGUITY.

BEGIN

     IF 'A' = 'D' THEN
          NULL;
     ELSIF 'A' = 'A' THEN                           -- ERROR: AMBIGUITY.
          NULL;
     END IF;

     CHAR := 'C';
     V_ENUM := ENUM'SUCC ('B');

     BOOL_1 := 'A' < 'C';                           -- ERROR: AMBIGUITY.
     BOOL_3 := 'B' > 'F';

END B25004B;
