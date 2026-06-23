-- C87B54A.ADA
 
-- CHECK THAT OVERLOADING RESOLUTION USES THE RULE THAT:
--
-- THE ARGUMENT OF THE DELAY STATEMENT IS OF THE PREDEFINED FIXED 
-- POINT TYPE DURATION.
  
-- TRH  7 SEPT 82
  
WITH REPORT; USE REPORT;
   
PROCEDURE C87B54A IS
 
     TYPE TEMPS  IS NEW DURATION;
     TYPE REAL   IS NEW FLOAT;
     TYPE TEMPUS IS DELTA 0.1 RANGE -1.0 .. 1.0;
     ERR : BOOLEAN := FALSE;
 
     FUNCTION F (X : TEMPS) RETURN TEMPS IS
     BEGIN
          ERR := TRUE;
          RETURN X;
     END F;
    
     FUNCTION F (X : REAL) RETURN REAL IS
     BEGIN
          ERR := TRUE;
          RETURN X;
     END F;
 
     FUNCTION F (X : TEMPUS) RETURN TEMPUS IS
     BEGIN
          ERR := TRUE;
          RETURN X;
     END F;
    
     FUNCTION F (X : DURATION) RETURN DURATION IS
     BEGIN
          RETURN X;
     END F;
    
BEGIN
     TEST ("C87B54A","OVERLOADED EXPRESSION WITHIN DELAY STATEMENT");
    
     DECLARE
          TASK T IS
               ENTRY E;
          END T;
  
          TASK BODY T IS
          BEGIN
               DELAY F (0.0);
               DELAY F (1.0);
               DELAY F (-1.0);
          END T;
  
     BEGIN
          IF ERR THEN FAILED ("DELAY STATEMENT TAKES AN ARGUMENT OF " &
                              "THE PREDEFINED FIXED POINT TYPE " &
                              "DURATION");
          END IF;
     END;
 
     RESULT;
END C87B54A;
