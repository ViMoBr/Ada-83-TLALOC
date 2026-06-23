-- B62006F.ADA

-- CHECK THAT AN OUT PARAMETER MAY NOT BE USED AS AN IN OR IN OUT ACTUAL
-- PARAMETER. 

-- SPS 2/21/84

PROCEDURE B62006F IS

     TYPE RC (D : BOOLEAN) IS RECORD
          X : BOOLEAN;
     END RECORD;

     PROCEDURE P (X : OUT BOOLEAN; Y : OUT RC) IS

          PROCEDURE P_IN (C : IN BOOLEAN) IS
          BEGIN
               NULL;
          END P_IN;

          PROCEDURE P_INOUT (C : IN OUT BOOLEAN) IS
          BEGIN
               C := FALSE;
          END P_INOUT;

          PROCEDURE P_OUT (C : OUT BOOLEAN) IS
          BEGIN
               C := TRUE;
          END P_OUT;

     BEGIN

          P_IN (X);           -- ERROR: OUT PARAMETER USED AS IN.
          P_IN (Y.X);         -- ERROR: OUT PARAMETER USED AS IN.
          P_IN (Y.D);         -- OK.
          P_INOUT (X);        -- ERROR: OUT PARAMETER USED AS INOUT.
          P_INOUT (Y.X);      -- ERROR: OUT PARAMETER USED AS INOUT.
          P_OUT (X);          -- OK.
          P_OUT (Y.X);        -- OK.

     END P;

BEGIN
     NULL;
END B62006F;
