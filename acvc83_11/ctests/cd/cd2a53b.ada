-- CD2A53B.ADA

-- OBJECTIVE:
--     CHECK THAT WHEN SIZE AND SMALL SPECIFICATIONS ARE GIVEN FOR A
--     FIXED POINT TYPE IN A GENERIC UNIT, THEN OPERATIONS ON VALUES OF
--     SUCH A TYPE ARE NOT AFFECTED BY THE REPRESENTATION CLAUSE.

-- HISTORY:
--     BCB 08/24/87  CREATED ORIGINAL TEST.
--     DHH 04/12/89  CHANGED EXTENSION FROM '.DEP' TO '.ADA', CHANGED
--                   OPERATORS ON 'SIZE TESTS.

WITH REPORT; USE REPORT;
PROCEDURE CD2A53B IS

     BASIC_SIZE : CONSTANT := INTEGER'SIZE / 2;
     BASIC_SMALL : CONSTANT := 2.0 ** (-4);
     B : BOOLEAN;

BEGIN
     TEST ("CD2A53B", "CHECK THAT WHEN SIZE AND SMALL SPECIFICATIONS " &
                      "ARE GIVEN FOR A FIXED POINT TYPE IN A " &
                      "GENERIC UNIT, THEN OPERATIONS ON VALUES OF " &
                      "SUCH A TYPE ARE NOT AFFECTED BY THE " &
                      "REPRESENTATION CLAUSE");

     DECLARE -- SIZE AND SMALL SPECIFICATIONS GIVEN WITHIN
             -- GENERIC FUNCTION.

          GENERIC
          FUNCTION FUNC RETURN BOOLEAN;

          FUNCTION FUNC RETURN BOOLEAN IS

               TYPE CHECK_TYPE IS DELTA 1.0 RANGE -4.0 .. 4.0;
               FOR CHECK_TYPE'SMALL USE BASIC_SMALL;
               FOR CHECK_TYPE'SIZE USE BASIC_SIZE;

               ZERO  : CONSTANT :=  0.0;

               TYPE BASIC_TYPE IS DELTA 2.0 ** (-4) RANGE -4.0 .. 4.0;

               CNEG1 : CHECK_TYPE := -3.5;
               CNEG2 : CHECK_TYPE := CHECK_TYPE (-1.0/3.0);
               CPOS1 : CHECK_TYPE := CHECK_TYPE (4.0/6.0);
               CPOS2 : CHECK_TYPE :=  3.5;
               CZERO : CHECK_TYPE;

               TYPE ARRAY_TYPE IS ARRAY (0 .. 3) OF CHECK_TYPE;
               CHARRAY : ARRAY_TYPE :=
               (-3.5, CHECK_TYPE (-1.0/3.0), CHECK_TYPE (4.0/6.0), 3.5);

               TYPE REC_TYPE IS RECORD
                    COMPF : CHECK_TYPE := -3.5;
                    COMPN : CHECK_TYPE := CHECK_TYPE (-1.0/3.0);
                    COMPP : CHECK_TYPE := CHECK_TYPE (4.0/6.0);
                    COMPL : CHECK_TYPE :=  3.5;
               END RECORD;

               CHREC : REC_TYPE;

               FUNCTION IDENT (FX : CHECK_TYPE) RETURN CHECK_TYPE IS
               BEGIN
                    IF EQUAL (3, 3) THEN
                         RETURN FX;
                    ELSE
                         RETURN 0.0;
                    END IF;
               END IDENT;

               PROCEDURE PROC (CN1IN, CP1IN      :        CHECK_TYPE;
                               CN2INOUT,CP2INOUT : IN OUT CHECK_TYPE;
                               CZOUT             :    OUT CHECK_TYPE) IS
               BEGIN

                    IF IDENT (CN1IN) + CP1IN NOT IN
                         -2.875 .. -2.8125 OR
                       CP2INOUT  - IDENT (CP1IN) NOT IN
                         2.8125 .. 2.875 THEN
                         FAILED ("INCORRECT RESULTS FOR " &
                                 "BINARY ADDING OPERATORS - 1");
                    END IF;

                    IF +IDENT (CN2INOUT) NOT IN -0.375 .. -0.3125 OR
                        IDENT (-CP1IN) NOT IN -0.6875 .. -0.625 THEN
                         FAILED ("INCORRECT RESULTS FOR " &
                                 "UNARY ADDING OPERATORS - 1");
                    END IF;

                    IF CHECK_TYPE (CN1IN * IDENT (CP1IN)) NOT IN
                         -2.4375 .. -2.1875 OR
                       CHECK_TYPE (IDENT (CN2INOUT) / CP2INOUT) NOT IN
                         -0.125 .. -0.0625 THEN
                         FAILED ("INCORRECT RESULTS FOR " &
                                 "MULTIPLYING OPERATORS - 1");
                    END IF;

                    IF ABS IDENT (CN2INOUT) NOT IN 0.3125 .. 0.375 OR
                       IDENT (ABS CP1IN) NOT IN 0.625 .. 0.6875 THEN
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

     BEGIN -- FUNC.

          PROC (CNEG1, CPOS1, CNEG2, CPOS2, CZERO);

          IF CNEG1'SIZE < IDENT_INT(BASIC_SIZE) THEN
               FAILED ("INCORRECT VALUE FOR CNEG1'SIZE");
          END IF;

          IF IDENT (CZERO) /= ZERO THEN
               FAILED ("INCORRECT VALUE FOR OUT PARAMETER");
          END IF;

          IF CHECK_TYPE'FIRST > IDENT (-3.9375) THEN
               FAILED ("INCORRECT VALUE FOR CHECK_TYPE'FIRST");
          END IF;

          IF CHECK_TYPE'LAST < IDENT (3.9375) THEN
               FAILED ("INCORRECT VALUE FOR CHECK_TYPE'LAST");
          END IF;

          IF CHECK_TYPE'SIZE /= IDENT_INT (BASIC_SIZE) THEN
               FAILED ("INCORRECT VALUE FOR CHECK_TYPE'SIZE");
          END IF;

          IF CHECK_TYPE'MANTISSA /= BASIC_TYPE'MANTISSA THEN
               FAILED ("INCORRECT VALUE FOR CHECK_TYPE'MANTISSA");
          END IF;

          IF CHECK_TYPE'SMALL /= BASIC_SMALL THEN
               FAILED ("INCORRECT VALUE FOR CHECK_TYPE'SMALL");
          END IF;

          IF CHECK_TYPE'LARGE /= BASIC_TYPE'LARGE THEN
               FAILED ("INCORRECT VALUE FOR CHECK_TYPE'LARGE");
          END IF;

          IF CHECK_TYPE'AFT /= 1 THEN
               FAILED ("INCORRECT VALUE FOR CHECK_TYPE'AFT");
          END IF;

          IF CHECK_TYPE'FORE /= BASIC_TYPE'FORE THEN
               FAILED ("INCORRECT VALUE FOR CHECK_TYPE'FORE");
          END IF;

          IF IDENT (CNEG1) + CPOS1 NOT IN -2.875 .. -2.8125 OR
             CPOS2  - IDENT (CPOS1) NOT IN 2.8125 .. 2.875 THEN
               FAILED ("INCORRECT RESULTS FOR BINARY ADDING " &
                       "OPERATORS - 2");
          END IF;

          IF +IDENT (CNEG2) NOT IN -0.375 .. -0.3125 OR
             IDENT (-CPOS1) NOT IN -0.6875 .. -0.625 THEN
               FAILED ("INCORRECT RESULTS FOR UNARY ADDING " &
                       "OPERATORS - 2");
          END IF;

          IF CHECK_TYPE (CNEG1 * IDENT (CPOS1)) NOT IN
               -2.4375 .. -2.1875 OR
             CHECK_TYPE (IDENT (CNEG2) / CPOS2) NOT IN
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

          IF CHARRAY(1)'SIZE < IDENT_INT (BASIC_SIZE) THEN
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

          IF CHECK_TYPE (CHARRAY (0) * IDENT (CHARRAY (2))) NOT IN
               -2.4375 .. -2.1875 OR
             CHECK_TYPE (IDENT (CHARRAY (1)) / CHARRAY (3)) NOT IN
               -0.125 .. -0.0625 THEN
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

          IF CHREC.COMPP'SIZE < IDENT_INT (BASIC_SIZE) THEN
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

          IF CHECK_TYPE (CHREC.COMPF * IDENT (CHREC.COMPP)) NOT IN
               -2.4375 .. -2.1875 OR
                  CHECK_TYPE (IDENT (CHREC.COMPN) / CHREC.COMPL) NOT IN
               -0.125 .. -0.0625 THEN
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

     FUNCTION NEWFUNC IS NEW FUNC;

     BEGIN
          B := NEWFUNC;
     END;

     RESULT;
END CD2A53B;
