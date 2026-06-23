-- B38101A.ADA
 
-- CHECK THAT IF AN INCOMPLETE TYPE DECLARATION APPEARS IN THE VISIBLE
-- PART OF A PACKAGE, THE FULL DECLARATION MUST APPEAR IN THE SAME 
-- PART AND IN PARTICULAR:
 
     -- 1) CANNOT BE OMITTED;
 
     -- 2) CANNOT BE GIVEN IN THE PRIVATE PART IF THE INCOMPLETE
     --    DECLARATION WAS IN THE VISIBLE PART;
 
     -- 3) CANNOT APPEAR IN THE PACKAGE BODY'S DECLARATIVE PART;
 
     -- 4) CANNOT APPEAR IN A PACKAGE SPECIFICATION NESTED IN THE 
     --    VISIBLE OR PRIVATE PART CONTAINING THE INCOMPLETE 
     --    DECLARATION.
 
-- CHECK THAT IF AN INCOMPLETE TYPE DECLARATION APPEARS IN THE
-- DECLARATIVE PART OF A
 
     -- 5) BLOCK,
 
     -- 6) SUBPROGRAM BODY OR 
 
     -- 7) PACKAGE BODY,

-- THE CORRESPONDING COMPLETE DECLARATION MUST APPEAR IN THE SAME 
-- DECLARATIVE PART, EXCLUDING ANY NESTED DECLARATIVE PARTS OR
-- PACKAGE SPECIFICATIONS.
--
-- CHECK THAT IF AN INCOMPLETE TYPE DECLARATION APPEARS IN THE
-- PRIVATE PART OF A PACKAGE THEN THE FULL DECLARATION MUST 
-- APPEAR IN
--
--        8) THE PRIVATE PART ITSELF OR 
--
--        9) THE DECLARATIVE PART OF THE CORRESPONDING
--           PACKAGE BODY.
 
-- ASL 7/16/81
-- VKG 1/21/83
-- AH  8/26/86  MODIFIED COMMENTS.

PROCEDURE B38101A IS
 
     PACKAGE PACK1 IS
          TYPE T1;                            -- ERROR: 1) FOR T1.
     PRIVATE      
          TYPE U1;
     END PACK1;                               -- OK U1
 
     PACKAGE PACK2 IS
          TYPE T2;                            -- ERROR: 2) FOR T2.
     PRIVATE      
          TYPE T2 IS (X);
     END PACK2;
 
     PACKAGE PACK3 IS
          TYPE T3;                            -- ERROR: 3) FOR T3.
     PRIVATE      
          TYPE U3;
     END PACK3;                               -- OK

     PACKAGE BODY PACK1 IS
     END;                                     -- ERROR: 8,9) FOR U1.
 
     PACKAGE BODY PACK3 IS
          TYPE T3 IS (X);       -- A COMPILER MIGHT GIVE AN ERROR
                                -- MESSAGE FOR THIS LINE.
          TYPE U3 IS (X);                     -- OK U3.
          TYPE T4;                            -- ERROR: 7) FOR T4
          TYPE U4;                            -- ERROR: 7) FOR U4
          PACKAGE PACK4 IS
               TYPE T4 IS (X);
          END PACK4;
          PROCEDURE PROC1 IS
               TYPE U4 IS (X);
          BEGIN
               NULL;
          END PROC1;
     END PACK3;
 
     PACKAGE PACK5 IS
          TYPE T5;                            -- ERROR: 4) FOR T5.
          PACKAGE PACK6 IS
               TYPE T5 IS (X);
          END PACK6;
     PRIVATE        
          TYPE U5;                            
          PACKAGE PACK7 IS
               TYPE U5 IS (X);
          END PACK7;
     END PACK5;   
 
     PACKAGE BODY PACK5 IS
     END PACK5;                               -- ERROR: U5.

     PROCEDURE PROC2 IS
          TYPE T6;                            -- ERROR: 6) FOR T6
          TYPE U6;                            -- ERROR: 6) FOR U6
          PACKAGE PACK8 IS
               TYPE T6 IS (X);
          END PACK8;
          PROCEDURE PROC3 IS 
               TYPE U6 IS (X);
          BEGIN
               NULL;
          END PROC3;
     BEGIN
          NULL;
     END PROC2;
 
BEGIN
 
     DECLARE
          TYPE T7;                            -- ERROR: 5) FOR T7
          TYPE U7;                            -- ERROR: 5) FOR U7
          PACKAGE PACK9 IS
               TYPE T7 IS (X);
          END PACK9;
          PROCEDURE PROC4 IS
               TYPE U7 IS (X);
          BEGIN
               NULL;
          END PROC4;
     BEGIN
          NULL;
     END;
 
END B38101A;
