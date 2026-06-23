-- B62006B.ADA

-- CHECK THAT THE DISCRIMINANTS OF A FORMAL OUT PARAMETER ARE THE ONLY
-- COMPONENTS THAT CAN BE READ INSIDE THE PROCEDURE.

-- SPS 2/17/84

PROCEDURE B62006B IS

     TYPE REC (DSC : BOOLEAN) IS RECORD
          C1 : NATURAL := 2;
     END RECORD;

     TYPE RC (D : POSITIVE) IS RECORD
          C : POSITIVE := D;
          CMP : REC (TRUE);
     END RECORD;

     R : RC (10);

     PROCEDURE P (OUT_REC : OUT RC) IS 
          B : BOOLEAN;
          I : INTEGER;
     BEGIN

          I := OUT_REC.D;               -- OK.
          I := OUT_REC.C;               -- ERROR:
          B := OUT_REC.CMP.DSC;         -- OK.
          I := OUT_REC.CMP.C1;          -- ERROR:

     END P;

BEGIN
     NULL;
END B62006B;
