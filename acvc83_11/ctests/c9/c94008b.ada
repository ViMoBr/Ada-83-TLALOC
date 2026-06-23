-- C94008B.ADA

-- CHECK THAT A TASK WAITING AT AN OPEN TERMINATE ALTERNATIVE
-- DOES  N O T  TERMINATE UNTIL ALL OTHER TASKS DEPENDING ON THE SAME
-- UNIT EITHER ARE TERMINATED OR ARE WAITING AT AN OPEN TERMINATE.

-- WEI  3/ 4/82
-- TBN 11/25/85     RENAMED FROM C940BBA-B.ADA.

WITH REPORT;
 USE REPORT;
PROCEDURE C94008B IS
BEGIN
     TEST ("C94008B", "TERMINATION WHILE WAITING AT AN OPEN TERMINATE");

BLOCK1 :
     DECLARE

          TASK TYPE TT1 IS
               ENTRY E1;
          END TT1;

          NUMB_TT1 : CONSTANT NATURAL := 3;
          DELAY_TIME : DURATION := 0.0;
          ARRAY_TT1 : ARRAY (1 .. NUMB_TT1) OF TT1;

          TASK BODY TT1 IS
          BEGIN
               DELAY_TIME := DELAY_TIME + 1.0;
               DELAY DELAY_TIME;
               FOR I IN 1 .. NUMB_TT1
               LOOP
                    IF ARRAY_TT1 (I)'TERMINATED THEN
                         FAILED ("TOO EARLY TERMINATION OF " &
                                 "TASK TT1 INDEX" & INTEGER'IMAGE(I));
                    END IF;
               END LOOP;

               SELECT
                    WHEN TRUE => TERMINATE;
                 OR WHEN FALSE => ACCEPT E1;
               END SELECT;
          END TT1;

     BEGIN  -- BLOCK1.
          FOR I IN 1 .. NUMB_TT1
          LOOP
               IF ARRAY_TT1 (I)'TERMINATED THEN
                    FAILED ("TERMINATION BEFORE OUTER " &
                            "UNIT HAS BEEN LEFT OF TASK TT1 INDEX " &
                            INTEGER'IMAGE(I));
               END IF;
          END LOOP;
     END BLOCK1;

     RESULT;

END C94008B;
