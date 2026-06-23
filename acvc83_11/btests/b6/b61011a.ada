-- B61011A.ADA

-- CHECK THAT A NAME REFERRING TO A FORMAL PARAMETER CANNOT BE USED
-- LATER IN THE SAME FORMAL PART (ALTHOUGH A PARAMETER'S IDENTIFIER CAN
-- BE USED (E.G., AS A SELECTOR) IF IT DOES NOT REFER TO THE PARAMETER).

-- BHS 7/2/84

PROCEDURE B61011A IS

     TYPE REC IS
          RECORD
               COMP : INTEGER;
          END RECORD;

     TYPE ARR IS ARRAY (1..10) OF INTEGER;

     I1 : INTEGER;
     R1 : REC;
     A1 : ARR;

     TYPE T IS
          RECORD
               T : INTEGER;
          END RECORD;

     SUBTYPE TT IS T;
     T_VAR : T;

     FUNCTION FUN (T : INTEGER) RETURN INTEGER IS
     BEGIN
          RETURN T + 1;
     END FUN;

     -- CHECK SUBPROGRAMS USING GLOBAL VARIABLE NAMES AS PARAMETER
     -- NAMES, AS WELL AS IMPLICITLY DECLARED PARAMETER NAMES.

     PROCEDURE P1A (I1 : INTEGER; J : INTEGER := I1) IS   -- ERROR: 
                                                          -- USE OF I1.
     BEGIN
          NULL;
     END P1A;


     PROCEDURE P1B (I2 : INTEGER; J : INTEGER := I2) IS  -- ERROR:
                                                         -- USE OF I2.
     BEGIN
          NULL;
     END P1B;


     PROCEDURE P2A (R1 : REC; C : INTEGER := R1.COMP) IS  -- ERROR: 
                                                          -- USE OF R1.
     BEGIN
          NULL;
     END P2A;


     PROCEDURE P2B (R2 : REC; C : INTEGER := R2.COMP) IS  -- ERROR:
                                                          -- USE OF R2.
     BEGIN
          NULL;
     END P2B;


     PROCEDURE P3A (A1 : ARR; J : INTEGER := A1(1)) IS   -- ERROR:
                                                         -- USE OF A1.
     BEGIN
          NULL;
     END P3A;


     PROCEDURE P3B (A2 : ARR; J : INTEGER := A2(1)) IS   -- ERROR:
                                                         -- USE OF A2.
     BEGIN
          NULL;
     END P3B;


     PROCEDURE P4A (A1 : ARR; J : INTEGER := A1'FIRST) IS  -- ERROR:
                                                           -- USE OF A1.
     BEGIN
          NULL;
     END P4A;


     PROCEDURE P4B (A2 : ARR; J : INTEGER := A2'FIRST) IS  -- ERROR:
                                                           -- USE OF A2.
     BEGIN
          NULL;
     END P4B;


     PROCEDURE P5A (I1 : INTEGER; J : INTEGER := FUN (I1)) IS  -- ERROR:
                                                           -- USE OF I1.
     BEGIN
          NULL;
     END P5A;


     PROCEDURE P5B (I2 : INTEGER; J : INTEGER := FUN (I2)) IS  -- ERROR:
                                                           -- USE OF I2.
     BEGIN
          NULL;
     END P5B;


     PROCEDURE P6 (T : INTEGER;
                   X : TT := (T => 3);              -- LEGAL USE OF T.
                   Y : INTEGER := T_VAR.T;          -- LEGAL USE OF T.
                   Z : INTEGER := FUN (T => 3)) IS  -- LEGAL USE OF T.
     BEGIN
          NULL;
     END P6;


BEGIN

     NULL;

END B61011A;  
