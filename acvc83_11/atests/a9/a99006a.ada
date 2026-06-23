-- A99006A.ADA

-- OBJECTIVE:
--     CHECK THAT 'COUNT RETURNS A UNIVERSAL INTEGER VALUE.

-- HISTORY:
--     DHH 03/28/88 CREATED ORIGINAL TEST.

WITH SYSTEM; USE SYSTEM;
WITH REPORT; USE REPORT;
PROCEDURE A99006A IS

     TASK CHOICE IS
          ENTRY START;
          ENTRY E1;
          ENTRY STOP;
     END CHOICE;

     TASK BODY CHOICE IS
          X : INTEGER;
     BEGIN
          ACCEPT START;
          ACCEPT E1 DO
               DECLARE
                    TYPE Y IS NEW INTEGER RANGE -5 .. 5;
                    T : Y := E1'COUNT;
               BEGIN
                    X := E1'COUNT;
               END;
          END E1;
          ACCEPT STOP;
     END CHOICE;

BEGIN

     TEST("A99006A", "CHECK THAT 'COUNT RETURNS A UNIVERSAL INTEGER " &
                     "VALUE");

     CHOICE.START;
     CHOICE.E1;
     CHOICE.STOP;

     RESULT;
END A99006A;
