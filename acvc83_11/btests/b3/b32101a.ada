-- B32101A.ADA

-- CHECK THAT OBJECTS HAVING A LIMITED PRIVATE TYPE OR A SUBCOMPONENT
-- OF A LIMITED PRIVATE TYPE CANNOT BE GIVEN INITIAL VALUES.

-- RJW 6/13/86

PROCEDURE B32101A IS

     PACKAGE PKG IS

          TYPE LIM_TYPE IS LIMITED PRIVATE;
          TYPE LIM_PTR_TYPE IS LIMITED PRIVATE;
          TYPE PTR_TYPE IS ACCESS LIM_TYPE;

          EC1 : CONSTANT LIM_TYPE;

          TYPE LTREC IS
               RECORD
                    LT : LIM_TYPE;
               END RECORD;

          TYPE LTREC1 IS
               RECORD
                    L : LTREC;
               END RECORD;

          TYPE ARR IS ARRAY (1 .. 1) OF LIM_TYPE;       
          TYPE ARR1 IS ARRAY (1 .. 1) OF ARR;
     
          TYPE ARR2 IS ARRAY (1 .. 1) OF LTREC;

          TYPE LTREC2 IS
               RECORD
                    A : ARR;
               END RECORD;

          FUNCTION INIT_LT RETURN LIM_TYPE;
          FUNCTION INIT_LPT RETURN LIM_PTR_TYPE;
          FUNCTION GET_REC RETURN LTREC;
          FUNCTION GET_REC1 RETURN LTREC1;
          FUNCTION GET_REC2 RETURN LTREC2;
          FUNCTION GET_ARR RETURN ARR;
          FUNCTION GET_ARR1 RETURN ARR1;
          FUNCTION GET_ARR2 RETURN ARR2;
     PRIVATE

          TYPE LIM_TYPE IS NEW INTEGER;
          TYPE LIM_PTR_TYPE IS ACCESS LIM_TYPE;

          EC1 : CONSTANT LIM_TYPE := 3;

     END PKG;

     PACKAGE BODY PKG IS
          FUNCTION INIT_LT RETURN LIM_TYPE IS
          BEGIN
               RETURN 5;
          END INIT_LT;

          FUNCTION INIT_LPT RETURN LIM_PTR_TYPE IS
          BEGIN
               RETURN NEW LIM_TYPE'(EC1);
          END INIT_LPT;

          FUNCTION GET_REC RETURN LTREC IS
          BEGIN
               RETURN (LT => 5);
          END GET_REC;

          FUNCTION GET_REC1 RETURN LTREC1 IS
          BEGIN
               RETURN (L => (LT => 5));
          END GET_REC1;

          FUNCTION GET_REC2 RETURN LTREC2 IS
          BEGIN
               RETURN (A => (1 => 5));
          END GET_REC2;

          FUNCTION GET_ARR RETURN ARR IS
          BEGIN
               RETURN (1 => 2);
          END GET_ARR;

          FUNCTION GET_ARR1 RETURN ARR1 IS
          BEGIN
               RETURN (1 => (1 => 2));
          END GET_ARR1;

          FUNCTION GET_ARR2 RETURN ARR2 IS
          BEGIN
               RETURN (1 => (LT => 2));
          END GET_ARR2;

     END PKG;

     USE PKG;

BEGIN
     DECLARE
          EC2 : CONSTANT LIM_TYPE := 3;            -- ERROR: ILLEGAL 
                                                   --   INITIALIZATION.
          EC3 : CONSTANT LIM_TYPE := INIT_LT;      -- ERROR: ILLEGAL
                                                   --   INITIALIZATION.

          E1  : LIM_TYPE     := 13;        -- ERROR: ILLEGAL 
                                           --        INITIALIZATION.
          E2  : LIM_TYPE     := EC1;       -- ERROR: ILLEGAL 
                                           --        INITIALIZATION.
          E3  : LIM_TYPE     := INIT_LT;   -- ERROR: INITIAL
                                           --        INITIALIZATION.
          
          LP1 : LIM_PTR_TYPE := NEW LIM_TYPE'(0);  -- ERROR: ILLEGAL
                                                   --   INITIALIZATION.
          LP2:  LIM_PTR_TYPE := NEW LIM_TYPE'(EC1);-- ERROR: ILLEGAL
                                                   --   INITIALIZATION.
          LP3 : LIM_PTR_TYPE := INIT_LPT;          -- ERROR: ILLEGAL
                                                   --   INITIALIZATION.
          
          P1  : PTR_TYPE     := NEW LIM_TYPE'(EC1);  -- ERROR: ILLEGAL
                                                     --     ALLOCATOR.
          
          P2 : PTR_TYPE      := NEW LIM_TYPE'(INIT_LT); -- ERROR: 
                                                        --   ILLEGAL
                                                        --   ALLOCATOR.

          LR1 : LTREC := (LT => INIT_LT);         -- ERROR: ILLEGAL
                                                  --   INITIALIZATION.
          LR2 : LTREC := GET_REC;                 -- ERROR: ILLEGAL
                                                  --   INITIALIZATION.
          LR3 : LTREC1 := (L => GET_REC);         -- ERROR: ILLEGAL
                                                  --   INITIALIZATION.
          LR4 : LTREC1 := GET_REC1;               -- ERROR: ILLEGAL
                                                  --   INITIALIZATION.
          LR5 : LTREC2 := (A => GET_ARR);         -- ERROR: ILLEGAL
                                                  --   INITIALIZATION.
          LR6 : LTREC2 := GET_REC2;               -- ERROR: ILLEGAL
                                                  --   INITIALIZATION.

          AR1 : ARR := (1 => INIT_LT);            -- ERROR: ILLEGAL
                                                  --   INITIALIZATION.
          AR2 : ARR := GET_ARR;                   -- ERROR: ILLEGAL
                                                  --   INITIALIZATION.
          AR3 : ARR1 := (1 => GET_ARR);           -- ERROR: ILLEGAL
                                                  --   INITIALIZATION.
          AR4 : ARR1 := GET_ARR1;                 -- ERROR: ILLEGAL
                                                  --   INITIALIZATION.
          AR5 : ARR2 := (1 => GET_REC);           -- ERROR: ILLEGAL
                                                  --   INITIALIZATION.
          AR6 : ARR2 := GET_ARR2;                 -- ERROR: ILLEGAL
                                                  --   INITIALIZATION.
     BEGIN          
          NULL;
     END;

END B32101A;
