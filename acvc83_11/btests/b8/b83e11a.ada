-- B83E11A.ADA

-- OBJECTIVE:
--     CHECK THAT AN ENTRY DECLARATION CANNOT DECLARE AN ENTRY OR AN
--     ENTRY FAMILY WITH DUPLICATE FORMAL PARAMETER NAMES.

-- HISTORY:
--     DHH 09/14/88  CREATED ORIGINAL TEST.

PROCEDURE B83E11A IS

     TASK T1 IS
          ENTRY DUP(PARAM1 : BOOLEAN;
                    PARAM1 : INTEGER;                         -- ERROR:
                    PARAM1 : CHARACTER;                       -- ERROR:
                    PARAM3 : STRING;
                    PARAM1 : STRING;                          -- ERROR:
                    PARAM2 : INTEGER;
                    PARAM1 : INTEGER);                        -- ERROR:
     END T1;

     TASK TYPE T2 IS
          ENTRY DUP(PARAM1 : BOOLEAN;
                    PARAM3 : STRING;
                    PARAM1 : STRING;                          -- ERROR:
                    PARAM2 : INTEGER;
                    PARAM1 : INTEGER);                        -- ERROR:
     END T2;

     TYPE COLOR IS (RED, YELLOW, BLUE);

     TASK T3 IS
          ENTRY DUP(COLOR)
                   (PARAM1 : INTEGER;
                    PARAM2 : INTEGER;
                    PARAM1 : INTEGER);                        -- ERROR:
     END T3;

     TASK BODY T1 IS
     BEGIN
          ACCEPT DUP(PARAM1 : BOOLEAN;
                     PARAM1 : INTEGER;          -- OPTIONAL ERR MESSAGE.
                     PARAM1 : CHARACTER;        -- OPTIONAL ERR MESSAGE.
                     PARAM3 : STRING;
                     PARAM1 : STRING;           -- OPTIONAL ERR MESSAGE.
                     PARAM2 : INTEGER;
                     PARAM1 : INTEGER);         -- OPTIONAL ERR MESSAGE.
     END T1;

     TASK BODY T2 IS
     BEGIN
          ACCEPT DUP(PARAM1 : BOOLEAN;
                     PARAM3 : STRING;
                     PARAM1 : STRING;           -- OPTIONAL ERR MESSAGE.
                     PARAM2 : INTEGER;
                     PARAM1 : INTEGER);         -- OPTIONAL ERR MESSAGE.
     END T2;

     TASK BODY T3 IS
     BEGIN
          ACCEPT DUP(RED)
                    (PARAM1 : INTEGER;
                     PARAM2 : INTEGER;
                     PARAM1 : INTEGER);         -- OPTIONAL ERR MESSAGE.
          ACCEPT DUP(YELLOW)
                    (PARAM1 : INTEGER;
                     PARAM2 : INTEGER;
                     PARAM1 : INTEGER);         -- OPTIONAL ERR MESSAGE.
          ACCEPT DUP(BLUE)
                    (PARAM1 : INTEGER;
                     PARAM2 : INTEGER;
                     PARAM1 : INTEGER);         -- OPTIONAL ERR MESSAGE.
     END T3;

BEGIN
     NULL;
END B83E11A;
