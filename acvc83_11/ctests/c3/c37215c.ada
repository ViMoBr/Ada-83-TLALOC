-- C37215C.ADA

-- OBJECTIVE:
--     CHECK THAT IF AN INDEX CONSTRAINT DEPENDS ON A DISCRIMINANT,
--     THEN THE DISCRIMINANT VALUE IS CHECKED FOR COMPATIBILITY WHEN
--     THE RECORD TYPE IS CONSTRAINED EXPLICITLY.

-- HISTORY:
--     JBG  10/17/86  CREATED ORIGINAL TEST.
--     VCL  20/26/87  MODIFIED THIS HEADER, CHANGED THE SUBTYPE
--                    CONSTRAINT OF COMPONENT C1 IN THE RECORD TYPE
--                    'CONS' TO (D3 .. 1).

WITH REPORT; USE REPORT;
PROCEDURE C37215C IS
     SUBTYPE SM IS INTEGER RANGE 1..10;

     TYPE MY_ARR IS ARRAY (SM RANGE <>) OF INTEGER;

     SEQUENCE_NUMBER : INTEGER := 1;
BEGIN
     TEST ("C37215C", "IF AN INDEX CONSTRAINT DEPENDS ON A " &
                      "DISCRIMINANT, THEN THE DISCRIMINANT VALUE IS " &
                      "CHECKED FOR COMPATIBILITY WHEN THE RECORD " &
                      "TYPE IS CONSTRAINED EXPLICITLY");

     DECLARE
          TYPE CONS (D3 : INTEGER) IS
               RECORD
                    C1 : MY_ARR(D3 .. 1);
               END RECORD;
     BEGIN
          BEGIN
               DECLARE
                    X : CONS(IDENT_INT(0));
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
                    SUBTYPE SCONS IS CONS(0);
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
                    TYPE ARR IS ARRAY (1..5) OF CONS(IDENT_INT(0));
               BEGIN
                    FAILED ("INDEX CHECK NOT PERFORMED - 3");
                    DECLARE
                         X : ARR;
                    BEGIN
                         IF X /= (1..5 => (1, (1 => 1))) THEN
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
                              C1 : CONS (0);
                         END RECORD;
               BEGIN
                    FAILED ("INDEX CHECK NOT PERFORMED - 4");
                    DECLARE
                         X : NREC;
                    BEGIN
                         IF X /= (C1 => (1, (1 => 1))) THEN
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
                    TYPE NREC IS NEW CONS(IDENT_INT(0));
               BEGIN
                    FAILED ("INDEX CHECK NOT PERFORMED - 5");
                    DECLARE
                         X : NREC;
                    BEGIN
                         IF X /= (1, (1 => 1)) THEN
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
                    TYPE ACC_CONS IS ACCESS CONS(0);
               BEGIN
                    FAILED ("INDEX CHECK NOT PERFORMED - 6");
                    DECLARE
                         X : ACC_CONS;
                    BEGIN
                         X := NEW CONS(0);
                         IF X.ALL /= (1, (1 => 1)) THEN
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
                    X := NEW CONS(0);
                    FAILED ("INDEX CHECK NOT PERFORMED - 7");
                    IF X.ALL /= (1, (1 => 1)) THEN
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

     RESULT;

EXCEPTION
     WHEN OTHERS =>
          FAILED ("INDEX VALUES CHECKED TOO SOON");
          RESULT;

END C37215C;
