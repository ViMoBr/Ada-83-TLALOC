-- C37211D.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED BY A DISCRIMINANT CONSTRAINT 
-- IF A VALUE SPECIFIED FOR A DISCRIMINANT DOES NOT LIE IN THE RANGE
-- OF THE DISCRIMINANT. THIS TEST CONTAINS CHECKS FOR SUBTYPE 
-- INDICATIONS WHERE THE TYPE MARK DENOTES AN INCOMPLETE TYPE.

-- R.WILLIAMS 8/28/86

WITH REPORT; USE REPORT;
PROCEDURE C37211D IS

     GLOBAL : BOOLEAN;

     TYPE DAY IS (SUN, MON, TUE, WED, THU, FRI, SAT);

     SUBTYPE WEEKDAY IS DAY RANGE MON .. FRI;

     FUNCTION SWITCH (B : BOOLEAN) RETURN BOOLEAN IS
     BEGIN
          GLOBAL := B;
          RETURN B;
     END SWITCH;
     
     FUNCTION IDENT (D : DAY) RETURN DAY IS
     BEGIN
          RETURN DAY'VAL (IDENT_INT (DAY'POS (D)));
     END IDENT;

BEGIN
     TEST ( "C37211D", "CHECK THAT CONSTRAINT_ERROR IS RAISED BY " &
                       "A DISCRIMINANT CONSTRAINT IF A VALUE " &
                       "SPECIFIED FOR A DISCRIMINANT DOES NOT LIE " &
                       "IN THE RANGE OF THE DISCRIMINANT WHERE THE " &
                       "TYPE MARK DENOTES AN INCOMPLETE TYPE" );
                         
     BEGIN
          DECLARE
                                   
               B1 : BOOLEAN := SWITCH (TRUE);

               TYPE REC (D : WEEKDAY);

               TYPE ACCREC IS ACCESS REC (IDENT (SUN));

               B2 : BOOLEAN := SWITCH (FALSE);

               TYPE REC (D : WEEKDAY) IS
                    RECORD
                         NULL;
                    END RECORD;
          BEGIN
               DECLARE
                    AC : ACCREC;
               BEGIN
                    FAILED ( "NO EXCEPTION RAISED AT THE " &
                             "ELABORATION OF TYPE ACCREC" );
               END;
          EXCEPTION
               WHEN OTHERS => 
                    FAILED ( "EXCEPTION RAISED AT DECLARATION OF " &
                             "OBJECT AC" );
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF GLOBAL THEN 
                    NULL;
               ELSE
                    FAILED ( "EXCEPTION RAISED AT ELABORATION OF " &
                             "FULL TYPE REC NOT TYPE ACCREC" );
               END IF;                    
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED AT ELABORATION OF " &
                        "TYPE ACCREC" );
     END;

     RESULT;
END C37211D;
