-- A35502R.ADA

-- CHECK THAT THE ATTRIBUTES WIDTH, POS, VAL, SUCC, PRED, IMAGE, VALUE,
-- FIRST, AND LAST YIELD THE CORRECT TYPE WHEN THE PREFIX IS A FORMAL 
-- DISCRETE TYPE WHOSE ACTUAL ARGUMENT IS AN ENUMERATION TYPE OTHER 
-- THAN A BOOLEAN OR CHARACTER TYPE.

-- RJW 6/13/86

WITH REPORT; USE REPORT;
PROCEDURE A35502R IS

     BEGIN
          TEST ( "A35502R", "CHECK THAT THE ATTRIBUTES WIDTH, POS, " &
                            "VAL, SUCC, PRED, IMAGE, VALUE, FIRST, " &
                            "AND LAST YIELD THE CORRECT TYPE WHEN " &
                            "THE PREFIX IS A FORMAL DISCRETE TYPE " &
                            "WHOSE ACTUAL ARGUMENT IS AN " &
                            "ENUMERATION TYPE OTHER THAN A BOOLEAN " &
                            "OR CHARACTER TYPE" );

     DECLARE
          TYPE COLOR IS (RED, BLUE, GREEN);

          GENERIC
               TYPE T IS (<>);
          PROCEDURE P (T1 : T; STR : STRING);

          PROCEDURE P (T1 : T; STR : STRING) IS 
               TYPE NINT IS NEW INTEGER;
               
               I1 : CONSTANT INTEGER := T'WIDTH;
               I2 : CONSTANT INTEGER := T'POS (T1);

               N1 : CONSTANT NINT := T'WIDTH;
               N2 : CONSTANT NINT := T'POS (T1);
     
               C1 : CONSTANT T := T'VAL (1);
               C2 : CONSTANT T := T'SUCC (T1);
               C3 : CONSTANT T := T'PRED (T1);
               C4 : CONSTANT T := T'VALUE (STR);
               C5 : CONSTANT T := T'FIRST;
               C6 : CONSTANT T := T'LAST;
     
               S1 : CONSTANT STRING := T'IMAGE (T1);
          BEGIN
               NULL;
          END P;
    
          PROCEDURE NP IS NEW P (COLOR);
     BEGIN
          NP (BLUE, "BLUE");
     END;

     RESULT;
END A35502R;
