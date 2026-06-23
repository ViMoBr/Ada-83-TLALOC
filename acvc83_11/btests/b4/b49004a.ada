-- B49004A.ADA

-- CHECK THAT A STATIC EXPRESSION MUST NOT RAISE AN EXCEPTION.

-- L.BROWN  08/21/86

PROCEDURE  B49004A  IS

     SUBTYPE INT IS INTEGER RANGE 1 .. 5 ;
     NAMED_NUM : CONSTANT := 5 MOD 0 ;                         -- ERROR:
     TYPE ENUM IS (OFF,ON,GREEN,RED,WARNING);
     TYPE INT1 IS RANGE 2/0 .. 5 ;                             -- ERROR:
     OBJ1 : INTEGER RANGE 1 .. 6 := 3 ;
     TYPE FIX1 IS DELTA 3.0 RANGE 1.0 .. 1.0*(INT'(6)) ;       -- ERROR:
     OBJ2 : ENUM ;
     TYPE FLT IS DIGITS 3 MOD 0 ;                              -- ERROR:
     OBJ3 : ENUM ;
     TYPE FIX2 IS DELTA 0.3*(5 REM 0) RANGE 0.0 .. 10.0 ;      -- ERROR:
     OBJ4 : ENUM ;
     TYPE ER_REC(INT2 : INT := 3) IS RECORD
          ATN : INTEGER RANGE 1 .. 10 := 2;
          CASE INT2 IS
               WHEN INT'LAST+5 =>                              -- ERROR:
                    X : CHARACTER RANGE 'A' .. 'C' ;
               WHEN OTHERS =>
                    Y : POSITIVE RANGE 1 .. 10 ;
          END CASE;
     END RECORD;

BEGIN

     CASE OBJ1 IS
          WHEN INT RANGE 3 .. 6 =>                             -- ERROR:
               OBJ1 := 4 ;
          WHEN OTHERS =>
               NULL;
     END CASE;

     CASE OBJ2 IS
          WHEN ENUM'PRED(OFF) =>                               -- ERROR:
               OBJ1 := 5 ;
          WHEN OTHERS =>
               OBJ2 := OFF ;
     END CASE;

     CASE OBJ3 IS
          WHEN ENUM'SUCC(WARNING) =>                           -- ERROR:
               OBJ3 := RED ;
          WHEN OTHERS =>
               OBJ2 := RED ;
     END CASE;

     CASE OBJ4 IS
          WHEN ENUM'VAL(5) =>                                  -- ERROR:
               OBJ4 := WARNING ;
          WHEN OTHERS =>
               OBJ3 := GREEN ;
     END CASE;

END B49004A;
