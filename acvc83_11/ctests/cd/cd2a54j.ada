-- CD2A54J.ADA

-- OBJECTIVE:
--     CHECK THAT WHEN SIZE AND SMALL SPECIFICATIONS FOR THE SMALLEST
--     SIZE APPROPRIATE FOR AN UNSIGNED REPRESENTATION ARE GIVEN FOR A
--     FIXED POINT TYPE, THEN OPERATIONS ON VALUES OF SUCH A TYPE
--     ARE NOT AFFECTED BY THE REPRESENTATION CLAUSE WHEN THE TYPE
--     IS PASSED AS A GENERIC ACTUAL PARAMETER.

-- HISTORY:
--     BCB 08/24/87  CREATED ORIGINAL TEST.
--     DHH 04/14/89  CHANGED EXTENSION FROM '.DEP' TO '.ADA' AND CHANGED
--                   OPERATORS ON 'SIZE TESTS.

WITH REPORT; USE REPORT;
PROCEDURE CD2A54J IS

     BASIC_SIZE : CONSTANT := 7;
     BASIC_SMALL : CONSTANT := 2.0 ** (-4);
     B : BOOLEAN;

     TYPE CHECK_TYPE IS DELTA 1.0 RANGE 0.0 .. 8.0;
     FOR CHECK_TYPE'SMALL USE BASIC_SMALL;
     FOR CHECK_TYPE'SIZE USE BASIC_SIZE;

