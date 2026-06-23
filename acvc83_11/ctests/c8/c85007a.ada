-- C85007A.ADA

-- CHECK THAT THE DISCRIMINANTS OF A RENAMED OUT FORMAL PARAMETER, AS
-- WELL AS THE DISCRIMINANTS OF THE RENAMED SUBCOMPONENTS OF AN OUT
-- FORMAL PARAMETER, MAY BE READ INSIDE THE PROCEDURE.

-- SPS 02/17/84 (SEE C62006A-B.ADA)
-- EG  02/21/84

WITH REPORT; USE REPORT;

PROCEDURE C85007A IS

BEGIN

     TEST ("C85007A", "CHECK THAT THE DISCRIMINANTS OF A RENAMED OUT " &
           "FORMAL PARAMETER CAN BE READ INSIDE THE PROCEDURE");

     DECLARE

          TYPE R1 (D1 : INTEGER) IS RECORD
               NULL;
          END RECORD;

          TYPE R2 (D2 : POSITIVE) IS RECORD
               C : R1 (2);
          END RECORD;

          SUBTYPE R1_2 IS R1(2);

          R : R2 (5);

          PROCEDURE PROC (REC : OUT R2) IS

               REC1 : R2   RENAMES REC;
               REC2 : R1_2 RENAMES REC.C;
               REC3 : R2   RENAMES REC1;
               REC4 : R1_2 RENAMES REC1.C;
               REC5 : R1_2 RENAMES REC4;

          BEGIN

               IF REC1.D2 /= 5 THEN
                    FAILED ("UNABLE TO CORRECTLY READ DISCRIMINANT OF" &
                            " A RENAMED OUT PARAMETER");
               END IF;

               IF REC1.C.D1 /= 2 THEN
                    FAILED ("UNABLE TO CORRECTLY READ DISCRIMINANT " &
                            "OF THE SUBCOMPONENT OF A RENAMED OUT "  &
                            "PARAMETER");
               END IF;

               IF REC2.D1 /= 2 THEN
                    FAILED ("UNABLE TO CORRECTLY READ DISCRIMINANT " &
                            "OF A RENAMED SUBCOMPONENT OF AN OUT "   &
                            "PARAMETER");
               END IF;

               IF REC3.D2 /= 5 THEN
                    FAILED ("UNABLE TO CORRECTLY READ DISCRIMINANT OF" &
                            " A RENAME OF A RENAMED OUT PARAMETER");
               END IF;

               IF REC3.C.D1 /= 2 THEN
                    FAILED ("UNABLE TO CORRECTLY READ DISCRIMINANT " &
                            "OF THE SUBCOMPONENT OF A RENAME OF A "  &
                            "RENAMED OUT PARAMETER");
               END IF;

               IF REC4.D1 /= 2 THEN
                    FAILED ("UNABLE TO CORRECTLY READ DISCRIMINANT " &
                            "OF A RENAMED SUBCOMPONENT OF A RENAMED" &
                            " OUT PARAMETER");
               END IF;

               IF REC5.D1 /= 2 THEN
                    FAILED ("UNABLE TO CORRECTLY READ DISCRIMINANT " &
                            "OF A RENAME OF RENAMED SUBCOMPONENT OF" &
                            " A RENAMED OUT PARAMETER");
               END IF;

          END PROC;

     BEGIN

          PROC (R);

     END;

     RESULT;

END C85007A;
