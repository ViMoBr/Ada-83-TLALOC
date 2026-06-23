-- B53003A.ADA

-- CHECK THAT ELSIF CANNOT BE SPELLED AS ELSEIF, ELSF, ELIF,
--    OR ELSE_IF.

-- DCB 3/6/80
-- SPS 3/3/83

PROCEDURE B53003A IS

     B1, B2 : BOOLEAN;
     I1, I2 : INTEGER;

BEGIN
     B1 := TRUE;
     B2 := FALSE;

     IF B1 AND B2 THEN
          I1 := 1;
     ELSEIF B2 THEN       -- ERROR: ELSIF MISSPELLED.
          I1 := 9;
     END IF;

     IF B1 AND B2 THEN
          I1 := 1;
     ELSF B2 THEN         -- ERROR: ELSIF MISSPELLED.
          I1 := 9;
     END IF;

     IF B1 AND B2 THEN
          I1 := 1;
     ELIF B2 THEN         -- ERROR: ELSIF MISSPELLED.
          I1 := 9;
     END IF;

     IF B1 AND B2 THEN
          I1 := 1;
     ELSE_IF B2 THEN      -- ERROR: ELSIF MISSPELLED.
          I1 := 9;
     END IF;

END B53003A;
