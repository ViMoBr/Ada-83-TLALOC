-- A83041C.ADA

-- OBJECTIVE:
--     CHECK THAT ATTRIBUTES FOR INTEGER, ENUMERATION,
--     FLOATING-POINT, AND FIXED-POINT TYPES ARE VISIBLE THROUGHOUT
--     THEIR SCOPE EVEN WHEN THE TYPE IS DECLARED IN THE VISIBLE
--     PART OF A PACKAGE AND NO USE CLAUSE IS GIVEN.

-- HISTORY:
--     SDA 09/16/88 CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE A83041C IS

BEGIN
     TEST ("A83041C", "CHECK THAT ATTRIBUTES FOR INTEGER, "&
           "ENUMERATION, FLOATING-POINT, AND FIXED-POINT TYPES "&
           "ARE VISIBLE THROUGHOUT THEIR SCOPE EVEN WHEN THE TYPE "&
           "IS DECLARED IN THE VISIBLE PART OF A PACKAGE AND NO "&
           "USE CLAUSE IS GIVEN");

     DECLARE
          PACKAGE P IS
               TYPE A IS RANGE 1..10;
               TYPE B IS (MIKE,JACKIE,BELINDA);
               TYPE C IS DIGITS 3 RANGE 1.0 .. 10.0;
               TYPE D IS DELTA 0.5 RANGE 1.0 .. 10.0;
          END P;

          NUM_L : P.A := P.A'FIRST;
          EN1_L : P.B := P.B'FIRST;
          FLP_L : P.C;
          FIP_L : P.D;
          INT_L : INTEGER;
          FLT_L : FLOAT;

          PACKAGE BODY P IS

               NUM : A := A'FIRST;
               EN1 : B := B'FIRST;
               FLP : C;
               FIP : D;
               INT : INTEGER;
               FLT : FLOAT;

          BEGIN
               NUM := A'LAST;
               NUM := A'POS(2);
               NUM := A'SUCC(3);
               NUM := A'PRED(4);
               NUM := A'VAL(5);
               EN1 := B'LAST;
               INT := B'POS(JACKIE);
               EN1 := B'SUCC(JACKIE);
               EN1 := B'PRED(BELINDA);
               EN1 := B'VAL(2);
               INT := C'DIGITS;
               FLT := C'SMALL;
               FLT := C'LARGE;
               FLT := C'EPSILON;
               FLT := D'DELTA;
               FLT := D'SMALL;
               FLT := D'LARGE;

               BEGIN
                    FLP := C'LAST;
                    FIP := D'LAST;
                    FLP := C'FIRST;
                    FIP := D'FIRST;
               EXCEPTION
                    WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
                         NULL;
               END;
          END P;

     BEGIN
          NUM_L := P.A'LAST;
          NUM_L := P.A'POS(2);
          NUM_L := P.A'SUCC(3);
          NUM_L := P.A'PRED(4);
          NUM_L := P.A'VAL(5);
          EN1_L := P.B'LAST;
          EN1_L := P.B'VAL(2);
          INT_L := P.C'DIGITS;
          FLT_L := P.C'SMALL;
          FLT_L := P.C'LARGE;
          FLT_L := P.C'EPSILON;
          FLT_L := P.D'DELTA;
          FLT_L := P.D'SMALL;
          FLT_L := P.D'LARGE;
          BEGIN
               FLP_L := P.C'LAST;
               FIP_L := P.D'LAST;
               FLP_L := P.C'FIRST;
               FIP_L := P.D'FIRST;
          EXCEPTION
               WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
                    NULL;
          END;
     END;
     RESULT;
END A83041C;
