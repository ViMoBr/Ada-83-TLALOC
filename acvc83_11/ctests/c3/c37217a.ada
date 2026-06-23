-- C37217A.ADA

-- OBJECTIVE:
--     CHECK WHETHER THE OPTIONAL COMPATIBILITY CHECK IS
--     PERFORMED WHEN A DISCRIMINANT CONSTRAINT IS GIVEN FOR AN ACCESS
--     TYPE - AFTER THE TYPE'S FULL DECLARATION.

-- HISTORY:
--     DHH 02/05/88 CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE C37217A IS

     SUBTYPE SM IS INTEGER RANGE 1..10;

BEGIN  --C37217A BODY
     TEST ("C37217A", "CHECK WHETHER THE OPTIONAL COMPATIBILITY " &
                      "CHECK IS PERFORMED WHEN A DISCRIMINANT " &
                      "CONSTRAINT IS GIVEN FOR AN ACCESS TYPE " &
                      "- AFTER THE TYPE'S FULL DECLARATION");

                                         -- CHECK FULL DECLARATION
                                         -- LOWER LIMIT
     BEGIN
          DECLARE

               TYPE SM_REC(D : SM) IS
                    RECORD
                         NULL;
                    END RECORD;

               TYPE REC(D1 : INTEGER) IS
                    RECORD
                         INT : SM_REC(D1);
                    END RECORD;

               TYPE PTR IS ACCESS REC;

               Y : PTR(IDENT_INT(0));           -- OPTIONAL EXCEPTION.
          BEGIN
               COMMENT("OPTIONAL COMBATIBILITY CHECK NOT PERFORMED " &
                       "- LOWER");
               Y := NEW REC(IDENT_INT(0));      -- MANDATORY EXCEPTION.
               FAILED("CONSTRAINT ERROR NOT RAISED");

               IF IDENT_INT(Y.INT.D) /= IDENT_INT(-1) THEN
                    COMMENT ("IRRELEVANT");
               END IF;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED("UNEXPECTED EXCEPTION RAISED IN " &
                           "VARIABLE ALLOCATION - LOWER");
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT("OPTIONAL CONSTRAINT ERROR RAISED - LOWER");
          WHEN OTHERS =>
               FAILED("UNEXPECTED EXCEPTION RAISED IN " &
                      "VARIABLE DECLARATION - LOWER");
     END;
---------------------------------------------------------------------
                                         -- CHECK FULL DECLARATION
                                         -- UPPER LIMIT
     BEGIN
          DECLARE
               TYPE SM_ARR IS ARRAY(SM RANGE <>) OF INTEGER;

               TYPE REC(D1 : INTEGER) IS
                    RECORD
                         INT : SM_ARR(1 .. D1);
                    END RECORD;

               TYPE PTR IS ACCESS REC;

               Y : PTR(IDENT_INT(11));           -- OPTIONAL EXCEPTION.
          BEGIN
               COMMENT("OPTIONAL COMBATIBILITY CHECK NOT PERFORMED " &
                       "- UPPER");
               Y := NEW REC'(IDENT_INT(11),     -- MANDATORY EXCEPTION.
                                      INT => (OTHERS => IDENT_INT(0)));
               FAILED("CONSTRAINT ERROR NOT RAISED");

               IF IDENT_INT(Y.INT(IDENT_INT(1))) /= 11 THEN
                    COMMENT ("IRRELEVANT");
               END IF;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED("UNEXPECTED EXCEPTION RAISED IN " &
                           "VARIABLE ALLOCATION - UPPER");
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT("OPTIONAL COMPATIBILITY CHECK PERFORMED " &
                       "- UPPER");
          WHEN OTHERS =>
               FAILED("UNEXPECTED EXCEPTION RAISED IN " &
                      "VARIABLE DECLARATION - UPPER");
     END;

     RESULT;

END C37217A;  -- BODY
