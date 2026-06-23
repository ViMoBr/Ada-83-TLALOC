-- C83007A.ADA

-- OBJECTIVE:
--     CHECK THAT A FORMAL PARAMETER OF A SUBPROGRAM DECLARED BY A
--     RENAMING DECLARATION CAN HAVE THE SAME IDENTIFIER AS A
--     DECLARATION IN THE BODY OF THE RENAMED SUBPROGRAM.

-- HISTORY:
--     VCL  02/18/88  CREATED ORIGINAL TEST.


WITH REPORT;  USE REPORT;
PROCEDURE C83007A IS
BEGIN
     TEST ("C83007A", "A FORMAL PARAMETER OF A SUBPROGRAM DECLARED " &
                      "BY A RENAMING DECLARATION CAN HAVE THE SAME " &
                      "IDENTIFIER AS A DECLARATION IN THE BODY OF " &
                      "THE RENAMED SUBPROGRAM");
     DECLARE
          PROCEDURE P (ONE : INTEGER; TWO : FLOAT; THREE : STRING);

          PROCEDURE R (D1 : INTEGER;
                       D2 : FLOAT;
                       D3 : STRING)  RENAMES P;

          PROCEDURE P (ONE : INTEGER; TWO : FLOAT; THREE : STRING) IS
               TYPE D1 IS RANGE 1..10;
               I : D1 := D1(IDENT_INT (7));

               D2 : FLOAT;

               FUNCTION D3 RETURN STRING IS
               BEGIN
                    RETURN "D3";
               END D3;

               FUNCTION IDENT_FLOAT (VAL : FLOAT) RETURN FLOAT IS
               BEGIN
                    IF EQUAL (3, 3) THEN
                         RETURN VAL;
                    ELSE
                         RETURN 0.0;
                    END IF;
               END IDENT_FLOAT;

          BEGIN
               IF ONE /= 5 THEN
                    FAILED ("INCORRECT VALUE FOR PARAMETER ONE");
               END IF;
               IF TWO /= 4.5 THEN
                    FAILED ("INCORRECT VALUE FOR PARAMETER TWO");
               END IF;
               IF THREE /= "R1" THEN
                    FAILED ("INCORRECT VALUE FOR PARAMETER THREE");
               END IF;

               IF I /= 7 THEN
                    FAILED ("INCORRECT VALUE FOR OBJECT I");
               END IF;
               D2 := IDENT_FLOAT (3.5);
               IF D2 /= 3.5 THEN
                    FAILED ("INCORRECT VALUE FOR OBJECT D2");
               END IF;
               IF D3 /= "D3" THEN
                    FAILED ("INCORRECT VALUE FOR FUNCTION D3");
               END IF;
          END P;
     BEGIN
          R (D1=>5, D2=>4.5, D3=>"R1");
     END;

     RESULT;
END C83007A;
