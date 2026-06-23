-- C37213G.ADA

-- CHECK THAT IF
--        AN INDEX CONSTRAINT
-- DEPENDS ON A DISCRIMINANT, THE NON-DISCRIMINANT EXPRESSIONS IN THE
-- CONSTRAINT ARE EVALUATED WHEN THE COMPONENT SUBTYPE DEFINITION IS
-- ELABORATED, BUT THE VALUES ARE CHECKED WHEN THE RECORD TYPE IS:
--
--   CASE C: CONSTRAINED EXPLICITLY AND THE COMPONENT IS PRESENT IN THE
--        SUBTYPE.

-- JBG 10/17/86

WITH REPORT; USE REPORT;
PROCEDURE C37213G IS

     SUBTYPE SM IS INTEGER RANGE 1..10;

     TYPE MY_ARR IS ARRAY (SM RANGE <>) OF INTEGER;

     F1_CONS : INTEGER := 0;

     FUNCTION CHK (
          CONS    : INTEGER;
          VALUE   : INTEGER;
          MESSAGE : STRING) RETURN BOOLEAN IS
     BEGIN
          IF CONS /= VALUE THEN
               FAILED (MESSAGE & ": F1_CONS IS " &
                       INTEGER'IMAGE(F1_CONS));
          END IF;
          RETURN TRUE;
     END CHK;

     FUNCTION F1 RETURN INTEGER IS
     BEGIN
          F1_CONS := F1_CONS + IDENT_INT(1);
          RETURN F1_CONS;
     END F1;

BEGIN
     TEST ("C37213G", "CHECK EVALUATION OF INDEX BOUNDS " &
                      "WHEN INDEX CONSTRAINT DEPENDS ON DISCRIMINANT" &
                      "AND COMPONENT IS PRESENT IN THE SUBTYPE");

-- CASE C1: COMPONENT IS PRESENT

     DECLARE
          TYPE CONS (D3 : INTEGER) IS
               RECORD
                    CASE D3 IS
                         WHEN -5..10 =>
                              C1 : MY_ARR(D3..F1);     -- F1 EVALUATED
                         WHEN OTHERS =>
                              C2 : INTEGER := IDENT_INT(0);
                    END CASE;
               END RECORD;
          CHK1 : BOOLEAN := CHK (F1_CONS, 1, "F1 NOT EVALUATED");
          X : CONS(1);             -- F1 NOT EVALUATED AGAIN
          Y : CONS(2);             -- F1 NOT EVALUATED AGAIN
          CHK2 : BOOLEAN := CHK (F1_CONS, 1, "F1 EVALUATED");
     BEGIN
          IF X.C1'FIRST /= 1 OR X.C1'LAST /= 1 OR
             Y.C1'FIRST /= 2 OR Y.C1'LAST /= 1 THEN
               FAILED ("VALUES NOT CORRECT");
          END IF;
     END;

     F1_CONS := -1;

     DECLARE
          TYPE CONS (D3 : INTEGER) IS
               RECORD
                    CASE D3 IS
                         WHEN -5..10 =>
                              C1 : MY_ARR(F1..D3);
                         WHEN OTHERS =>
                              C2 : INTEGER := IDENT_INT(0);
                    END CASE;
               END RECORD;
     BEGIN
          BEGIN
               DECLARE
                    X : CONS(IDENT_INT(1));
               BEGIN
                    FAILED ("INDEX CHECK NOT PERFORMED - 1");
                    IF X /= (1, (1, 1)) THEN
                         COMMENT ("SHOULDN'T GET HERE");
                    END IF;
               END;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - 1");
          END;

          BEGIN
               DECLARE
                    SUBTYPE SCONS IS CONS(1);
               BEGIN
                    FAILED ("INDEX CHECK NOT PERFORMED - 2");
                    BEGIN   -- THIS IS HERE TO DEFEAT OPTIMIZATION.
                         DECLARE
                              X : SCONS;
                         BEGIN
                              IF X /= (1, (1, 1)) THEN
                                   COMMENT ("IRRELEVANT");
                              END IF;
                         END;
                    EXCEPTION
                         WHEN OTHERS =>
                              COMMENT ("SHOULDN'T GET HERE");
                    END;
               END;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - 2");
          END;

          BEGIN
               DECLARE
                    TYPE ARR IS ARRAY (1..5) OF CONS(1);
               BEGIN
                    FAILED ("INDEX CHECK NOT PERFORMED - 3");
                    DECLARE
                         X : ARR;
                    BEGIN
                         IF X /= (1..5 => (1, (1, 1))) THEN
                              COMMENT ("IRRELEVANT");
                         END IF;
                    END;
               EXCEPTION
                    WHEN OTHERS =>
                         COMMENT ("SHOULDN'T GET HERE");
               END;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - 3");
          END;

          BEGIN
               DECLARE
                    TYPE NREC IS
                         RECORD
                              C1 : CONS (1);
                         END RECORD;
               BEGIN
                    FAILED ("INDEX CHECK NOT PERFORMED - 4");
                    DECLARE
                         X : NREC;
                    BEGIN
                         IF X /= (C1 => (1, (1, 1))) THEN
                              COMMENT ("IRRELEVANT");
                         END IF;
                    END;
               EXCEPTION
                    WHEN OTHERS =>
                         COMMENT ("SHOULDN'T GET HERE");
               END;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - 4");
          END;

          BEGIN
               DECLARE
                    TYPE NREC IS NEW CONS(1);
               BEGIN
                    FAILED ("INDEX CHECK NOT PERFORMED - 5");
                    DECLARE
                         X : NREC;
                    BEGIN
                         IF X /= (1, (1, 1)) THEN
                              COMMENT ("IRRELEVANT");
                         END IF;
                    END;
               EXCEPTION
                    WHEN OTHERS =>
                         COMMENT ("SHOULDN'T GET HERE");
               END;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - 5");
          END;

          BEGIN
               DECLARE
                    TYPE ACC_CONS IS ACCESS CONS(1);
               BEGIN
                    FAILED ("INDEX CHECK NOT PERFORMED - 6");
                    DECLARE
                         X : ACC_CONS;
                    BEGIN
                         X := NEW CONS(1);
                         IF X.ALL /=  (1, (1, 1)) THEN
                              COMMENT ("IRRELEVANT");
                         END IF;
                    END;
               EXCEPTION
                    WHEN OTHERS =>
                         COMMENT ("SHOULDN'T GET HERE");
               END;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - 6");
          END;

          BEGIN
               DECLARE
                    TYPE ACC_CONS IS ACCESS CONS;
                    X : ACC_CONS;
               BEGIN
                    X := NEW CONS(1);
                    FAILED ("INDEX CHECK NOT PERFORMED - 7");
                    IF X.ALL /= (1, (1, 1)) THEN
                         COMMENT ("IRRELEVANT");
                    END IF;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION - 7A");
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - 7B");
          END;
     END;

-- CASE C2: COMPONENT IS ABSENT

     F1_CONS := 0;

     DECLARE
          TYPE CONS (D3 : INTEGER) IS
               RECORD
                    CASE D3 IS
                         WHEN -5..10 =>
                              C1 : MY_ARR(D3..F1);     -- F1 EVALUATED
                         WHEN OTHERS =>
                              C2 : INTEGER := IDENT_INT(0);
                    END CASE;
               END RECORD;
          CHK1 : BOOLEAN := CHK (F1_CONS, 1, "F1 NOT EVALUATED - 2");
          X : CONS(IDENT_INT(-6));             -- F1 NOT EVALUATED AGAIN
          Y : CONS(IDENT_INT(11));             -- F1 NOT EVALUATED AGAIN
          CHK2 : BOOLEAN := CHK (F1_CONS, 1, "F1 EVALUATED - 2");
     BEGIN
          IF X /= (-6, 0) OR Y /= (11, 0) THEN
               FAILED ("VALUES NOT CORRECT");
          END IF;
     END;

     F1_CONS := -1;

     DECLARE
          TYPE CONS (D3 : INTEGER) IS
               RECORD
                    CASE D3 IS
                         WHEN -5..10 =>
                              C1 : MY_ARR(F1..D3);
                         WHEN OTHERS =>
                              C2 : INTEGER := IDENT_INT(0);
                    END CASE;
               END RECORD;
     BEGIN
          BEGIN
               DECLARE
                    X : CONS(IDENT_INT(11));
               BEGIN
                    IF X /= (11, 0) THEN
                         FAILED ("X VALUE IS INCORRECT - 11");
                    END IF;
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("NONEXISTENT CONSTRAINT CHECKED - 11");
          END;

          BEGIN
               DECLARE
                    SUBTYPE SCONS IS CONS(IDENT_INT(11));
               BEGIN
                    DECLARE
                         X : SCONS;
                    BEGIN
                         IF X /= (11, 0) THEN
                              FAILED ("X VALUE INCORRECT - 12");
                         END IF;
                    END;
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("NONEXISTENT CONSTRAINT CHECKED - 12");
          END;

          BEGIN
               DECLARE
                    TYPE ARR IS ARRAY (1..5) OF CONS(11);
                    X : ARR;
               BEGIN
                    IF X /= (1..5 => (11, 0)) THEN
                         FAILED ("X VALUE INCORRECT - 13");
                    END IF;
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("NONEXISTENT CONSTRAINT CHECKED - 13");
          END;

          BEGIN
               DECLARE
                    TYPE NREC IS
                         RECORD
                              C1 : CONS (11);
                         END RECORD;
                    X : NREC;
               BEGIN
                    IF X /= (C1 => (11, 0)) THEN
                         FAILED ("X VALUE INCORRECT - 14");
                    END IF;
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("NONEXISTENT CONSTRAINT CHECKED - 14");
          END;

          BEGIN
               DECLARE
                    TYPE NREC IS NEW CONS(11);
                    X : NREC;
               BEGIN
                    IF X /= (11, 0) THEN
                         FAILED ("X VALUE INCORRECT - 15");
                    END IF;
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("NONEXISTENT CONSTRAINT CHECKED - 15");
          END;

          BEGIN
               DECLARE
                    TYPE ACC_CONS IS ACCESS CONS(11);
                    X : ACC_CONS;
               BEGIN
                    X := NEW CONS(11);
                    IF X.ALL /= (11, 0) THEN
                         FAILED ("X VALUE INCORRECT - 16");
                    END IF;
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("NONEXISTENT CONSTRAINT CHECKED - 16");
          END;

          BEGIN
               DECLARE
                    TYPE ACC_CONS IS ACCESS CONS;
                    X : ACC_CONS := NEW CONS(IDENT_INT(11));
               BEGIN
                    IF X.ALL /= (11, 0) THEN
                         FAILED ("X VALUE INCORRECT - 17");
                    END IF;
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("NONEXISTENT CONSTRAINT CHECKED - 17");
          END;
     END;

     RESULT;

EXCEPTION
     WHEN OTHERS =>
          FAILED ("INDEX VALUES CHECKED TOO SOON");
          RESULT;

END C37213G;
