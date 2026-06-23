-- B35803A.ADA
 
-- CHECK THAT THE PREFIX OF 'DIGITS', 'EPSILON', 'EMAX' AND 'SAFE_EMAX'
-- CANNOT BE A FIXED POINT TYPE.
 
-- R.WILLIAMS 8/20/86
 
PROCEDURE B35803A IS

     TYPE FIXED IS DELTA 1.0 RANGE -1.0 .. 1.0;   
     FI : FIXED;

     TYPE NFXED IS NEW FIXED;

     TYPE FLOAT IS DIGITS 3 RANGE -1.0 .. 1.0;
     FL : FLOAT;     
     
     I : INTEGER;
BEGIN
     I := FLOAT'DIGITS;                    -- OK: FLOATING POINT.
     I := FIXED'DIGITS;                    -- ERROR: FIXED POINT.
     I := NFXED'DIGITS;                    -- ERROR: FIXED POINT.

     FL := FLOAT'EPSILON;                  -- OK: FLOATING POINT.
     FI := FIXED'EPSILON;                  -- ERROR: FIXED POINT.
     FI := NFXED'EPSILON;                  -- ERROR: FIXED POINT.

     I := FLOAT'EMAX;                      -- OK: FLOATING POINT.
     I := FIXED'EMAX;                      -- ERROR: FIXED POINT.
     I := NFXED'EMAX;                      -- ERROR: FIXED POINT.

     I := FLOAT'SAFE_EMAX;                 -- OK: FLOATING POINT.
     I := FIXED'SAFE_EMAX;                 -- ERROR: FIXED POINT.
     I := NFXED'SAFE_EMAX;                 -- ERROR: FIXED POINT.
END B35803A;
