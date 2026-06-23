-- C45232A.TST

-- CHECK WHETHER NUMERIC_ERROR/CONSTRAINT_ERROR IS RAISED WHEN
-- AN INTEGER OPERAND IN A COMPARISON OR AN INTEGER LEFT OPERAND IN
-- A MEMBERSHIP TEST IS OUTSIDE THE RANGE OF THE BASE TYPE.

-- P. BRASHEAR  08/20/86

WITH REPORT, SYSTEM; USE REPORT;
PROCEDURE C45232A IS

BEGIN

     TEST ("C45232A", "CHECK WHETHER NUMERIC_ERROR/CONSTRAINT_ERROR " &
                      "IS RAISED WHEN AN INTEGER OPERAND IN A " &
                      "COMPARISON OR AN INTEGER LEFT OPERAND IN A " &
                      "MEMBERSHIP TEST IS OUTSIDE THE BASE TYPE'S " &
                      "RANGE");

     BEGIN    -- PRE-DEFINED INTEGER COMPARISON

          -- $INTEGER_LAST_PLUS_1 IS A LITERAL 
          -- WHOSE VALUE IS (INTEGER'LAST + 1).

          IF $INTEGER_LAST_PLUS_1 > IDENT_INT(10) THEN
               COMMENT ("NO EXCEPTION RAISED FOR PRE-DEFINED INTEGER " &
                        "COMPARISON");
          ELSE
               FAILED ("WRONG RESULT FROM PRE-DEFINED INTEGER " &
                       "COMPARISON");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR =>
               COMMENT ("NUMERIC_ERROR RAISED FOR PRE-DEFINED " &
                        "INTEGER COMPARISON");
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED FOR PRE-DEFINED " &
                        "INTEGER COMPARISON");
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED FOR PRE-DEFINED " &
                       "INTEGER COMPARISON");
     END;  -- PRE-DEFINED INTEGER COMPARISON

     BEGIN    -- PRE-DEFINED INTEGER MEMBERSHIP

          -- $INTEGER_LAST_PLUS_1 IS A LITERAL 
          -- WHOSE VALUE IS (INTEGER'LAST + 1).

          IF $INTEGER_LAST_PLUS_1 NOT IN INTEGER THEN
               COMMENT ("NO EXCEPTION RAISED FOR PRE-DEFINED INTEGER " &
                        "MEMBERSHIP");
          ELSE
               FAILED ("WRONG RESULT FROM PRE-DEFINED INTEGER " &
                       "MEMBERSHIP");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR =>
               COMMENT ("NUMERIC_ERROR RAISED FOR PRE-DEFINED " &
                        "INTEGER MEMBERSHIP");
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED FOR PRE-DEFINED " &
                        "INTEGER MEMBERSHIP");
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED FOR PRE-DEFINED " &
                       "INTEGER MEMBERSHIP");
     END;  -- PRE-DEFINED INTEGER MEMBERSHIP

     DECLARE -- LARGE INTEGER COMPARISON
          TYPE LARGE_INT IS RANGE SYSTEM.MIN_INT .. SYSTEM.MAX_INT;
          NUM : LARGE_INT := 0;
     BEGIN
          IF EQUAL(3,3) THEN
               NUM := 10;
          END IF;

          -- $MAX_INT_PLUS_1 IS A LITERAL 
          -- WHOSE VALUE IS (SYSTEM.MAX_INT + 1).

          IF $MAX_INT_PLUS_1 > NUM THEN
               COMMENT ("NO EXCEPTION RAISED FOR LARGE_INT COMPARISON");
          ELSE
               FAILED ("WRONG RESULT FROM LARGE_INT COMPARISON");
          END IF;

     EXCEPTION
          WHEN NUMERIC_ERROR =>
               COMMENT ("NUMERIC_ERROR RAISED FOR " &
                        "LARGE_INT COMPARISON");
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED FOR " &
                        "LARGE_INT COMPARISON");
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED FOR  " &
                       "LARGE_INT COMPARISON");
     END;  --  LARGE_INT COMPARISON

     DECLARE -- LARGE INTEGER MEMBERSHIP
          TYPE LARGE_INT IS RANGE SYSTEM.MIN_INT .. SYSTEM.MAX_INT;
     BEGIN

          -- $MAX_INT_PLUS_1 IS A LITERAL 
          -- WHOSE VALUE IS (SYSTEM.MAX_INT + 1).

          IF $MAX_INT_PLUS_1 NOT IN LARGE_INT THEN
               COMMENT ("NO EXCEPTION RAISED FOR LARGE_INT MEMBERSHIP");
          ELSE
               FAILED ("WRONG RESULT FROM LARGE_INT MEMBERSHIP");
          END IF;

     EXCEPTION
          WHEN NUMERIC_ERROR =>
               COMMENT ("NUMERIC_ERROR RAISED FOR " &
                        "LARGE_INT MEMBERSHIP");
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED FOR " &
                        "LARGE_INT MEMBERSHIP");
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED FOR  " &
                       "LARGE_INT MEMBERSHIP");
     END;  --  LARGE_INT MEMBERSHIP


     DECLARE -- SMALL INTEGER COMPARISON
          TYPE SMALL_INT IS RANGE -10 .. 10;
          NUM : SMALL_INT := 0;
     BEGIN
          IF EQUAL(3,3) THEN
               NUM := 10;
          END IF;

          IF INTEGER'LAST > INTEGER(SMALL_INT'BASE'LAST) THEN
               BEGIN

               -- $INTEGER_LAST IS A LITERAL 
               -- WHOSE VALUE IS INTEGER'LAST.

                    IF $INTEGER_LAST  > NUM THEN
                         COMMENT ("NO EXCEPTION RAISED FOR SMALL_INT " &
                                  "COMPARISON");
                    ELSE
                         FAILED ("WRONG RESULT FROM SMALL_INT " &
                                 "COMPARISON");
                    END IF;
               EXCEPTION
                    WHEN NUMERIC_ERROR =>
                        COMMENT ("NUMERIC_ERROR RAISED FOR " &
                                 "SMALL_INT COMPARISON");
                    WHEN CONSTRAINT_ERROR =>
                         COMMENT ("CONSTRAINT_ERROR RAISED FOR " &
                                  "SMALL_INT COMPARISON");
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED FOR  " &
                                 "SMALL_INT COMPARISON");
               END;
          ELSE
               COMMENT ("BASE TYPE FOR RANGE -10 .. 10 IS " &
                        "NO SMALLER THAN PRE-DEFINED INTEGER");
          END IF;
     END;  --  SMALL_INT COMPARISON

     DECLARE -- SMALL INTEGER MEMBERSHIP
          TYPE SMALL_INT IS RANGE -10 .. 10;
          NUM : SMALL_INT := 0;
     BEGIN
          IF EQUAL(3,3) THEN
               NUM := 10;
          END IF;

          IF INTEGER'LAST > INTEGER(SMALL_INT'BASE'LAST) THEN
               BEGIN

          -- $INTEGER_LAST IS A LITERAL 
          -- WHOSE VALUE IS INTEGER'LAST.

                    IF $INTEGER_LAST NOT IN SMALL_INT THEN
                         COMMENT ("NO EXCEPTION RAISED FOR SMALL_INT " &
                                  "MEMBERSHIP");
                    ELSE
                         FAILED ("WRONG RESULT FROM SMALL_INT " &
                                 "MEMBERSHIP");
                    END IF;
               EXCEPTION
                    WHEN NUMERIC_ERROR =>
                        COMMENT ("NUMERIC_ERROR RAISED FOR " &
                                 "SMALL_INT MEMBERSHIP");
                    WHEN CONSTRAINT_ERROR =>
                         COMMENT ("CONSTRAINT_ERROR RAISED FOR " &
                                  "SMALL_INT MEMBERSHIP");
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED FOR  " &
                                 "SMALL_INT MEMBERSHIP");
               END;
          ELSE
               COMMENT ("BASE TYPE FOR RANGE -10 .. 10 IS " &
                        "NO SMALLER THAN PRE-DEFINED INTEGER");
          END IF;
     END;  --  SMALL_INT MEMBERSHIP

     RESULT;

END C45232A;
