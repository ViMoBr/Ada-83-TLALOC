-- B53001A.ADA

-- CHECK THAT AN IF STATEMENT MUST END WITH "END IF;".

-- DCB 3/6/80
-- JRK 7/7/80
-- ABW 6/11/82

PROCEDURE B53001A IS

     B1, B2 : BOOLEAN;
     I1, I2 : INTEGER;

BEGIN
     B1 := TRUE;
     B2 := FALSE;

     IF B1 AND B2 THEN
          I2 := 1;
                        -- "END IF;" MISSING.
     I1 := 0;

     IF B1 AND B2 THEN
          I1 := 2;
     ELSE IF B1 OR B2 THEN
          I1 := 3;
     ELSE I1 := 4;
                        -- "END IF;" MISSING.
                        -- "END IF;" MISSING.

     IF B1 OR B2 THEN
          I1 := 1;
     END;               -- ERROR: 3 PREVIOUS "END IF;"S MISSING;
                        --        "END;" USED INSTEAD OF "END IF;".

END B53001A;
