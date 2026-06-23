-- B45204A.ADA

-- CHECK THAT RELATIONAL AND MEMBERSHIP OPERATIONS RETURN VALUES OF
-- TYPE STANDARD.BOOLEAN, EVEN WHEN THIS TYPE IS HIDDEN.

-- JWC 8/5/85

PROCEDURE B45204A IS

     TYPE BOOLEAN IS (FALSE, TRUE);

     B1 : BOOLEAN := 1 > 2;             -- ERROR: WRONG TYPE.
     B2 : BOOLEAN := 1 IN INTEGER;      -- ERROR: WRONG TYPE.
     PROCEDURE P ( X : BOOLEAN ) IS
     BEGIN
          NULL;
     END P;

BEGIN

     IF 1 < 2 THEN                      -- OK.
          NULL;
     END IF;

     IF 1 IN INTEGER THEN               -- OK.
          NULL;
     END IF;

     P (FALSE);                         -- OK.

     P (1 < 2);                         -- ERROR: WRONG PARAMETER TYPE.

     P (1 IN INTEGER);                  -- ERROR: WRONG PARAMETER TYPE.

END B45204A;
