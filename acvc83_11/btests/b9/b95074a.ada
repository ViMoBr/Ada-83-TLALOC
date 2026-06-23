-- B95074A.ADA

-- CHECK THAT THE DISCRIMINANT OF AN OUT FORMAL PARAMETER AND ITS
-- SUBCOMPONENTS MAY BE READ INSIDE THE TASK, BUT NOT OTHER COMPONENT
-- VALUES.

-- JWC 6/24/85

PROCEDURE B95074A IS

     TYPE REC (DSC : BOOLEAN) IS RECORD
          C1 : NATURAL := 2;
     END RECORD;

     TYPE RC (D : POSITIVE) IS RECORD
          C : POSITIVE := D;
          CMP : REC (TRUE);
     END RECORD;

     R : RC (10);

     TASK T IS
          ENTRY E (OUT_REC : OUT RC);
     END T;

     TASK BODY T IS
          B : BOOLEAN;
          I : INTEGER;
     BEGIN
          ACCEPT E (OUT_REC : OUT RC) DO
               I := OUT_REC.D;               -- OK.
               I := OUT_REC.C;               -- ERROR:
               B := OUT_REC.CMP.DSC;         -- OK.
               I := OUT_REC.CMP.C1;          -- ERROR:
          END E;
     END T;

BEGIN
     NULL;
END B95074A;
