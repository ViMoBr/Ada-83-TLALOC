-- C4A013B.ADA

-- CHECK THAT IF MACHINE_OVERFLOWS IS TRUE, NUMERIC_ERROR OR
-- CONSTRAINT_ERROR IS RAISED FOR A NONSTATIC UNIVERSAL_REAL EXPRESSION
-- IF A STATIC OPERAND HAS A VALUE OUTSIDE THE RANGE OF THE MOST
-- ACCURATE FLOATING POINT BASE TYPE, EVEN IF THE RESULT LIES WITHIN THE
-- RANGE OF THE BASE TYPE.

-- JRK 1/13/86

WITH SYSTEM, REPORT;
USE SYSTEM, REPORT;

PROCEDURE C4A013B IS

     TYPE F IS DIGITS MAX_DIGITS;

     B : BOOLEAN;

BEGIN

     TEST ("C4A013B", "CHECK NONSTATIC UNIVERSAL_REAL EXPRESSIONS " &
                      "WITH STATIC OPERANDS THAT OVERFLOW, BUT WITH " &
                      "RESULTS WITHIN THE BASE TYPE RANGE");

     COMMENT ("SYSTEM.MAX_DIGITS = " & INTEGER'IMAGE (MAX_DIGITS));
     COMMENT ("F'DIGITS = " & INTEGER'IMAGE (F'DIGITS));
     COMMENT ("F'MACHINE_RADIX = " & INTEGER'IMAGE (F'MACHINE_RADIX));
     COMMENT ("F'MACHINE_EMAX = " & INTEGER'IMAGE (F'MACHINE_EMAX));
     COMMENT ("F'MACHINE_OVERFLOWS = " &
              BOOLEAN'IMAGE (F'MACHINE_OVERFLOWS));

     DECLARE

          N : CONSTANT := 2.0 * F'MACHINE_RADIX ** F'MACHINE_EMAX;
                         -- THIS DECLARATION MAY BE REJECTED AT COMPILE-
                         -- TIME (BECAUSE THE VALUE IS TOO LARGE AND
                         -- RAISES NUMERIC_ERROR/CONSTRAINT_ERROR), BUT
                         -- MUST NOT RAISE AN EXCEPTION AT RUN-TIME
                         -- (BECAUSE THE EXPRESSION MUST BE STATIC).

     BEGIN

          IF N <= F'BASE'LAST THEN      -- CAN RAISE EXCEPTION.

               IF F'MACHINE_OVERFLOWS THEN
                    FAILED ("2.0 * F'MACHINE_RADIX ** F'MACHINE_EMAX " &
                            "<= F'BASE'LAST");
               ELSE NOT_APPLICABLE ("STATIC CONSTANT STILL IN BASE " &
                                    "TYPE RANGE");
               END IF;

          ELSE BEGIN
                    B := 0.0 = N * (1.0 * INTEGER'POS (IDENT_INT (0)));

                    IF F'MACHINE_OVERFLOWS THEN
                         FAILED ("MACHINE_OVERFLOWS IS TRUE, BUT NO " &
                                 "EXCEPTION WAS RAISED");
                    ELSE COMMENT ("MACHINE_OVERFLOWS IS FALSE AND NO " &
                                  "EXCEPTION WAS RAISED");
                    END IF;

                    IF NOT B THEN  -- USE B TO PREVENT DEAD VARIABLE
                                   -- OPTIMIZATION.
                         COMMENT ("0.0 = N * 0.0 YIELDS FALSE");
                    END IF;
               EXCEPTION
                    WHEN NUMERIC_ERROR =>
                         COMMENT ("NUMERIC_ERROR RAISED FOR N * 0.0");
                    WHEN CONSTRAINT_ERROR =>
                         COMMENT ("CONSTRAINT_ERROR RAISED FOR N * " &
                                  "0.0");
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED FOR N * 0.0");
               END;
          END IF;

     EXCEPTION
          WHEN NUMERIC_ERROR =>
               COMMENT ("NUMERIC_ERROR RAISED FOR N <= F'BASE'LAST");
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED FOR N <= F'BASE'LAST");
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED FOR N <= F'BASE'LAST");
     END;

     RESULT;

EXCEPTION
     WHEN OTHERS =>
          FAILED ("EXCEPTION RAISED BY NUMBER DECLARATION");
          RESULT;
END C4A013B;
