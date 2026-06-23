-- C45273A.ADA

-- OBJECTIVE:
--     CHECK THAT EQUALITY AND INEQUALITY ARE EVALUATED CORRECTLY FOR
--     RECORD OBJECTS HAVING DIFFERENT VALUES OF THE 'CONSTRAINED
--     ATTRIBUTE.

-- HISTORY:
--     TBN  08/07/86  CREATED ORIGINAL TEST.
--     VCL  10/27/87  MODIFIED THIS HEADER; RELOCATED THE CALL TO
--                    REPORT.TEST SO THAT IT COMES BEFORE ANY
--                    DECLARATIONS; CHANGED THE 'ELSEIF' CONDITION IN
--                    THE PROCEDURE 'PROC' SO THAT IT REFERS TO THE
--                    FORMAL PARAMETERS.

WITH REPORT; USE REPORT;
PROCEDURE C45273A IS
BEGIN
     TEST ("C45273A", "EQUALITY AND INEQUALITY ARE " &
                      "EVALUATED CORRECTLY FOR RECORD OBJECTS HAVING " &
                      "DIFFERENT VALUES OF THE 'CONSTRAINED' " &
                      " ATTRIBUTE");

     DECLARE
          SUBTYPE INT IS INTEGER RANGE 1 .. 20;
          TYPE REC_TYPE1 IS
               RECORD
                    A : INTEGER;
               END RECORD;

          TYPE REC_TYPE2 (LEN : INT := 3) IS
               RECORD
                    A : STRING (1 .. LEN);
               END RECORD;

          TYPE REC_TYPE3 (NUM : INT := 1) IS
               RECORD
                    A : REC_TYPE1;
               END RECORD;

          REC1 : REC_TYPE2 (3) := (3, "WHO");
          REC2 : REC_TYPE2;
          REC3 : REC_TYPE2 (5) := (5, "WHERE");
          REC4 : REC_TYPE3;
          REC5 : REC_TYPE3 (1) := (1, A => (A => 5));

          PROCEDURE PROC (PREC1 : REC_TYPE2;
                          PREC2 : IN OUT REC_TYPE2) IS
          BEGIN
               IF NOT (PREC1'CONSTRAINED) OR PREC2'CONSTRAINED THEN
                    FAILED ("INCORRECT RESULTS FROM 'CONSTRAINED " &
                            "ATTRIBUTE - 6");
               ELSIF PREC1 /= PREC2 THEN
                    FAILED ("INCORRECT RESULTS FOR RECORDS - 6");
               END IF;
               PREC2.A := "WHO";
          END PROC;

     BEGIN
          REC2.A := "WHO";
          IF NOT (REC1'CONSTRAINED) OR REC2'CONSTRAINED THEN
               FAILED ("INCORRECT RESULTS FROM 'CONSTRAINED " &
                       "ATTRIBUTE - 1");
          ELSIF REC1 /= REC2 THEN
               FAILED ("INCORRECT RESULTS FOR RECORDS - 1");
          END IF;

          IF REC2'CONSTRAINED OR NOT (REC3'CONSTRAINED) THEN
               FAILED ("INCORRECT RESULTS FROM 'CONSTRAINED " &
                       "ATTRIBUTE - 2");
          ELSIF REC2 = REC3 THEN
               FAILED ("INCORRECT RESULTS FOR RECORDS - 2");
          END IF;

          REC2 := (5, "WHERE");
          IF REC2'CONSTRAINED OR NOT (REC3'CONSTRAINED) THEN
               FAILED ("INCORRECT RESULTS FROM 'CONSTRAINED " &
                       "ATTRIBUTE - 3");
          ELSIF REC2 /= REC3 THEN
               FAILED ("INCORRECT RESULTS FOR RECORDS - 3");
          END IF;

          REC4.A.A := 5;
          IF REC4'CONSTRAINED OR NOT (REC5'CONSTRAINED) THEN
               FAILED ("INCORRECT RESULTS FROM 'CONSTRAINED " &
                       "ATTRIBUTE - 4");
          ELSIF REC4 /= REC5 THEN
               FAILED ("INCORRECT RESULTS FOR RECORDS - 4");
          END IF;

          REC5.A := (A => 6);
          IF REC4'CONSTRAINED OR NOT (REC5'CONSTRAINED) THEN
               FAILED ("INCORRECT RESULTS FROM 'CONSTRAINED " &
                       "ATTRIBUTE - 5");
          ELSIF REC4 = REC5 THEN
               FAILED ("INCORRECT RESULTS FOR RECORDS - 5");
          END IF;

          REC1.A := "WHY";
          REC2 := (3, "WHY");
          PROC (REC1, REC2);
          IF NOT (REC1'CONSTRAINED) OR REC2'CONSTRAINED THEN
               FAILED ("INCORRECT RESULTS FROM 'CONSTRAINED " &
                       "ATTRIBUTE - 7");
          ELSIF REC1 = REC2 THEN
               FAILED ("INCORRECT RESULTS FOR RECORDS - 7");
          END IF;
     END;

     RESULT;
END C45273A;
