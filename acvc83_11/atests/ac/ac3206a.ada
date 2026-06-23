-- AC3206A.ADA

-- OBJECTIVE:
--     CHECK THAT AN INSTANTIATION IS LEGAL IF A FORMAL PRIVATE TYPE IS
--     USED IN  A CONSTANT DECLARATION AND THE ACTUAL PARAMETER IS A
--     TYPE WITH DISCRIMINANTS THAT DO AND DO NOT HAVE DEFAULTS. (CHECK
--     CASES THAT USED TO BE FORBIDDEN).

-- HISTORY:
--     DHH 09/16/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE AC3206A IS

BEGIN
     TEST ("AC3206A", "CHECK THAT AN INSTANTIATION IS LEGAL IF A " &
                      "FORMAL PRIVATE TYPE IS USED IN  A CONSTANT " &
                      "DECLARATION AND THE ACTUAL PARAMETER IS A " &
                      "TYPE WITH DISCRIMINANTS THAT DO AND DO NOT " &
                      "HAVE DEFAULTS");

     DECLARE             -- CHECK DEFAULTS LEGAL UNDER AI-37.

          GENERIC
               TYPE GEN IS PRIVATE;
               INIT : GEN;
          PACKAGE GEN_PACK IS
               CONST : CONSTANT GEN := INIT;
               SUBTYPE NEW_GEN IS GEN;
          END GEN_PACK;

          TYPE REC(A : INTEGER := 4) IS
               RECORD
                    X : INTEGER;
                    Y : BOOLEAN;
               END RECORD;

          PACKAGE P IS NEW GEN_PACK(REC, (4, 5, FALSE));
          USE P;

          CON : CONSTANT P.NEW_GEN := (4, 5, FALSE);

     BEGIN
          NULL;
     END;

     DECLARE

          GENERIC
               TYPE GEN(DIS : INTEGER) IS PRIVATE;
               INIT : GEN;
          PACKAGE GEN_PACK IS
               CONST : CONSTANT GEN := INIT;
               SUBTYPE NEW_GEN IS GEN(4);
          END GEN_PACK;

          TYPE REC(A : INTEGER := 4) IS
               RECORD
                    X : INTEGER;
                    Y : BOOLEAN;
               END RECORD;

          PACKAGE P IS NEW GEN_PACK(REC, (4, 5, FALSE));
          USE P;

          CON : CONSTANT P.NEW_GEN := (4, 5, FALSE);

     BEGIN
          NULL;
     END;

     DECLARE

          GENERIC
               TYPE GEN(DIS : INTEGER) IS PRIVATE;
               INIT : GEN;
          PACKAGE GEN_PACK IS
               CONST : CONSTANT GEN := INIT;
               SUBTYPE NEW_GEN IS GEN(4);
          END GEN_PACK;

          TYPE REC(A : INTEGER) IS
               RECORD
                    X : INTEGER;
                    Y : BOOLEAN;
               END RECORD;

          PACKAGE P IS NEW GEN_PACK(REC, (4, 5, FALSE));
          USE P;

          CON : CONSTANT P.NEW_GEN := (4, 5, FALSE);

     BEGIN
          NULL;
     END;

     RESULT;
END AC3206A;
