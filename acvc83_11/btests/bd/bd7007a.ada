-- BD7007A.ADA

-- OBJECTIVE:
--     THE SUBTYPE PRIORITY IS NOT DECLARED WITHIN STANDARD.
--     (REFER TO PRIORITY AND TO STANDARD.PRIORITY.)

-- HISTORY:
--     LDC  06/14/88 CREATED ORIGINAL TEST.

PROCEDURE BD7007A IS

     PRI1 : PRIORITY;                             -- ERROR:

     PRI2 : STANDARD.PRIORITY;                    -- ERROR: PRIORITY
                                                  -- SHOULD BE DEFINED
                                                  -- IN SYSTEM.
BEGIN
     NULL;
END BD7007A;
