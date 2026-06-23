-- CD5012I.ADA

-- OBJECTIVE:
--     CHECK THAT AN ADDRESS CLAUSE CAN BE GIVEN FOR A VARIABLE OF AN
--     ACCESS TYPE IN THE DECLARATIVE PART OF A GENERIC SUBPROGRAM.

-- HISTORY:
--     DHH 09/17/87  CREATED ORIGINAL TEST.
--     PWB 05/11/89  CHANGED EXTENSION FROM '.DEP' TO '.ADA'.

WITH SYSTEM; USE SYSTEM;
WITH REPORT; USE REPORT;
WITH SPPRT13;
PROCEDURE CD5012I IS

BEGIN

     TEST ("CD5012I", "AN ADDRESS CLAUSE CAN BE " &
                      "GIVEN FOR A VARIABLE OF AN ACCESS " &
                      "TYPE IN THE DECLARATIVE PART OF A " &
                      "GENERIC SUBPROGRAM");

     DECLARE

          GENERIC
          PROCEDURE GENPROC;

          PROCEDURE GENPROC IS

               TYPE CELL;
               TYPE POINTER IS ACCESS CELL;
               TYPE CELL IS
                    RECORD
                         VALUE : INTEGER;
                         NEXT : POINTER;
                    END RECORD;

               C,PTR : POINTER := NULL;

               FOR PTR USE AT
                      SPPRT13.VARIABLE_ADDRESS;
          BEGIN
               PTR := NEW CELL'(0,NULL);
               C := PTR;

               IF EQUAL (3, 3) THEN
                    PTR.VALUE := 1;
                    PTR.NEXT := C;
               END IF;
               IF PTR.ALL /= (1,C) THEN
                    FAILED ("WRONG VALUE FOR VARIABLE IN " &
                            "A GENERIC PROCEDURE");
               END IF;
               IF PTR'ADDRESS /= SPPRT13.VARIABLE_ADDRESS THEN
                    FAILED ("WRONG ADDRESS FOR VARIABLE " &
                            "IN A GENERIC PROCEDURE");
               END IF;
          END GENPROC;

          PROCEDURE PROC IS NEW GENPROC;
     BEGIN
          PROC;
     END;
     RESULT;
END CD5012I;
