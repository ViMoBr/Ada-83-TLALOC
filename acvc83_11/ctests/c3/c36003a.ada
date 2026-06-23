-- C36003A.ADA

-- CHECK WHETHER AN ARRAY TYPE OR SUBTYPE DECLARATION RAISES 
-- NUMERIC_ERROR/CONSTRAINT_ERROR WHEN ONE DIMENSION OF THE
-- TYPE HAS MORE THAN SYSTEM.MAX_INT COMPONENTS.

-- L.BROWN  7/9/86

WITH SYSTEM; USE SYSTEM;
WITH REPORT; USE REPORT;

PROCEDURE C36003A IS

     TYPE LARGE_INT IS RANGE MIN_INT .. MAX_INT;
      
BEGIN
      
     TEST ("C36003A", "AN ARRAY TYPE OR SUBTYPE DECLARATION " &
                      "RAISES NUMERIC_ERROR/CONSTRAINT_ERROR WHEN " &
                      "ONE DIMENSION OF THE TYPE HAS MORE THAN " &
                      "SYSTEM.MAX_INT COMPONENTS");
 
     BEGIN
          DECLARE
               TYPE ARR_MAX IS ARRAY (LARGE_INT RANGE -1 ..
                                      MAX_INT) OF INTEGER;
          BEGIN
               COMMENT ("NO EXCEPTION RAISED FOR ONE-DIM ARRAY TYPE");
          END;
     EXCEPTION
          WHEN NUMERIC_ERROR => 
               COMMENT ("NUMERIC_ERROR RAISED FOR ONE-DIM ARRAY TYPE");
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED FOR ONE-DIM " &
                        "ARRAY TYPE");
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED FOR ONE-DIM ARRAY TYPE");
     END;

     BEGIN
          DECLARE
               TYPE AR_MAX IS ARRAY (LARGE_INT RANGE <>) OF BOOLEAN;
               SUBTYPE SAR_MAX IS AR_MAX (MIN_INT .. MAX_INT);
          BEGIN
               COMMENT ("NO EXCEPTION RAISED FOR ONE-DIM " &
                        "ARRAY SUBTYPE");
          END;
     EXCEPTION
          WHEN NUMERIC_ERROR => 
               COMMENT ("NUMERIC_ERROR RAISED FOR ONE-DIM " &
                        "ARRAY SUBTYPE");
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED FOR ONE-DIM " &
                        "ARRAY SUBTYPE");
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED FOR ONE-DIM " &
                       "ARRAY SUBTYPE");
     END;

     BEGIN
          DECLARE
               TYPE ARR_BIG IS ARRAY (LARGE_INT RANGE 0 .. MAX_INT,
                               INTEGER RANGE 1 .. 4) OF INTEGER;
          BEGIN
               COMMENT ("NO EXCEPTION RAISED FOR TWO-DIM ARRAY TYPE " &
                        "WHEN THE BIG DIMENSION IS THE FIRST ONE.");
          END;
     EXCEPTION
          WHEN NUMERIC_ERROR => 
               COMMENT ("NUMERIC_ERROR RAISED FOR TWO-DIM ARRAY TYPE " &
                        "WHEN THE BIG DIMENSION IS THE FIRST ONE.");
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED FOR TWO-DIM ARRAY " &
                       "TYPE WHEN THE BIG DIMENSION IS THE FIRST ONE.");
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED FOR TWO-DIM ARRAY " &
                       "TYPE WHEN THE BIG DIMENSION IS THE FIRST ONE.");
     END;

     BEGIN
          DECLARE
               TYPE ARR_GOOD IS ARRAY (LARGE_INT RANGE <>,
                                       INTEGER RANGE <>) OF CHARACTER;
               SUBTYPE AR_BAD IS ARR_GOOD (LARGE_INT RANGE 0 .. MAX_INT,
                                           INTEGER RANGE 2 .. 5);
          BEGIN
               COMMENT ("NO EXCEPTION RAISED FOR TWO-DIM ARRAY " &
                       "SUBTYPE WHEN THE BIG DIMENSION IS THE FIRST " &
                       "ONE.");
          END;
     EXCEPTION
          WHEN NUMERIC_ERROR => 
               COMMENT ("NUMERIC_ERROR RAISED FOR TWO-DIM ARRAY " &
                       "SUBTYPE WHEN THE BIG DIMENSION IS THE FIRST " &
                       "ONE.");
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED FOR TWO-DIM ARRAY " &
                        "SUBTYPE WHEN THE BIG DIMENSION IS THE FIRST " &
                        "ONE.");
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED FOR TWO-DIM ARRAY " &
                       "SUBTYPE WHEN THE BIG DIMENSION IS THE FIRST " &
                       "ONE.");
     END;
 
     BEGIN
          DECLARE
               TYPE AR2_BIG IS ARRAY (INTEGER RANGE 1 .. 5, 
                                    LARGE_INT RANGE MIN_INT .. MAX_INT)
                                    OF INTEGER;
         BEGIN
               COMMENT ("NO EXCEPTION RAISED FOR TWO-DIM ARRAY TYPE " &
                        "WHEN THE BIG DIMENSION IS THE SECOND ONE.");
          END;
     EXCEPTION
          WHEN NUMERIC_ERROR => 
               COMMENT ("NUMERIC_ERROR RAISED FOR TWO-DIM ARRAY TYPE " &
                        "WHEN THE BIG DIMENSION IS THE SECOND ONE.");
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED FOR TWO-DIM ARRAY " &
                        "TYPE WHEN THE BIG DIMENSION IS THE SECOND " &
                        "ONE.");
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED FOR TWO-DIM ARRAY " &
                       "TYPE WHEN THE BIG DIMENSION IS THE SECOND " &
                       "ONE.");
     END;
 
     BEGIN
          DECLARE
               TYPE ARR_OK IS ARRAY(INTEGER RANGE <>,
                                    INTEGER RANGE <>) OF INTEGER;
               SUBTYPE ARR_BAD2 IS ARR_OK (1 .. 2, MIN_INT .. 3);
         BEGIN
               COMMENT ("NO EXCEPTION RAISED FOR TWO-DIM ARRAY " &
                       "SUBTYPE WHEN THE BIG DIMENSION IS THE " &
                       "SECOND ONE.");
          END;
     EXCEPTION
          WHEN NUMERIC_ERROR => 
               COMMENT("NUMERIC_ERROR RAISED FOR TWO-DIM ARRAY " &
                       "SUBTYPE WHEN THE BIG DIMENSION IS THE " &
                       "SECOND ONE.");
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED FOR TWO-DIM ARRAY " &
                        "SUBTYPE WHEN THE BIG DIMENSION IS THE " &
                        "SECOND ONE.");
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED FOR TWO-DIM ARRAY " &
                       "SUBTYPE WHEN THE BIG DIMENSION IS THE SECOND " &
                       "ONE.");
     END;
 
     RESULT;
END C36003A;
