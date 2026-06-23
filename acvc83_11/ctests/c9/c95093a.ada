-- C95093A.ADA

-- CHECK THAT THE DEFAULT EXPRESSIONS OF FORMAL PARAMETERS ARE EVALUATED
-- EACH TIME THEY ARE NEEDED.

-- GLH 7/2/85

WITH REPORT; USE REPORT;

PROCEDURE C95093A IS
BEGIN

     TEST ("C95093A", "CHECK THAT THE DEFAULT EXPRESSION IS " &
                      "EVALUATED EACH TIME IT IS NEEDED");

     DECLARE

          X : INTEGER := 1;

          FUNCTION F RETURN INTEGER IS
          BEGIN
               X := X + 1;
               RETURN X;
          END F;

          TASK T1 IS
               ENTRY E1 (X, Y : INTEGER := F);
          END T1;

          TASK BODY T1 IS
          BEGIN

               ACCEPT E1 (X, Y : INTEGER := F) DO
                    IF X = Y OR Y /= 2 THEN
                         FAILED ("DEFAULT NOT EVALUATED CORRECTLY - " &
                                 "1, X =" & INTEGER'IMAGE(X) &
                                 ", Y =" & INTEGER'IMAGE(Y));
                    END IF;
               END E1;

               ACCEPT E1 (X, Y : INTEGER := F) DO
                    IF X = Y OR
                       NOT ((X = 3 AND Y = 4) OR
                            (X = 4 AND Y = 3)) THEN
                         FAILED ("DEFAULT NOT EVALUATED CORRECTLY - " &
                                 "2, X =" & INTEGER'IMAGE(X) &
                                 ", Y =" & INTEGER'IMAGE(Y));
                    END IF;
               END E1;

          END T1;

     BEGIN

          COMMENT ("FIRST CALL");
          T1.E1 (3);

          COMMENT ("SECOND CALL");
          T1.E1;

     END;

     RESULT;

END C95093A;
