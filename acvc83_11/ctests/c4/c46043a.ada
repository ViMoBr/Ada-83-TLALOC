-- C46043A.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED FOR CONVERSION TO AN 
-- UNCONSTRAINED ARRAY TYPE IF COMPONENT SUBTYPES DO NOT HAVE THE SAME 
-- CONSTRAINTS.

-- R.WILLIAMS 9/8/86

WITH REPORT; USE REPORT;
PROCEDURE C46043A IS
     
BEGIN
     TEST ( "C46043A", "CHECK THAT CONSTRAINT_ERROR IS RAISED FOR " &
                       "CONVERSION TO AN UNCONSTRAINED ARRAY TYPE " &
                       "IF COMPONENT SUBTYPES DO NOT HAVE THE SAME " &
                       "CONSTRAINTS" );

     DECLARE
          TYPE ARR1 IS ARRAY (INTEGER RANGE <>) OF 
               INTEGER RANGE IDENT_INT (1) .. IDENT_INT (10);
          A1 : ARR1 (1 .. 10) := (OTHERS => 1);

          TYPE ARR2 IS ARRAY (INTEGER RANGE <>) OF
               INTEGER RANGE IDENT_INT (0) .. IDENT_INT (9);
          
          PROCEDURE CHECK (A : ARR2) IS
          BEGIN               
               FAILED ( "NO EXCEPTION RAISED WITH DIFFERING " &
                        "RANGE CONSTRAINTS" );
          END CHECK;
               
     BEGIN
          CHECK (ARR2 (A1));
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED WITH DIFFERING " &
                        "RANGE CONSTRAINTS" );
     END;

     DECLARE
          
          TYPE ARR1 IS ARRAY (INTEGER RANGE <>) OF FLOAT DIGITS 1;
          A1 : ARR1 (1 .. 10) := (OTHERS => 1.0);

          TYPE ARR2 IS ARRAY (INTEGER RANGE <>) OF FLOAT DIGITS 3;

          PROCEDURE CHECK (A : ARR2) IS
          BEGIN               
               FAILED ( "NO EXCEPTION RAISED WITH DIFFERING " &
                        "FLOATING POINT ACCURACY CONSTRAINTS" );
          END CHECK;
               
     BEGIN
          CHECK (ARR2 (A1));
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED WITH DIFFERING " &
                        "FLOATING POINT ACCURACY CONSTRAINTS" );
     END;

     DECLARE
          TYPE FIXED IS DELTA 0.1 RANGE 1.0 .. 2.0;                   
          
          TYPE ARR1 IS ARRAY (INTEGER RANGE <>) OF FIXED DELTA 0.5;
          A1 : ARR1 (1 .. 10) := (OTHERS => 1.0);

          TYPE ARR2 IS ARRAY (INTEGER RANGE <>) OF FIXED DELTA 1.0;

          PROCEDURE CHECK (A : ARR2) IS
          BEGIN               
               FAILED ( "NO EXCEPTION RAISED WITH DIFFERING " &
                        "FIXED POINT ACCURACY CONSTRAINTS" );
          END CHECK;
               
     BEGIN
          CHECK (ARR2 (A1));
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED WITH DIFFERING " &
                        "FIXED POINT ACCURACY CONSTRAINTS" );
     END;

     DECLARE
          TYPE ARR IS ARRAY (INTEGER RANGE <>) OF INTEGER;

          TYPE ARR1 IS ARRAY (INTEGER RANGE <>) OF 
               ARR (IDENT_INT (1) .. IDENT_INT (10));
          A1 : ARR1 (1 .. 10)  := (OTHERS => (OTHERS => 1));

          TYPE ARR2 IS ARRAY (INTEGER RANGE <>) OF 
               ARR (IDENT_INT (0) .. IDENT_INT (9));

          PROCEDURE CHECK (A : ARR2) IS
          BEGIN               
               FAILED ( "NO EXCEPTION RAISED WITH DIFFERING " &
                        "ARRAY COMPONENT INDEX CONSTRAINTS" );
          END CHECK;
               
     BEGIN
          CHECK (ARR2 (A1));
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED WITH DIFFERING " &
                        "ARRAY COMPONENT INDEX CONSTRAINTS" );
     END;

     DECLARE
          TYPE REC (D : INTEGER) IS
               RECORD
                    NULL;
               END RECORD;

          TYPE ARR1 IS ARRAY (INTEGER RANGE <>) OF REC (IDENT_INT (0));
          A1 : ARR1 (1 .. 10) := (OTHERS => (D =>0));

          TYPE ARR2 IS ARRAY (INTEGER RANGE <>) OF REC (IDENT_INT (2));

          PROCEDURE CHECK (A : ARR2) IS
          BEGIN               
               FAILED ( "NO EXCEPTION RAISED WITH DIFFERING " &
                        "RECORD COMPONENT DISCRIMINANT CONSTRAINTS" );
          END CHECK;
               
     BEGIN
          CHECK (ARR2 (A1));
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED WITH DIFFERING " &
                        "RECORD COMPONENT DISCRIMINANT CONSTRAINTS" );
     END;
                              
     DECLARE
          TYPE REC (D : INTEGER) IS
               RECORD
                    NULL;
               END RECORD;

          TYPE ACCREC IS ACCESS REC;

          TYPE ARR1 IS ARRAY (INTEGER RANGE <>) OF 
               ACCREC (IDENT_INT (0));
          A1 : ARR1 (1 .. 10) := (OTHERS => (NEW REC (0)));

          TYPE ARR2 IS ARRAY (INTEGER RANGE <>) OF 
               ACCREC (IDENT_INT (1));

          PROCEDURE CHECK (A : ARR2) IS
          BEGIN               
               FAILED ( "NO EXCEPTION RAISED WITH DIFFERING " &
                        "ACCESS TYPE COMPONENT DISCRIMINANT " &
                        "CONSTRAINTS" );
          END CHECK;
               
     BEGIN
          CHECK (ARR2 (A1));
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED WITH DIFFERING " &
                        "ACCESS TYPE COMPONENT DISCRIMINANT " &
                        "CONSTRAINTS" );
     END;

     DECLARE
          PACKAGE PRIV IS
               TYPE REC (D : INTEGER) IS PRIVATE;
               FUNCTION F RETURN REC;

          PRIVATE
               TYPE REC (D : INTEGER) IS
                    RECORD
                         NULL;
                    END RECORD;
          END PRIV;

          PACKAGE BODY PRIV IS
               FUNCTION F RETURN REC IS
               BEGIN
                    RETURN (D => IDENT_INT (0));
               END F;
          END PRIV;               

          USE PRIV;

          PACKAGE PKG IS
               TYPE ARR1 IS ARRAY (INTEGER RANGE <>) OF 
                    REC (IDENT_INT (0));
               A1 : ARR1 (1 .. 10) := (OTHERS => F);

               TYPE ARR2 IS ARRAY (INTEGER RANGE <>) OF 
                    REC (IDENT_INT (1));
          END PKG;
          
          USE PKG;

          PROCEDURE CHECK (A : ARR2) IS
          BEGIN               
               FAILED ( "NO EXCEPTION RAISED WITH DIFFERING " &
                        "PRIVATE COMPONENT DISCRIMINANT CONSTRAINTS" );
          END CHECK;
               
     BEGIN
          CHECK (ARR2 (A1));
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED WITH DIFFERING " &
                        "PRIVATE COMPONENT DISCRIMINANT CONSTRAINTS" );
     END;

     RESULT;
END C46043A;
