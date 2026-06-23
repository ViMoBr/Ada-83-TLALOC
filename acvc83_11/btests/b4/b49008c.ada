-- B49008C.ADA

-- CHECK THAT IN A STATIC EXPRESSION THE ARGUMENTS OF A FUNCTION CALL
-- CANNOT BE NONSTATIC EXPRESSIONS IF THE FUNCTION NAME IS AN OPERATOR
-- SYMBOL THAT DENOTES A PREDEFINED OPERATOR.

-- L.BROWN  08/27/86

PROCEDURE  B49008C  IS

     TYPE INT IS RANGE 1 .. 15;
     TYPE REAL IS DIGITS 5 RANGE 0.0 .. 25.0;
     OBJ_INT : INT := 5;
     OBJ_REAL : REAL := 3.0;
     CAS_OBJ1 : INT := 6;
     TYPE INT1 IS RANGE 1 .. "+"(1,OBJ_INT);                   -- ERROR:
     TYPE FIX IS DELTA 3.0*("+"(1.0,OBJ_REAL))                 -- ERROR:
                                    RANGE 0.0 .. 24.0;
     TYPE FIX1 IS DELTA 3.0 RANGE 0.0 .. "-"(5.0,OBJ_REAL);    -- ERROR:
BEGIN

     CASE CAS_OBJ1 IS
          WHEN "+"(1,OBJ_INT) =>                               -- ERROR:
               OBJ_INT := 6;
          WHEN OTHERS =>
               NULL;
     END CASE;

END B49008C;
