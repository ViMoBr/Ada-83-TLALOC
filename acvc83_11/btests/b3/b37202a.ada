-- B37202A.ADA

-- CHECK THAT DISCRIMINANT_CONSTRAINTS ARE NOT PERMITTED WHERE THEY ARE
-- FORBIDDEN, I.E. CHECK THAT A DISCRIMINANT CONSTRAINT:

-- CANNOT BE GIVEN IN A SUBTYPE INDICATION FOR A TYPE MARK THAT HAS
-- ALREADY BEEN CONSTRAINED.

-- CANNOT BE SPECIFIED FOR A RECORD OR PRIVATE TYPE DECLARED WITHOUT
-- ANY DISCRIMINANTS, OR FOR AN ARRAY OR SCALAR, OR FOR AN ACCESS
-- TYPE THAT DESIGNATES ANY OF THESE TYPES.

-- ASL 6/18/81
-- JWC 6/28/85   RENAMED TO -AB

PROCEDURE B37202A IS

     PACKAGE PACK1 IS
          TYPE PRIV1(DISC1 : INTEGER) IS PRIVATE;
          TYPE PRIV2 IS PRIVATE;
          TYPE LIM1(DISC2 : INTEGER) IS LIMITED PRIVATE;
          TYPE LIM2 IS LIMITED PRIVATE;
     PRIVATE
          TYPE PRIV1(DISC1 : INTEGER) IS
               RECORD
                    NULL;
               END RECORD;
          TYPE PRIV2 IS
               RECORD
                    NULL;
               END RECORD;
          TYPE LIM1(DISC2 : INTEGER) IS
               RECORD
                    NULL;
               END RECORD;
          TYPE LIM2 IS
               RECORD
                    NULL;
               END RECORD;
     END PACK1;

     USE PACK1;

     TYPE R1(DISC3 : INTEGER) IS
          RECORD
               NULL;
          END RECORD;

     TYPE R2 IS
          RECORD
               NULL;
          END RECORD;

     SUBTYPE R3 IS R1(5);
     SUBTYPE R4 IS R3(5);                     -- ERROR: ALREADY
                                              --   CONSTRAINED.

     SUBTYPE PRIV3 IS PRIV1(5);
     SUBTYPE PRIV4 IS PRIV3(5);               -- ERROR: ALREADY
                                              --   CONSTRAINED.

     SUBTYPE LIM3 IS LIM1(5);
     SUBTYPE LIM4 IS LIM3(5);                 -- ERROR: ALREADY
                                              --   CONSTRAINED.

     TYPE ACC1 IS ACCESS R1(5);
     SUBTYPE ACC2 IS ACC1(5);                 -- ERROR: ALREADY
                                              --   CONSTRAINED.

     SUBTYPE R5 IS R2(5);                     -- ERROR: CONSTRAINT.
     SUBTYPE R6 IS R2(DISC3 => 5);            -- ERROR: CONSTRAINT.
     SUBTYPE PRI5 IS PRIV2(5);                -- ERROR: CONSTRAINT.
     SUBTYPE PRIV6 IS PRIV2(DISC1 => 5);      -- ERROR: CONSTRAINT.
     SUBTYPE LIM5 IS LIM2(5);                 -- ERROR: CONSTRAINT.
     SUBTYPE LIM6 IS LIM2(DISC2 => 5);        -- ERROR: CONSTRAINT.

     I : INTEGER(DISC2 => 5);                 -- ERROR: CONSTRAINT.
     J : INTEGER(5);                          -- ERROR: CONSTRAINT.
     TYPE ARR1 IS ARRAY(INTEGER RANGE <>) OF INTEGER;
     SUBTYPE ARR2 IS ARR1(DISC2 => 5);        -- ERROR: CONSTRAINT.
     SUBTYPE ARR3 IS ARR1(5);                 -- ERROR: CONSTRAINT.

     TYPE ACC3 IS ACCESS R2(5);               -- ERROR: CONSTRAINT.
     TYPE ACC4 IS ACCESS PRIV2(5);            -- ERROR: CONSTRAINT.
     TYPE ACC5 IS ACCESS LIM2(5);             -- ERROR: CONSTRAINT.

     TYPE ACC6 IS ACCESS INTEGER(5);          -- ERROR: CONSTRAINT.

     TYPE ACC7 IS ACCESS ARR1(5);             -- ERROR: CONSTRAINT.

BEGIN
     NULL;
END B37202A;
