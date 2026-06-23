-- C64106C.ADA

-- CHECK THAT ASSIGNMENTS TO FORMAL PARAMETERS OF UNCONSTRAINED
--    RECORD, PRIVATE, AND LIMITED PRIVATE TYPES WITH DEFAULT
--    CONSTRAINTS RAISE CONSTRAINT_ERROR IF THE ACTUAL PARAMETER IS
--    CONSTRAINED AND THE CONSTRAINT VALUES OF THE OBJECT BEING
--    ASSIGNED TO DO NOT SATISFY THOSE OF THE ACTUAL PARAMETER.  

--    SUBTESTS ARE:
--        (A) CONSTRAINED ACTUAL PARAMETERS OF RECORD TYPE.
--        (B) CONSTRAINED ACTUAL PARAMETERS OF PRIVATE TYPE.
--        (C) CONSTRAINED ACTUAL PARAMETERS OF LIMITED PRIVATE TYPE.

-- DAS  1/16/81
-- VKG  1/7/83
-- CPP  8/9/84

WITH REPORT;
PROCEDURE C64106C IS

     USE REPORT;

BEGIN

     TEST ("C64106C", "CHECK ASSIGNMENTS TO FORMAL PARAMETERS OF " &
                      "UNCONSTRAINED TYPES (WITH DEFAULTS)");

     --------------------------------------------------

     DECLARE  -- (A)

          PACKAGE PKG IS

               SUBTYPE INTRANGE IS INTEGER RANGE 0..31;

               TYPE RECTYPE (CONSTRAINT : INTRANGE := 15) IS
                    RECORD
                         INTFLD   : INTRANGE;
                         STRFLD   : STRING(1..CONSTRAINT);
                    END RECORD;

               REC91,REC92,REC93  : RECTYPE(9);
               REC_OOPS           : RECTYPE(4);

               PROCEDURE P (REC1 : IN RECTYPE; REC2 : IN OUT RECTYPE;
                            REC3 : OUT RECTYPE);
          END PKG;

          PACKAGE BODY PKG IS

               PROCEDURE P (REC1 : IN RECTYPE; REC2 : IN OUT RECTYPE;
                            REC3 : OUT RECTYPE) IS

                    PROCEDURE P1 (REC11 : IN RECTYPE;
                                  REC12 : IN OUT RECTYPE;
                                  REC13 : OUT RECTYPE) IS
                    BEGIN
                         IF (NOT REC11'CONSTRAINED) OR
                            (REC11.CONSTRAINT /= IDENT_INT(9)) THEN
                              FAILED ("CONSTRAINT ON RECORD " &
                                      "TYPE IN PARAMETER " &
                                      "NOT RECOGNIZED");
                         END IF;

                         BEGIN  -- ASSIGNMENT TO IN OUT PARAMETER
                              REC12 := REC_OOPS;
                              FAILED ("CONSTRAINT ERROR NOT RAISED - " &
                                      "A.1");
                         EXCEPTION
                              WHEN CONSTRAINT_ERROR =>
                                   NULL;
                              WHEN OTHERS =>
                                   FAILED ("WRONG EXCEPTION RAISED - " &
                                           "A.1");
                         END;

                         BEGIN  -- ASSIGNMENT TO OUT PARAMETER
                              REC13 := REC_OOPS;
                              FAILED ("CONSTRAINT_ERROR NOT RAISED - " &
                                      "A.2");
                         EXCEPTION
                              WHEN CONSTRAINT_ERROR =>
                                   NULL;
                              WHEN OTHERS =>
                                   FAILED ("WRONG EXCEPTION RAISED - " &
                                           "A.2");
                         END;
                    END P1;

               BEGIN
                    P1 (REC1, REC2, REC3);
               END P;

          BEGIN

               REC91 := (9, 9, "123456789");
               REC92 := REC91;
               REC93 := REC91;

               REC_OOPS := (4, 4, "OOPS");

          END PKG;

     BEGIN  -- (A)

          PKG.P (PKG.REC91, PKG.REC92, PKG.REC93);

     END;   -- (A)

     --------------------------------------------------

     DECLARE  -- (B)

          PACKAGE PKG IS

               SUBTYPE INTRANGE IS INTEGER RANGE 0..31;

               TYPE RECTYPE (CONSTRAINT : INTRANGE := 15) IS PRIVATE;

               PROCEDURE P (REC1 : IN RECTYPE; REC2 : IN OUT RECTYPE;
                            REC3 : OUT RECTYPE);

          PRIVATE

               TYPE RECTYPE (CONSTRAINT : INTRANGE := 15) IS
                    RECORD
                         INTFLD   : INTRANGE;
                         STRFLD   : STRING(1..CONSTRAINT);
                    END RECORD;
          END PKG;

          REC91, REC92, REC93  : PKG.RECTYPE(9);
          REC_OOPS             : PKG.RECTYPE(4);

          PACKAGE BODY PKG IS

               PROCEDURE P (REC1 : IN RECTYPE; REC2 : IN OUT RECTYPE;
                            REC3 : OUT RECTYPE) IS

                    PROCEDURE P1 (REC11 : IN RECTYPE;
                                  REC12 : IN OUT RECTYPE;
                                  REC13 : OUT RECTYPE) IS
                    BEGIN
                         IF (NOT REC11'CONSTRAINED) OR
                            (REC11.CONSTRAINT /= IDENT_INT(9)) THEN
                              FAILED ("CONSTRAINT ON PRIVATE " &
                                      "TYPE IN PARAMETER " &
                                      "NOT RECOGNIZED");
                         END IF;

                         BEGIN  -- ASSIGNMENT TO IN OUT PARAMETER
                              REC12 := REC_OOPS;
                              FAILED ("CONSTRAINT ERROR NOT RAISED - " &
                                      "B.1");
                         EXCEPTION
                              WHEN CONSTRAINT_ERROR =>
                                   NULL;
                              WHEN OTHERS =>
                                   FAILED ("WRONG EXCEPTION RAISED - " &
                                           "B.1");
                         END;

                         BEGIN  -- ASSIGNMENT TO OUT PARAMETER
                              REC13 := REC_OOPS;
                              FAILED ("CONSTRAINT_ERROR NOT RAISED - " &
                                      "B.2");
                         EXCEPTION
                              WHEN CONSTRAINT_ERROR =>
                                   NULL;
                              WHEN OTHERS =>
                                   FAILED ("WRONG EXCEPTION RAISED - " &
                                           "B.2");
                         END;
                    END P1;

               BEGIN
                    P1 (REC1, REC2, REC3);
               END P;

          BEGIN

               REC91 := (9, 9, "123456789");
               REC92 := REC91;
               REC93 := REC91;

               REC_OOPS := (4, 4, "OOPS");

          END PKG;

     BEGIN  -- (B)

          PKG.P (REC91, REC92, REC93);

     END;   -- (B)

     --------------------------------------------------

     DECLARE  -- (C)

          PACKAGE PKG IS

               SUBTYPE INTRANGE IS INTEGER RANGE 0..31;

               TYPE RECTYPE (CONSTRAINT : INTRANGE := 15) IS
                    LIMITED PRIVATE;

               PROCEDURE P (REC1 : IN RECTYPE; REC2 : IN OUT RECTYPE;
                            REC3 : OUT RECTYPE);

          PRIVATE

               TYPE RECTYPE (CONSTRAINT : INTRANGE := 15) IS
                    RECORD
                         INTFLD   : INTRANGE;
                         STRFLD   : STRING(1..CONSTRAINT);
                    END RECORD;
          END PKG;

          REC91,REC92,REC93  : PKG.RECTYPE(9);
          REC_OOPS           : PKG.RECTYPE(4);

          PACKAGE BODY PKG IS

               PROCEDURE P (REC1 : IN RECTYPE; REC2 : IN OUT RECTYPE;
                            REC3 : OUT RECTYPE) IS

                    PROCEDURE P1 (REC11 : IN RECTYPE;
                                  REC12 : IN OUT RECTYPE;
                                  REC13 : OUT RECTYPE) IS
                    BEGIN
                         IF (NOT REC11'CONSTRAINED) OR
                            (REC11.CONSTRAINT /= 9) THEN
                              FAILED ("CONSTRAINT ON LIMITED PRIVATE " &
                                      "TYPE IN PARAMETER " &
                                      "NOT RECOGNIZED");
                         END IF;

                         BEGIN  -- ASSIGNMENT TO IN OUT PARAMETER
                              REC12 := REC_OOPS;
                              FAILED ("CONSTRAINT ERROR NOT RAISED - " &
                                      "C.1");
                         EXCEPTION
                              WHEN CONSTRAINT_ERROR =>
                                   NULL;
                              WHEN OTHERS =>
                                   FAILED ("WRONG EXCEPTION RAISED - " &
                                           "C.1");
                         END;

                         BEGIN  -- ASSIGNMENT TO OUT PARAMETER
                              REC13 := REC_OOPS;
                              FAILED ("CONSTRAINT_ERROR NOT RAISED - " &
                                      "C.2");
                         EXCEPTION
                              WHEN CONSTRAINT_ERROR =>
                                   NULL;
                              WHEN OTHERS =>
                                   FAILED ("WRONG EXCEPTION RAISED - " &
                                           "C.2");
                         END;
                    END P1;

               BEGIN
                    P1 (REC1, REC2, REC3);
               END P;

          BEGIN

               REC91 := (9, 9, "123456789");
               REC92 := REC91;
               REC93 := REC91;

               REC_OOPS := (4, 4, "OOPS");

          END PKG;

     BEGIN  -- (C)

          PKG.P (REC91, REC92, REC93);

     END;   -- (C)

     --------------------------------------------------

     RESULT;

END C64106C;
