-- C37215E.ADA

-- OBJECTIVE:
--     CHECK THAT IF A DISCRIMINANT CONSTRAINT DEPENDS ON A
--     DISCRIMINANT, THE DISCRIMINANT VALUE IS CHECKED FOR
--     COMPATIBILITY WHEN THE RECORD TYPE IS:
--
--          CASE C: CONSTRAINED EXPLICITLY AND THE COMPONENT
--          CONTAINING THE CONSTRAINT IS PRESENT IN THE SUBTYPE.

-- HISTORY:
--     JBG 10/17/86  CREATED THE ORIGNAL TEST.
--     RJW 10/13/87  CHANGED THE CONSTRAINT OF THE COMPONENT SUBTYPE
--                   CONSTRAINT OF COMPONENT 'C1' OF 'NREC' FROM '11'
--                   TO '0' IN 'CASE C1 - 4'.
--     RJW 03/18/88  CHANGED THE CONSTRAINT OF THE SUBTYPE INDICATION
--                   OF THE DERIVED TYPE DEFINITION FOR 'NREC' FROM 
--                   '11'TO '0' IN 'CASE C1 - 5'.


WITH REPORT; USE REPORT;
PROCEDURE C37215E IS

     SUBTYPE SM IS INTEGER RANGE 1..10;

     TYPE REC (D1, D2 : SM) IS
          RECORD NULL; END RECORD;

BEGIN

     TEST ("C37215E", "CHECK COMPATIBILITY OF DISCRIMINANT " &
                      "EXPRESSIONS WHEN CONSTRAINT DEPENDS ON " &
                      "DISCRIMINANT");

-- CASE C1 : COMPONENT IS PRESENT

     DECLARE
          TYPE CONS (D3 : INTEGER) IS
               RECORD
                    CASE D3 IS
                         WHEN -5..10 =>
                              C1 : REC(D3, 1);
                         WHEN OTHERS =>
                              C2 : INTEGER := IDENT_INT(0);
                    END CASE;
               END RECORD;
     BEGIN
          BEGIN
               DECLARE
                    X : CONS(IDENT_INT(0));
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
                    FAILED ("UNEXPECTED EXCEPTION RAISED - 1");
          END;

          BEGIN
               DECLARE
                    SUBTYPE SCONS IS CONS(0);
               BEGIN
                    FAILED ("DISCRIMINANT CHECK NOT PERFORMED - 2");
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
                    FAILED ("DISCRIMINANT CHECK NOT PERFORMED - 3");
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
                              C1 : CONS (0);
                         END RECORD;
               BEGIN
                    FAILED ("DISCRIMINANT CHECK NOT PERFORMED - 4");
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
                    TYPE NREC IS NEW CONS(IDENT_INT(0));
               BEGIN
                    FAILED ("DISCRIMINANT CHECK NOT PERFORMED - 5");
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
                    TYPE ACC_CONS IS ACCESS CONS(0);
               BEGIN
                    FAILED ("DISCRIMINANT CHECK NOT PERFORMED - 6");
                    DECLARE
                         X : ACC_CONS;
                    BEGIN
                         X := NEW CONS(0);
                         IF X.ALL /= (1, (1, 1)) THEN
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
                    FAILED ("DISCRIMINANT CHECK NOT PERFORMED - 7");
                    BEGIN
                         IF X.ALL /= (1, (1, 1)) THEN
                              COMMENT ("IRRELEVANT");
                         END IF;
                    END;
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

-- CASE C2 : COMPONENT IS ABSENT

     DECLARE
          TYPE CONS (D3 : INTEGER) IS
               RECORD
                    CASE D3 IS
                         WHEN -5..10 =>
                              C1 : REC(D3, IDENT_INT(1));
                         WHEN OTHERS =>
                              C2 : INTEGER := IDENT_INT(5);
                    END CASE;
               END RECORD;
     BEGIN
          BEGIN
               DECLARE
                    X : CONS(-6);
               BEGIN
                    IF X /= (-6, 5) THEN
                         FAILED ("WRONG VALUE FOR X - 11");
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
                         IF X /= (11, 5) THEN
                              FAILED ("X VALUE WRONG - 2");
                         END IF;
                    END;
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("NONEXISTENT CONSTRAINT CHECKED - 12");
          END;

          BEGIN
               DECLARE
                    TYPE ARR IS ARRAY (1..5) OF CONS(IDENT_INT(-6));
                    X : ARR;
               BEGIN
                    IF X /= (1..5 => (-6, 5)) THEN
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
                              C1 : CONS(11);
                         END RECORD;
                    X : NREC;
               BEGIN
                    IF X /= (C1 => (11, 5)) THEN
                         FAILED ("X VALUE IS INCORRECT - 14");
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
                    IF X /= (11, 5) THEN
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
                    X := NEW CONS(IDENT_INT(11));
                    IF X.ALL /= (11, 5) THEN
                         FAILED ("X VALUE INCORRECT - 16");
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("NONEXISTENT CONSTRAINT " &
                                 "CHECKED - 16A");
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("NONEXISTENT CONSTRAINT CHECKED - 16B");
          END;

          BEGIN
               DECLARE
                    TYPE ACC_CONS IS ACCESS CONS;
                    X : ACC_CONS := NEW CONS(-6);
               BEGIN
                    IF X.ALL /= (-6, 5) THEN
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
          FAILED ("DISCRIMINANT VALUE CHECKED TOO SOON");
          RESULT;

END C37215E;
