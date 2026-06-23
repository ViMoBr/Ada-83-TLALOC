-- B63103A.ADA

-- CHECK THAT UNIVERSAL REAL LITERALS IN DEFAULT EXPRESSIONS MUST HAVE
-- THE SAME VALUE IN CONFORMING FORMAL PARTS. 

-- BHS 7/16/84

PROCEDURE B63103A IS

     TYPE REAL IS NEW FLOAT;

     PACKAGE PACK1 IS
          PROCEDURE P1 (X : REAL := 0.333_333_333_333_333_333_33);
     PRIVATE
          PROCEDURE P2 (Y : REAL := 3#0.1#);
     END PACK1;

     PACKAGE BODY PACK1 IS                                       
          PROCEDURE P1 (X : REAL := 3#0.1#) IS     -- ERROR: 0.333...
                                                   -- AND 3#0.1# DO NOT
                                                   -- CONFORM. 
          BEGIN  
               NULL;  
          END P1;

          PROCEDURE P2 (Y : REAL
                        := 16#0.555_555_555_555_555_555#) IS  -- ERROR: 
                                                    -- 3#0.1# AND
                                                    -- 16#0.555_555...#
                                                    -- DO NOT CONFORM.
          BEGIN
               NULL;
          END P2;
     END PACK1;


     GENERIC
     PROCEDURE P3 (Z : REAL := 16#0.555_555_555_555_555_555#);

     PROCEDURE P3 (Z : REAL 
                   := 0.333_333_333_333_333_333_33) IS  -- ERROR: 
                                                   -- 16#0.555_555...#
                                                   -- AND 0.333... DO
                                                   -- NOT CONFORM.
     BEGIN
          NULL;
     END P3;


     GENERIC
     PROCEDURE P4 (ZZ : REAL := 0.333_333_333_333_333_333_33);

     PROCEDURE P4 (ZZ : REAL := 3#0.1#) IS      -- ERROR: 0.333... AND
                                                -- 3#0.1# DO NOT
                                                -- CONFORM. 
     BEGIN
          NULL;
     END P4;


     PACKAGE OK_PACK IS
          PROCEDURE P5 (OK : REAL := 0.75);
     END OK_PACK;

     PACKAGE BODY OK_PACK IS
          PROCEDURE P5 (OK : REAL := 2#0.11#) IS    -- OK.
          BEGIN
               NULL;
          END P5;
     END OK_PACK;

BEGIN
     NULL;
END B63103A;
