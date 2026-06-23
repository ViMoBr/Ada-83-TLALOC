-- C38108A.ADA

-- CHECK THAT AN INCOMPLETE TYPE CAN BE DECLARED IN THE PRIVATE PART OF
-- A PACKAGE, WITH THE FULL DECLARATION OCCURRING IN THE PACKAGE BODY.

-- AH  8/20/86

WITH REPORT; USE REPORT;
PROCEDURE C38108A IS

     PACKAGE P IS 
          TYPE L IS LIMITED PRIVATE;
          PROCEDURE ASSIGN (X : IN INTEGER; Y : IN OUT L);
          FUNCTION "=" (X, Y : IN L) RETURN BOOLEAN;
     PRIVATE
          TYPE INC (D : INTEGER);
          TYPE L IS ACCESS INC;
     END P;

     PACKAGE BODY P IS
          TYPE INC (D : INTEGER) IS
               RECORD
                    C : INTEGER;
               END RECORD;
          
          PROCEDURE ASSIGN (X : IN INTEGER; Y : IN OUT L) IS
          BEGIN
               Y := NEW INC(1);
               Y.C := X;
          END ASSIGN;

          FUNCTION "=" (X, Y : IN L) RETURN BOOLEAN IS
          BEGIN
               RETURN (X.C = Y.C);          
          END "=";

     END P;

USE P;
BEGIN

     TEST ("C38108A", "CHECK THAT INCOMPLETE TYPE CAN BE DECLARED IN " &
                      "PRIVATE PART WITHOUT FULL DECLARATION");
     DECLARE
          VAL_1, VAL_2 : L;
     BEGIN
          ASSIGN (2, VAL_1);
          ASSIGN (2, VAL_2);
          IF NOT "=" (VAL_1, VAL_2) THEN
               FAILED ("INCOMPLETE TYPE NOT FULLY DECLARED");
          END IF;
     END;

     RESULT;
END C38108A;
