-- BD5101B.ADA

-- OBJECTIVE:
--      CHECK THAT AN ADDRESS CLAUSE CANNOT BE SPECIFIED FOR AN
--      ENTRY THAT HAS A PARAMETER OF MODE IN OUT.

-- HISTORY:
--      DJ  09/09/87  CREATED ORIGINAL TEST.
--      DWC 09/29/87  REFORMATTED TEST AND DELETED PACKAGE BODY.

WITH SYSTEM;
WITH SPPRT13; USE SPPRT13;

PACKAGE BD5101B IS

     TASK TASK1 IS
          ENTRY ENTRY1 (PARAM1 : IN OUT INTEGER);
          FOR ENTRY1 USE AT ENTRY_ADDRESS;           -- ERROR:  ADDRESS
                                                     -- CLAUSE FOR ENTRY
                                                     -- WITH IN OUT
                                                     -- PARAMETER.
     END TASK1;

END BD5101B;
