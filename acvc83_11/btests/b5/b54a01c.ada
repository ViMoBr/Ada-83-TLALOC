-- B54A01C.ADA

-- CHECK THAT 'IF' IS NOT ALLOWED IN PLACE OF 'WHEN' IN CASE STATEMENTS.

-- DAT 3/18/81
-- ABW 6/11/82

PROCEDURE B54A01C IS

     I : INTEGER := 4;

BEGIN

     CASE I IS
          WHEN 101 => NULL;        -- OK.
          IF 5 => NULL;            -- ERROR: '=>'; 'IF' NOT ALLOWED FOR
                                   --              'WHEN'.
          WHEN OTHERS => NULL;     -- OK.
     END CASE;

END B54A01C;
