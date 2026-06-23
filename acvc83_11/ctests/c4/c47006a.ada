-- C47006A.ADA

-- WHEN THE TYPE MARK IN A QUALIFIED EXPRESSION DENOTES A FIXED POINT 
-- TYPE, CHECK THAT CONSTRAINT_ERROR IS RAISED WHEN THE VALUE OF THE 
-- OPERAND DOES NOT LIE WITHIN THE RANGE OF THE TYPE MARK.

-- RJW 7/23/86

WITH REPORT; USE REPORT; 
PROCEDURE C47006A IS

     TYPE FIXED IS DELTA 0.5 RANGE -5.0 .. 5.0;

BEGIN

     TEST( "C47006A", "WHEN THE TYPE MARK IN A QUALIFIED " &
                      "EXPRESSION DENOTES A FIXED POINT TYPE, " &
                      "CHECK THAT CONSTRAINT_ERROR IS RAISED " &
                      "WHEN THE VALUE OF THE OPERAND DOES NOT LIE " &
                      "WITHIN THE RANGE OF THE TYPE MARK" );

     DECLARE  

          SUBTYPE SFIXED IS FIXED RANGE -2.0 .. 2.0;

          FUNCTION IDENT (X : FIXED) RETURN FIXED IS
          BEGIN
               IF EQUAL (3, 3) THEN
                    RETURN X;
               ELSE
                    RETURN 0.0;
               END IF;
          END IDENT;

     BEGIN
          IF SFIXED'(IDENT (-5.0)) = -2.0 THEN
               FAILED ( "NO EXCEPTION RAISED FOR VALUE OUTSIDE OF " &
                        "SUBTYPE SFIXED - 1");
          ELSE
               FAILED ( "NO EXCEPTION RAISED FOR VALUE OUTSIDE OF " &
                        "SUBTYPE SFIXED - 2");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR => 
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR VALUE OUTSIDE " &
                        "OF SUBTYPE SFIXED" );
     END;

     DECLARE  

          TYPE NFIX IS NEW FIXED;
          SUBTYPE SNFIX IS NFIX RANGE -2.0 .. 2.0;

          FUNCTION IDENT (X : NFIX) RETURN NFIX IS
          BEGIN
               RETURN NFIX (IDENT_INT (INTEGER (X)));
          END IDENT;

     BEGIN
          IF SNFIX'(IDENT (-5.0)) = -2.0 THEN
               FAILED ( "NO EXCEPTION RAISED FOR VALUE OUTSIDE OF " &
                        "SUBTYPE SNFIX - 1");
          ELSE
               FAILED ( "NO EXCEPTION RAISED FOR VALUE OUTSIDE OF " &
                        "SUBTYPE SNFIX - 2");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR => 
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR VALUE OUTSIDE " &
                        "OF SUBTYPE SNFIX" );
     END;

     RESULT;
END C47006A;
