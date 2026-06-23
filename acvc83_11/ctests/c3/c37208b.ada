-- C37208B.ADA
 
-- FOR A TYPE WITH DEFAULT DISCRIMINANT VALUES, CHECK THAT A
-- DISCRIMINANT CONSTRAINT CAN BE OMITTED IN A GENERIC FORMAL
-- PARAMETER, AND HENCE, FOR BOTH IN AND IN OUT PARAMETERS, THE
-- 'CONSTRAINED ATTRIBUTE OF THE ACTUAL PARAMETER BECOMES THE
-- 'CONSTRAINED ATTRIBUTE OF THE FORMAL PARAMETER, AND, FOR IN
-- OUT PARAMETERS, IF THE 'CONSTRAINED ATTRIBUTE IS FALSE,
-- ASSIGNMENTS TO THE FORMAL PARAMETERS CAN CHANGE THE
-- DISCRIMINANTS OF THE ACTUAL PARAMETER; IF THE 'CONSTRAINED
-- ATTRIBUTE IS  TRUE, ASSIGNMENTS THAT ATTEMPT TO CHANGE THE
-- DISCRIMINANTS OF THE ACTUAL PARAMETER RAISE CONSTRAINT_ERROR.
 
-- ASL 7/29/81
-- VKG 1/20/83

WITH REPORT;
PROCEDURE C37208B IS
 
     USE REPORT;
 
BEGIN
     TEST ("C37208B","FOR TYPES WITH DEFAULT DISCRIMINANT " &
            "VALUES, DISCRIMINANT CONSTRAINTS CAN BE OMITTED " &
            "IN GENERIC FORMAL PARAMETERS, AND THE " &
            "'CONSTRAINED ATTRIBUTE HAS CORRECT VALUES " &
            "DEPENDING ON THE ACTUAL PARAMETERS");
 
     DECLARE
          TYPE REC(DISC : INTEGER := 7) IS
               RECORD
                    NULL;
               END RECORD;
 
          KC : CONSTANT REC(3) := (DISC => 3);
          KU : CONSTANT REC := (DISC => 3);
          OBJC1,OBJC2 : REC(3) := (DISC => 3);
          OBJU1,OBJU2 : REC := (DISC => 3);
 
          GENERIC
               P_IN1 : REC;
               P_IN2 : REC;
               P_IN_OUT : IN OUT REC;
               STATUS : BOOLEAN;
          PROCEDURE PROC;

          PROCEDURE PROC IS
          BEGIN

               IF P_IN1'CONSTRAINED /= TRUE  OR
                  P_IN2'CONSTRAINED /= TRUE  OR
                  P_IN_OUT'CONSTRAINED /= STATUS
               THEN

                    FAILED ("'CONSTRAINED ATTRIBUTES DO NOT MATCH " &
                            "FOR ACTUAL AND FORMAL PARAMETERS");
               END IF;
               IF NOT STATUS THEN
                    BEGIN
                         P_IN_OUT := (DISC => IDENT_INT(7));
                    EXCEPTION 
                         WHEN OTHERS =>
                              FAILED ("EXCEPTION RAISED " &
                                      "WHEN TRYING TO " &
                                      "CHANGE UNCONSTRAINED " &
                                      "DISCRIMINANT VALUE");
                    END;
               ELSE
                    BEGIN
                         P_IN_OUT := (DISC => IDENT_INT(7));
                         FAILED ("DISCRIMINANT OF CONSTRAINED " &
                                 "ACTUAL PARAMETER ILLEGALLY " &
                                 "CHANGED BY ASSIGNMENT");
                    EXCEPTION
                         WHEN CONSTRAINT_ERROR => NULL;     
                         WHEN OTHERS => FAILED ("WRONG EXCEPTION");
                    END;
               END IF;
          END PROC;

     BEGIN

          DECLARE
               PROCEDURE PROC_C IS NEW PROC(KC,OBJC1,OBJC2,TRUE);
               PROCEDURE PROC_U IS NEW PROC(KU,OBJU1,OBJU2,FALSE);
          BEGIN
               PROC_C;
               PROC_U;
               IF OBJU2.DISC /= 7 THEN
               FAILED ("ASSIGNMENT TO UNCONSTRAINED ACTUAL " &
                       "PARAMETER FAILED TO CHANGE DISCRIMINANT ");
               END IF;
          END;

     END;
     RESULT;
END C37208B;
