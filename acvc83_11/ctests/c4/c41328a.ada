-- C41328A.ADA

-- CHECK THAT IMPLICITLY DECLARED DERIVED SUBPROGRAMS CAN BE SELECTED
-- FROM OUTSIDE A PACKAGE USING AN EXPANDED NAME, FOR A DERIVED TYPE.

-- TBN  7/21/86

WITH REPORT; USE REPORT;
PROCEDURE C41328A IS

     PACKAGE P IS
          PACKAGE Q IS
               TYPE PAIR IS ARRAY (1..2) OF INTEGER;
               FUNCTION INIT (INT : INTEGER) RETURN PAIR;
               PROCEDURE SWAP (TWO : IN OUT PAIR);
          END Q;
          TYPE COUPLE IS NEW Q.PAIR;
     END P;

     VAR_1 : P.COUPLE;
     VAR_2 : P.COUPLE;

     PACKAGE BODY P IS

          PACKAGE BODY Q IS

               FUNCTION INIT (INT : INTEGER) RETURN PAIR IS
                    A : PAIR;
               BEGIN
                    A (1) := INT;
                    A (2) := INT + 1;
                    RETURN (A);
               END INIT;

               PROCEDURE SWAP (TWO : IN OUT PAIR) IS
                    TEMP : INTEGER;
               BEGIN
                    TEMP := TWO (1);
                    TWO (1) := TWO (2);
                    TWO (2) := TEMP;
               END SWAP;

          BEGIN
               NULL;
          END Q;

     BEGIN
          NULL;
     END P;

BEGIN
     TEST ("C41328A", "CHECK THAT IMPLICITLY DECLARED DERIVED " &
                      "SUBPROGRAMS CAN BE SELECTED FROM OUTSIDE A " &
                      "PACKAGE USING AN EXPANDED NAME, FOR A DERIVED " &
                      "TYPE");

     VAR_1 := P.INIT (IDENT_INT(1));
     IF P."/=" (VAR_1, P.COUPLE'(1 => 1, 2 => 2)) THEN
          FAILED ("INCORRECT RESULTS FROM DERIVED SUBPROGRAM - 1");
     END IF;

     VAR_2 := P.INIT (IDENT_INT(2));
     IF P."=" (VAR_2, P.COUPLE'(1 => 1, 2 => 2)) THEN
          FAILED ("INCORRECT RESULTS FROM DERIVED SUBPROGRAM - 2");
     END IF;

     P.SWAP (VAR_1);
     IF P."=" (VAR_1, P.COUPLE'(1 => 1, 2 => 2)) THEN
          FAILED ("INCORRECT RESULTS FROM DERIVED SUBPROGRAM - 3");
     END IF;

     P.SWAP (VAR_2);
     IF P."/=" (VAR_2, P.COUPLE'(1 => 3, 2 => 2)) THEN
          FAILED ("INCORRECT RESULTS FROM DERIVED SUBPROGRAM - 4");
     END IF;

     RESULT;
END C41328A;
