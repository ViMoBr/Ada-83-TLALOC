-- C37216A.ADA

-- OBJECTIVE:
--     CHECK, WHEN THE TYPE BEING CONSTRAINED HAS NOT BEEN COMPLETELY
--     DECLARED, THAT IF A DISCRIMINANT CONSTRAINT DEPENDS ON A
--     DISCRIMINANT, THE VALUES OF THE DISCRIMINANTS ARE CHECKED NO
--     LATER THAN WHEN THE RECORD TYPE IS FULLY DECLARED AND THE TYPE IS
--     CONSTRAINED EXPLICITLY.

-- HISTORY:
--     DHH 08/30/88 CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE C37216A IS

     SUBTYPE SM IS INTEGER RANGE 1..10;

BEGIN  --C37216A BODY
     TEST("C37216A", "CHECK, WHEN THE TYPE BEING CONSTRAINED HAS NOT " &
                     "BEEN COMPLETELY DECLARED, THAT IF A " &
                     "DISCRIMINANT CONSTRAINT DEPENDS ON A " &
                     "DISCRIMINANT, THE VALUES OF THE DISCRIMINANTS " &
                     "ARE CHECKED NO LATER THAN WHEN THE RECORD TYPE " &
                     "IS FULLY DECLARED AND THE TYPE IS CONSTRAINED " &
                     "EXPLICITLY");
     DECLARE
-----------------------------------------------------------------------
                                        -- CONSTRAINT CHECKS ON A
                                        -- RECORD DECLARATION
     BEGIN -- B1

          DECLARE  -- B1A

               PACKAGE PACK IS
                    TYPE FULL_AND_COMPLETE IS PRIVATE;

                    TYPE REC (D1 : SM) IS
                         RECORD
                              X : FULL_AND_COMPLETE;
                         END RECORD;

                    TYPE CONS1 (D3 : INTEGER) IS
                         RECORD
                              C1 : REC(D3);
                         END RECORD;

               PRIVATE
                    TYPE FULL_AND_COMPLETE IS
                         RECORD
                              X : INTEGER;
                         END RECORD;
               END PACK;
               USE PACK;

               X : CONS1(IDENT_INT(0));

          BEGIN  --B1A
               FAILED("CONSTRAINT CHECK NOT PERFORMED - RECORD");

               IF X.C1.D1 /= IDENT_INT(0) THEN
                    COMMENT("THIS LINE SHOULD NOT PRINT");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED("EXCEPTION RAISED TOO LATE " &
                           "- RECORD");
          END;  -- B1A
     EXCEPTION  -- B1
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED - 1");
     END;  -- B1

-----------------------------------------------------------------------
                                              -- THIS SECTION MONITORS
                                              -- CONSTRAINT CHECKS ON A
                                              -- SUBTYPE DECLARATION.
     BEGIN  -- B2

          DECLARE  -- B2A
               PACKAGE PACK IS
                    TYPE FULL_AND_COMPLETE IS PRIVATE;

                    TYPE REC (D1 : SM) IS
                         RECORD
                              X : FULL_AND_COMPLETE;
                         END RECORD;

                    TYPE CONS1 (D3 : INTEGER) IS
                         RECORD
                              C1 : REC(D3);
                         END RECORD;

                    SUBTYPE SCONS IS CONS1(IDENT_INT(0));

               PRIVATE
                    TYPE FULL_AND_COMPLETE IS
                         RECORD
                              X : INTEGER;
                         END RECORD;
               END PACK;
               USE PACK;
          BEGIN  -- B2A
               FAILED("CONSTRAINT CHECK NOT PERFORMED " &
                      "- SUBTYPE");
               DECLARE
                    X : SCONS;
               BEGIN
                    IF X.D3 /= IDENT_INT(0) THEN
                         COMMENT("IRREVELANT");
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED("EXCEPTION RAISED TOO LATE " &
                                "- SUBTYPE");
               END;
          END;   -- B2A

     EXCEPTION  -- B2
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED - 2");
     END;  -- B2

