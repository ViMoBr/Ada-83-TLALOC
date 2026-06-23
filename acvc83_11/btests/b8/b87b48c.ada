-- B87B48C.ADA
    
-- CHECK THAT OVERLOADING RESOLUTION USES THE RULE THAT:
--
-- MODES OF PARAMETERS CANNOT RESOLVE OVERLOADING OF SUBPROGRAMS.
  
-- TRH  19 AUG 82
   
PROCEDURE B87B48C IS
  
     TYPE FIXED IS DELTA 0.1 RANGE -1.0 .. 1.0;
     TYPE LINK  IS ACCESS FIXED;
     TYPE COLOR IS (RED, YELLOW, BLUE);
     TYPE AGE IS NEW INTEGER RANGE 0 .. 120;
 
     A1 : CONSTANT AGE := 18;
     F1 : CONSTANT FIXED := 1.0;
 
     PROCEDURE P (X : OUT STRING) IS
     BEGIN
          NULL;
     END P;
 
     PROCEDURE P (X : IN STRING; Y : FLOAT := 0.0) IS
     BEGIN
          NULL;
     END P;
 
     PROCEDURE P (X : IN LINK) IS
     BEGIN
          NULL;
     END P;
 
     PROCEDURE P (X : OUT LINK; Y : BOOLEAN := FALSE) IS
     BEGIN
          NULL;
     END P;

     PROCEDURE P (X : OUT CHARACTER) IS
     BEGIN
          NULL;
     END P;
 
     PROCEDURE P (X : IN CHARACTER; Y : FIXED := 0.0) IS
     BEGIN
          NULL;
     END P;
 
     PROCEDURE P (X : IN BOOLEAN) IS
     BEGIN
          NULL;
     END P;
 
     PROCEDURE P (X : IN OUT BOOLEAN; Y : COLOR := RED) IS
     BEGIN
          NULL;
     END P;
 
     PROCEDURE P (X : IN OUT AGE) IS
     BEGIN
          NULL;
     END P;
 
     PROCEDURE P (X : IN AGE; Y : STRING := "STRING") IS
     BEGIN
          NULL;
     END P;
 
     PROCEDURE P (X : OUT FIXED) IS
     BEGIN
          NULL;
     END P;
 
     PROCEDURE P (X : IN FIXED; Y : INTEGER := 1) IS
     BEGIN
          NULL;
     END P;
 
     PROCEDURE P (X : IN OUT FLOAT) IS
     BEGIN
          NULL;
     END P;
 
     PROCEDURE P (X : IN FLOAT; Y : AGE := 11) IS
     BEGIN
          NULL;
     END P;
 
     PROCEDURE P (X : IN COLOR) IS
     BEGIN
          NULL;
     END P;
 
     PROCEDURE P (X : OUT COLOR; Y : LINK := NULL) IS
     BEGIN
          NULL;
     END P;
 
BEGIN
   
     P ("STRING");        -- ERROR: AMBIGUOUS PROCEDURE CALL.
 
     P (NULL);            -- ERROR: AMBIGUOUS PROCEDURE CALL.
 
     P ('+');             -- ERROR: AMBIGUOUS PROCEDURE CALL.

     P (TRUE);            -- ERROR: AMBIGUOUS PROCEDURE CALL.
 
     P (21);              -- ERROR: AMBIGUOUS PROCEDURE CALL.
 
     P (FIXED'(1.0));     -- ERROR: AMBIGUOUS PROCEDURE CALL.
   
     P (FLOAT'(1.0));     -- ERROR: AMBIGUOUS PROCEDURE CALL.
 
     P (YELLOW);          -- ERROR: AMBIGUOUS PROCEDURE CALL.
  
     P (A1);              -- ERROR: AMBIGUOUS PROCEDURE CALL.
 
     P (F1);              -- ERROR: AMBIGUOUS PROCEDURE CALL.
 
END B87B48C;
