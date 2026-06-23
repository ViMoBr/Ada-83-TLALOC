-- C41308D.ADA

-- CHECK F.X, WHERE F IS THE NAME OF A FUNCTION RETURNING A RECORD WITH
-- COMPONENT X, AND X IS ALSO DECLARED WITHIN F, IN THE FOLLOWING 
-- CASES:
--      CASE 1 : F.X OCCURS WITHIN F AND ANOTHER SUBPROGRAM NAMED F IS
--               DECLARED IMMEDIATELY WITHIN F, THE INNER DECLARATION
--               OF F IS NOT A RENAMING DECLARATION, AND THE INNER F
--               DOES NOT HIDE THE OUTER F (F IS NOT INVOKED).
--      CASE 2 : F.X OCCURS WITHIN F AND ANOTHER SUBPROGRAM NAMED F IS
--               DECLARED IMMEDIATELY WITHIN F, THE INNER DECLARATION
--               OF F IS NOT A RENAMING DECLARATION, AND THE INNER F
--               HIDES THE OUTER F (THE INNER F IS INVOKED).
--      CASE 3 : F.X OCCURS WITHIN F AND ANOTHER SUBPROGRAM NAMED F IS
--               DECLARED IMMEDIATELY WITHIN F, THE INNER DECLARATION
--               OF F IS A RENAMING DECLARATION, AND THE INNER F
--               DOES NOT HIDE THE OUTER F (F IS NOT INVOKED).

-- RJW 7/08/86

WITH REPORT; USE REPORT;

PROCEDURE C41308D IS

     TYPE REC IS RECORD
          X : INTEGER;
     END RECORD;

BEGIN

     TEST ( "C41308D", "CHECK F.X, WHERE F IS THE NAME OF A " &
                       "FUNCTION RETURNING A RECORD WITH COMPONENT " &
                       "X, AND X IS ALSO DECLARED WITHIN F" );

-- CASE 1.

     DECLARE -- CASE 1.

          FIRST_CALL : BOOLEAN := TRUE;

          FUNCTION F RETURN REC IS

               X  : INTEGER := 3;
               F1 : REC;
               
               FUNCTION F RETURN INTEGER IS 
               BEGIN
                    RETURN IDENT_INT (10);
               END F;
     
          BEGIN
               IF FIRST_CALL THEN
                    FIRST_CALL := FALSE;
                    IF F.X /= 3 THEN
                         FAILED ( "EXPANDED NAME 'F.X' NOT " &
                                  "EVALUATED CORRECTLY IN CASE 1" );
                    END IF;
               END IF;
                                        
               F1.X := 20;
               RETURN F1;
          END F;

     BEGIN
          IF F.X /= 20 THEN 
               FAILED ( "FUNCTION F NOT CORRECTLY INVOKED IN " &
                        "CASE 1" );
          END IF;
     END; -- CASE 1.

-----------------------------------------------------------------------

-- CASE 2.

     DECLARE -- CASE 2.

          FIRST_CALL : BOOLEAN := TRUE;

          FUNCTION F RETURN REC IS

               X  : INTEGER := 3;
               F1 : REC;

               FUNCTION F RETURN REC IS 
                    X : INTEGER := 20;
                    F1 : REC;
               BEGIN
                    F1.X := 10;
                    RETURN F1;
               END F;
     
          BEGIN
               IF FIRST_CALL THEN
                    FIRST_CALL := FALSE;
                    IF F.X /= 10 THEN
                         FAILED ( "INNER FUNCTION F NOT INVOKED " &
                                  "CORRECTLY IN CASE 2" );
                    END IF;
               END IF;
                                        
               F1.X := 20;
               RETURN F1;
          END F;

     BEGIN
          IF F.X /= 20 THEN 
               FAILED ( "FUNCTION F NOT CORRECTLY INVOKED IN " &
                        "CASE 2" );
          END IF;
     END; -- CASE 2.

-----------------------------------------------------------------------

-- CASE 3.

     DECLARE -- CASE 3.

          FIRST_CALL : BOOLEAN := TRUE;

          FUNCTION F RETURN REC IS

               X  : INTEGER := 3;
               F1 : REC;
               
               FUNCTION G RETURN INTEGER;

               FUNCTION F RETURN INTEGER RENAMES G;

               FUNCTION G RETURN INTEGER IS 
                    X : INTEGER := 20;
               BEGIN
                    RETURN IDENT_INT (10);
               END G;

          BEGIN
               IF FIRST_CALL THEN
                    FIRST_CALL := FALSE;
                    IF F.X /= 3 THEN
                         FAILED ( "EXPANDED NAME 'F.X' NOT " &
                                  "EVALUATED CORRECTLY IN CASE 3" );
                    END IF;
               END IF;
                                        
               F1.X := 20;
               RETURN F1;
          END F;

     BEGIN
          IF F.X /= 20 THEN 
               FAILED ( "FUNCTION F NOT CORRECTLY INVOKED IN " &
                        "CASE 3" );
          END IF;
     END; -- CASE 3.

-----------------------------------------------------------------------

     RESULT;

END C41308D;
