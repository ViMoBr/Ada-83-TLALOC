-- C37102B.ADA

-- CHECK THAT, FOR A RECORD TYPE, THE IDENTIFIER FOR A DISCRIMINANT 
-- CAN BE USED AS A SELECTED COMPONENT IN AN INDEX OR DISCRIMINANT 
-- CONSTRAINT, AS THE NAME OF A DISCRIMINANT IN A DISCRIMINANT 
-- SPECIFICATION, AND AS THE PARAMETER NAME IN A FUNCTION CALL IN A 
-- DISCRIMINANT OR INDEX CONSTRAINT.

-- R.WILLIAMS 8/25/86

WITH REPORT; USE REPORT;
PROCEDURE C37102B IS
     
BEGIN
     TEST ( "C37102B", "CHECK THAT, FOR A RECORD TYPE, THE " &
                       "IDENTIFIER FOR A DISCRIMINANT CAN BE USED " &
                       "AS A SELECTED COMPONENT IN AN INDEX OR " &
                       "DISCRIMINANT CONSTRAINT, AS THE NAME OF A " &
                       "DISCRIMINANT IN A DISCRIMINANT " &
                       "SPECIFICATION, AND AS THE PARAMETER NAME " &
                       "IN A FUNCTION CALL IN A DISCRIMINANT OR " &
                       "INDEX CONSTRAINT" );

     DECLARE

          FUNCTION F (D : INTEGER) RETURN INTEGER IS
          BEGIN
               RETURN IDENT_INT (D);
          END F;

          PACKAGE P IS

               TYPE D IS NEW INTEGER;
          
               TYPE REC1 IS
                    RECORD
                         D : INTEGER := IDENT_INT (1);
                    END RECORD;

               G : REC1;

               TYPE REC2 (D : INTEGER := 3) IS
                    RECORD
                         NULL;
                    END RECORD;

               H : REC2 (IDENT_INT (5));

               TYPE ARR IS ARRAY (INTEGER RANGE <>) OF INTEGER;

               TYPE Q (D : INTEGER := 0) IS
                    RECORD
                         J : REC2 (D => H.D);
                         K : ARR (G.D .. F (D => 5));
                         L : REC2 (F (D => 4));
                    END RECORD;
               
          END P;

          USE P;

     BEGIN
          DECLARE
               R : Q;
          
          BEGIN
               IF R.J.D /= 5 THEN
                    FAILED ( "INCORRECT VALUE FOR R.J" );
               END IF;
               
               IF R.K'FIRST /= 1 THEN
                    FAILED ( "INCORRECT VALUE FOR R.K'FIRST" );
               END IF;

               IF R.K'LAST /= 5 THEN
                    FAILED ( "INCORRECT VALUE FOR R.K'LAST" );
               END IF;

               IF R.L.D /= 4 THEN
                    FAILED ( "INCORRECT VALUE FOR R.L" );
               END IF;
          END;
        
     END;

     RESULT;
END C37102B;
