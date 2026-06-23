-- C37215H.ADA

-- OBJECTIVE:
--      CHECK THAT IF AN INDEX CONSTRAINT DEPENDS ON A DISCRIMINANT,
--      THE DISCRIMINANT VALUE IS CHECKED FOR COMPATIBILITY WHEN THE
--      RECORD TYPE IS:
--
--           CASE D: CONSTRAINED BY DEFAULT AND THE COMPONENT IS
--                   PRESENT IN THE SUBTYPE.

-- HISTORY:
--      JBG 10/17/86  CREATED ORIGINAL TEST.
--      RJW 10/13/87  CORRECTED VARIOUS CONSTRAINT ERRORS IN 'CASE D1'.
--      VCL 03/30/88  CORRECTED VARIOUS CONSTRAINT ERRORS WITH TYPE
--                    DECLARATIONS THROUGHOUT THE TEST.  ADDED SEQUENCE
--                    NUMBERS.

WITH REPORT; USE REPORT;
PROCEDURE C37215H IS

     SUBTYPE SM IS INTEGER RANGE 1..10;
     TYPE MY_ARR IS ARRAY (SM RANGE <>) OF INTEGER;

     SEQUENCE_NUMBER : INTEGER;
BEGIN
     TEST ("C37215H", "THE DISCRIMINANT VALUES OF AN INDEX " &
                      "CONSTRAINT ARE PROPERLY CHECK FOR " &
                      "COMPATIBILITY WHEN THE DISCRIMINANT IS " &
                      "DEFINED BY DEFAULT AND THE COMPONENT IS AND " &
                      "IS NOT PRESENT IN THE SUBTYPE");

-- CASE D1: COMPONENT IS PRESENT

     SEQUENCE_NUMBER := 1;
     DECLARE
          TYPE CONS (D3 : INTEGER := IDENT_INT(0)) IS
               RECORD
                    CASE D3 IS
                         WHEN -5..10 =>
                              C1 : MY_ARR(D3..1);
                         WHEN OTHERS =>
                              C2 : INTEGER := IDENT_INT(0);
                    END CASE;
               END RECORD;
     BEGIN
          BEGIN
               DECLARE
                    X : CONS;
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
                    SUBTYPE SCONS IS CONS;
               BEGIN
                    DECLARE
                         X : SCONS;
                    BEGIN
                         FAILED ("INDEX CHECK NOT PERFORMED - 2");
                         IF X /= (1, (1, 1)) THEN
                              COMMENT ("IRRELEVANT");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED - 2A");
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - 2B");
          END;

          BEGIN
               DECLARE
                    TYPE ARR IS ARRAY (1..5) OF CONS;
               BEGIN
                    DECLARE
                         X : ARR;
                    BEGIN
                         FAILED ("INDEX CHECK NOT PERFORMED - 3");
                         IF X /= (1..5 => (1, (1, 1))) THEN
                              COMMENT ("IRRELEVANT");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED - 3A");
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - 3B");
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
                         FAILED ("INDEX CHECK NOT PERFORMED - 4");
                         IF X /= (C1 => (1, (1, 1))) THEN
                              COMMENT ("IRRELEVANT");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED - 4A");
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - 4B");
          END;

          BEGIN
               DECLARE
                    TYPE NREC IS NEW CONS;
               BEGIN
                    DECLARE
                         X : NREC;
                    BEGIN
                         FAILED ("INDEX CHECK NOT PERFORMED - 5");
                         IF X /= (1, (1, 1)) THEN
                              COMMENT ("IRRELEVANT");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED - 5A");
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - 5B");
          END;

          BEGIN
               DECLARE
                    TYPE ACC_CONS IS ACCESS CONS;
               BEGIN
                    DECLARE
                         X : ACC_CONS;
                    BEGIN
                         X := NEW CONS;
                         FAILED ("INDEX CHECK NOT PERFORMED - 6");
                         IF X.ALL /= (1, (1, 1)) THEN
                              COMMENT ("WRONG VALUE FOR X - 6");
                         END IF;
                    EXCEPTION
                         WHEN CONSTRAINT_ERROR =>
                              NULL;
                         WHEN OTHERS =>
                              FAILED ("UNEXPECTED EXCEPTION RAISED " &
                                      "- 6A");
                    END;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED - 6B");
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - 6C");
          END;
     END;

-- CASE D2: COMPONENT IS ABSENT

     SEQUENCE_NUMBER := 2;
     DECLARE
          TYPE CONS (D3 : INTEGER := IDENT_INT(11)) IS
               RECORD
                    CASE D3 IS
                         WHEN -5..10 =>
                              C1 : MY_ARR(IDENT_INT(2)..D3);
                         WHEN OTHERS =>
                              C2 : INTEGER := IDENT_INT(5);
                    END CASE;
               END RECORD;
     BEGIN
          BEGIN
               DECLARE
                    X : CONS;
               BEGIN
                    IF X /= (11, 5) THEN
                         COMMENT ("X VALUE IS INCORRECT - 11");
                    END IF;
               END;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - 11");
          END;

          BEGIN
               DECLARE
                    SUBTYPE SCONS IS CONS;
               BEGIN
                    DECLARE
                         X : SCONS;
                    BEGIN
                         IF X /= (11, 5) THEN
                              FAILED ("X VALUE INCORRECT - 12");
                         END IF;
                    END;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED - 12A");
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - 12B");
          END;

          BEGIN
               DECLARE
                    TYPE ARR IS ARRAY (1..5) OF CONS;
               BEGIN
                    DECLARE
                         X : ARR;
                    BEGIN
                         IF X /= (1..5 => (11, 5)) THEN
                              FAILED ("X VALUE INCORRECT - 13");
                         END IF;
                    END;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED - 13A");
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - 13B");
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
                         IF X /= (C1 => (11, 5)) THEN
                              FAILED ("X VALUE INCORRECT - 14");
                         END IF;
                    END;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED - 14A");
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - 14B");
          END;

          BEGIN
               DECLARE
                    TYPE NREC IS NEW CONS;
               BEGIN
                    DECLARE
                         X : NREC;
                    BEGIN
                         IF X /= (11, 5) THEN
                              FAILED ("X VALUE INCORRECT - 15");
                         END IF;
                    END;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED - 15A");
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - 15B");
          END;

          BEGIN
               DECLARE
                    TYPE ACC_CONS IS ACCESS CONS;
                    X : ACC_CONS;
               BEGIN
                    X := NEW CONS;
                    IF X.ALL /= (11, 5) THEN
                         FAILED ("X VALUE INCORRECT - 17");
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED - 17A");
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - 17B");
          END;
     END;

     RESULT;
EXCEPTION
     WHEN OTHERS =>
          FAILED ("INDEX VALUES CHECKED TOO SOON - " &
                  INTEGER'IMAGE(SEQUENCE_NUMBER));
          RESULT;
END C37215H;
