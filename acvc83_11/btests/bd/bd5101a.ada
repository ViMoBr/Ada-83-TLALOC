-- BD5101A.ADA

-- OBJECTIVE:
--     CHECK THAT AN ADDRESS CLAUSE CANNOT BE SPECIFIED FOR AN
--     ENTRY THAT HAS A PARAMETER OF MODE OUT.

-- HISTORY:
--     DJ  09/08/87  CREATED ORIGINAL TEST.
--     DWC 09/29/87  REFORMATTED TEST AND DELETED PACKAGE BODY.

WITH SYSTEM;
WITH SPPRT13; USE SPPRT13;

PACKAGE BD5101A IS

     TASK TASK1 IS
          ENTRY ENTRY1 (PARAM1 : OUT INTEGER);
          FOR ENTRY1 USE AT ENTRY_ADDRESS;          -- ERROR:  ADDRESS
                                                    -- CLAUSE FOR ENTRY
                                                    -- WITH OUT
                                                    -- PARAMETER.
     END TASK1;

END BD5101A;
