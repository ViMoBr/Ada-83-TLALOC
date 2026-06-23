-- C37206A.ADA

-- OBJECTIVE:
--     FOR A TYPE WITHOUT DEFAULT DISCRIMINANT VALUES (BUT WITH
--     DISCRIMINANTS) CHECK THAT A TYPEMARK WHICH DENOTES SUCH AN
--     UNCONSTRAINED TYPE CAN BE USED IN:

--      1) A SUBTYPE DECLARATION, AND THE SUBTYPE NAME ACTS SIMPLY AS A
--         NEW NAME FOR THE UNCONSTRAINED TYPE;
--      2) AN ACCESS TYPE DEFINITION;
--      3) A FORMAL PARAMETER DECLARATION FOR A SUBPROGRAM, AND HENCE,
--         THE CONSTRAINTS OF THE ACTUAL PARAMETER ARE AVAILABLE WITHIN
--         THE SUBPROGRAM, 'CONSTRAINED IS TRUE, AND ASSIGNMENTS TO THE
--         FORMAL PARAMETER CANNOT ATTEMPT TO CHANGE THE DISCRIMINANTS
--         OF THE ACTUAL PARAMETER WITHOUT RAISING CONSTRAINT_ERROR;
--      4) IN A CONSTANT DECLARATION.

-- HISTORY:
--     AH  08/21/86 CREATED ORIGINAL TEST.
--     DHH 10/19/87 SHORTENED LINES CONTAINING MORE THAN 72 CHARACTERS.

WITH REPORT; USE REPORT;
PROCEDURE C37206A IS
BEGIN

     TEST ("C37206A", "FOR TYPE WITH DEFAULT-LESS DISCRIMINANTS, " &
           "UNCONSTRAINED TYPE_MARK CAN BE USED IN SUBTYPE " &
           "DECLARATION, ACCESS TYPE DEFINITION, " &
           "OR FORMAL SUBPROGRAM PARAMETER DECLARATION");

     DECLARE
          TYPE REC(DISC : INTEGER) IS
               RECORD
                    NULL;
               END RECORD;

          SUBTYPE ST IS REC;                               -- 1.

          X1, X2, X3 : ST(2) := (DISC => 2);

          TYPE REC_NAME IS ACCESS REC;                     -- 2.
          A1, A2, A3 : REC_NAME;

          C1 : CONSTANT REC := (DISC => 5);                -- 4.
          C2 : CONSTANT REC := (DISC => IDENT_INT(5));     -- 4.

          PROCEDURE PROC (P_IN : IN REC;                   -- 3.
                          P_OUT : OUT REC;                 -- 3.
                          P_IN_OUT : IN OUT REC;           -- 3.
                          DVAL : IN INTEGER) IS
          BEGIN

               IF P_IN.DISC /= DVAL  OR
                  P_OUT.DISC /= DVAL OR   -- DISCRIMINANTS CAN BE READ
                                          --   ALSO FOR "OUT" ACTUALS
                  P_IN_OUT.DISC /= DVAL
               THEN
                    FAILED ("DISCRIMINANT VALUES OF ACTUAL " &
                            "PARAMETERS NOT AVAILABLE WITHIN " &
                            "SUBPROGRAM");
               END IF;

               IF NOT (P_IN'CONSTRAINED AND P_OUT'CONSTRAINED
                                        AND P_IN_OUT'CONSTRAINED)
               THEN
                    FAILED ("'CONSTRAINED NOT TRUE FOR ALL FORMALS");
               END IF;

               BEGIN
                    P_OUT := (DISC => 0);
                    FAILED ("CONSTRAINT_ERROR NOT RAISED UPON " &
                            "ATTEMPT TO CHANGE DISCRIMINANT " &
                            "VALUE OF CONSTRAINED FORMAL OUT " &
                            "PARAMETER");
               EXCEPTION
                    WHEN CONSTRAINT_ERROR => NULL;
                    WHEN OTHERS => FAILED ("WRONG EXCEPTION - 1");
               END;

               BEGIN
                    P_IN_OUT := (DISC => 0);
                    FAILED ("CONSTRAINT ERROR NOT RAISED UPON " &
                            "ATTEMPT TO CHANGE DISCRIMINANT " &
                            "VALUE OF CONSTRAINED FORMAL IN OUT " &
                            "PARAMETER");
               EXCEPTION
                    WHEN CONSTRAINT_ERROR => NULL;
                    WHEN OTHERS => FAILED ("WRONG EXCEPTION - 2");
               END;

          END PROC;
     BEGIN

          IF C1 /= C2 OR C1 /= (DISC => 5) THEN
               FAILED ("CONSTANT DECLARATIONS INCORRECT");
          END IF;

          A1 := NEW REC(3);
          A2 := NEW REC(3);
          A3 := NEW REC(3);

          PROC (X1, X2, X3, 2);
          PROC (A1.ALL, A2.ALL, A3.ALL, 3);
     END;

     RESULT;
END C37206A;