BEGIN

     TEST ("CD2A54J", "CHECK THAT WHEN SIZE AND SMALL SPECIFICATIONS " &
                      "FOR THE SMALLEST SIZE APPROPRIATE FOR AN " &
                      "UNSIGNED REPRESENTATION ARE GIVEN FOR A " &
                      "FIXED POINT TYPE, THEN OPERATIONS ON VALUES " &
                      "OF SUCH A TYPE ARE NOT AFFECTED BY THE " &
                      "REPRESENTATION CLAUSE WHEN THE TYPE IS PASSED " &
                      "AS A GENERIC ACTUAL PARAMETER");

     DECLARE

          GENERIC

               TYPE FIXED_ELEMENT IS DELTA <>;

          FUNCTION FUNC RETURN BOOLEAN;

          FUNCTION FUNC RETURN BOOLEAN IS

               ZERO  : CONSTANT :=  0.0;

               TYPE BASIC_TYPE IS DELTA 2.0 ** (-4) RANGE 0.0 .. 8.0;

               CVAL1 : FIXED_ELEMENT := 0.5;
               CVAL2 : FIXED_ELEMENT := FIXED_ELEMENT (4.0/3.0);
               CPOS1 : FIXED_ELEMENT := FIXED_ELEMENT (4.0/6.0);
               CPOS2 : FIXED_ELEMENT := 7.5;
               CZERO : FIXED_ELEMENT;

               TYPE ARRAY_TYPE IS ARRAY (0 .. 3) OF FIXED_ELEMENT;
               CHARRAY : ARRAY_TYPE :=
                   (0.5, FIXED_ELEMENT (4.0/3.0), FIXED_ELEMENT
                    (4.0/6.0), 7.5);

               TYPE REC_TYPE IS RECORD
                    COMPF : FIXED_ELEMENT := 0.5;
                    COMPN : FIXED_ELEMENT := FIXED_ELEMENT (4.0/3.0);
                    COMPP : FIXED_ELEMENT := FIXED_ELEMENT (4.0/6.0);
                    COMPL : FIXED_ELEMENT := 7.5;
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
                         1.125 .. 1.1875 OR
                        CP2INOUT  - IDENT (CP1IN) NOT IN
                         6.8125 .. 6.875 THEN
                        FAILED ("INCORRECT RESULTS FOR " &
                                "BINARY ADDING OPERATORS - 1");
                    END IF;

                    IF +IDENT (CN2INOUT) NOT IN 1.3125 .. 1.375 OR
                         IDENT (+CP1IN) NOT IN 0.625 .. 0.6875 THEN
                        FAILED ("INCORRECT RESULTS FOR " &
                                "UNARY ADDING OPERATORS - 1");
                    END IF;

                    IF FIXED_ELEMENT (CN1IN * IDENT (CP1IN)) NOT IN
                         0.3125 .. 0.375 OR
                       FIXED_ELEMENT (IDENT (CN2INOUT) / CP2INOUT)
                         NOT IN 0.125 .. 0.1875 THEN
                         FAILED ("INCORRECT RESULTS FOR " &
                                 "MULTIPLYING OPERATORS - 1");
                    END IF;

                    IF ABS IDENT (CN2INOUT) NOT IN 1.3125 .. 1.375 OR
                         IDENT (ABS CP1IN) NOT IN 0.625 .. 0.6875 THEN
                         FAILED ("INCORRECT RESULTS FOR " &
                                 "ABSOLUTE VALUE OPERATORS - 1");
                    END IF;

                    IF IDENT (CP1IN) NOT IN 0.625 .. 0.6875 OR
                           CN2INOUT IN 1.0 .. 1.25 OR
                           IDENT (CN2INOUT) IN 1.4375 .. 2.0 THEN
                         FAILED ("INCORRECT RESULTS FOR MEMBERSHIP " &
                                 "OPERATORS - 1");
                    END IF;

                    CZOUT := 0.0;

               END PROC;

          BEGIN -- FUNC

               PROC (CVAL1, CPOS1, CVAL2, CPOS2, CZERO);

               IF IDENT (CZERO) /= ZERO THEN
                    FAILED ("INCORRECT VALUE FOR OUT PARAMETER");
               END IF;

               IF FIXED_ELEMENT'FIRST > IDENT (0.0625) THEN
                    FAILED ("INCORRECT VALUE FOR FIXED_ELEMENT'FIRST");
               END IF;

               IF FIXED_ELEMENT'LAST < IDENT (7.9375) THEN
                    FAILED ("INCORRECT VALUE FOR FIXED_ELEMENT'LAST");
               END IF;

               IF FIXED_ELEMENT'SIZE < IDENT_INT (BASIC_SIZE) THEN
                    FAILED ("INCORRECT VALUE FOR FIXED_ELEMENT'SIZE");
               END IF;

               IF FIXED_ELEMENT'MANTISSA /= BASIC_TYPE'MANTISSA THEN
                    FAILED ("INCORRECT VALUE FOR FIXED_ELEMENT'" &
                            "MANTISSA");
               END IF;

               IF FIXED_ELEMENT'SMALL /= BASIC_SMALL THEN
                    FAILED ("INCORRECT VALUE FOR FIXED_ELEMENT'SMALL");
               END IF;

               IF FIXED_ELEMENT'LARGE /= BASIC_TYPE'LARGE THEN
                    FAILED ("INCORRECT VALUE FOR FIXED_ELEMENT'LARGE");
               END IF;

               IF FIXED_ELEMENT'FORE /= BASIC_TYPE'FORE THEN
                    FAILED ("INCORRECT VALUE FOR FIXED_ELEMENT'FORE");
               END IF;

               IF FIXED_ELEMENT'AFT /= 1 THEN
                    FAILED ("INCORRECT VALUE FOR FIXED_ELEMENT'AFT");
               END IF;

               IF CVAL1'SIZE < IDENT_INT(BASIC_SIZE) THEN
                    FAILED ("INCORRECT VALUE FOR CVAL1'SIZE");
               END IF;

               IF IDENT (CVAL1) + CPOS1 NOT IN 1.125 .. 1.1875 OR
                     CPOS2  - IDENT (CPOS1) NOT IN 6.8125 .. 6.875 THEN
                    FAILED ("INCORRECT RESULTS FOR BINARY ADDING " &
                            "OPERATORS - 2");
               END IF;

               IF +IDENT (CVAL2) NOT IN 1.3125 .. 1.375 OR
                     IDENT (+CPOS1) NOT IN 0.625 .. 0.6875 THEN
                     FAILED ("INCORRECT RESULTS FOR UNARY ADDING " &
                             "OPERATORS - 2");
               END IF;

               IF FIXED_ELEMENT (CVAL1 * IDENT (CPOS1)) NOT IN
                    0.3125 .. 0.375 OR
                  FIXED_ELEMENT (IDENT (CVAL2) / CPOS2) NOT IN
                    0.125 .. 0.1875 THEN
                    FAILED ("INCORRECT RESULTS FOR MULTIPLYING " &
                            "OPERATORS - 2");
               END IF;

               IF ABS IDENT (CVAL2) NOT IN 1.3125 .. 1.375 OR
                      IDENT (ABS CPOS1) NOT IN 0.625 .. 0.6875 THEN
                    FAILED ("INCORRECT RESULTS FOR ABSOLUTE VALUE " &
                            "OPERATORS - 2");
               END IF;

               IF IDENT (CPOS1) NOT IN 0.625 .. 0.6875 OR
                      CVAL2 IN 1.0 .. 1.25 OR
                      IDENT (CVAL2) IN 1.4375 .. 2.0 THEN
                    FAILED ("INCORRECT RESULTS FOR MEMBERSHIP " &
                            "OPERATORS - 2");
               END IF;

               IF CHARRAY(1)'SIZE < IDENT_INT(BASIC_SIZE) THEN
                    FAILED ("INCORRECT VALUE FOR CHARRAY(1)'SIZE");
               END IF;

               IF IDENT (CHARRAY (0)) + CHARRAY (2) NOT IN
                      1.125 .. 1.1875 OR
                    CHARRAY (3)  - IDENT (CHARRAY (2)) NOT IN
                      6.8125 .. 6.875 THEN
                    FAILED ("INCORRECT RESULTS FOR BINARY ADDING " &
                            "OPERATORS - 3");
               END IF;

               IF +IDENT (CHARRAY (1)) NOT IN 1.3125 .. 1.375 OR
                    IDENT (+CHARRAY (2)) NOT IN 0.625 .. 0.6875 THEN
                    FAILED ("INCORRECT RESULTS FOR UNARY ADDING " &
                            "OPERATORS - 3");
               END IF;

               IF FIXED_ELEMENT (CHARRAY (0) * IDENT (CHARRAY (2)))
                    NOT IN 0.3125 .. 0.375 OR
                  FIXED_ELEMENT (IDENT (CHARRAY (1)) / CHARRAY (3))
                    NOT IN 0.125 .. 0.1875 THEN
                    FAILED ("INCORRECT RESULTS FOR MULTIPLYING " &
                            "OPERATORS - 3");
               END IF;

               IF ABS IDENT (CHARRAY (1)) NOT IN 1.3125 .. 1.375 OR
                    IDENT (ABS CHARRAY (2)) NOT IN 0.625 .. 0.6875 THEN
                    FAILED ("INCORRECT RESULTS FOR ABSOLUTE VALUE " &
                            "OPERATORS - 3");
               END IF;

               IF IDENT (CHARRAY (2)) NOT IN 0.625 .. 0.6875 OR
                      CHARRAY (1) IN 1.0 .. 1.25 OR
                      IDENT (CHARRAY (1)) IN 1.4375 .. 2.0 THEN
                    FAILED ("INCORRECT RESULTS FOR MEMBERSHIP " &
                            "OPERATORS - 3");
               END IF;

               IF CHREC.COMPP'SIZE < IDENT_INT(BASIC_SIZE) THEN
                    FAILED ("INCORRECT VALUE FOR CHREC.COMPP'SIZE");
               END IF;

               IF IDENT (CHREC.COMPF) + CHREC.COMPP NOT IN
                     1.125 .. 1.1875 OR
                    CHREC.COMPL  - IDENT (CHREC.COMPP) NOT IN
                     6.8125 .. 6.875 THEN
                    FAILED ("INCORRECT RESULTS FOR BINARY ADDING " &
                            "OPERATORS - 4");
               END IF;

               IF +IDENT (CHREC.COMPN) NOT IN 1.3125 .. 1.375 OR
                   IDENT (+CHREC.COMPP) NOT IN 0.625 .. 0.6875 THEN
                    FAILED ("INCORRECT RESULTS FOR UNARY ADDING " &
                            "OPERATORS - 4");
               END IF;

               IF FIXED_ELEMENT (CHREC.COMPF * IDENT (CHREC.COMPP))
                    NOT IN 0.3125 .. 0.375 OR
                  FIXED_ELEMENT (IDENT (CHREC.COMPN) / CHREC.COMPL)
                    NOT IN 0.125 .. 0.1875 THEN
                    FAILED ("INCORRECT RESULTS FOR MULTIPLYING " &
                            "OPERATORS - 4");
               END IF;

               IF ABS IDENT (CHREC.COMPN) NOT IN 1.3125 .. 1.375 OR
                  IDENT (ABS CHREC.COMPP) NOT IN 0.625 .. 0.6875 THEN
                    FAILED ("INCORRECT RESULTS FOR ABSOLUTE VALUE " &
                            "OPERATORS - 4");
               END IF;

               IF IDENT (CHREC.COMPP) NOT IN 0.625 .. 0.6875 OR
                      CHREC.COMPN IN 1.0 .. 1.25 OR
                      IDENT (CHREC.COMPN) IN 1.4375 .. 2.0 THEN
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
END CD2A54J;
