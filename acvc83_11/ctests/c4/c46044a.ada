-- C46044A.ADA

-- CHECK THAT CONSTRAINT ERROR IS RAISED FOR CONVERSION TO A  
-- CONSTRAINED ARRAY TYPE IF COMPONENT SUBTYPES DO NOT HAVE THE SAME 
-- CONSTRAINTS.

-- R.WILLIAMS 9/8/86

WITH REPORT; USE REPORT;
PROCEDURE C46044A IS
     
BEGIN
     TEST ( "C46044A", "CHECK THAT CONSTRAINT ERROR IS RAISED FOR " &
                       "CONVERSION TO A CONSTRAINED ARRAY TYPE " &
                       "IF COMPONENT SUBTYPES DO NOT HAVE THE SAME " &
                       "CONSTRAINTS" );

     DECLARE
          TYPE ARR1 IS ARRAY (1 .. 5) OF 
               INTEGER RANGE IDENT_INT (1) .. IDENT_INT (10);
          A1 : ARR1;

          TYPE ARR2 IS ARRAY (1 .. 5) OF
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
          
          TYPE ARR1 IS ARRAY (1 .. 5) OF FLOAT DIGITS 1;
          A1 : ARR1;

          TYPE ARR2 IS ARRAY (1 .. 5) OF FLOAT DIGITS 3;

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
          
          TYPE ARR1 IS ARRAY (1 .. 5) OF FIXED DELTA 0.5;
          A1 : ARR1;

          TYPE ARR2 IS ARRAY (1 .. 5) OF FIXED DELTA 1.0;

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

          TYPE ARR1 IS ARRAY (1 .. 5) OF 
               ARR (IDENT_INT (1) .. IDENT_INT (10));
          A1 : ARR1;

          TYPE ARR2 IS ARRAY (1 .. 5) OF 
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

          TYPE ARR1 IS ARRAY (1 .. 5) OF REC (IDENT_INT (0));
          A1 : ARR1;

          TYPE ARR2 IS ARRAY (1 .. 5) OF REC (IDENT_INT (2));

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

          TYPE ARR1 IS ARRAY (1 .. 5) OF 
               ACCREC (IDENT_INT (0));
          A1 : ARR1;

          TYPE ARR2 IS ARRAY (1 .. 5) OF 
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
          PRIVATE
               TYPE REC (D : INTEGER) IS
                    RECORD
                         NULL;
                    END RECORD;
          END PRIV;

          USE PRIV;

          PACKAGE PKG IS
               TYPE ARR1 IS ARRAY (1 .. 5) OF 
                    REC (IDENT_INT (0));
               A1 : ARR1;

               TYPE ARR2 IS ARRAY (1 .. 5) OF 
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
END C46044A;
