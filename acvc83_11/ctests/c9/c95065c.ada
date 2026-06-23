-- C95065C.ADA

-- CHECK THAT CONSTRAINT_ERROR IS NOT RAISED WHEN AN ENTRY IS DECLARED
-- IF THE VALUE OF THE DEFAULT EXPRESSION FOR THE FORMAL PARAMETER DOES
-- NOT SATISFY THE CONSTRAINTS OF THE TYPE MARK, BUT IS RAISED WHEN THE
-- ENTRY IS CALLED AND THE DEFAULT VALUE IS USED.

-- CASE (C) A RECORD PARAMETER WHOSE COMPONENTS HAVE NON-STATIC
--          CONSTRAINTS INITIALIZED WITH A STATIC AGGREGATE.

-- JWC 6/19/85

WITH REPORT; USE REPORT;
PROCEDURE C95065C IS

BEGIN

     TEST ("C95065C", "CHECK THAT CONSTRAINT_ERROR IS NOT RAISED IF " &
                      "AN INITIALIZATION VALUE DOES NOT SATISFY " &
                      "CONSTRAINTS ON A FORMAL PARAMETER WHEN THE " &
                      "FORMAL PART IS ELABORATED");

     BEGIN

          DECLARE

               TYPE A1 IS ARRAY (1 .. 3) OF INTEGER
                                RANGE IDENT_INT(1) .. IDENT_INT(3);

               TYPE REC IS
                    RECORD
                         I : INTEGER RANGE IDENT_INT(1)..IDENT_INT(3);
                         A : A1;
                    END RECORD;

               TASK T IS
                    ENTRY E1 (R : REC := (-3,(0,2,3)));
               END T;

               TASK BODY T IS
               BEGIN
                    SELECT
                         ACCEPT E1 (R : REC := (-3,(0,2,3))) DO
                              FAILED ("ACCEPT E1 EXECUTED");
                         END E1;
                    OR
                         TERMINATE;
                    END SELECT;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("EXCEPTION RAISED IN TASK T");
               END T;

          BEGIN
               T.E1;
               FAILED ("CONSTRAINT ERROR NOT RAISED ON CALL TO T.E1");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - E1");
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               FAILED ("CONSTRAINT_ERROR RAISED (BY ENTRY DECL)");
          WHEN TASKING_ERROR =>
               FAILED ("TASKING_ERROR RAISED");
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED");
     END;

     RESULT;

END C95065C;
