-- BC2004B.ADA

-- CHECK THAT A GENERIC SUBPROGRAM BODY MUST FOLLOW
-- ITS GENERIC DECLARATION.

-- PWB  2/12/86

PROCEDURE BC2004B IS

BEGIN

     DECLARE     -- (A) GENERIC PROCEDURE.

          PROCEDURE GEN_PROC (X : INTEGER) IS
          BEGIN
               NULL;
          END GEN_PROC;

          GENERIC
               TYPE BASE IS (<>);
          PROCEDURE GEN_PROC (X : INTEGER);        -- ERROR: DECLARATION
                                                   --        AFTER BODY.

     BEGIN     -- (A)
          NULL;
     END;

     DECLARE     -- (B) GENERIC FUNCTION.

          FUNCTION GEN_FUNC (X : BOOLEAN) 
                   RETURN INTEGER IS
          BEGIN
               RETURN INTEGER'LAST;
          END GEN_FUNC;

          GENERIC
               I : INTEGER;
          FUNCTION GEN_FUNC (X : BOOLEAN) RETURN INTEGER;  -- ERROR: DEC
                                                           --      AFTER
                                                           --      BODY.

     BEGIN     -- (B)
          NULL;
     END;

END BC2004B;
