-- BC3003B.ADA

-- CHECK THAT GENERIC INSTANTIATIONS OF THE FORM P(A | B => C) ARE
-- FORBIDDEN, EVEN WHEN GENERIC FORMAL PARAMETERS A AND B ARE OF 
-- THE SAME KIND (OBJECT, TYPE OR SUBPROGRAM) AND MATCH (SAME SUBTYPE, 
-- SAME KIND OF GENERIC TYPE DEFINITION OR SAME SUBPROGRAM 
-- SPECIFICATION).

-- ASL 8/14/81

PROCEDURE BC3003B IS

     PROCEDURE PROC; 

     TYPE ENUM IS (YES,NO,MAYBE);

     X : INTEGER := 5;

     GENERIC
          TYPE GT1 IS (<>);
          TYPE GT2 IS (<>);
          GOBJ1 : INTEGER;
          GOBJ2 : INTEGER;
          WITH PROCEDURE GPROC1;
          WITH PROCEDURE GPROC2;
     PACKAGE P IS
     END P;

     PACKAGE BAD1 IS
          NEW P(GT1 | GT2 => ENUM,           -- ERROR: CHOICES.
                GOBJ1 => X,
                GOBJ2 => X,
                GPROC1 => PROC,
                GPROC2 => PROC);
     PACKAGE BAD2 IS 
          NEW P(GT1 => ENUM,
                GT2 => ENUM,
                GOBJ1 | GOBJ2 => X,          -- ERROR: CHOICES.
                GPROC1 => PROC,
                GPROC2 => PROC);
     PACKAGE BAD3 IS
          NEW P(GT1 => ENUM,
                GT2 => ENUM,
                GOBJ1 => X,
                GOBJ2 => X,
                GPROC1 | GPROC2 => PROC);   -- ERROR: CHOICES.

     PROCEDURE PROC IS
     BEGIN
          NULL;
     END PROC;
BEGIN
     NULL;
END BC3003B;
