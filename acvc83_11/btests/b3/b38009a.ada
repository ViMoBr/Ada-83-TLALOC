-- B38009A.ADA
 
-- CHECK THAT AN INDEX OR DISCRIMINANT CONSTRAINT CANNOT BE IMPOSED ON 
-- AN ACCESS TYPE WHOSE DESIGNATED TYPE IS AN ACCESS TYPE.

-- TYPES OF ERROR MESSAGES:
--     A) CONSTRAINT IMPOSED IN OBJECT DECLARATION.
--     B) CONSTRAINT IMPOSED IN ARRAY COMPONENT DECLARATION.
--     C) CONSTRAINT IMPOSED IN RECORD COMPONENT DECLARATION.
--     D) CONSTRAINT IMPOSED IN ACCESS TYPE DECLARATION.
--     E) CONSTRAINT IMPOSED IN DERIVED TYPE DEFINITION.
--     F) CONSTRAINT IMPOSED IN PARAMETER DECLARATION.
--     G) CONSTRAINT IMPOSED IN RETURN TYPE IN FUNCTION DECLARATION.

-- AH  8/25/86 

PROCEDURE B38009A IS

     TYPE ARR IS ARRAY(INTEGER RANGE <>) OF INTEGER;
 
     TYPE REC(DISC : INTEGER) IS
          RECORD
               NULL;
          END RECORD;
 
     TYPE ACC1 IS ACCESS ARR;
     TYPE ACC2 IS ACCESS REC;

     SUBTYPE ST1 IS ACC1(1..5);
     SUBTYPE ST2 IS ACC2(5);

     TYPE A1 IS ACCESS ACC1;
     TYPE A2 IS ACCESS ACC2;

     OBJ1 : ACC1(1..5);                            -- OK.
     OBJ2 : ACC2(5);                               -- OK.

     OBJ3 : ST1;                                   -- OK.
     OBJ4 : ST2;                                   -- OK.

     OBJ5 : A1(1..5);                              -- ERROR: A.
     OBJ6 : A2(5);                                 -- ERROR: A.

     TYPE ARR2 IS ARRAY(1..10) OF A1(1..5);        -- ERROR: B.
     TYPE ARR3 IS ARRAY(1..10) OF A2(5);           -- ERROR: B.
  
     TYPE REC2 IS
          RECORD
               COMP1 : A1(1..5);                   -- ERROR: C.
               COMP2 : A2(5);                      -- ERROR: C.
          END RECORD;
 
     TYPE AT1 IS ACCESS A1(1..5);                  -- ERROR: D.
     TYPE AT2 IS ACCESS A2(5);                     -- ERROR: D.

     TYPE DER1 IS NEW A1(1..5);                    -- ERROR: E.
     TYPE DER2 IS NEW A2(5);                       -- ERROR: E.
 
     PROCEDURE PROC1 (PARM1 : IN OUT A1(1..5);     -- ERROR: F.
                      PARM2 : IN OUT A2(5)) IS     -- ERROR: F.
     BEGIN
          PARM1 := NEW ACC1; 
          PARM2 := NEW ACC2;
     END PROC1;

     FUNCTION FUNC1 RETURN A1(1..5) IS             -- ERROR: G.
          F1 : A1;
     BEGIN
          F1 := NEW ACC1(1..5);
          RETURN F1;
     END FUNC1;

     FUNCTION FUNC2 RETURN A2(5) IS                -- ERROR: G.
          F2 : A2;
     BEGIN
          F2 := NEW ACC2(5);
          RETURN F2;
     END FUNC2;

BEGIN
     NULL;
END B38009A;
