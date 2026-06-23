-- B49010A.ADA

-- CHECK THAT A STATIC EXPRESSION CANNOT CONTAIN A QUALIFIED EXPRESSION
-- IF THE TYPE MARK DENOTES A NONSTATIC TYPE (SCALAR OR NOT), OR THE
-- ARGUMENT IS A NONSTATIC SCALAR EXPRESSION.

-- RJW 2/26/86

PROCEDURE B49010A IS

BEGIN
     DECLARE
          TYPE DAY IS (SUN, MON, TUE, WED, THUR, FRI, SAT);
          M : DAY := MON;
          F : DAY := FRI;
          SUBTYPE WEEKDAY IS DAY RANGE M .. F;
          TYPE PTR IS ACCESS DAY;
          P : CONSTANT PTR := NEW DAY'(MON);
          Q : CONSTANT PTR := NEW DAY'(TUE);
          B : BOOLEAN;

     BEGIN
          CASE B IS
               WHEN (DAY'(SUN) = DAY'(MON)) =>   -- OK.
                    NULL;
               WHEN (PTR'(P) = PTR'(Q)) =>       -- ERROR: NONSTATIC
                                                 --        NON SCALAR
                                                 --        TYPE MARK.
                    NULL;
               WHEN (WEEKDAY'(WED) = WEEKDAY'(FRI)) =>  -- ERROR:
                                                        -- NONSTATIC
                                                        -- SCALAR TYPE
                                                        -- MARK.
                    NULL;
               WHEN (DAY'(M) = DAY'(F)) =>       -- ERROR: NONSTATIC
                                                 --        ARGUMENT.
                    NULL;
               WHEN OTHERS =>
                    NULL;
          END CASE;
     END;

END B49010A;
