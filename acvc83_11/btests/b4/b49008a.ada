-- B49008A.ADA

-- CHECK THAT A STATIC EXPRESSION CANNOT CONTAIN A CALL TO A 
-- USER-DEFINED OPERATOR, NOR CAN THE NAME IN THE FUNCTION CALL BE AN 
-- IDENTIFIER, EVEN IF THE IDENTIFIER DENOTES A PREDEFINED OPERATOR.

-- L.BROWN   08/27/86

PROCEDURE  B49008A  IS

     TYPE INT IS RANGE 1 .. 25;
     TYPE REAL IS DIGITS 5;
     FUNCTION "&"(X,Y : INT) RETURN INT IS
          BEGIN
               RETURN X + Y;
          END "&";
     FUNCTION "/"(X,Y : REAL) RETURN REAL IS
          BEGIN
               RETURN X - Y;
          END "/";
BEGIN
     DECLARE
          TYPE INT1 IS RANGE 1 .. 2&5;                         -- ERROR:
          CAS_OBJ : INT := 7;
          TYPE FIX IS DELTA 3.0*(REAL'(5.0)/REAL'(4.0))        -- ERROR:
                         RANGE 0.0 .. 10.0;
     BEGIN
          NULL;
     END;

     DECLARE
          FUNCTION SUM(X,Y : INT) RETURN INT RENAMES "+";
          CAS_OBJ : INT := 7;
          CAS_OBJ1 : INTEGER := 7;
          FUNCTION DIVIDE(X,Y : INTEGER) RETURN INTEGER
                          RENAMES "-";
          TYPE FIX IS DIGITS 3*DIVIDE(5,4)                     -- ERROR:
                          RANGE 0.0 .. 10.0;   
     BEGIN
          CASE CAS_OBJ IS
               WHEN SUM(3,4) =>                                -- ERROR:
                    CAS_OBJ := 10;
               WHEN OTHERS =>
                    NULL;
          END CASE;
     END;

END B49008A;
