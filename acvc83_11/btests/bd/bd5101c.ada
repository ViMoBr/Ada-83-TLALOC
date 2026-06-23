-- BD5101C.ADA

-- OBJECTIVE:
--     CHECK THAT AN ADDRESS SPECIFICATION CANNOT BE GIVEN FOR AN ENTRY
--     OF A TASK TYPE IF THE ENTRY HAS A PARAMETER OF MODE 'OUT' OR
--     'IN OUT'.

-- HISTORY:
--     JET 08/23/88  CREATED ORIGINAL TEST.

WITH SYSTEM, SPPRT13;
PROCEDURE BD5101C IS

     TASK TYPE TASK1 IS
          ENTRY ENTRY1 (PARAM1 : OUT INTEGER);
          FOR ENTRY1 USE AT SPPRT13.ENTRY_ADDRESS;   -- ERROR:  ADDRESS
                                                     -- CLAUSE FOR ENTRY
                                                     -- WITH OUT
                                                     -- PARAMETER.
     END TASK1;

     TASK TYPE TASK2 IS
          ENTRY ENTRY1 (PARAM1 : IN OUT INTEGER);
          FOR ENTRY1 USE AT SPPRT13.ENTRY_ADDRESS;   -- ERROR:  ADDRESS
                                                     -- CLAUSE FOR ENTRY
                                                     -- WITH IN OUT
                                                     -- PARAMETER.
     END TASK2;

     TASK BODY TASK1 IS
     BEGIN
          ACCEPT ENTRY1 (PARAM1 : OUT INTEGER) DO
               NULL;
          END ENTRY1;
     END TASK1;

     TASK BODY TASK2 IS
     BEGIN
          ACCEPT ENTRY1 (PARAM1 : IN OUT INTEGER) DO
               NULL;
          END ENTRY1;
     END TASK2;

BEGIN
     NULL;
END BD5101C;
