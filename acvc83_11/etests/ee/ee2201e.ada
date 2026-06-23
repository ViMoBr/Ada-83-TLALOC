-- EE2201E.ADA

-- CHECK WHETHER READ, WRITE, AND END_OF_FILE ARE SUPPORTED FOR
-- SEQUENTIAL FILES WITH VARIANT RECORDS WITH NON-DEFAULT DISCRIMINANTS.

-- THIS TEST IS NON-APPLICABLE IF THE INSTANTIATION OF SEQUENTIAL_IO 
-- WITH VARIANT RECORDS HAVING NO DEFAULT DISCRIMINANT VALUES IS 
-- REJECTED.

-- IF I/O IS NOT SUPPORTED, THEN CREATE AND OPEN CAN RAISE USE_ERROR
-- OR NAME_ERROR. SEE (AI-00332).

-- JBG 1/6/83
-- JBG 5/2/83
-- TBN 11/18/85     RENAMED FROM CE2201E.DEP AND MODIFIED COMMENTS.
--                  SPLIT DEFAULT DISCRIMINANT CASE INTO CE2201G.ADA.
-- TBN 11/04/86     REVISED TEST TO OUTPUT A NON_APPLICABLE
--                  RESULT WHEN FILES ARE NOT SUPPORTED.

WITH REPORT; USE REPORT;
WITH SEQUENTIAL_IO;

PROCEDURE EE2201E IS
     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("EE2201E", "CHECK WHETHER READ, WRITE, AND END_OF_FILE " &
                      "ARE SUPPORTED FOR SEQUENTIAL FILES WITH " &
                      "UNCONSTRAINED VARIANT RECORD TYPES WITH " &
                      "NON-DEFAULT DISCRIMINANTS.");

     DECLARE
          TYPE VAR_REC (DISCR : BOOLEAN) IS
               RECORD
                    CASE DISCR IS
                         WHEN TRUE =>
                              A : INTEGER;
                         WHEN FALSE =>
                              B : STRING (1..20);
                    END CASE;
               END RECORD;

          PACKAGE SEQ_VAR_REC IS NEW SEQUENTIAL_IO (VAR_REC);
          USE SEQ_VAR_REC;

          FILE_VAR_REC : FILE_TYPE;
          ITEM_TRUE  : VAR_REC(TRUE);
          ITEM_FALSE : VAR_REC(FALSE);

     BEGIN

          BEGIN
               CREATE (FILE_VAR_REC);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED; SEQUENTIAL " &
                                    "CREATE");
                    RAISE INCOMPLETE;
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED; SEQUENTIAL " &
                                    "CREATE");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED; SEQUENTIAL " &
                            "CREATE");
                    RAISE INCOMPLETE;
          END;

          BEGIN
               WRITE (FILE_VAR_REC, (TRUE, -6));
               WRITE (FILE_VAR_REC, (FALSE, (1..20 => 'C')));
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("WRITE FOR RECORD WITH DISCRIMINANT");
          END;

          BEGIN
               RESET (FILE_VAR_REC,IN_FILE);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR FOR RESET");
                    RAISE INCOMPLETE;
          END;

          IF END_OF_FILE (FILE_VAR_REC) THEN
               FAILED ("WRONG END_OF_FILE VALUE FOR RECORD" &
                       "WITH DISCRIMINANT");
          END IF;

          BEGIN
               READ (FILE_VAR_REC,ITEM_TRUE);

               IF ITEM_TRUE /= (TRUE, IDENT_INT(-6)) THEN
                    FAILED ("READ WRONG VALUE - 1");
               END IF;

               IF END_OF_FILE (FILE_VAR_REC) THEN
                    FAILED ("PREMATURE END OF FILE");
               END IF;

               READ (FILE_VAR_REC, ITEM_FALSE);

               IF ITEM_FALSE /= (FALSE, (1..IDENT_INT(20) => 'C')) THEN
                    FAILED ("READ WRONG VALUE - 2");
               END IF;

               IF NOT END_OF_FILE(FILE_VAR_REC) THEN
                    FAILED ("NOT AT END OF FILE");
               END IF;

          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("READ FOR VARIANT RECORD");
          END;

          CLOSE (FILE_VAR_REC);

     END;
     RESULT;

EXCEPTION
     WHEN INCOMPLETE =>
          RESULT;

END EE2201E;
