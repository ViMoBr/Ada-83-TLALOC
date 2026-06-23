-- A35801B.ADA

-- CHECK THAT THE ATTRIBUTES DIGITS, MANTISSA, EMAX, AND SAFE_EMAX ARE
-- OF TYPE UNIVERSAL INTEGER AND THAT THE ATTRIBUTES SMALL, LARGE, 
-- EPSILON, SAFE_SMALL, AND SAFE_LARGE ARE OF TYPE UNIVERSAL REAL 
-- WHEN THEIR PREFIX IS A GENERIC FORMAL SUBTYPE.

-- R.WILLIAMS 8/21/86

WITH REPORT; USE REPORT;
PROCEDURE A35801B IS

     BEGIN
          TEST ( "A35801B", "CHECK THAT THE ATTRIBUTES DIGITS, " &
                            "MANTISSA, EMAX, SAFE_EMAX, SMALL, " &
                            "LARGE, EPSILON, SAFE_SMALL, AND " &
                            "SAFE_LARGE YIELD THE CORRECT TYPES " &
                            "WHEN THEIR PREFIX IS A GENERIC FORMAL " &
                            "SUBTYPE" );

     DECLARE
          
          GENERIC
               TYPE F IS DIGITS <>;
          PROCEDURE P;

          PROCEDURE P IS
               SUBTYPE SF IS F;          
               TYPE NINT IS NEW INTEGER;
               
               TYPE NFLT IS NEW FLOAT;

               I1  : CONSTANT INTEGER := SF'DIGITS;
               I2  : CONSTANT INTEGER := SF'MANTISSA;
               NI1 : NINT := SF'DIGITS + SF'MANTISSA;
     
               I4  : CONSTANT INTEGER := SF'EMAX;
               I5  : CONSTANT INTEGER := SF'SAFE_EMAX;
               NI2 : NINT := SF'EMAX + SF'MANTISSA;
          
               F1 : CONSTANT FLOAT := SF'SMALL;
               F2 : CONSTANT FLOAT := SF'LARGE;

               NF1 : CONSTANT NFLT := SF'SMALL;
               NF2 : CONSTANT NFLT := SF'LARGE;
     
               F3 : CONSTANT FLOAT := SF'EPSILON;
               NF3 : CONSTANT NFLT := SF'EPSILON;

               F4 : CONSTANT FLOAT := SF'SAFE_SMALL;
               F5 : CONSTANT FLOAT := SF'SAFE_LARGE;

               NF4 : CONSTANT NFLT := SF'SAFE_SMALL;
               NF5 : CONSTANT NFLT:= SF'SAFE_LARGE;

          BEGIN
               NULL;
          END P;

          PROCEDURE NP IS NEW P (FLOAT);

     BEGIN
          NP;
     END;
    
     RESULT;
END A35801B;
