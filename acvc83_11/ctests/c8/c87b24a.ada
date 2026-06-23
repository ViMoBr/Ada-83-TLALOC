-- C87B24A.ADA
 
-- CHECK THAT OVERLOADING RESOLUTION USES THE RULE THAT:
    
-- THE PREFIX OF A SLICE MUST BE APPROPRIATE FOR A ONE DIMENSIONAL
-- ARRAY TYPE.
  
-- TRH  26 JULY 82
  
WITH REPORT; USE REPORT;
   
PROCEDURE C87B24A IS
 
     TYPE LIST IS ARRAY (1 .. 5) OF INTEGER;
     TYPE GRID IS ARRAY (1 .. 5, 1 .. 5) OF INTEGER;
     TYPE CUBE IS ARRAY (1 .. 5, 1 .. 5, 1 .. 5) OF INTEGER;
     TYPE HYPE IS ARRAY (1 .. 5, 1 .. 5, 1 .. 5, 1 .. 5) OF INTEGER;
     TYPE FLAG IS (PASS, FAIL);
   
     L : LIST := (1 .. 5 => 0);
     G : GRID := (1 .. 5 => (1 .. 5 => 0));
     C : CUBE := (1 .. 5 => (1 .. 5 => (1 .. 5 => 0)));
     H : HYPE := (1 .. 5 => (1 .. 5 => (1 .. 5 => (1 .. 5 => 0))));
 
     GENERIC
          TYPE T IS PRIVATE;
          ARG  : IN T;
          STAT : IN FLAG;
     FUNCTION F1 RETURN T;
 
     FUNCTION F1 RETURN T IS
     BEGIN
          IF STAT = FAIL THEN 
             FAILED ("SLICE PREFIX MUST BE APPROPRIATE FOR ONE " &
                     "DIMENSIONAL ARRAY");
          END IF;
          RETURN ARG;
     END F1;
 
     FUNCTION F2 IS NEW F1 (LIST, L, PASS);
     FUNCTION F2 IS NEW F1 (GRID, G, FAIL);
     FUNCTION F2 IS NEW F1 (CUBE, C, FAIL);
     FUNCTION F2 IS NEW F1 (HYPE, H, FAIL);
    
BEGIN
     TEST ("C87B24A","OVERLOADED PREFIX FOR SLICE RESOLVED TO " &
           "ONE DIMENSIONAL ARRAY TYPE");
 
     DECLARE
          S1 : INTEGER;
 
     BEGIN
          S1 := F2 (2 .. 3)(2);
     END;
 
     RESULT;
END C87B24A;
