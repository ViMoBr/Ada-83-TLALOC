-- C35503K.ADA

-- OBJECTIVE:
--     CHECK THAT 'POS' AND 'VAL' YIELD THE CORRECT RESULTS WHEN THE
--     PREFIX IS AN INTEGER TYPE.

-- HISTORY:
--     RJW 03/17/86 CREATED ORIGINAL TEST.
--     DHH 10/19/87 SHORTENED LINES CONTAINING MORE THAN 72 CHARACTERS.

WITH SYSTEM; USE SYSTEM;
WITH REPORT; USE REPORT;

PROCEDURE C35503K IS

BEGIN
     TEST ("C35503K", "CHECK THAT 'POS' AND 'VAL' YIELD THE " &
                      "CORRECT RESULTS WHEN THE PREFIX IS AN " &
                      "INTEGER TYPE" );

     DECLARE
          TYPE INT IS RANGE -6 .. 6;
          SUBTYPE SINT IS INT RANGE -4 .. 4;

          PROCEDURE P (I : INTEGER; STR : STRING) IS
          BEGIN
               BEGIN
                    IF INTEGER'POS (I) /= I THEN
                         FAILED ( "WRONG POS FOR " & STR);
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ( "EXCEPTION RAISED FOR POS OF " &
                                   STR);
               END;
               BEGIN
                    IF INTEGER'VAL (I) /= I THEN
                         FAILED ( "WRONG VAL FOR " & STR);
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ( "EXCEPTION RAISED FOR VAL OF " &
                                   STR);
               END;
          END P;

     BEGIN
          P ( INTEGER'FIRST, "INTEGER'FIRST");
          P ( INTEGER'LAST,  "INTEGER'LAST");
          P ( 0, "'0'");

          FOR I IN INT'FIRST .. INT'LAST LOOP
               BEGIN
                    IF SINT'POS (I) /= I THEN
                         FAILED ( "WRONG POS FOR "
                                   & INT'IMAGE (I));
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ( "EXCEPTION RAISED FOR POS OF "
                                  & INT'IMAGE (I));
               END;
               BEGIN
                    IF SINT'VAL (I) /= I THEN
                         FAILED ( "WRONG VAL FOR "
                                  & INT'IMAGE (I));
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ( "EXCEPTION RAISED FOR VAL OF "
                                  & INT'IMAGE (I));
               END;
          END LOOP;

          BEGIN
               IF INT'VAL (INTEGER'(0)) /= 0 THEN
                    FAILED ( "WRONG VAL FOR INT WITH INTEGER" );
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ( "EXCEPTION RAISED FOR VAL OF " &
                             "INT WITH INTEGER" );
          END;

          BEGIN
               IF INTEGER'VAL (INT'(0)) /= 0 THEN
                    FAILED ( "WRONG VAL FOR INTEGER WITH INT" );
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ( "EXCEPTION RAISED FOR VAL OF " &
                             "INTEGER WITH INT" );
          END;
     END;
     DECLARE
          TYPE INT IS RANGE MIN_INT .. MAX_INT;
          I : INT := 0;
     BEGIN
          IF INT(INTEGER'FIRST) > INT'FIRST THEN
               IF EQUAL (3,3) THEN
                    I := INT(INTEGER'FIRST) - 1;
               END IF;
               BEGIN
                    IF INTEGER'VAL (I) > 0 THEN
                        FAILED ("VAL('FIRST - 1) WRAPPED AROUND");
                    END IF;
                    FAILED ("NO EXCEPTION RAISED FOR VAL('FIRST - 1)");
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                        NULL;
                        WHEN OTHERS =>
                        FAILED ("WRONG EXCEPTION RAISED FOR " &
                                "VAL('FIRST - 1)");
               END;
          END IF;
          I := 0;
          IF INT(INTEGER'LAST) > INT'LAST THEN
               IF EQUAL (3,3) THEN
                    I := INT(INTEGER'LAST) + 1;
               END IF;
               BEGIN
                    IF INTEGER'VAL (I) > 0 THEN
                        FAILED ("VAL('LAST + 1) WRAPPED AROUND");
                    END IF;
                    FAILED ("NO EXCEPTION RAISED FOR VAL('LAST + 1)");
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                        NULL;
                    WHEN OTHERS =>
                        FAILED ("WRONG EXCEPTION RAISED FOR " &
                                "VAL('LAST + 1)");
               END;
         END IF;
     END;

     RESULT;
END C35503K;
