-- B54A01D.ADA

-- CHECK THAT 'OR' IS NOT ALLOWED IN PLACE OF '|' IN CASE STATEMENTS.

-- DAT 3/18/81
-- ABW 6/11/81

PROCEDURE B54A01D IS

     I : INTEGER := 4;

BEGIN

     CASE I IS
          WHEN 6 => NULL;              -- OK.
          WHEN 3 OR 9 => NULL;         -- ERROR: OR.
          WHEN OTHERS => NULL;         -- OK. 
     END CASE;

END B54A01D;
