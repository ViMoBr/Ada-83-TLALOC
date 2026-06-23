-- CD2B15B.ADA

-- OBJECTIVE:
--     IF A COLLECTION SIZE SPECIFIED BY A NON-STATIC EXPRESSION
--     IS TOO SMALL TO HOLD A VALUE OF THE DESIGNATED TYPE, AND
--     THE SPECIFIED COLLECTION SIZE IS THE SIZE REPORTED BY THE
--     'STORAGE_SIZE ATRIBUTE,THEN
--     "STORAGE_ERROR" IS RAISED ON ELABORATION OF THE
--     REPRESENTATION CLAUSE, OR AT EVALUATION OF AN ALLOCATOR.

-- HISTORY:
--     DHH 09/22/87 CREATED ORIGINAL TEST.
--     PWB 05/11/89  CHANGED EXTENSION FROM '.DEP' TO '.ADA'.

WITH SYSTEM;
WITH REPORT; USE REPORT;
PROCEDURE CD2B15B IS
BEGIN
     TEST ("CD2B15B", "IF A COLLECTION SIZE SPECIFIED BY A " &
                      "NON-STATIC EXPRESSION IS TOO SMALL TO " &
                      "HOLD A VALUE OF THE DESIGNATED TYPE, " &
                      "AND THE SPECIFIED COLLECTION SIZE IS " &
                      "THE SIZE REPORTED BY THE 'STORAGE_SIZE " &
                      "ATTRIBUTE, THEN " &
                      "STORAGE_ERROR IS RAISED ON ELABORATION " &
                      "OF THE REPRESENTATION CLAUSE OR AT " &
                      "EVALUATION OF AN ALLOCATOR");

     BEGIN   --OUTER EXCEPTION HANDLER.
          DECLARE

               UNITS_PER_INTEGER : CONSTANT := (INTEGER'SIZE +
                    SYSTEM.STORAGE_UNIT - 1)/SYSTEM.STORAGE_UNIT;

               TYPE CELL IS
                    RECORD
                         VALUE : INTEGER := INTEGER'LAST;
                         PTR : INTEGER := INTEGER'LAST;
                    END RECORD;

               TYPE CHECK_TYPE IS ACCESS CELL;
               FOR CHECK_TYPE'STORAGE_SIZE USE
                               UNITS_PER_INTEGER/2;

               TYPE LINK IS ACCESS CELL;
               FOR LINK'STORAGE_SIZE USE
                    IDENT_INT(UNITS_PER_INTEGER/2);
               L : LINK := NULL;

          BEGIN    -- ACTIVE DECLARE

               IF LINK'STORAGE_SIZE >
                                IDENT_INT(UNITS_PER_INTEGER)/2 THEN
                    NOT_APPLICABLE("COLLECTION SIZE LARGER THAN SIZE " &
                                   "SPECIFIED WAS  ALLOCATED");
               ELSE

                    BEGIN
                         L := NEW CELL;
                         FAILED("STORAGE_ERROR NOT RAISED");
                         IF EQUAL(L.VALUE,L.VALUE) THEN
                            COMMENT("THIS LINE SHOULD NOT BE PRINTED");
                         END IF;

                    EXCEPTION
                         WHEN STORAGE_ERROR =>
                              COMMENT("STORAGE_ERROR RAISED AT " &
                                      "EVALUATION OF AN ALLOCATOR");
                         WHEN OTHERS =>
                              FAILED("WRONG EXCEPTION RAISED AT " &
                                     "EVALUATION OF ALLOCATOR");

                    END;  --INNER EXCEPTION HANDLER.

               END IF;
          END;    --ACTIVE DECLARE

     EXCEPTION
          WHEN STORAGE_ERROR =>
               COMMENT("STORAGE_ERROR RAISED AT ELABORATION OF " &
                       "REPRESENTATION CLAUSE");

          WHEN OTHERS =>
               FAILED("WRONG EXCEPTION RAISED AT ELABORATION OF " &
                      "REPRESENTATION CLAUSE");
     END;  -- OUTER EXCEPTION HANDLER.
     RESULT;
END CD2B15B;
