-- CD1009N.ADA

-- OBJECTIVE:
--     CHECK THAT A RECORD REPRESENTATION CLAUSE MAY BE GIVEN
--     IN THE VISIBLE OR PRIVATE PART OF A PACKAGE FOR A RECORD TYPE
--     DECLARED IN THE VISIBLE PART OF THE SAME PACKAGE.

-- HISTORY:
--     VCL 10/08/87  CREATED ORIGINAL TEST.
--     BCB 03/20/89  CHANGED EXTENSION FROM '.ADA' TO '.DEP', CORRECTED
--                    CHECKS FOR FAILURE.

WITH SYSTEM;
WITH REPORT; USE REPORT;
PROCEDURE CD1009N IS
BEGIN
     TEST ("CD1009N", "A RECORD REPRESENTATION CLAUSE MAY BE GIVEN " &
                      "IN THE VISIBLE OR PRIVATE PART OF A PACKAGE " &
                      "FOR A RECORD TYPE DECLARED IN THE " &
                      "VISIBLE PART OF THE SAME PACKAGE");
     DECLARE
          PACKAGE PACK IS
               UNITS_PER_INTEGER : CONSTANT :=
                    (INTEGER'SIZE + SYSTEM.STORAGE_UNIT - 1) /
                    SYSTEM.STORAGE_UNIT;

               TYPE CHECK_TYPE_1 IS
                    RECORD
                         I1 : INTEGER RANGE 0 .. 255;
                         B1 : BOOLEAN;
                         B2 : BOOLEAN;
                         I2 : INTEGER RANGE 0 .. 15;
                    END RECORD;
               FOR CHECK_TYPE_1 USE
                    RECORD
                         I1 AT 0 * UNITS_PER_INTEGER
                              RANGE 0 .. INTEGER'SIZE - 1;
                         B1 AT 1 * UNITS_PER_INTEGER
                              RANGE 0 .. BOOLEAN'SIZE - 1;
                         B2 AT 2 * UNITS_PER_INTEGER
                              RANGE 0 .. BOOLEAN'SIZE - 1;
                         I2 AT 3 * UNITS_PER_INTEGER
                              RANGE 0 .. INTEGER'SIZE - 1;
                    END RECORD;

               TYPE CHECK_TYPE_2 IS
                    RECORD
                         I1 : INTEGER RANGE 0 .. 255;
                         B1 : BOOLEAN;
                         B2 : BOOLEAN;
                         I2 : INTEGER RANGE 0 .. 15;
                    END RECORD;

          PRIVATE
               FOR CHECK_TYPE_2 USE
                         RECORD
                         I1 AT 0 * UNITS_PER_INTEGER
                              RANGE 0 .. INTEGER'SIZE - 1;
                         B1 AT 1 * UNITS_PER_INTEGER
                              RANGE 0 .. BOOLEAN'SIZE - 1;
                         B2 AT 2 * UNITS_PER_INTEGER
                              RANGE 0 .. BOOLEAN'SIZE - 1;
                         I2 AT 3 * UNITS_PER_INTEGER
                              RANGE 0 .. INTEGER'SIZE - 1;
                         END RECORD;
          END PACK;

          USE PACK;

          R1 : CHECK_TYPE_1;

          R2 : CHECK_TYPE_2;
     BEGIN
          IF R1.I1'FIRST_BIT /= 0 OR
                    R1.I1'LAST_BIT /= INTEGER'SIZE - 1 OR
                    R1.I1'POSITION /= 0 THEN
               FAILED ("INCORRECT REPRESENTATION FOR R1.I1");
          END IF;

          IF R1.B1'FIRST_BIT /= 0 OR
                    R1.B1'LAST_BIT /= BOOLEAN'SIZE - 1 OR
                    R1.B1'POSITION /= 1 * UNITS_PER_INTEGER THEN
               FAILED ("INCORRECT REPRESENTATION FOR R1.B1");
          END IF;

          IF R1.B2'FIRST_BIT /= 0 OR
                    R1.B2'LAST_BIT /= BOOLEAN'SIZE - 1 OR
                    R1.B2'POSITION /= 2 * UNITS_PER_INTEGER THEN
               FAILED ("INCORRECT REPRESENTATION FOR R1.B2");
          END IF;

          IF R1.I2'FIRST_BIT /= 0 OR
                    R1.I2'LAST_BIT /= INTEGER'SIZE - 1 OR
                    R1.I2'POSITION /= 3 * UNITS_PER_INTEGER THEN
               FAILED ("INCORRECT REPRESENTATION FOR R1.I2");
          END IF;


          IF R2.I1'FIRST_BIT /= 0 OR
                    R2.I1'LAST_BIT /= INTEGER'SIZE - 1 OR
                    R2.I1'POSITION /= 0 THEN
               FAILED ("INCORRECT REPRESENTATION FOR R2.I1");
          END IF;

          IF R2.B1'FIRST_BIT /= 0 OR
                    R2.B1'LAST_BIT /= BOOLEAN'SIZE - 1 OR
                    R2.B1'POSITION /= 1 * UNITS_PER_INTEGER THEN
               FAILED ("INCORRECT REPRESENTATION FOR R2.B1");
          END IF;

          IF R2.B2'FIRST_BIT /= 0 OR
                    R2.B2'LAST_BIT /= BOOLEAN'SIZE - 1 OR
                    R2.B2'POSITION /= 2 * UNITS_PER_INTEGER THEN
               FAILED ("INCORRECT REPRESENTATION FOR R2.B2");
          END IF;

          IF R2.I2'FIRST_BIT /= 0 OR
                    R2.I2'LAST_BIT /= INTEGER'SIZE - 1 OR
                    R2.I2'POSITION /= 3 * UNITS_PER_INTEGER THEN
               FAILED ("INCORRECT REPRESENTATION FOR R2.I2");
          END IF;
     END;

     RESULT;
END CD1009N;