-----------------------------------------------------------------------
                                              -- THIS SECTION MONITORS
                                              -- CONSTRAINT CHECKS ON AN
                                              -- ARRAY DECLARATION.
     BEGIN  -- B3

          DECLARE
               PACKAGE PACK IS
                    TYPE FULL_AND_COMPLETE IS PRIVATE;

                    TYPE REC (D1 : SM) IS
                         RECORD
                              X : FULL_AND_COMPLETE;
                         END RECORD;

                    TYPE CONS1 (D3 : INTEGER) IS
                         RECORD
                              C1 : REC(D3);
                         END RECORD;

                    TYPE ARR IS ARRAY(1 .. 5) OF CONS1(IDENT_INT(0));

               PRIVATE
                    TYPE FULL_AND_COMPLETE IS
                         RECORD
                              X : INTEGER;
                         END RECORD;
               END PACK;
               USE PACK;

          BEGIN
               FAILED("CONSTRAINT CHECK NOT PERFORMED " &
                      "- ARRAY");
               DECLARE
                    X : ARR;
               BEGIN
                    IF X(IDENT_INT(1)).D3 /= IDENT_INT(0) THEN
                         COMMENT("SHOULDN'T GET HERE");
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED("EXCEPTION RAISED TOO LATE " &
                                "- ARRAY");
               END;
          END;
     EXCEPTION  -- B3
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED - 3");
     END;  -- B3

-----------------------------------------------------------------------
                                             -- THIS SECTION CHECKS
                                             -- ACCESS TYPES WHERE
                                             -- THE CONSTRAINT IS
                                             -- GIVEN IN THE ACCESS
                                             -- TYPE DECLARATION.
     BEGIN  -- B6
          DECLARE
               PACKAGE PACK IS
                    TYPE FULL_AND_COMPLETE IS PRIVATE;

                    TYPE REC (D1 : SM) IS
                         RECORD
                              X : FULL_AND_COMPLETE;
                         END RECORD;

                    TYPE CONS1 (D3 : INTEGER) IS
                         RECORD
                              C1 : REC(D3);
                         END RECORD;

                    TYPE ACC_CONS IS ACCESS CONS1(IDENT_INT(11));

               PRIVATE
                    TYPE FULL_AND_COMPLETE IS
                         RECORD
                              X : INTEGER;
                         END RECORD;
               END PACK;
               USE PACK;
          BEGIN
               FAILED("CONSTRAINT CHECK NOT PERFORMED " &
                      "- ACCESS TYPE");
               DECLARE
                    X : ACC_CONS;
               BEGIN
                    X := NEW CONS1(IDENT_INT(11));
                    IF X.D3 /= IDENT_INT(1) THEN
                         COMMENT("SHOULD NOT PRINT OUT");
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED("EXCEPTION RAISED TOO LATE " &
                                "- ACCESS TYPE");
               END;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED - 6");
     END;
-----------------------------------------------------------------------
                                             -- THIS SECTION CHECKS
                                             -- ACCESS TYPES WHERE
                                             -- THE CONSTRAINT IS
                                             -- GIVEN ON AN INCOMPLETE
                                             -- TYPE.
     BEGIN  -- B7
          DECLARE
               PACKAGE PACK IS

                    TYPE CONS1(D3 : INTEGER);
                    TYPE ACC_CONS IS ACCESS CONS1(IDENT_INT(11));

                    TYPE REC (D1 : SM) IS
                         RECORD
                              NULL;
                         END RECORD;

                    TYPE CONS1(D3 : INTEGER) IS
                         RECORD
                              C1 : REC(D3);
                         END RECORD;

               END PACK;
               USE PACK;
          BEGIN
               FAILED("CONSTRAINT CHECK NOT PERFORMED " &
                      "- INCOMPLETE TYPE");
               DECLARE
                    X : ACC_CONS;
               BEGIN
                    X := NEW CONS1(IDENT_INT(11));
                    IF X.D3 /= IDENT_INT(11) THEN
                         COMMENT("SHOULD NEVER BE PRINTED");
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED("EXCEPTION RAISED TOO LATE " &
                                "- INCOMPLETE TYPE");
               END;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED - 7");
     END;
-----------------------------------------------------------------------
     RESULT;

EXCEPTION  -- BODY
     WHEN OTHERS =>
          FAILED ("DISCRIMINANT VALUE CHECKED TOO SOON");
          RESULT;

END C37216A;  -- BODY
