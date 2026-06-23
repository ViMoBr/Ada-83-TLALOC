-- B95074F.ADA

-- CHECK THAT AN OUT PARAMETER OR OUT PARAMETER SUBCOMPONENT CANNOT BE
-- READ OR PASSED AS AN IN OR IN OUT PARAMETER.

-- JWC 6/26/85

PROCEDURE B95074F IS

     TYPE RC (D : BOOLEAN) IS RECORD
          X : BOOLEAN;
     END RECORD;

     TASK T1 IS
          ENTRY E (X : OUT BOOLEAN; Y : OUT RC);
     END T1;

     TASK BODY T1 IS

          TASK T2 IS
               ENTRY E_IN (C : IN BOOLEAN);

               ENTRY E_INOUT (C : IN OUT BOOLEAN);

               ENTRY E_OUT (C : OUT BOOLEAN);
          END T2;

          TASK BODY T2 IS
          BEGIN
               NULL;
          END T2;

     BEGIN
          ACCEPT E (X : OUT BOOLEAN; Y : OUT RC) DO

               T2.E_IN (X);       -- ERROR: OUT PARAMETER USED AS IN.
               T2.E_IN (Y.X);     -- ERROR: OUT PARAMETER USED AS IN.
               T2.E_IN (Y.D);     -- OK.
               T2.E_INOUT (X);    -- ERROR: OUT PARAMETER USED AS INOUT.
               T2.E_INOUT (Y.X);  -- ERROR: OUT PARAMETER USED AS INOUT.
               T2.E_OUT (X);      -- OK.
               T2.E_OUT (Y.X);    -- OK.

          END E;
     END T1;

BEGIN
     NULL;
END B95074F;
