-- CC2002A.ADA

-- CHECK THAT THE ELABORATION OF A GENERIC BODY HAS NO EFFECT OTHER
-- THAN TO ESTABLISH THE TEMPLATE BODY TO BE USED FOR THE
-- CORRESPONDING INSTANTIATIONS.

-- ASL 09/02/81
-- EG  10/30/85  ELIMINATE THE USE OF NUMERIC_ERROR IN TEST.

WITH REPORT; USE REPORT;
PROCEDURE CC2002A IS

     GLOBAL : INTEGER := 0;
     Q : INTEGER RANGE 1..1 := 1;
BEGIN
     TEST ("CC2002A","NO SIDE EFFECTS OF ELABORATION OF GENERIC BODY");

     BEGIN
          DECLARE
               GENERIC
                    PACKAGE P IS
                    END P;

               GENERIC PROCEDURE PROC;

                    PROCEDURE PROC IS
                         C : CONSTANT INTEGER RANGE 1 .. 1 := 2;
                    BEGIN
                         RAISE PROGRAM_ERROR;
                    END PROC;

                    PACKAGE BODY P IS
                         C : CONSTANT BOOLEAN := BOOLEAN'SUCC(TRUE);
                    BEGIN
                         GLOBAL := 1;
                         Q := Q + 1;
                    END P;
          BEGIN
               NULL;
          END;
     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED DURING ELABORATION OF " &
                       "GENERIC BODY");
     END;

     IF GLOBAL /= 0 THEN
          FAILED ("VALUE OF GLOBAL VARIABLE CHANGED BY ELABORATION " &
                  "OF GENERIC BODY");
     END IF;

     RESULT;
END CC2002A;
