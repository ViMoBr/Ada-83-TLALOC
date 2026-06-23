-- CC3015A.ADA

-- CHECK THAT WHEN A GENERIC PACKAGE INSTANTIATION IS ELABORATED, 
-- STATEMENTS IN ITS PACKAGE BODY ARE EXECUTED AND EXPRESSIONS
-- REQUIRING EVALUATION ARE EVALUATED (E.G., DEFAULTS FOR OBJECT
-- DECLARATIONS ARE EVALUATED).

-- RJW 6/11/86

WITH REPORT; USE REPORT;

PROCEDURE CC3015A IS
     BOOL1, BOOL2 : BOOLEAN := FALSE;          
          
     TYPE ENUM IS (BEFORE, AFTER);

     FUNCTION F (I : INTEGER) RETURN INTEGER IS
     BEGIN
          BOOL2 := TRUE;
          RETURN I;
     END;
          
     FUNCTION CHECK (E : ENUM) RETURN CHARACTER IS
     BEGIN
          IF E = BEFORE THEN
               IF BOOL1 THEN
                    FAILED ( "STATEMENT EXECUTED BEFORE " &
                             "INSTANTIATION" );
               END IF;
               IF BOOL2 THEN
                    FAILED ( "DEFAULT EXPRESSION EVALUATED " &
                             "BEFORE INSTANTIATION" );
               END IF;
          ELSE
               IF BOOL1 THEN
                    NULL;
               ELSE
                    FAILED ( "STATEMENT NOT EXECUTED AT " &
                             "INSTANTIATION" );
               END IF;
               IF BOOL2 THEN
                    NULL;
               ELSE
                    FAILED ( "DEFAULT EXPRESSION NOT EVALUATED " &
                             "AT INSTANTIATION" );
               END IF;
          END IF;
          RETURN 'A';
      END;

     GENERIC 
          TYPE INT IS RANGE <>;
     PACKAGE PKG IS END PKG;

     PACKAGE BODY PKG IS
          I : INT := INT'VAL (F(0));
     BEGIN
          BOOL1 := TRUE;
     END;
                         
BEGIN
     TEST ("CC3015A", "CHECK THAT WHEN A GENERIC PACKAGE " & 
                      "INSTANTIATION IS ELABORATED, STATEMENTS " & 
                      "IN ITS PACKAGE BODY ARE EXECUTED AND " &
                      "EXPRESSIONS REQUIRING EVALUATION ARE " &
                      "EVALUATED (E.G., DEFAULTS FOR OBJECT " &
                      "DECLARATIONS ARE EVALUATED)" );
     

     DECLARE
          A : CHARACTER := CHECK (BEFORE);

          PACKAGE NPKG IS NEW PKG (INTEGER);
     
          B : CHARACTER := CHECK (AFTER);

     BEGIN
          NULL;
     END;          

     RESULT;
END CC3015A;
