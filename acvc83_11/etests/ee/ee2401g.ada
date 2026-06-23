-- EE2401G.ADA

-- CHECK WHETHER READ, WRITE, SET_INDEX, INDEX, SIZE, AND END_OF_FILE 
-- ARE SUPPORTED FOR DIRECT FILES WITH ELEMENT_TYPE UNCONSTRAINED
-- RECORDS WITH NON-DEFAULT DISCRIMINANTS.

-- THIS TEST IS NON-APPLICABLE IF THE INSTANTIATION OF DIRECT_IO WITH 
-- UNCONSTRAINED RECORD TYPE IS REJECTED.

-- IF I/O IS NOT SUPPORTED, THEN CREATE AND OPEN CAN RAISE USE_ERROR
-- OR NAME_ERROR. SEE (AI-00332).

-- TBN 5/15/86
-- TBN 11/04/86     REVISED TEST TO OUTPUT A NON_APPLICABLE
--                  RESULT WHEN FILES ARE NOT SUPPORTED.

WITH REPORT;
USE REPORT;
WITH DIRECT_IO;

PROCEDURE EE2401G IS

     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("EE2401G", "CHECK WHETHER READ, WRITE, SET_INDEX, INDEX, " &
                      "SIZE, AND END_OF_FILE ARE SUPPORTED FOR " &
                      "DIRECT FILES WITH UNCONSTRAINED RECORDS WITH " &
                      "NON-DEFAULT DISCRIMINANTS");

     DECLARE
          TYPE REC_DSCR (DISCR : BOOLEAN) IS
               RECORD
                    ONE : BOOLEAN := IDENT_BOOL (TRUE);
                    TWO : BOOLEAN := DISCR;
                    THREE : BOOLEAN := NOT FALSE;
          END RECORD;
          PACKAGE DIR_REC_DSCR IS NEW DIRECT_IO (REC_DSCR);
          USE DIR_REC_DSCR;
          FILE : FILE_TYPE;
          REC : REC_DSCR (FALSE);
          ITEM : REC_DSCR (FALSE);
          ONE : POSITIVE_COUNT := 1;
          TWO : POSITIVE_COUNT := 2;
     BEGIN

          BEGIN
               CREATE (FILE);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED; DIRECT CREATE");
                    RAISE INCOMPLETE;
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED; DIRECT CREATE");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED; DIRECT " &
                            "CREATE");
                    RAISE INCOMPLETE;
          END;

          BEGIN
               WRITE (FILE,REC);
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("WRITE WITHOUT TO FOR " &
                            "RECORD WITH DISCRIMINANT WITHOUT DEFAULT");
          END;

          BEGIN
               WRITE (FILE,REC,TWO);
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("WRITE WITH TO FOR RECORD " &
                            "WITH DISCRIMINANT WITHOUT DEFAULT");
          END;

          BEGIN
               IF SIZE (FILE) /= TWO THEN
                    FAILED ("SIZE FOR TYPE RECORD WITH DISCRIMINANT " &
                            "WITHOUT DEFAULT");
               END IF;
               IF NOT END_OF_FILE (FILE) THEN
                    FAILED ("WRONG END_OF_FILE VALUE FOR TYPE " &
                            "RECORD WITH DISCRIMINANT WITHOUT DEFAULT");
               END IF;
               SET_INDEX (FILE,TWO);
               IF INDEX (FILE) /= TWO THEN
                    FAILED ("WRONG INDEX VALUE FOR RECORD " &
                            "WITH DISCRIMINANT WITHOUT DEFAULT");
               END IF;
          END;

          BEGIN
               RESET (FILE,IN_FILE);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR FOR RESET");
                    RAISE INCOMPLETE;
          END;

          BEGIN
               READ (FILE,ITEM);
               IF ITEM /= (FALSE, TRUE, FALSE, TRUE) THEN
                    FAILED ("WRONG VALUE READ");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("READ WITHOUT FROM FOR " &
                            "RECORD WITH DISCRIMINANT WITHOUT DEFAULT");
          END;

          BEGIN
               ITEM := (OTHERS => FALSE);
               READ (FILE,ITEM,ONE);
               IF ITEM /= (FALSE, TRUE, FALSE, TRUE) THEN
                    FAILED ("WRONG VALUE READ");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("READ WITH FROM FOR TYPE RECORD" &
                            " WITH DISCRIMINANT WITHOUT DEFAULT");
          END;

          CLOSE (FILE);

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
          WHEN OTHERS =>
               FAILED ("SUBTEST NOT COMPLETED FOR RECORD " &
                       "WITH DISCRIMINANT WITHOUT DEFAULT");
     END;
     RESULT;

END EE2401G;
