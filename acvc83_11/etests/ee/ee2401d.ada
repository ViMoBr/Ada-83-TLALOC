-- EE2401D.ADA

-- OBJECTIVE:
--     CHECK WHETHER READ, WRITE, SET_INDEX, INDEX, SIZE, AND
--     END_OF_FILE ARE SUPPORTED FOR DIRECT FILES WITH ELEMENT_TYPE
--     UNCONSTRAINED ARRAY.

--     IF I/O IS NOT SUPPORTED, THEN CREATE AND OPEN CAN RAISE
--     USE_ERROR OR NAME_ERROR. SEE (AI-00332).

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE TO IMPLEMENTATIONS THAT SUPPORT THE
--     INSTANTIATION OF DIRECT_IO WITH UNCONSTRAINED ARRAYS.

--     IF INSTANTIATION OF DIRECT_IO WITH UNCONSTRAINED ARRAYS IS NOT
--     SUPPORTED THEN THE INSTANTIATION OF 'DIR_ARR_UNCN' MUST BE
--     REJECTED.

-- HISTORY:
--     ABW  8/18/82
--     SPS  9/20/82
--     SPS 11/09/82
--     JBG  5/02/83
--     JRK  3/26/84
--     EG  11/02/84
--     TBN 11/19/85  RENAMED FROM CE2401D.DEP AND MODIFIED COMMENTS.
--                   SPLIT NON-DEFAULT DISC. CASE INTO EE2401G.ADA.
--                   SPLIT DEFAULT DISC. CASE INTO CE2401H.ADA.
--     TBN 11/04/86  REVISED TEST TO OUTPUT A NON_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     RJW  1/28/88  REVISED HEADER. CORRECTED NOT-APPLICABLE AND
--                   FAILED MESSAGES.

WITH REPORT;
USE REPORT;
WITH DIRECT_IO;

PROCEDURE EE2401D IS

     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("EE2401D" , "CHECK WHETHER READ, WRITE, SET_INDEX, INDEX, " &
                       "SIZE, AND END_OF_FILE ARE SUPPORTED FOR " &
                       "DIRECT FILES FOR AN UNCONSTRAINED ARRAY TYPE");

     DECLARE
          TYPE ARR_UNCN IS ARRAY (INTEGER RANGE <>) OF INTEGER;

          PACKAGE DIR_ARR_UNCN IS                      -- N/A => ERROR.
               NEW DIRECT_IO (ARR_UNCN);

          USE DIR_ARR_UNCN;
          FILE : FILE_TYPE;
          ARR : ARR_UNCN (1 .. 5) := (1,3,5,7,9);
          ITEM : ARR_UNCN (1.. 5) := (0,2,4,6,8);
          ONE : POSITIVE_COUNT := 1;
          TWO : POSITIVE_COUNT := 2;
     BEGIN

          BEGIN
               CREATE (FILE);

          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED; DIRECT " &
                                    "CREATE");
                    RAISE INCOMPLETE;
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED; DIRECT " &
                                    "CREATE");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED; DIRECT " &
                            "CREATE");
                    RAISE INCOMPLETE;
          END;

          BEGIN
               WRITE (FILE,ARR);
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("WRITE WITHOUT TO FOR " &
                            "TYPE UNCONSTRAINED ARRAY");
          END;

          BEGIN
               WRITE (FILE,ARR,TWO);
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("WRITE WITH TO FOR UNCONSTRAINED ARRAY");
          END;

          BEGIN
               IF SIZE (FILE) /= TWO THEN
                    FAILED ("SIZE FOR TYPE UNCONSTRAINED ARRAY");
               END IF;
               IF NOT END_OF_FILE (FILE) THEN
                    FAILED ("WRONG END_OF_FILE VALUE FOR TYPE " &
                            "UNCONSTRAINED ARRAY");
               END IF;
               SET_INDEX (FILE,TWO);
               IF INDEX (FILE) /= TWO THEN
                    FAILED ("WRONG INDEX VALUE FOR " &
                            "UNCONSTRAINED ARRAY");
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
               IF ITEM /= (1,3,5,7,9) THEN
                    FAILED ("WRONG VALUE READ");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("READ WITHOUT FROM FOR " &
                            "TYPE UNCONSTRAINED ARRAY");
          END;

          BEGIN
               ITEM := (OTHERS => 0);
               READ (FILE,ITEM,ONE);
               IF ITEM /= (1,3,5,7,9) THEN
                    FAILED ("WRONG VALUE READ");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("READ WITH FROM FOR " &
                            "TYPE UNCONSTRAINED ARRAY");
          END;

          CLOSE (FILE);

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
          WHEN OTHERS =>
               FAILED ("SUBTEST NOT COMPLETED FOR UNCONSTRAINED ARRAY");
     END;
     RESULT;

END EE2401D;
