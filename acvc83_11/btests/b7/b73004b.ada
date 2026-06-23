-- B73004B.ADA

-- OBJECTIVE:
--     CHECK THAT ENTITIES DECLARED IN A LIBRARY PACKAGE BODY AREN'T
--     ACCESSIBLE FROM OUTSIDE THE PACKAGE BODY.

-- HISTORY:
--     LDC   06/13/88 CREATED ORIGINAL TEST.


PACKAGE B73004B_PACK IS

     SUBTYPE INT_TYPE IS INTEGER RANGE 0 .. 15;
     TYPE    FLT_TYPE IS DIGITS 3;
     SUBTYPE CHR_TYPE IS CHARACTER RANGE 'A' .. 'C';
     TYPE REC_TYPE IS
          RECORD
               ELEMT : INT_TYPE;
          END RECORD;

END B73004B_PACK;

PACKAGE BODY B73004B_PACK IS

      INT : INT_TYPE;
      FLT : FLT_TYPE;
      CHR : CHR_TYPE;
      REC : REC_TYPE;
      BOL : BOOLEAN;
      CON : CONSTANT INT_TYPE := 5;

      PACKAGE PACK1 IS
           A : INT_TYPE;
      END PACK1;

      FUNCTION FAIL_IT(X : INTEGER) RETURN BOOLEAN IS
      BEGIN
           RETURN TRUE;
      END FAIL_IT;

     PROCEDURE PROC IS
     BEGIN
          NULL;
     END PROC;

END B73004B_PACK;

PACKAGE B73004B_PACK2 IS

     SUBTYPE CHR2_TYPE IS CHARACTER RANGE 'A' .. 'C';
     TYPE TRY_REF IS
          RECORD
               ELEMT1 : CHR2_TYPE;
               ELEMT2 : INT_BODY_TYPE;                 -- ERROR:
          END RECORD;

END B73004B_PACK2;

PACKAGE BODY B73004B_PACK2 IS

      SUBTYPE INT_BODY_TYPE IS INTEGER RANGE 0 .. 15;

END B73004B_PACK2;


WITH B73004B_PACK;
PROCEDURE B73004B IS

     A : INTEGER;
     B : BOOLEAN;


     PROCEDURE REFERENCE IS
          C : BOOLEAN;
          D : B73004B_PACK.INT_TYPE;                 -- OK;
          E : B73004B_PACK.INT_BODY_TYPE;            -- ERROR:
     BEGIN
          B73004B_PACK.INT := 1;                     -- ERROR:
          B73004B_PACK.FLT := 1.0;                   -- ERROR:
          B73004B_PACK.CHR := 'C';                   -- ERROR:
          B73004B_PACK.RCD.ELEMT := 1;               -- ERROR:
          B73004B_PACK.BOL := TRUE;                  -- ERROR:
          C := B73004B_PACK.FAIL_IT;                 -- ERROR:
          B73004B_PACK.PROC;                         -- ERROR:
          D := B73004B_PACK.CON;                     -- ERROR:
     END REFERENCE;

USE B73004B_PACK;

BEGIN
     INT := 1;                                   -- ERROR:
     FLT := 1.0;                                 -- ERROR:
     CHR := 'C';                                 -- ERROR:
     REC.ELEMT := 1;                             -- ERROR:
     BOL := TRUE;                                -- ERROR:
     A := FAIL_IT;                               -- ERROR:
     PROC;                                       -- ERROR:
     B := CON;                                   -- ERROR:

END B73004B;
