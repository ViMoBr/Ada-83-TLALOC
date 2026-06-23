-- C47003A.ADA

-- WHEN THE TYPE MARK IN A QUALIFIED EXPRESSION DENOTES AN 
-- ENUMERATION TYPE, CHECK THAT CONSTRAINT_ERROR IS RAISED WHEN THE 
-- VALUE OF THE OPERAND DOES NOT LIE WITHIN THE RANGE OF THE TYPE MARK.

-- RJW 7/23/86

WITH REPORT; USE REPORT; 
PROCEDURE C47003A IS

BEGIN

     TEST( "C47003A", "WHEN THE TYPE MARK IN A QUALIFIED " &
                      "EXPRESSION DENOTES AN ENUMERATION " &
                      "TYPE, CHECK THAT CONSTRAINT_ERROR IS RAISED " &
                      "WHEN THE VALUE OF THE OPERAND DOES NOT LIE " &
                      "WITHIN THE RANGE OF THE TYPE MARK" );

     DECLARE  
          
          TYPE WEEK IS (SUN, MON, TUE, WED, THU, FRI, SAT);
          SUBTYPE MIDWEEK IS WEEK RANGE TUE .. THU;

          FUNCTION IDENT (W : WEEK) RETURN WEEK IS
          BEGIN
               RETURN WEEK'VAL (IDENT_INT (WEEK'POS (W)));
          END IDENT;

     BEGIN
          IF MIDWEEK'(IDENT (SUN)) = TUE THEN
               FAILED ( "NO EXCEPTION RAISED FOR VALUE OUTSIDE OF " &
                        "SUBTYPE MIDWEEK - 1");
          ELSE
               FAILED ( "NO EXCEPTION RAISED FOR VALUE OUTSIDE OF " &
                        "SUBTYPE MIDWEEK - 2");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR => 
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR VALUE OUTSIDE " &
                        "OF SUBTYPE MIDWEEK" );
     END;

     DECLARE  
          
          SUBTYPE CHAR IS CHARACTER RANGE 'C' .. 'R';

     BEGIN
          IF CHAR'(IDENT_CHAR ('A')) = 'C' THEN
               FAILED ( "NO EXCEPTION RAISED FOR VALUE OUTSIDE OF " &
                        "SUBTYPE CHAR - 1");
          ELSE
               FAILED ( "NO EXCEPTION RAISED FOR VALUE OUTSIDE OF " &
                        "SUBTYPE CHAR - 2");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR => 
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR VALUE OUTSIDE " &
                        "OF SUBTYPE CHAR" );
     END;

     DECLARE  

          TYPE NBOOL IS NEW BOOLEAN;
          SUBTYPE NFALSE IS NBOOL RANGE FALSE .. FALSE;

          FUNCTION IDENT (B : NBOOL) RETURN NBOOL IS
          BEGIN
               RETURN NBOOL (IDENT_BOOL (BOOLEAN (B)));
          END IDENT;

     BEGIN
          IF NFALSE'(IDENT (TRUE)) = FALSE THEN
               FAILED ( "NO EXCEPTION RAISED FOR VALUE OUTSIDE OF " &
                        "SUBTYPE NFALSE - 1");
          ELSE
               FAILED ( "NO EXCEPTION RAISED FOR VALUE OUTSIDE OF " &
                        "SUBTYPE NFALSE - 2");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR => 
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR VALUE OUTSIDE " &
                        "OF SUBTYPE NFALSE" );
     END;

     RESULT;
END C47003A;
