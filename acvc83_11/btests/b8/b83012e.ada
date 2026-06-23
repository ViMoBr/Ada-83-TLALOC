-- B83012E.ADA

-- OBJECTIVE:
--     CHECK THAT WITHIN A SUBPROGRAM INSTANTIATION NO DECLARATION OF
--     THE DESIGNATOR OF THE DECLARED SUBPROGRAM IS VISIBLE, EITHER
--     DIRECTLY OR BY SELECTION.  THIS TEST CHECKS THE CASE IN WHICH
--     SUBPROGRAM NAMES ARE OPERATOR SYMBOLS.

-- HISTORY:
--     JET 08/09/88  CREATED ORIGINAL TEST.

PROCEDURE B83012E IS

     GENERIC
          TYPE T IS PRIVATE;
          I : T;
     FUNCTION OPER1 (R : T) RETURN INTEGER;

     GENERIC
          TYPE T IS PRIVATE;
          I : T;
     FUNCTION OPER2 (L, R : T) RETURN INTEGER;

     FUNCTION OPER1 (R : T) RETURN INTEGER IS BEGIN RETURN 0; END;
     FUNCTION OPER2 (L, R : T) RETURN INTEGER IS BEGIN RETURN 0; END;

     FUNCTION "+" IS NEW OPER2(INTEGER, 1+2);
                                           -- ERROR: "+" UNDENOTABLE.
     FUNCTION "-" IS NEW OPER1(INTEGER, -12);
                                           -- ERROR: "-" UNDENOTABLE.
     FUNCTION "+" IS NEW OPER1(INTEGER, 1+2);
                                           -- ERROR: "+" UNDENOTABLE.
     FUNCTION "-" IS NEW OPER2(INTEGER, -12);
                                           -- ERROR: "-" UNDENOTABLE.
     FUNCTION "+" IS NEW OPER2(FLOAT, "+"(12.0));
                                           -- ERROR: "+" UNDENOTABLE.
     FUNCTION "-" IS NEW OPER1(FLOAT, "-"(1.0,2.0));
                                           -- ERROR: "-" UNDENOTABLE.
     FUNCTION "+" IS NEW OPER1(FLOAT, STANDARD."+"(1.0,2.0));
                                           -- ERROR: "+" UNDENOTABLE.
     FUNCTION "-" IS NEW OPER2(FLOAT, STANDARD."-"(12.0));
                                           -- ERROR: "-" UNDENOTABLE.
     FUNCTION "AND" IS NEW OPER2(BOOLEAN, TRUE AND TRUE);
                                           -- ERROR: "AND" UNDENOTABLE.
     FUNCTION "NOT" IS NEW OPER1(BOOLEAN, NOT TRUE);
                                           -- ERROR: "NOT" UNDENOTABLE.
     FUNCTION "XOR" IS NEW OPER2(BOOLEAN, "XOR"(FALSE, FALSE));
                                           -- ERROR: "XOR" UNDENOTABLE.
     FUNCTION "ABS" IS NEW OPER1(INTEGER, STANDARD."ABS"(1));
                                           -- ERROR: "ABS" UNDENOTABLE.
BEGIN
     NULL;
END B83012E;
