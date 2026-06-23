-- B38003B.ADA
 
-- CHECK THAT IF AN INDEX OR DISCRIMINANT CONSTRAINT IS PROVIDED IN
-- AN ACCESS TYPE DEFINITION (OR IF THE SUBTYPE INDICATION IS ALREADY 
-- CONSTRAINED), THE ACCESS TYPE NAME CANNOT SUBSEQUENTLY BE USED 
-- WITH AN INDEX OR DISCRIMINANT CONSTRAINT, EVEN IF THE SAME 
-- CONSTRAINT VALUES ARE USED.
-- 
-- CHECK GENERIC FORMAL ACCESS TYPES WHEN SUBTYPE INDICATION IS ALREADY
-- CONSTRAINED.
--
-- CASES:
--     A) OBJECT DECLARATION
--     B) ARRAY COMPONENT DECLARATION
--     C) RECORD COMPONENT DECLARATION
--     D) ACCESS TYPE DECLARATION
--     E) DERIVED TYPE DEFINITION
--     F) PARAMETER DECLARATION
--     G) RETURN TYPE IN FUNCTION DECLARATION

-- AH  8/25/86 

PROCEDURE B38003B IS

     DISC_VAL : INTEGER := 0;
     TYPE REC1(DISC1 : INTEGER) IS
          RECORD
               NULL;
          END RECORD;
     SUBTYPE CON_REC IS REC1(DISC_VAL);

     GENERIC
          TYPE INDEX IS RANGE <>;

          TYPE LIST IS ARRAY (INDEX) OF BOOLEAN;
          TYPE A_LIST IS ACCESS LIST;

          TYPE A_CON_REC IS ACCESS CON_REC;

     PACKAGE P IS

          OBJ1 : A_LIST(INDEX);                         -- ERROR: A.
          OBJ2 : A_CON_REC(DISC_VAL);                   -- ERROR: A.
 
          TYPE ARR1 IS ARRAY(1..10) OF 
                       A_LIST(INDEX);                   -- ERROR: B.
          TYPE ARR2 IS ARRAY(1..10) OF 
                       A_CON_REC(DISC_VAL);             -- ERROR: B.
  
          TYPE REC2 IS
               RECORD
                    COMP1 : A_LIST(INDEX);              -- ERROR: C.
                    COMP2 : A_CON_REC(DISC_VAL);        -- ERROR: C.
               END RECORD;
 
          TYPE ACC1 IS ACCESS A_LIST(INDEX);            -- ERROR: D.
          TYPE ACC2 IS ACCESS A_CON_REC(DISC_VAL);      -- ERROR: D.
 
          TYPE DER1 IS NEW A_LIST(INDEX);               -- ERROR: E.
          TYPE DER2 IS NEW A_CON_REC(DISC_VAL);         -- ERROR: E.
 
          PROCEDURE PROC1 (PARM1 : A_LIST(INDEX));         -- ERROR: F.
          PROCEDURE PROC2 (PARM2 : A_CON_REC(DISC_VAL));   -- ERROR: F.

          FUNCTION FUNC1 RETURN A_LIST(INDEX);          -- ERROR: G.
          FUNCTION FUNC2 RETURN A_CON_REC(DISC_VAL);    -- ERROR: G.

     END P;

     PACKAGE BODY P IS
          PROCEDURE PROC1 (PARM1 : A_LIST(INDEX)) IS        -- OPTIONAL
                                                            -- ERROR: F.
          BEGIN
               NULL;
          END PROC1;

          PROCEDURE PROC2 (PARM2 : A_CON_REC(DISC_VAL)) IS  -- OPTIONAL
                                                            -- ERROR: F.
          BEGIN
               NULL;
          END PROC2;

          FUNCTION FUNC1 RETURN A_LIST(INDEX) IS          -- OPTIONAL
                                                          -- ERROR: G.
          BEGIN
               RETURN NULL;
          END FUNC1;

          FUNCTION FUNC2 RETURN A_CON_REC(DISC_VAL) IS    -- OPTIONAL
                                                          -- ERROR: G.
          BEGIN
               RETURN NULL;
          END FUNC2;

     END P;

BEGIN
     NULL;
END B38003B;
