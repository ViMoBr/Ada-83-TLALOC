-- C64202A.ADA

-- CHECK THAT THE DEFAULT EXPRESSIONS OF FORMAL PARAMETERS ARE EVALUATED
-- EACH TIME THEY ARE NEEDED.

-- SPS 2/22/84

WITH REPORT; USE REPORT;
PROCEDURE C64202A IS
BEGIN

     TEST ("C64202A", "CHECK THAT THE DEFAULT EXPRESSION IS EVALUATED" &
           " EACH TIME IT IS NEEDED");

     DECLARE
          X : INTEGER := 1;
          FUNCTION F RETURN INTEGER IS
          BEGIN
               X := X + 1;
               RETURN X;
          END F;

          PROCEDURE P (CALL : POSITIVE; X, Y : INTEGER := F) IS 
          BEGIN
               IF CALL = 1 THEN
                    IF X = Y OR Y /= 2 THEN
                         FAILED ("DEFAULT NOT EVALUATED CORRECTLY - 1" &
                                 " X =" & INTEGER'IMAGE(X) & " Y =" &
                                 INTEGER'IMAGE(Y));
                    END IF;
               ELSIF CALL = 2 THEN
                    IF X = Y OR 
                       NOT ((X = 3 AND Y = 4) OR (X = 4 AND Y = 3)) THEN
                         FAILED ("DEFAULT NOT EVALUATED CORRECTLY - 2" &
                                 " X =" & INTEGER'IMAGE(X) & " Y =" &
                                 INTEGER'IMAGE(Y));
                    END IF;
               END IF;
          END P;

     BEGIN
          COMMENT ("FIRST CALL");
          P (1, 3);
          COMMENT ("SECOND CALL");
          P(2);
     END;

     RESULT;

END C64202A;
