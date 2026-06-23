-- B49009B.ADA

-- CHECK THAT A STATIC EXPRESSION CANNOT CONTAIN THE ATTRIBUTES 'POS,
-- 'VAL, 'SUCC, OR 'PRED IF THE PREFIX OF THESE ATTRIBUTES DENOTES A
-- NONSTATIC SUBTYPE OR THE ARGUMENT IS A NONSTATIC EXPRESSION.

-- L.BROWN  08/29/86

PROCEDURE  B49009B  IS

     TYPE ENUM IS (RED,YELLOW,BLUE,GREEN,BLACK,WHITE);
     OBJ1 : ENUM := GREEN;
     SUBTYPE SUENUM IS ENUM RANGE RED .. OBJ1;
     TYPE INT IS RANGE 1 .. SUENUM'POS(YELLOW);                -- ERROR:
     OBJ2 : BOOLEAN := FALSE;
     X : INTEGER := 2;
BEGIN
     CASE OBJ1 IS
          WHEN SUENUM'PRED(YELLOW) =>                          -- ERROR:
               OBJ2 := TRUE;
          WHEN OTHERS =>
               NULL;
     END CASE;

     CASE OBJ1 IS
          WHEN SUENUM'SUCC(YELLOW) =>                          -- ERROR:
               OBJ2 := TRUE;
          WHEN OTHERS =>
               NULL;
     END CASE;

     CASE OBJ1 IS
          WHEN SUENUM'VAL(3) =>                                -- ERROR:
               OBJ2 := TRUE;
          WHEN OTHERS =>
               NULL;
     END CASE;

     CASE  X IS
          WHEN ENUM'POS(OBJ1) =>                               -- ERROR:
               OBJ2 := TRUE;
          WHEN OTHERS =>
               NULL;
     END CASE;

     CASE OBJ1 IS
          WHEN ENUM'VAL(X) =>                                  -- ERROR:
               OBJ2 := TRUE;
          WHEN OTHERS =>
               NULL;
     END CASE;

END B49009B;
