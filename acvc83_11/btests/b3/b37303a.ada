-- B37303A.ADA
 
-- CHECK THAT NON-STATIC CHOICE VALUES ARE FORBIDDEN IN VARIANT
-- RECORDS.
 
-- ASL 7/9/81
-- JWC 5/29/85
 
PROCEDURE B37303A IS
 
     N : INTEGER RANGE 1..1 := 1;
     I1 : INTEGER := 3;
     I2 : INTEGER := 9;
     SUBTYPE ST1 IS INTEGER RANGE I1..6;
     SUBTYPE ST2 IS INTEGER RANGE 7..I2;
     HIGH : INTEGER RANGE 20..20 := 20;
     LOW : INTEGER RANGE 10..10 := 10;
     X : INTEGER := 30;
     Y : INTEGER := 35;
 
     TYPE REC(DISC : INTEGER) IS
          RECORD
               COMP : INTEGER;
               CASE DISC IS
                    WHEN N => NULL;           -- ERROR: DYNAMIC CHOICE.
                    WHEN 15 => NULL;          -- OK.
                    WHEN ST1 => NULL;         -- ERROR: DYNAMIC CHOICE.
                    WHEN 23..22 => NULL;      -- OK.
                    WHEN ST2 RANGE 7..9 =>    -- ERROR: DYNAMIC CHOICE.
                         NULL;
                    WHEN 5000 => NULL;        -- OK.
                    WHEN HIGH..LOW => NULL;   -- ERROR: DYNAMIC CHOICE.
                    WHEN INTEGER RANGE 50..55 => -- OK.
                         NULL;
                    WHEN INTEGER RANGE X..Y => -- ERROR: DYNAMIC CHOICE.
                         NULL;
                    WHEN 100 => NULL;         -- OK.
                    WHEN OTHERS => NULL;
               END CASE;
          END RECORD;
BEGIN
     NULL;
END B37303A;
