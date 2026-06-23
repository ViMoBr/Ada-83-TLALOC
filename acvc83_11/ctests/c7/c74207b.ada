-- C74207B.ADA

-- CHECK THAT 'CONSTRAINED CAN BE APPLIED AFTER THE FULL DECLARATION OF
-- A PRIVATE TYPE THAT IS DERIVED FROM A PRIVATE TYPE.

-- BHS 6/18/84

WITH REPORT;
USE REPORT;
PROCEDURE C74207B IS
BEGIN
     TEST ("C74207B", "AFTER THE FULL DECLARATION OF A PRIVATE " &
                      "TYPE DERIVED FROM A PRIVATE TYPE, " &
                      "'CONSTRAINED MAY BE APPLIED");

     DECLARE
          PACKAGE P1 IS
               TYPE PREC (D : INTEGER) IS PRIVATE;
               TYPE P IS PRIVATE;
          PRIVATE
               TYPE PREC (D : INTEGER) IS RECORD
                         NULL; 
                    END RECORD;
               TYPE P IS NEW INTEGER;
          END P1;

          PACKAGE P2 IS
               TYPE LP1 IS LIMITED PRIVATE;
               TYPE LP2 IS LIMITED PRIVATE;
          PRIVATE
               TYPE LP1 IS NEW P1.PREC(3);
               TYPE LP2 IS NEW P1.P;
               B1 : BOOLEAN := LP1'CONSTRAINED;
               B2 : BOOLEAN := LP2'CONSTRAINED;
          END P2;

          PACKAGE BODY P2 IS
          BEGIN
               IF NOT IDENT_BOOL(B1) THEN
                    FAILED ("WRONG VALUE FOR LP1'CONSTRAINED");
               END IF;
               IF NOT IDENT_BOOL(B2) THEN
                    FAILED ("WRONG VALUE FOR LP2'CONSTRAINED");
               END IF;
          END P2;

     BEGIN
          NULL;
     END;

     RESULT;

END C74207B;
