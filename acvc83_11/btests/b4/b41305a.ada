-- B41305A.ADA

-- CHECK THAT L.R MUST NOT OCCUR OUTSIDE A FUNCTION DECLARING L AS AN 
-- OPERATOR SYMBOL.

-- TBN 5/23/86

PROCEDURE B41305A IS

     J : INTEGER;

     FUNCTION "+" (X, Y : INTEGER) RETURN INTEGER IS

          I : INTEGER := 1;

     BEGIN
          I := "+".I;                                          -- OK.
          RETURN (X + Y);
     END;

BEGIN
     J := "+".I;                                               -- ERROR:
     J := "+".X;                                               -- ERROR:
END B41305A;
