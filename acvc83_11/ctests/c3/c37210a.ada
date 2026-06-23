-- C37210A.ADA

-- CHECK THAT THE EXPRESSION IN A DISCRIMINANT ASSOCIATION WITH MORE 
-- THAN ONE NAME IS EVALUATED ONCE FOR EACH NAME.

-- R.WILLIAMS 8/28/86

WITH REPORT; USE REPORT;
PROCEDURE C37210A IS

     BUMP : INTEGER := IDENT_INT (0);

     FUNCTION F RETURN INTEGER IS
     BEGIN
          BUMP := BUMP + 1;
          RETURN BUMP;
     END F;

     FUNCTION CHECK (STR : STRING) RETURN INTEGER IS
     BEGIN
          IF BUMP /= 2 THEN
               FAILED ( "INCORRECT DISCRIMINANT VALUES FOR " & STR);
          END IF;
          BUMP := IDENT_INT (0);
          RETURN 5;
     END CHECK;
          
BEGIN
     TEST ( "C37210A", "CHECK THAT THE EXPRESSION IN A " &
                       "DISCRIMINANT ASSOCIATION WITH MORE THAN " &
                       "ONE NAME IS EVALUATED ONCE FOR EACH NAME" );

     DECLARE
          TYPE REC (D1, D2 : INTEGER) IS
               RECORD 
                    NULL;
               END RECORD;

          R : REC (D1 | D2 => F);

          I1 : INTEGER := CHECK ( "R" );

          TYPE ACC IS ACCESS REC;

          AC : ACC (D1 | D2 => F);
     
          I2 : INTEGER := CHECK ( "AC" );
          
          PACKAGE PKG IS
               TYPE PRIV (D1, D2 : INTEGER) IS PRIVATE; 
               TYPE PACC IS ACCESS PRIV;

               TYPE LIM (D1, D2 : INTEGER) IS LIMITED PRIVATE;
               TYPE LACC IS ACCESS LIM;

          PRIVATE
               TYPE PRIV (D1, D2 : INTEGER) IS 
                    RECORD
                         NULL;
                    END RECORD;

               TYPE LIM (D1, D2 : INTEGER) IS
                    RECORD
                         NULL;
                    END RECORD;
          END PKG;                                  
          
          USE PKG;

     BEGIN

          DECLARE
               P  : PRIV (D1 | D2 => F);
               
               I1 : INTEGER := CHECK ( "P" );

               PA : PACC (D1 | D2 => F);

               I2 : INTEGER := CHECK ( "PA" );

               L  : LIM (D1 | D2 => F);
          
               I3 : INTEGER := CHECK ( "L" );

               LA : LACC (D1 | D2 => F);

               I : INTEGER;
          BEGIN
               I := CHECK ( "LA" );
          END;
     END;

     RESULT;
END C37210A;
