-- C95072A.ADA

-- CHECK THAT SCALAR AND ACCESS PARAMETERS ARE COPIED FOR ALL THREE
-- PARAMETER MODES.
-- SUBTESTS ARE:
--   (A)  SCALAR PARAMETERS TO ENTRIES.
--   (B)  ACCESS PARAMETERS TO ENTRIES.

-- JWC 7/22/85

WITH REPORT; USE REPORT;
PROCEDURE C95072A IS

BEGIN
     TEST ("C95072A", "CHECK THAT SCALAR AND ACCESS PARAMETERS ARE " &
                      "COPIED");

     --------------------------------------------------

     DECLARE  -- (A)

          I : INTEGER;
          E : EXCEPTION;

          TASK TA IS
               ENTRY EA (EI : IN INTEGER; EO : OUT INTEGER;
                         EIO : IN OUT INTEGER);
          END TA;

          TASK BODY TA IS

               TMP : INTEGER;

          BEGIN

               ACCEPT EA (EI : IN INTEGER; EO : OUT INTEGER;
                          EIO : IN OUT INTEGER) DO

                    TMP := EI;     -- SAVE VALUE OF EI AT ACCEPT.

                    EO := 10;
                    IF EI /= TMP THEN
                         FAILED ("ASSIGNMENT TO SCALAR OUT " &
                                 "PARAMETER CHANGES THE VALUE OF " &
                                 "INPUT PARAMETER");
                         TMP := EI;     -- RESET TMP FOR NEXT CASE.
                    END IF;

                    EIO := EIO + 100;
                    IF EI /= TMP THEN
                         FAILED ("ASSIGNMENT TO SCALAR IN OUT " &
                                 "PARAMETER CHANGES THE VALUE OF " &
                                 "INPUT PARAMETER");
                         TMP := EI;     -- RESET TMP FOR NEXT CASE.
                    END IF;

                    I := I + 1;
                    IF EI /= TMP THEN
                         FAILED ("ASSIGNMENT TO SCALAR ACTUAL " &
                                 "PARAMETER CHANGES THE VALUE OF " &
                                 "INPUT PARAMETER");
                    END IF;

                    RAISE E;            -- CHECK EXCEPTION HANDLING.
               END EA;

          EXCEPTION
               WHEN OTHERS => NULL;
          END TA;

     BEGIN  -- (A)

          I := 0;   -- INITIALIZE I SO VARIOUS CASES CAN BE DETECTED.
          TA.EA (I, I, I);
          FAILED ("EXCEPTION NOT RAISED - A");

     EXCEPTION
          WHEN E =>
               IF I /= 1 THEN
                    CASE I IS
                         WHEN 11  =>
                              FAILED ("OUT ACTUAL SCALAR PARAMETER " &
                                      "CHANGED GLOBAL VALUE");
                         WHEN 101 =>
                              FAILED ("IN OUT ACTUAL SCALAR " &
                                      "PARAMETER CHANGED GLOBAL VALUE");
                         WHEN 111 =>
                              FAILED ("OUT AND IN OUT ACTUAL SCALAR " &
                                      "PARAMETERS CHANGED GLOBAL " &
                                      "VALUE");
                         WHEN OTHERS =>
                              FAILED ("UNDETERMINED CHANGE TO GLOBAL " &
                                      "VALUE");
                    END CASE;
               END IF;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - A");
     END;  -- (A)

     --------------------------------------------------

     DECLARE  -- (B)

          TYPE ACCTYPE IS ACCESS INTEGER;

          I : ACCTYPE;
          E : EXCEPTION;

          TASK TB IS
               ENTRY EB (EI : IN ACCTYPE; EO : OUT ACCTYPE;
                         EIO : IN OUT ACCTYPE);
          END TB;

          TASK BODY TB IS

               TMP : ACCTYPE;

          BEGIN

               ACCEPT EB (EI : IN ACCTYPE; EO : OUT ACCTYPE;
                          EIO : IN OUT ACCTYPE) DO

                    TMP := EI;     -- SAVE VALUE OF EI AT ACCEPT.

                    I := NEW INTEGER'(101);
                    IF EI /= TMP THEN
                         FAILED ("ASSIGNMENT TO ACCESS ACTUAL " &
                                 "PARAMETER CHANGES THE VALUE OF " &
                                 "INPUT PARAMETER");
                         TMP := EI;     -- RESET TMP FOR NEXT CASE.
                    END IF;

                    EO := NEW INTEGER'(1);
                    IF EI /= TMP THEN
                         FAILED ("ASSIGNMENT TO ACCESS OUT " &
                                 "PARAMETER CHANGES THE VALUE OF " &
                                 "INPUT PARAMETER");
                         TMP := EI;     -- RESET TMP FOR NEXT CASE.
                    END IF;

                    EIO := NEW INTEGER'(10);
                    IF EI /= TMP THEN
                         FAILED ("ASSIGNMENT TO ACCESS IN OUT " &
                                 "PARAMETER CHANGES THE VALUE OF " &
                                 "INPUT PARAMETER");
                    END IF;

                    RAISE E;            -- CHECK EXCEPTION HANDLING.
               END EB;

          EXCEPTION
               WHEN OTHERS => NULL;
          END TB;

     BEGIN  -- (B)

          I := NEW INTEGER'(100);
          TB.EB (I, I, I);
          FAILED ("EXCEPTION NOT RAISED - B");

     EXCEPTION
          WHEN E =>
               IF I.ALL /= 101 THEN
                    FAILED ("OUT OR IN OUT ACTUAL ENTRY " &
                            "PARAMETER VALUE CHANGED DESPITE " &
                            "RAISED EXCEPTION");
               END IF;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - B");
     END;  -- (B)

     --------------------------------------------------

     RESULT;
END C95072A;
