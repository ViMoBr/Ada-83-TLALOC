-- B54A01L.ADA

-- CHECK THAT 'OTHERS' IN CASE STATEMENTS MUST BE LAST
-- AND THAT IT MUST BE THE ONLY CHOICE.

-- DAT 3/18/81
-- ABW 6/11/82

PROCEDURE B54A01L IS

     I : INTEGER := 4;

BEGIN

     CASE I IS
          WHEN 5 => NULL;
          WHEN OTHERS => NULL;          -- ERROR: OTHERS NOT LAST.
          WHEN 6 => NULL;
     END CASE;

     CASE I IS
          WHEN OTHERS => NULL;          -- ERROR: OTHERS NOT LAST.
          WHEN 7 => NULL;
     END CASE;

     CASE I IS
          WHEN 7 | OTHERS => NULL;      -- ERROR: OTHERS NOT ALONE.
     END CASE;

     CASE I IS
          WHEN 7 => NULL;
          WHEN OTHERS | 5 => NULL;      -- ERROR: OTHERS NOT ALONE.
     END CASE;

     CASE I IS
          WHEN 7 => NULL;
          WHEN 1 | OTHERS | 3 => NULL;  -- ERROR: OTHERS NOT ALONE.
     END CASE;

     CASE I IS
          WHEN 3 | 4 => NULL;
          WHEN 1 | OTHERS => NULL;      -- ERROR: OTHERS NOT ALONE.
     END CASE;

END B54A01L;
