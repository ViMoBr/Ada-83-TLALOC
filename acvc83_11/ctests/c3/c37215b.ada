-- C37215B.ADA

-- CHECK THAT IF
--        A DISCRIMINANT CONSTRAINT
-- DEPENDS ON A DISCRIMINANT, THE DISCRIMINANT VALUE IS CHECKED FOR
-- COMPATIBILITY WHEN THE RECORD TYPE IS:
--
--   CASE B: USED WITHOUT A CONSTRAINT ONLY IN AN ALLOCATOR OR OBJECT
--      DECLARATION.

-- JBG 10/17/86

WITH REPORT; USE REPORT;
PROCEDURE C37215B IS

     SUBTYPE SM IS INTEGER RANGE 1..10;

     TYPE REC (D1, D2 : SM) IS
          RECORD NULL; END RECORD;

BEGIN
     TEST ("C37215B", "CHECK COMPATIBILITY OF DISCRIMINANT EXPRESSIONS"&
                      " WHEN CONSTRAINT DEPENDS ON DISCRIMINANT, " &
                      "AND DISCRIMINANTS HAVE DEFAULTS");

-- CASE B

     DECLARE
          TYPE CONS (D3 : INTEGER := IDENT_INT(11)) IS
               RECORD
                    C1 : REC(D3, 1);
               END RECORD;
     BEGIN
          BEGIN
               DECLARE
                    X : CONS;
               BEGIN
                    FAILED ("DISCRIMINANT CHECK NOT PERFORMED - 1");
                    IF X /= (1, (1, 1)) THEN
                         COMMENT ("SHOULDN'T GET HERE");
                    END IF;
               END;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION - 1");
          END;

          BEGIN
               DECLARE
                    TYPE ACC_CONS IS ACCESS CONS;
                    X : ACC_CONS;
               BEGIN
                    X := NEW CONS;
                    FAILED ("DISCRIMINANT CHECK NOT PERFORMED - 2");
                    BEGIN
                         IF X.ALL /= (1, (1, 1)) THEN
                              COMMENT ("IRRELEVANT");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED - 2");
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("CONSTRAINT CHECKED TOO SOON - 2");
          END;

          BEGIN
               DECLARE
                    SUBTYPE SCONS IS CONS;
               BEGIN
                    DECLARE
                         X : SCONS;
                    BEGIN
                         FAILED ("DISCRIMINANT CHECK NOT " &
                                 "PERFORMED - 3");
                         IF X /= (1, (1, 1)) THEN
                              COMMENT ("IRRELEVANT");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED - 3");
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("CONSTRAINT CHECKED TOO SOON - 3");
          END;

          BEGIN
               DECLARE
                    TYPE ARR IS ARRAY (1..5) OF CONS;
               BEGIN
                    DECLARE
                         X : ARR;
                    BEGIN
                         FAILED ("DISCRIMINANT CHECK NOT " &
                                 "PERFORMED - 4");
                         IF X /= (1..5 => (1, (1, 1))) THEN
                              COMMENT ("IRRELEVANT");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED - 4");
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("CONSTRAINT CHECKED TOO SOON - 4");
          END;

          BEGIN
               DECLARE
                    TYPE NREC IS
                         RECORD
                              C1 : CONS;
                         END RECORD;
               BEGIN
                    DECLARE
                         X : NREC;
                    BEGIN
                         FAILED ("DISCRIMINANT CHECK NOT " &
                                 "PERFORMED - 5");
                         IF X /= (C1 => (1, (1, 1))) THEN
                              COMMENT ("IRRELEVANT");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED - 5");
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("CONSTRAINT CHECKED TOO SOON - 5");
          END;

          BEGIN
               DECLARE
                    TYPE DREC IS NEW CONS;
               BEGIN
                    DECLARE
                         X : DREC;
                    BEGIN
                         FAILED ("DISCRIMINANT CHECK NOT " &
                                 "PERFORMED - 6");
                         IF X /= (1, (1, 1)) THEN
                              COMMENT ("IRRELEVANT");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED - 6");
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("CONSTRAINT CHECKED TOO SOON - 6");
          END;

     END;

     RESULT;

EXCEPTION
     WHEN OTHERS =>
          FAILED ("CONSTRAINT CHECK DONE TOO EARLY");
          RESULT;

END C37215B;
