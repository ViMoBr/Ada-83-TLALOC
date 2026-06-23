-- CD2A51E.ADA

-- OBJECTIVE:
--     CHECK THAT WHEN A SIZE SPECIFICATION IS GIVEN FOR A
--     FIXED POINT TYPE, THEN OPERATIONS ON VALUES OF SUCH A TYPE
--     ARE NOT AFFECTED BY THE REPRESENTATION CLAUSE WHEN THE TYPE
--     IS PASSED AS A GENERIC ACTUAL PARAMETER.

-- HISTORY:
--     BCB 08/21/87  CREATED ORIGINAL TEST.
--     DHH 04/12/89  CHANGED EXTENSION FROM '.DEP' TO '.ADA', CHANGED
--                   OPERATORS ON 'SIZE TESTS, AND CHANGED 'SIZE CLAUSE
--                   SO THAT IT IS NOT A POWER OF TWO.

WITH REPORT; USE REPORT;
PROCEDURE CD2A51E IS

     BASIC_SIZE : CONSTANT := 7;
     B : BOOLEAN;

     TYPE CHECK_TYPE IS DELTA 2.0 ** (-4) RANGE -4.0 .. 4.0;
     FOR CHECK_TYPE'SIZE USE BASIC_SIZE;

BEGIN

     TEST ("CD2A51E", "CHECK THAT WHEN A SIZE SPECIFICATION " &
                      "IS GIVEN FOR A FIXED POINT TYPE, " &
                      "THEN OPERATIONS ON VALUES OF SUCH " &
                      "A TYPE ARE NOT AFFECTED BY THE " &
                      "REPRESENTATION CLAUSE WHEN THE " &
                      "TYPE IS PASSED AS A GENERIC ACTUAL" &
                      "PARAMETER");

     DECLARE

          GENERIC

               TYPE FIXED_ELEMENT IS DELTA <>;

          FUNCTION FUNC RETURN BOOLEAN;

          FUNCTION FUNC RETURN BOOLEAN IS

               ZERO  : CONSTANT :=  0.0;

               TYPE BASIC_TYPE IS DELTA 2.0 ** (-4) RANGE -4.0 .. 4.0;

               CNEG1 : FIXED_ELEMENT := -3.5;
               CNEG2 : FIXED_ELEMENT := FIXED_ELEMENT (-1.0/3.0);
               CPOS1 : FIXED_ELEMENT := FIXED_ELEMENT (4.0/6.0);
               CPOS2 : FIXED_ELEMENT :=  3.5;
               CZERO : FIXED_ELEMENT;

               TYPE ARRAY_TYPE IS ARRAY (0 .. 3) OF FIXED_ELEMENT;
               CHARRAY : ARRAY_TYPE :=
                   (-3.5, FIXED_ELEMENT (-1.0/3.0), FIXED_ELEMENT
                    (4.0/6.0), 3.5);

               TYPE REC_TYPE IS RECORD
                    COMPF : FIXED_ELEMENT := -3.5;
                    COMPN : FIXED_ELEMENT := FIXED_ELEMENT (-1.0/3.0);
                    COMPP : FIXED_ELEMENT := FIXED_ELEMENT (4.0/6.0);
                    COMPL : FIXED_ELEMENT :=  3.5;
               END RECORD;

               CHREC : REC_TYPE;

               FUNCTION IDENT (FX : FIXED_ELEMENT) RETURN
                    FIXED_ELEMENT IS
               BEGIN
                    IF EQUAL (3, 3) THEN
                         RETURN FX;
                    ELSE
                         RETURN 0.0;
                    END IF;
               END IDENT;

               PROCEDURE PROC (CN1IN, CP1IN      :        FIXED_ELEMENT;
                               CN2INOUT,CP2INOUT : IN OUT FIXED_ELEMENT;
                               CZOUT             :    OUT FIXED_ELEMENT)
                               IS
               BEGIN

                    IF IDENT (CN1IN) + CP1IN NOT IN
                         -2.875 .. -2.8125 OR
                       CP2INOUT  - IDENT (CP1IN) NOT IN
                         2.8125 .. 2.875 THEN
                        FAILED ("INCORRECT RESULTS FOR " &
                                "BINARY ADDING OPERATORS - 1");
                    END IF;

                    IF +IDENT (CN2INOUT) NOT IN
                         -0.375 .. -0.3125 OR
                        IDENT (-CP1IN) NOT IN
                         -0.6875 .. -0.625 THEN
                        FAILED ("INCORRECT RESULTS FOR " &
                                "UNARY ADDING OPERATORS - 1");
                    END IF;

                    IF FIXED_ELEMENT (CN1IN * IDENT (CP1IN)) NOT IN
                          -2.4375 .. -2.1875 OR
                       FIXED_ELEMENT (IDENT (CN2INOUT) / CP2INOUT)
                           NOT IN -0.125 .. -0.0625 THEN
                         FAILED ("INCORRECT RESULTS FOR " &
                                 "MULTIPLYING OPERATORS - 1");
                    END IF;

                    IF ABS IDENT (CN2INOUT) NOT IN
                           0.3125 .. 0.375 OR
                         IDENT (ABS CP1IN) NOT IN
                           0.625 .. 0.6875 THEN
                         FAILED ("INCORRECT RESULTS FOR " &
                                 "ABSOLUTE VALUE OPERATORS - 1");
                    END IF;

                    IF IDENT (CP1IN) NOT IN 0.625 .. 0.6875 OR
                           CN2INOUT IN -0.25 .. 0.0 OR
                           IDENT (CN2INOUT) IN -1.0 .. -0.4375 THEN
                         FAILED ("INCORRECT RESULTS FOR MEMBERSHIP " &
                                 "OPERATORS - 1");
                    END IF;

                    CZOUT := 0.0;

               END PROC;

          BEGIN -- FUNC

               PROC (CNEG1, CPOS1, CNEG2, CPOS2, CZERO);

               IF IDENT (CZERO) /= ZERO THEN
                    FAILED ("INCORRECT VALUE FOR OUT PARAMETER");
               END IF;

               IF FIXED_ELEMENT'FIRST > IDENT (-3.9375) THEN
                    FAILED ("INCORRECT VALUE FOR FIXED_ELEMENT'FIRST");
               END IF;

               IF FIXED_ELEMENT'LAST < IDENT (3.9375) THEN
                    FAILED ("INCORRECT VALUE FOR FIXED_ELEMENT'LAST");
               END IF;

               IF FIXED_ELEMENT'SIZE /= IDENT_INT (BASIC_SIZE) THEN
                    FAILED ("INCORRECT VALUE FOR FIXED_ELEMENT'SIZE");
               END IF;

               IF FIXED_ELEMENT'DELTA /= BASIC_TYPE'DELTA THEN
                    FAILED ("INCORRECT VALUE FOR FIXED_ELEMENT'DELTA");
               END IF;

               IF FIXED_ELEMENT'MANTISSA /= BASIC_TYPE'MANTISSA THEN
                    FAILED ("INCORRECT VALUE FOR FIXED_ELEMENT'" &
                            "MANTISSA");
               END IF;

               IF FIXED_ELEMENT'SMALL /= BASIC_TYPE'SMALL THEN
                    FAILED ("INCORRECT VALUE FOR FIXED_ELEMENT'SMALL");
               END IF;

               IF FIXED_ELEMENT'LARGE /= BASIC_TYPE'LARGE THEN
                    FAILED ("INCORRECT VALUE FOR FIXED_ELEMENT'LARGE");
               END IF;

               IF FIXED_ELEMENT'FORE /= BASIC_TYPE'FORE THEN
                    FAILED ("INCORRECT VALUE FOR FIXED_ELEMENT'FORE");
               END IF;

               IF FIXED_ELEMENT'AFT /= BASIC_TYPE'AFT THEN
                    FAILED ("INCORRECT VALUE FOR FIXED_ELEMENT'AFT");
               END IF;

               IF CNEG1'SIZE < IDENT_INT(BASIC_SIZE) THEN
                    FAILED ("INCORRECT VALUE FOR CNEG1'SIZE");
               END IF;

               IF IDENT (CNEG1) + CPOS1 NOT IN
                       -2.875 .. -2.8125 OR
                  CPOS2  - IDENT (CPOS1) NOT IN
                        2.8125 .. 2.875 THEN
                    FAILED ("INCORRECT RESULTS FOR BINARY ADDING " &
                            "OPERATORS - 2");
               END IF;

               IF +IDENT (CNEG2) NOT IN -0.375 .. -0.3125 OR
                   IDENT (-CPOS1) NOT IN -0.6875 .. -0.625 THEN
                  FAILED ("INCORRECT RESULTS FOR UNARY ADDING " &
                               "OPERATORS - 2");
               END IF;

               IF FIXED_ELEMENT (CNEG1 * IDENT (CPOS1)) NOT IN
                    -2.4375 .. -2.1875 OR
                  FIXED_ELEMENT (IDENT (CNEG2) / CPOS2) NOT IN
                    -0.125 .. -0.0625 THEN
                    FAILED ("INCORRECT RESULTS FOR MULTIPLYING " &
                            "OPERATORS - 2");
               END IF;

               IF ABS IDENT (CNEG2) NOT IN 0.3125 .. 0.375 OR
                  IDENT (ABS CPOS1) NOT IN 0.625 .. 0.6875 THEN
                    FAILED ("INCORRECT RESULTS FOR ABSOLUTE VALUE " &
                            "OPERATORS - 2");
               END IF;

               IF IDENT (CPOS1) NOT IN 0.625 .. 0.6875 OR
                      CNEG2 IN -0.25 .. 0.0 OR
                      IDENT (CNEG2) IN -1.0 .. -0.4375 THEN
                    FAILED ("INCORRECT RESULTS FOR MEMBERSHIP " &
                            "OPERATORS - 2");
               END IF;

               IF CHARRAY(1)'SIZE < IDENT_INT(BASIC_SIZE) THEN
                    FAILED ("INCORRECT VALUE FOR CHARRAY(1)'SIZE");
               END IF;

               IF IDENT (CHARRAY (0)) + CHARRAY (2) NOT IN
                     -2.875 .. -2.8125 OR
                  CHARRAY (3)  - IDENT (CHARRAY (2)) NOT IN
                     2.8125 .. 2.875 THEN
                    FAILED ("INCORRECT RESULTS FOR BINARY ADDING " &
                            "OPERATORS - 3");
               END IF;

               IF +IDENT (CHARRAY (1)) NOT IN -0.375 .. -0.3125 OR
                   IDENT (-CHARRAY (2)) NOT IN -0.6875 .. -0.625 THEN
                    FAILED ("INCORRECT RESULTS FOR UNARY ADDING " &
                            "OPERATORS - 3");
               END IF;

               IF FIXED_ELEMENT (CHARRAY (0) * IDENT (CHARRAY (2)))
                     NOT IN -2.4375 .. -2.1875 OR
                    FIXED_ELEMENT (IDENT (CHARRAY (1)) / CHARRAY (3))
                     NOT IN -0.125 .. -0.0625 THEN
                    FAILED ("INCORRECT RESULTS FOR MULTIPLYING " &
                            "OPERATORS - 3");
               END IF;

               IF ABS IDENT (CHARRAY (1)) NOT IN 0.3125 .. 0.375 OR
                  IDENT (ABS CHARRAY (2)) NOT IN 0.625 .. 0.6875 THEN
                    FAILED ("INCORRECT RESULTS FOR ABSOLUTE VALUE " &
                            "OPERATORS - 3");
               END IF;

               IF IDENT (CHARRAY (2)) NOT IN 0.625 .. 0.6875 OR
                      CHARRAY (1) IN -0.25 .. 0.0 OR
                      IDENT (CHARRAY (1)) IN -1.0 .. -0.4375 THEN
                    FAILED ("INCORRECT RESULTS FOR MEMBERSHIP " &
                            "OPERATORS - 3");
               END IF;

               IF CHREC.COMPP'SIZE < IDENT_INT(BASIC_SIZE) THEN
                    FAILED ("INCORRECT VALUE FOR CHREC.COMPP'SIZE");
               END IF;

               IF IDENT (CHREC.COMPF) + CHREC.COMPP NOT IN
                     -2.875 .. -2.8125 OR
                   CHREC.COMPL  - IDENT (CHREC.COMPP) NOT IN
                     2.8125 .. 2.875 THEN
                   FAILED ("INCORRECT RESULTS FOR BINARY ADDING " &
                           "OPERATORS - 4");
               END IF;

               IF +IDENT (CHREC.COMPN) NOT IN -0.375 .. -0.3125 OR
                   IDENT (-CHREC.COMPP) NOT IN -0.6875 .. -0.625 THEN
                    FAILED ("INCORRECT RESULTS FOR UNARY ADDING " &
                            "OPERATORS - 4");
               END IF;

               IF FIXED_ELEMENT (CHREC.COMPF * IDENT (CHREC.COMPP))
                    NOT IN -2.4375 .. -2.1875 OR
                  FIXED_ELEMENT (IDENT (CHREC.COMPN) / CHREC.COMPL)
                    NOT IN -0.125 .. -0.0625 THEN
                    FAILED ("INCORRECT RESULTS FOR MULTIPLYING " &
                            "OPERATORS - 4");
               END IF;

               IF ABS IDENT (CHREC.COMPN) NOT IN 0.3125 .. 0.375 OR
                    IDENT (ABS CHREC.COMPP) NOT IN 0.625 .. 0.6875 THEN
                    FAILED ("INCORRECT RESULTS FOR ABSOLUTE VALUE " &
                            "OPERATORS - 4");
               END IF;

               IF IDENT (CHREC.COMPP) NOT IN 0.625 .. 0.6875 OR
                      CHREC.COMPN IN -0.25 .. 0.0 OR
                      IDENT (CHREC.COMPN) IN -1.0 .. -0.4375 THEN
                    FAILED ("INCORRECT RESULTS FOR MEMBERSHIP " &
                            "OPERATORS - 4");
               END IF;

               RETURN TRUE;

          END FUNC;

          FUNCTION NEWFUNC IS NEW FUNC(CHECK_TYPE);

          BEGIN
               B := NEWFUNC;
          END;

     RESULT;
END CD2A51E;
