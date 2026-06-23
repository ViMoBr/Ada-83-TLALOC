-- C37010B.ADA

-- CHECK THAT EXPRESSIONS IN AN INDEX CONSTRAINT OR DISCRIMINANT 
-- CONSTRAINT ARE EVALUATED WHEN THE COMPONENT DECLARATION IS 
-- ELABORATED EVEN IF SOME BOUNDS OR DISCRIMINANTS ARE GIVEN BY
-- A DISCRIMINANT OF AN ENCLOSING RECORD TYPE.

-- R.WILLIAMS 8/22/86

WITH REPORT; USE REPORT;
PROCEDURE C37010B IS
     
     INIT :INTEGER := IDENT_INT (5);

     TYPE R (D1, D2 : INTEGER) IS
          RECORD
               NULL;
          END RECORD;

     TYPE ACCR IS ACCESS R;

     TYPE ARR IS ARRAY (INTEGER RANGE <> ) OF INTEGER;

     TYPE ACCA IS ACCESS ARR;

     FUNCTION RESET (N : INTEGER) RETURN INTEGER IS
     BEGIN
          INIT := IDENT_INT (N);
          RETURN N;
     END RESET;

BEGIN
     TEST ( "C37010B", "CHECK THAT EXPRESSIONS IN AN INDEX " &
                       "CONSTRAINT OR DISCRIMINANT CONSTRAINT " &
                       "ARE EVALUATED WHEN THE COMPONENT " &
                       "DECLARATION IS ELABORATED EVEN IF SOME " &
                       "BOUNDS OR DISCRIMINANTS ARE GIVEN BY " &
                       "A DISCRIMINANT OF AN ENCLOSING RECORD TYPE" );

     DECLARE
          
          TYPE REC1 (D : INTEGER) IS 
               RECORD
                    W1 : R (D1 => INIT, D2 => D);
                    X1 : ARR (INIT .. D);
                    Y1 : ACCR (D, INIT);
                    Z1 : ACCA (D .. INIT);
               END RECORD;
          
          INT1 : INTEGER := RESET (10);

          R1 : REC1 (D => 4);

     BEGIN
          IF R1.W1.D1 /= 5 THEN 
               FAILED ( "INCORRECT VALUE FOR R1.W1.D1" );
          END IF;
     
          IF R1.W1.D2 /= 4 THEN 
               FAILED ( "INCORRECT VALUE FOR R1.W1.D2" );
          END IF;

          IF R1.X1'FIRST /= 5 THEN
               FAILED ( "INCORRECT VALUE FOR R1.X1'FIRST" );
          END IF;

          IF R1.X1'LAST /= 4 THEN
               FAILED ( "INCORRECT VALUE FOR R1.X1'LAST" );
          END IF;

          BEGIN
               R1.Y1 := NEW R (4, 5);
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ( "INCORRECT VALUE FOR R1.Y1" );
          END;

          BEGIN
               R1.Z1 := NEW ARR (4 .. 5);
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ( "INCORRECT VALUE FOR R1.Z1" );
          END;
                    
     END;

     DECLARE
          
          TYPE REC2 (D : INTEGER) IS
               RECORD
                    CASE D IS
                         WHEN 1 =>
                              NULL;
                         WHEN 2 =>
                              NULL;
                         WHEN OTHERS =>
                              W2 : R (D1 => D, D2 => INIT);
                              X2 : ARR (D .. INIT);
                              Y2 : ACCR (INIT, D);
                              Z2 : ACCA (D .. INIT);
                    END CASE;                     
               END RECORD;

          INT2 : INTEGER := RESET (20);

          R2 : REC2 (D => 6);

     BEGIN
          IF R2.W2.D1 /= 6 THEN 
               FAILED ( "INCORRECT VALUE FOR R2.W2.D1" );
          END IF;

          IF R2.W2.D2 /= 10 THEN 
               FAILED ( "INCORRECT VALUE FOR R2.W2.D2" );
          END IF;

          IF R2.X2'FIRST /= 6 THEN
               FAILED ( "INCORRECT VALUE FOR R2.X2'FIRST" );
          END IF;

          IF R2.X2'LAST /= 10 THEN
               FAILED ( "INCORRECT VALUE FOR R2.X2'LAST" );
          END IF;

          BEGIN
               R2.Y2 := NEW R (10, 6);
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ( "INCORRECT VALUE FOR R2.Y2" );
          END;

          BEGIN
               R2.Z2 := NEW ARR (6 .. 10);
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ( "INCORRECT VALUE FOR R2.Z2" );
          END;
                    
     END;

     RESULT;
END C37010B;
