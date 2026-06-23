-- A83041B.ADA

-- OBJECTIVE:
--     CHECK THAT SELECTED COMPONENTS, INDEXED COMPONENTS,
--     SLICES, LITERALS (NUMERIC, STRING, NULL) AND AGGREGATES
--     ARE VISIBLE THROUGHOUT THEIR SCOPE EVEN WHEN THE TYPE
--     IS DECLARED IN THE VISIBLE PART OF A PACKAGE AND NO USE
--     CLAUSE IS GIVEN.

-- HISTORY:
--     SDA 09/16/88 CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE A83041B IS

BEGIN
     TEST ("A83041B", "CHECK THAT SELECTED COMPONENTS, INDEXED "&
           "COMPONENTS, SLICES, LITERALS (NUMERIC, STRING, NULL) "&
           "AND AGGREGATES ARE VISIBLE THROUGHOUT THEIR SCOPE "&
           "EVEN WHEN THE TYPE IS DECLARED IN THE VISIBLE PART OF "&
           "A PACKAGE AND NO USE CLAUSE IS GIVEN");

     DECLARE
          PACKAGE P IS
               TYPE A IS RANGE 1..10;
               TYPE B IS (MIKE,JACKIE,BELINDA);
               TYPE C IS DIGITS 3 RANGE 1.0 .. 10.0;
               TYPE D IS DELTA 0.5 RANGE 1.0 .. 10.0;
               TYPE E2 IS ARRAY(INTEGER RANGE 4..6) OF A;
               TYPE F IS ACCESS INTEGER;
               TYPE R IS
                    RECORD
                         S : A;
                         U : C;
                         V : D;
                         X : F;
                    END RECORD;
               TYPE LINE IS NEW STRING(1 ..10);
          END P;

          NUM_L : P.A := 5;
          FLP_L : P.C := 1.0;
          FIP_L : P.D := 1.0;
          LIT_L : P.LINE;
          ARR2_L : P.E2 := (5,OTHERS => 3);
          AR12_L : P.E2 := P.E2'(4 => 8,5 => 3,OTHERS => 1);
          ACC1_L : P.F;
          ACC2_L : P.F;
          REC_L : P.R := (S => 1,U => 1.0,V => 1.0,
                         X => NULL);

          PACKAGE BODY P IS

               NUM : A := 5;
               EN1 : B := MIKE;
               FLP : C := 1.0;
               FIP : D := 1.0;
               LIT : LINE;
               ARR2 : E2 := (5,OTHERS => 3);
               AR12 : E2 := E2'(4 => 8,5 => 3,OTHERS => 1);
               ACC1 : F;
               ACC2 : F;
               REC : R := (S => 1,U => 1.0,
                          V => 1.0, X => NULL);

          BEGIN
               REC.S := 5;
               REC.U := 3.0;
               REC.V := 2.0;
               REC.X := NEW INTEGER;
               REC.X.ALL := 32;
               ARR2(4) := 6;
               ARR2(5 * 1) := 5;
               ARR2(12 / 2) := 4;
               AR12(4 .. 5) := ARR2(5 .. 6);
               NUM := 2;
               EN1 := MIKE;
               FLP := 2.0;
               FIP := 2.0;
               LIT := "ANDERSONST";
               REC.X := NULL;
               ARR2 := (4,OTHERS => 2);
          END P;

     BEGIN
          REC_L.S := 5;
          REC_L.U := 3.0;
          REC_L.V := 2.0;
          REC_L.X := NEW INTEGER;
          REC_L.X.ALL := 32;
          ARR2_L(4) := 6;
          ARR2_L(5 * 1) := 5;
          ARR2_L(12 / 2) := 4;
          AR12_L(4 .. 5) := ARR2_L(5 .. 6);
          NUM_L := 2;
          FLP_L := 2.0;
          FIP_L := 2.0;
          LIT_L := "ANDERSONST";
          REC_L.X := NULL;
          ARR2_L := (4,OTHERS => 2);
     END;
     RESULT;
END A83041B;
