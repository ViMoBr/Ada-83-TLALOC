-- B85007B.ADA

-- CHECK THAT THE DISCRIMINANTS OF A RENAMED FORMAL OUT PARAMETER ARE
-- THE ONLY COMPONENTS THAT CAN BE READ INSIDE THE PROCEDURE.

-- SPS 02/17/84 (SEE B62006B-B.ADA)
-- EG  02/21/84

PROCEDURE B85007B IS

     TYPE REC (DSC : BOOLEAN) IS RECORD
          C1 : NATURAL := 2;
     END RECORD;

     TYPE RC (D : POSITIVE) IS RECORD
          C : POSITIVE := D;
          CMP : REC (TRUE);
     END RECORD;

     SUBTYPE REC_TRUE IS REC(TRUE);

     R : RC (10);

     PROCEDURE PROC (OUT_REC : OUT RC) IS 

          B : BOOLEAN;
          I : INTEGER;

          REC1 : RC       RENAMES OUT_REC;
          REC2 : REC_TRUE RENAMES OUT_REC.CMP;
          REC3 : RC       RENAMES REC1;

     BEGIN

          I := REC1.D;                                 -- OK.
          I := REC1.C;                                 -- ERROR:
          B := REC1.CMP.DSC;                           -- OK.
          I := REC1.CMP.C1;                            -- ERROR:
          B := REC2.DSC;                               -- OK.
          I := REC2.C1;                                -- ERROR:
          I := REC3.D;                                 -- OK.
          I := REC3.C;                                 -- ERROR:
          B := REC3.CMP.DSC;                           -- OK.
          I := REC3.CMP.C1;                            -- ERROR:

     END PROC;

BEGIN

     NULL;

END B85007B;
