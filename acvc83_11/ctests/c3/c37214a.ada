-- C37214A.ADA

-- OBJECTIVE:
--     CHECK, WHEN A TYPE BEING CONSTRAINED HAS NOT BEEN COMPLETELY
--     DECLARED, THAT WHERE A DISCRIMINANT CONSTRAINT DEPENDS ON A
--     DISCRIMINANT, ANY CONSTRAINT EXPRESSIONS WHICH DO NOT DEPEND
--     ON THE DISCRIMINANT ARE EVALUATED AND CHECKED NO LATER THAN THE
--     END OF THE DECLARATION THAT COMPLETELY DECLARES THE TYPE.

-- HISTORY:
--     DHH 02/03/88 CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE C37214A IS

     SUBTYPE SM IS INTEGER RANGE 1..10;
     F1_CONS : INTEGER := 0;

     FUNCTION CHK (
          FIRST   : BOOLEAN;
          CONS    : INTEGER;
          VALUE   : INTEGER;
          MESSAGE : STRING) RETURN BOOLEAN IS
     BEGIN
          IF FIRST THEN
               IF CONS /= VALUE THEN
                    COMMENT (MESSAGE & ": F1_CONS IS " &
                             INTEGER'IMAGE(F1_CONS));
               END IF;
          ELSE
               IF CONS /= VALUE THEN
                    FAILED (MESSAGE & ": F1_CONS IS " &
                            INTEGER'IMAGE(F1_CONS));
               END IF;
          END IF;
          RETURN TRUE;
     END CHK;

     FUNCTION F1 RETURN INTEGER IS
     BEGIN
          F1_CONS := F1_CONS + IDENT_INT(1);
          RETURN F1_CONS;
     END F1;

BEGIN  --C37214A BODY
     TEST("C37214A", "CHECK, WHEN A TYPE BEING CONSTRAINED HAS NOT " &
                     "BEEN COMPLETELY DECLARED, THAT WHERE A " &
                     "DISCRIMINANT CONSTRAINT DEPENDS ON A " &
                     "DISCRIMINANT, ANY CONSTRAINT EXPRESSIONS " &
                     "WHICH DO NOT DEPEND ON THE DISCRIMINANT ARE " &
                     "EVALUATED AND CHECKED NO LATER THAN THE END OF " &
                     "THE DECLARATION THAT COMPLETELY DECLARES THE " &
                     "TYPE");

--**********************************************************************
                                        -- THIS SECTION CHECKS THAT THE
                                        -- COMPONENT CONSTRAINT NOT
                                        -- DEPENDENT UPON THE
                                        -- DISCRIMINANT IS EVALUATED
                                        -- PROPERLY.
     DECLARE  -- A

          PACKAGE PACK IS
               TYPE FULL_AND_COMPLETE IS PRIVATE;

               TYPE REC (D1, D2 : SM) IS
                    RECORD
                         X : FULL_AND_COMPLETE;
                    END RECORD;

               TYPE CONS1 (D3 : INTEGER) IS
                    RECORD
                         C1 : REC(D3, F1);
                                        -- F1 MAY BE EVALUATED HERE BUT
                                        -- NEED NOT BE FOR INCOMPLETELY
                                        -- DECLARED TYPES.
                    END RECORD;
               CHK1 : BOOLEAN := CHK (TRUE, F1_CONS, 1,
                                     "F1 NOT EVALUATED");
                                        -- IF F1_CONS IS NOT EQUAL TO
                                        -- 1 AT THIS POINT, F1 HAS NOT
                                        -- BEEN EVALUATED, WHICH IS
                                        -- LEGAL FOR INCOMPLETE TYPES.
                                        -- IT IS ALSO LEGAL AT THIS
                                        -- POINT TO CHECK CONSTRAINTS.
          PRIVATE
               TYPE FULL_AND_COMPLETE IS
                    RECORD
                         X : INTEGER;
                    END RECORD;
               CHK2 : BOOLEAN := CHK (FALSE, F1_CONS, 1,
                                     "F1 EVALUATED");
                                        -- THIS CHECKS TO SEE IF F1
                                        -- HAS BEEN RE-EVALUATED ABOVE,
                                        -- WHICH IS ILLEGAL.IF THAT
                                        -- HAS HAPPENED, THE TEST
                                        -- FAILS. BUT AT THIS
                                        -- POINT, F1 MUST BE EVALUATED
                                        -- AND MUST EQUAL 1, AS THE
                                        -- FULL DECLARATION OF REC
                                        -- IS THE LAST LEGAL POINT OF
                                        -- EVALUATION.
          END PACK;
          USE PACK;
          X : CONS1(1);
                                        -- F1 SHOULD NOT BE
                                        -- RE-EVALUATED HERE. IF IT IS,
                                        -- THE VALUE OF F1_CONS WILL
                                        -- BE 2.
          Y : CONS1(2);
                                        -- F1 SHOULD NOT BE
                                        -- RE-EVALUATED HERE. IF IT IS,
                                        -- THE VALUE OF F1_CONS WILL
                                        -- BE 3.
          CHK3 : BOOLEAN := CHK (FALSE, F1_CONS, 1, "F1 RE-EVALUATED");
     BEGIN  -- A
          IF X.D3 /= 1 OR X.C1.D1 /= 1 OR X.C1.D2 /= 1 OR
               Y.D3 /= 2 OR Y.C1.D1 /= 2 OR Y.C1.D2 /= 1  THEN
               FAILED ("DISCRIMINANT VALUES NOT CORRECT");
          END IF;
     END;  -- A

--*********************************************************************
                                        -- THIS SECTION CHECKS THAT THE
                                        -- COMPONENT CONSTRAINT WHICH
                                        -- IS NOT DEPENDENT UPON THE
                                        -- DISCRIMINANT IS
                                        -- CHECKED FOR COMPATIBILITY AT
                                        -- LEAST BY THE END OF THE FULL
                                        -- DECLARATION OF REC.
                                        -- F1_CONS IS SET TO -1 SO THAT
                                        -- THE FIRST, AND WHAT SHOULD
                                        -- BE ONLY EVALUATION OF F1
                                        -- WILL YIELD A RESULT OF ZERO.
                                        -- THE ZERO WILL CAUSE
                                        -- CONSTRAINT_ERROR WHEN
                                        -- PROPERLY CHECKED.
                                        -- IF F1 IS IMPROPERLY
                                        -- RE-EVALUATED, THE VALUE OF
                                        -- F1_CONS WILL BE IN RANGE AND
                                        -- WILL NOT CAUSE CONSTRAINT_
                                        -- ERROR, WHICH WILL CAUSE THE
                                        -- TEST TO FAIL.
-----------------------------------------------------------------------
                                        -- THIS SECTION MONITORS
                                        -- CONSTRAINT CHECKS ON A
                                        -- RECORD DECLARATION
     F1_CONS := -1;
     BEGIN -- B1

          DECLARE  -- B1A

               PACKAGE PACK IS
                    TYPE FULL_AND_COMPLETE IS PRIVATE;

                    TYPE REC (D1, D2 : SM) IS
                         RECORD
                              X : FULL_AND_COMPLETE;
                         END RECORD;

                    TYPE CONS1 (D3 : INTEGER) IS
                         RECORD
                              C1 : REC(D3, F1);
                         END RECORD;

               PRIVATE
                    TYPE FULL_AND_COMPLETE IS
                         RECORD
                              X : INTEGER;
                         END RECORD;
               END PACK;
               USE PACK;

               X : CONS1(1);

          BEGIN  --B1A
               FAILED("CONSTRAINT CHECK NOT PERFORMED - RECORD");

               IF X.C1.D2 /= IDENT_INT(0) THEN
                    FAILED("COMPONENT ILLEGALLY RE-EVALUATED");
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


--*********************************************************************
                                              -- THIS SECTION MONITORS
                                              -- CONSTRAINT CHECKS ON A
                                              -- SUBTYPE DECLARATION.
     F1_CONS := -1;
     BEGIN  -- B2

          DECLARE  -- B2A
               PACKAGE PACK IS
                    TYPE FULL_AND_COMPLETE IS PRIVATE;

                    TYPE REC (D1, D2 : SM) IS
                         RECORD
                              X : FULL_AND_COMPLETE;
                         END RECORD;

                    TYPE CONS1 (D3 : INTEGER) IS
                         RECORD
                              C1 : REC(D3, F1);
                         END RECORD;

                    SUBTYPE SCONS IS CONS1(1);

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
                    IF X.D3 /= IDENT_INT(1) THEN
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
     F1_CONS := -1;
     BEGIN  -- B3

          DECLARE
               PACKAGE PACK IS
                    TYPE FULL_AND_COMPLETE IS PRIVATE;

                    TYPE REC (D1, D2 : SM) IS
                         RECORD
                              X : FULL_AND_COMPLETE;
                         END RECORD;

                    TYPE CONS1 (D3 : INTEGER) IS
                         RECORD
                              C1 : REC(D3, F1);
                         END RECORD;

                    TYPE ARR IS ARRAY(1 .. 5) OF CONS1(1);

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
                    IF X(IDENT_INT(1)).D3 /= IDENT_INT(1) THEN
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
     F1_CONS := -1;
     BEGIN  -- B6
          DECLARE
               PACKAGE PACK IS
                    TYPE FULL_AND_COMPLETE IS PRIVATE;

                    TYPE REC (D1, D2 : SM) IS
                         RECORD
                              X : FULL_AND_COMPLETE;
                         END RECORD;

                    TYPE CONS1 (D3 : INTEGER) IS
                         RECORD
                              C1 : REC(D3, F1);
                         END RECORD;

                    TYPE ACC_CONS IS ACCESS CONS1(1);

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
                    X := NEW CONS1(1);
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
     F1_CONS := -1;
     BEGIN  -- B7
          DECLARE
               PACKAGE PACK IS

                    TYPE CONS1(D3 : INTEGER);
                    TYPE ACC_CONS IS ACCESS CONS1(1);

                    TYPE REC (D1, D2 : SM) IS
                         RECORD
                              NULL;
                         END RECORD;

                    TYPE CONS1(D3 : INTEGER) IS
                         RECORD
                              C1 : REC(D3, F1);
                         END RECORD;

               END PACK;
               USE PACK;
          BEGIN
               FAILED("CONSTRAINT CHECK NOT PERFORMED " &
                      "- INCOMPLETE TYPE");
               DECLARE
                    X : ACC_CONS;
               BEGIN
                    X := NEW CONS1(1);
                    IF X.D3 /= IDENT_INT(1) THEN
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
--*********************************************************************
     RESULT;

EXCEPTION  -- C37214A BODY
     WHEN OTHERS =>
          FAILED ("DISCRIMINANT VALUE CHECKED TOO SOON");
          RESULT;

END C37214A;  -- BODY
