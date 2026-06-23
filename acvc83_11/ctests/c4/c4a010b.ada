-- C4A010B.ADA

-- CHECK THAT STATIC UNIVERSAL REAL EXPRESSIONS ARE EVALUATED 
-- EXACTLY.  IN PARTICULAR, CHECK THAT THE CASCADING USE OF FRACTIONAL
-- VALUES DOES NOT RESULT IN THE LOSS OF PRECISION.

-- RJW 7/31/86

WITH REPORT; USE REPORT; 
PROCEDURE C4A010B IS


BEGIN

     TEST( "C4A010B", "CHECK THAT STATIC UNIVERSAL REAL EXPRESSIONS " &
                      "ARE EVALUATED EXACTLY.  IN PARTICULAR, CHECK " &
                      "THAT THE CASCADING USE OF FRACTIONAL VALUES " &
                      "DOES NOT RESULT IN THE LOSS OF PRECISION" );

     DECLARE
          B : CONSTANT := 2.0/3.0;
          
          X0 : CONSTANT := 1.0;
          X1 : CONSTANT := X0 + B;
          X2 : CONSTANT := X1 + B ** 2;
          X3 : CONSTANT := X2 + B ** 3;
          X4 : CONSTANT := X3 + B ** 4;
          X5 : CONSTANT := X4 + B ** 5;
          X6 : CONSTANT := X5 + B ** 6;
          X7 : CONSTANT := X6 + B ** 7;
          X8 : CONSTANT := X7 + B ** 8;
          X9 : CONSTANT := X8 + B ** 9;
     
          Y1 : CONSTANT := B ** 10;
          Y2 : CONSTANT := 1.0;
          Y3 : CONSTANT := Y1 - Y2;
          Y4 : CONSTANT := B;
          Y5 : CONSTANT := Y4 - Y2;
          Y6 : CONSTANT := Y3 / Y5;

     BEGIN
          IF X9 /= 58025.0/19683.0 THEN
               FAILED ( "INCORRECT RESULTS FOR SERIES OF NAMED " &
                        "NUMBERS  - 1" );
          END IF;
          
          IF Y6 /= 58025.0/19683.0 THEN
               FAILED ( "INCORRECT RESULTS FOR SERIES OF NAMED " &
                        "NUMBERS  - 2" );
          END IF;
          
          IF X9 /= Y6 THEN
               FAILED ( "INCORRECT RESULTS FOR SERIES OF NAMED " &
                        "NUMBERS  - 3" );
          END IF;
          
     END;   
     
     RESULT;
END C4A010B;
