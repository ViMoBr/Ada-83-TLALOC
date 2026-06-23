-- C95074C.ADA

-- CHECK THAT 'FIRST, 'LAST, 'LENGTH, AND 'RANGE, CAN BE APPLIED TO AN
-- OUT PARAMETER OR OUT PARAMETER SUBCOMPONENT THAT DOES NOT HAVE AN
-- ACCESS TYPE.

-- JWC 6/25/85

WITH REPORT; USE REPORT;
PROCEDURE C95074C IS

BEGIN

     TEST ("C95074C", "CHECK THAT ATTRIBUTES MAY BE APPLIED TO " &
                      "NON-ACCESS FORMAL OUT PARAMETERS");

     DECLARE

          TYPE ARR IS ARRAY (1 .. 10) OF NATURAL;

          TYPE REC IS RECORD
               A : ARR;
          END RECORD;

          A1 : ARR;
          R1 : REC;

          TASK T1 IS
               ENTRY E (A2 : OUT ARR; R2 : OUT REC);
          END T1;

          TASK BODY T1 IS
          BEGIN
               ACCEPT E (A2 : OUT ARR; R2 : OUT REC) DO

                    IF A2'FIRST /= 1 THEN
                         FAILED ("WRONG VALUE FOR A2'FIRST");
                    END IF;

                    IF A2'LAST /= 10 THEN
                         FAILED ("WRONG VALUE FOR A2'LAST");
                    END IF;

                    IF A2'LENGTH /= 10 THEN
                         FAILED ("WRONG VALUE FOR A2'LENGTH");
                    END IF;

                    IF (1 NOT IN A2'RANGE) OR
                       (10 NOT IN A2'RANGE) OR
                       (0 IN A2'RANGE) OR
                       (11 IN A2'RANGE) THEN
                         FAILED ("WRONG VALUE FOR A2'RANGE");
                    END IF;

                    IF R2.A'FIRST /= 1 THEN
                         FAILED ("WRONG VALUE FOR R2.A'FIRST");
                    END IF;

                    IF R2.A'LAST /= 10 THEN
                         FAILED ("WRONG VALUE FOR R2.A'LAST");
                    END IF;

                    IF R2.A'LENGTH /= 10 THEN
                         FAILED ("WRONG VALUE FOR R2.A'LENGTH");
                    END IF;

                    IF (1 NOT IN R2.A'RANGE) OR
                       (10 NOT IN R2.A'RANGE) OR
                       (0 IN R2.A'RANGE) OR
                       (11 IN R2.A'RANGE) THEN
                         FAILED ("WRONG VALUE FOR R2.A'RANGE");
                    END IF;
               END E;
          END T1;

     BEGIN
          T1.E (A1,R1);
     END;

     RESULT;
END C95074C;
