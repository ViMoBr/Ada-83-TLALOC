-- CC1204A.ADA

-- CHECK THAT GENERIC FORMAL TYPES MAY HAVE A DISCRIMINANT PART,
-- WHICH MAY BE OF A GENERIC FORMAL TYPE.

-- DAT 8/14/81
-- SPS 5/12/82

WITH REPORT; USE REPORT;

PROCEDURE CC1204A IS
BEGIN
     TEST ("CC1204A", "DISCRIMINANT PARTS FOR GENERIC FORMAL TYPES");

     DECLARE
          GENERIC
               TYPE T IS ( <> );
               TYPE I IS RANGE <> ;
               TYPE R1 (C : BOOLEAN) IS PRIVATE;
               TYPE R2 (C : T) IS PRIVATE;
               TYPE R3 (C : I) IS LIMITED PRIVATE;
               P1 : IN R1;
               P2 : IN R2;
               V1 : IN OUT R1;
               V2 : IN OUT R2;
               V3 : IN OUT R3;
          PROCEDURE PROC;

          TYPE DD IS NEW INTEGER RANGE 1 .. 10;
          TYPE ARR IS ARRAY (DD RANGE <>) OF CHARACTER;
          TYPE RECD (C : DD := DD (IDENT_INT (1))) IS
               RECORD
                    C1 : ARR (1..C);
               END RECORD;

          X1 : RECD;
          X2 : RECD := (1, "Y");

          TYPE RECB (C : BOOLEAN) IS
               RECORD
                    V : INTEGER := 6;
               END RECORD;
          RB : RECB (IDENT_BOOL (TRUE));
          RB1 : RECB (IDENT_BOOL (TRUE));

          PROCEDURE PROC IS
          BEGIN
               IF P1.C /= TRUE
                  OR P2.C /= T'FIRST
                  OR V1.C /= TRUE
                  OR V2.C /= T'FIRST
                  OR V3.C /= I'FIRST
               THEN
                    FAILED ("WRONG GENERIC PARAMETER VALUE");
               END IF;

               V1 := P1;
               V2 := P2;

               IF V1 /= P1
                  OR V2 /= P2 
               THEN
                    FAILED ("BAD ASSIGNMENT TO GENERIC PARAMETERS");
               END IF;
          END PROC;

     BEGIN
          RB1.V := IDENT_INT (1);
          X1.C1 := "X";

          DECLARE
     
               PROCEDURE PR IS NEW PROC
                    (T => DD,
                     I => DD,
                     R1 => RECB,
                     R2 => RECD,
                     R3 => RECD,
                     P1 => RB1,
                     P2 => X1,
                     V1 => RB,
                     V2 => X2,
                     V3 => X2);
          BEGIN
               PR;
               IF RB /= (TRUE, 1) OR X2.C1 /= "X" THEN
                    FAILED ("PR NOT CALLED CORRECTLY");
               END IF;
          END;
     END;

     RESULT;
END CC1204A;
