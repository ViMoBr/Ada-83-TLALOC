-- C83041A.ADA

-- OBJECTIVE:
--     CHECK THAT IMPLICIT TYPE CONVERSION, ASSIGNMENT,
--     ALLOCATORS (INCLUDING .ALL), MEMBERSHIP TESTS, AND
--     SHORT-CIRCUIT CONTROL FORMS ARE VISIBLE THROUGHOUT
--     THEIR SCOPE EVEN WHEN THE TYPE IS DECLARED IN THE
--     VISIBLE PART OF A PACKAGE AND NO USE CLAUSE IS
--     GIVEN.

-- HISTORY:
--     SDA 09/14/88 CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C83041A IS

BEGIN
     TEST ("C83041A", "CHECK THAT IMPLICIT TYPE CONVERSION, "&
           "ASSIGNMENT, ALLOCATORS (INCLUDING .ALL), MEMBERSHIP "&
           "TESTS, AND SHORT-CIRCUIT CONTROL FORMS ARE VISIBLE "&
           "THROUGHOUT THEIR SCOPE EVEN WHEN THE TYPE IS DECLARED "&
           "IN THE VISIBLE PART OF A PACKAGE AND NO USE CLAUSE IS "&
           "GIVEN");

     DECLARE
          PACKAGE P IS
               TYPE A IS RANGE 1..10;
               TYPE B IS (MIKE,JACKIE,BELINDA);
               TYPE C IS DIGITS 3 RANGE 1.0 .. 10.0;
               TYPE D IS DELTA 0.5 RANGE 1.0 .. 10.0;
               TYPE E IS ARRAY(INTEGER RANGE <>) OF A;
               SUBTYPE E1 IS E(1 .. 3);
               SUBTYPE E2 IS E(4 .. 6);
               TYPE F IS ACCESS INTEGER;
               TYPE G IS PRIVATE;
               G1 : CONSTANT G;
               TYPE R IS
                    RECORD
                         X : INTEGER;
                    END RECORD;
               TYPE BOOL IS NEW BOOLEAN;
          PRIVATE
               TYPE G IS RANGE 1..5;
               G1 : CONSTANT G := 2;
          END P;

          SUBTYPE PBOOL IS P.BOOL;

          PACKAGE BODY P IS

               NUM : A := 5;
               NUM1 : A;
               EN1 : B := MIKE;
               FLP : C := 1.0;
               FIP : D := 1.0;
               ARR1 : E1 := (1,2,3);
               ARR2 : E2;
               ACC1 : F;
               PRI : G;
               REC : R;
               MY_TRUE : BOOL := TRUE;
               MY_FALSE : BOOL := FALSE;

          BEGIN
               NUM1 := NUM;
               FLP := 1.0;
               FIP := 3.0;
               PRI := 2;
               REC.X := 3;
               ACC1 := NEW INTEGER;
               ACC1.ALL := 32;
               IF (NUM /= 5 OR FLP /= 1.0 OR FIP /= 3.0) THEN
                    FAILED ("INCORRECT RESULTS FROM IMPLICIT "&
                            "CONVERSION - 1");
               END IF;
               IF (MY_FALSE AND THEN MY_TRUE) OR NOT
                  (MY_TRUE OR ELSE MY_FALSE) THEN
                    FAILED ("INCORRECT RESULT FROM SHORT "&
                            "CIRCUIT FORMS - 1");
               END IF;
               IF NOT (PRI IN G AND NUM IN A AND EN1 IN B AND
                      FLP IN C) OR (FIP NOT IN D) THEN
                    FAILED ("INCORRECT RESULT FROM "&
                            "MEMBERSHIP - 1");
               END IF;
          END P;
     BEGIN

          DECLARE
               NUM_L : P.A := 5;
               NUM1_L : P.A;
               EN1_L : P.B;
               FLP_L : P.C := 1.0;
               FIP_L : P.D := 1.0;
               ARR1_L : P.E1 := (1,2,3);
               ARR2_L : P.E2;
               ACC1_L : P.F;
               PRI_L : P.G;
               REC_L : P.R;
               MY_TRUE_L : PBOOL := P.TRUE;
               MY_FALSE_L : PBOOL := P.FALSE;

          BEGIN
               NUM1_L := NUM_L;
               FLP_L := 1.0;
               FIP_L := 3.0;
               PRI_L := P.G1;
               REC_L.X := 3;
               ACC1_L := NEW INTEGER;
               ACC1_L.ALL := 32;
               IF (P."/="(NUM_L,5) OR P."/="(FLP_L,1.0) OR
                   P."/="(FIP_L,3.0)) THEN
                    FAILED ("INCORRECT RESULTS FROM IMPLICIT "&
                            "CONVERSION - 2");
               END IF;
               IF P."OR"((MY_FALSE_L AND THEN MY_TRUE_L),
                         P."NOT"(MY_TRUE_L OR ELSE MY_FALSE_L)) THEN
                    FAILED ("INCORRECT RESULT FROM SHORT "&
                            "CIRCUIT FORMS - 2");
               END IF;
               IF NOT (PRI_L IN P.G AND NUM_L IN P.A AND EN1_L IN P.B
                       AND FLP_L IN P.C) OR (FIP_L NOT IN P.D) THEN
                    FAILED ("INCORRECT RESULT FROM "&
                            "MEMBERSHIP - 2");
               END IF;
          END;
          RESULT;
     END;
END C83041A;
