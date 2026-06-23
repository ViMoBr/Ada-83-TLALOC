-- B53004A.ADA

-- CHECK THAT CONDITIONS MUST BE BOOLEAN EXPRESSIONS.

-- DCB 3/9/80
-- JRK 7/7/80

PROCEDURE B53004A IS

     I1, I2, I3 : INTEGER;
     C1, C2 : CHARACTER;
     B1, B2 : BOOLEAN;

     TYPE FTM IS (FALSE, TRUE, MAYBE);
     E1, E2 : FTM;

BEGIN
     I1 := 0;    I2 := 1;
     C1 := '0';  C2 := '1';
     B1 := TRUE; B2 := FALSE;
     E1 := TRUE; E2 := FALSE;

     IF 0 THEN      -- ERROR: ZERO AS A CONDITION.
          I3 := 9;
     END IF;

     IF I1 THEN     -- ERROR: INTEGER AS A CONDITION.
          I3 := 9;
     END IF;

     IF I2 THEN     -- ERROR: INTEGER AS A CONDITION.
          I3 := 9;
     END IF;

     IF I1 + I2 THEN -- ERROR: INTEGER EXPRESSION AS A CONDITION.
          I3 := 9;
     END IF;

     IF C1 THEN     -- ERROR: CHARACTER AS A CONDITION.
          I3 := 9;
     END IF;

     IF C2 THEN     -- ERROR: CHARACTER AS A CONDITION.
          I3 := 9;
     END IF;

     IF E1 THEN     -- ERROR: ENUMERATION AS A CONDITION.
          I3 := 9;
     END IF;

     IF E2 THEN     -- ERROR: ENUMERATION AS A CONDITION.
          I3 := 9;
     END IF;

     IF B1 OR I1 THEN     -- ERROR: INTEGER IN BOOLEAN EXPRESSION.
          I3 := 9;
     END IF;

     IF B2 OR C1 THEN     -- ERROR: CHAR IN BOOLEAN EXPRESSION.
          I3 := 9;
     END IF;

     IF B2 OR E1 THEN     -- ERROR: ENUM IN BOOLEAN EXPRESSION.
          I3 := 9;
     END IF;

END B53004A;
