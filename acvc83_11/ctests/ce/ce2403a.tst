-- CE2403A.TST

-- OBJECTIVE:
--     CHECK THAT, FOR DIRECT_IO, WRITE RAISES THE EXCEPTION
--     USE_ERROR IF THE CAPACITY OF THE EXTERNAL FILE IS EXCEEDED.
--     THIS TEST ONLY CHECKS THAT THE IMPLEMENTATION SUPPORTS AN
--     EXTERNAL FILE CAPACITY OF 4096 CHARACTERS OR LESS.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS ONLY APPLICABLE TO IMPLEMENTATIONS WHICH SUPPORT
--     DIRECT FILES.  ALSO, THE IMPLEMENTATION MUST BE ABLE TO
--     RESTRICT THE CAPACITY OF AN EXTERNAL FILE.

--     $FORM_STRING2 IS DEFINED SUCH THAT THE CAPACITY OF THE FILE IS
--     RESTRICTED TO 4096 CHARACTERS OR LESS. IF THE IMPLEMENTATION
--     CANNOT RESTRICT FILE CAPACITY, $FORM_STRING2 SHOULD EQUAL
--     "CANNOT_RESTRICT_FILE_CAPACITY".

-- HISTORY:
--     JLH 07/12/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH DIRECT_IO;

PROCEDURE CE2403A IS

     SUBTYPE STR512 IS STRING (1 .. 512);

     PACKAGE DIR_IO IS NEW DIRECT_IO (STR512);
          USE DIR_IO;

     FILE : FILE_TYPE;
     ITEM : STR512 := (1 .. 512 => 'A');
     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("CE2403A", "CHECK FOR DIRECT_IO THAT WRITE RAISES " &
                      "USE_ERROR IF THE CAPACITY OF THE EXTERNAL " &
                      "FILE IS EXCEEDED");

     BEGIN

          IF
$FORM_STRING2
               = "CANNOT_RESTRICT_FILE_CAPACITY" THEN
               NOT_APPLICABLE ("IMPLEMENTATION CANNOT RESTRICT FILE " &
                               "CAPACITY");
               RAISE INCOMPLETE;
          ELSE
               BEGIN
                    CREATE (FILE, OUT_FILE, LEGAL_FILE_NAME,

$FORM_STRING2
);
               EXCEPTION
                    WHEN USE_ERROR =>
                         NOT_APPLICABLE ("USE_ERROR RAISED ON CREATE " &
                                         "WITH MODE OUT_FILE");
                         RAISE INCOMPLETE;
                    WHEN NAME_ERROR =>
                         NOT_APPLICABLE ("NAME_ERROR RAISED ON " &
                                         "CREATE WITH MODE OUT_FILE");
                         RAISE INCOMPLETE;
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED ON " &
                                 "CREATE");
                         RAISE INCOMPLETE;
               END;
          END IF;

          BEGIN
               FOR I IN 1 .. 9 LOOP
                    WRITE (FILE, ITEM);
               END LOOP;
               FAILED ("USE_ERROR NOT RAISED WHEN THE CAPACITY " &
                       "OF THE EXTERNAL FILE IS EXCEEDED");
          EXCEPTION
               WHEN USE_ERROR =>
                    NULL;
          END;

          BEGIN
               DELETE (FILE);
          EXCEPTION
               WHEN USE_ERROR =>
                    NULL;
          END;

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;

     END;

     RESULT;

END CE2403A;
