-- C45231D.TST

-- CHECK THAT THE RELATIONAL AND MEMBERSHIP OPERATIONS YIELD CORRECT 
-- RESULTS FOR PREDEFINED TYPE $NAME (INCLUDING THE CASE IN 
-- WHICH THE RELATIONAL OPERATORS ARE REDEFINED).

-- SUBTESTS ARE:
--     (A). TESTS FOR RELATIONAL OPERATORS.
--     (B). TESTS FOR MEMBERSHIP OPERATORS.
--     (C). TESTS FOR MEMBERSHIP OPERATORS IN THE CASE IN WHICH THE 
--          RELATIONAL OPERATORS ARE REDEFINED.

-- NAME IS A PREDEFINED INTEGER TYPE OTHER THAN INTEGER, SHORT_INTEGER,
-- AND LONG_INTEGER.

-- RJW 2/4/86

WITH REPORT; USE REPORT;

PROCEDURE C45231D IS
     
     FUNCTION IDENT (X : $NAME) RETURN $NAME IS
     BEGIN
          RETURN $NAME (IDENT_INT (INTEGER (X)));
     END IDENT;
     
BEGIN

     TEST ( "C45231D", "CHECK THAT THE RELATIONAL AND " &
                       "MEMBERSHIP OPERATIONS YIELD CORRECT " &
                       "RESULTS FOR PREDEFINED TYPE $NAME " &
                       "(INCLUDING THE CASE IN WHICH THE " &
                       "RELATIONAL OPERATORS ARE REDEFINED)" );

     DECLARE -- (A)
     
          I1A, I1B   : $NAME          := IDENT (1);
          I2         : $NAME          := IDENT (2);
          CI2        : CONSTANT $NAME := 2;


     BEGIN -- (A)

          IF (I2 = CI2) AND (NOT (I2 /= CI2)) THEN
               NULL;
          ELSE
               FAILED ( "RELATIONAL TEST - 1" );
          END IF;

          IF (I2 /= 4) AND (NOT (I2 = 4)) THEN
               NULL;
          ELSE
               FAILED ( "RELATIONAL TEST - 2" );
          END IF;

          IF (I1A = I1B) AND (NOT (I1A /= I1B)) THEN
               NULL;
          ELSE
               FAILED ( "RELATIONAL TEST - 3" );
          END IF;

          IF (I2 >= CI2) AND (NOT (I2 < CI2)) THEN
               NULL;
          ELSE
               FAILED ( "RELATIONAL TEST - 4");
          END IF;

          IF (I2 <= 4) AND (NOT (I2 > 4)) THEN
               NULL;
          ELSE
               FAILED ( "RELATIONAL TEST - 5" );
          END IF;

          IF (I1A >= I1B) AND (I1A <= I1B) THEN
               NULL;
          ELSE
               FAILED ( "RELATIONAL TEST - 6" );
          END IF;

          IF ">" (LEFT => CI2, RIGHT => I1A) THEN
               NULL;
          ELSE
               FAILED ( "RELATIONAL TEST - 7" );
          END IF;

          IF "<" (LEFT => I1A, RIGHT => I2) THEN
               NULL;
          ELSE
               FAILED ( "RELATIONAL TEST - 8" );
          END IF;

          IF ">=" (LEFT => I1A, RIGHT => I1A ) THEN
               NULL;
          ELSE
               FAILED ( "RELATIONAL TEST - 9 ");
          END IF;

          IF "<=" (LEFT => I1A, RIGHT => CI2) THEN
               NULL;
          ELSE
               FAILED ( "RELATIONAL TEST - 10 ");
          END IF;

          IF "=" (LEFT => I1A, RIGHT => I1B ) THEN
               NULL;
          ELSE
               FAILED ( "RELATIONAL TEST - 11 ");
          END IF;

          IF "/=" (LEFT => CI2, RIGHT => 4) THEN
               NULL;
          ELSE
               FAILED ( "RELATIONAL TEST - 12 ");
          END IF;
         
     END; -- (A) 

     ----------------------------------------------------------------

     DECLARE -- (B)
          
          SUBTYPE ST IS $NAME RANGE -10 .. 10;

          I1 : $NAME := IDENT (1);
          I5 : $NAME := IDENT (5);

          CI2  : CONSTANT $NAME := 2;
          CI10 : CONSTANT $NAME := 10;
          
          
     BEGIN -- (B)
     
          IF (I1 IN ST) AND (I1 NOT IN CI2 .. CI10) THEN
               NULL;
          ELSE
               FAILED ( "MEMBERSHIP TEST - B.1" );
          END IF;

          IF (IDENT (11) NOT IN ST) AND (CI2 IN I1 .. I5) THEN
               NULL;
          ELSE
               FAILED ( "MEMBERSHIP TEST - B.2" );
          END IF;

          IF NOT (I5 NOT IN CI2 .. 10) AND NOT (IDENT (-11) IN ST) THEN
               NULL;
          ELSE
               FAILED ( "MEMBERSHIP TEST - B.3" );
          END IF;
     
          IF NOT (I1 IN CI2 .. CI10) AND NOT (I5 NOT IN ST) THEN
               NULL;
          ELSE
               FAILED ( "MEMBERSHIP TEST - B.4" );
          END IF;

          IF (I1 NOT IN I5 .. I1) AND NOT (I5 IN I5 .. I1) THEN 
               NULL;
          ELSE
               FAILED ( "MEMBERSHIP TEST - B.5" );
          END IF;

     END; -- (B)

     -------------------------------------------------------------

     DECLARE -- (C)

          SUBTYPE ST IS $NAME RANGE -10 .. 10;

          I1 : $NAME := IDENT (1);
          I5 : $NAME := IDENT (5);

          CI2  : CONSTANT $NAME := 2;
          CI10 : CONSTANT $NAME := 10;
          
                    
          FUNCTION ">" ( L, R : $NAME ) RETURN BOOLEAN IS
          BEGIN
               RETURN $NAME'POS (L) <= $NAME'POS (R);
          END;
                    
          FUNCTION ">=" ( L, R : $NAME ) RETURN BOOLEAN IS
          BEGIN
               RETURN $NAME'POS (L) < $NAME'POS (R);
          END;

          FUNCTION "<" ( L, R : $NAME ) RETURN BOOLEAN IS
          BEGIN
               RETURN  $NAME'POS (L) >= $NAME'POS (R);
          END;
                    
          FUNCTION "<=" ( L, R : $NAME ) RETURN BOOLEAN IS
          BEGIN
               RETURN $NAME'POS (L) > $NAME'POS (R);
          END;
                    
     BEGIN -- (C)

          IF (I1 IN ST) AND (I1 NOT IN CI2 .. CI10) THEN
               NULL;
          ELSE
               FAILED ( "MEMBERSHIP TEST - C.1" );
          END IF;

          IF (IDENT (11) NOT IN ST) AND (CI2 IN I1 .. I5) THEN
               NULL;
          ELSE
               FAILED ( "MEMBERSHIP TEST - C.2" );
          END IF;

          IF NOT (I5 NOT IN CI2 .. 10) AND NOT (IDENT (-11) IN ST) THEN
               NULL;
          ELSE
               FAILED ( "MEMBERSHIP TEST - C.3" );
          END IF;
     
          IF NOT (I1 IN CI2 .. CI10) AND NOT (I5 NOT IN ST) THEN
               NULL;
          ELSE
               FAILED ( "MEMBERSHIP TEST - C.4" );
          END IF;

          IF (I1 NOT IN I5 .. I1) AND NOT (I5 IN I5 .. I1) THEN 
               NULL;
          ELSE
               FAILED ( "MEMBERSHIP TEST - C.5" );
          END IF;

     END; -- (C)

     RESULT;

END C45231D;
