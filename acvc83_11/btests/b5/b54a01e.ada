-- B54A01E.ADA

-- CHECK THAT 'THEN' IS NOT ALLOWED IN PLACE OF '=>' IN CASE STATEMENTS.

-- DAT 3/18/81
-- ABW 6/11/82

PROCEDURE B54A01E IS

     I : INTEGER := 4;

BEGIN

     CASE I IS
          WHEN -1 => NULL;             -- OK.
          WHEN 7 THEN NULL;            -- ERROR: THEN.
          WHEN -2 => NULL;             -- OK.
          WHEN OTHERS => NULL;         -- OK.
     END CASE;

END B54A01E;
