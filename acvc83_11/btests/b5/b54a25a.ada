-- B54A25A.ADA

-- CHECK THAT OUT OF RANGE NON-NULL DERIVED ENUMERATION TYPE CHOICES 
-- ARE FORBIDDEN WHEN THE CASE EXPRESSION HAS A STATIC SUBTYPE.

-- DAT 1/29/81
-- SPS 8/23/82

PROCEDURE B54A25A IS

     TYPE DAY IS (MON, TUE, WED, THU, FRI, SAT, SUN);
     TYPE WEEKDAY IS NEW DAY RANGE MON .. FRI;
     X: WEEKDAY RANGE TUE .. THU;

BEGIN
     X := WED;

     CASE X IS 
          WHEN SAT => X := TUE;             -- ERROR: OUT OF RANGE, SAT.
          WHEN TUE .. WED => X := WED;      -- OK.
          WHEN THU | FRI => X := THU;       -- ERROR: OUT OF RANGE, FRI.
     END CASE;

     CASE X IS
          WHEN MON .. WED => NULL;          -- ERROR: OUT OF RANGE, MON.
          WHEN SAT .. SUN => NULL;          -- ERROR: OUT OF RANGE, SAT,
                                            --        OUT OF RANGE, SUN.
          WHEN THU .. FRI => NULL;          -- ERROR: OUT OF RANGE, FRI.
     END CASE;

END B54A25A;
