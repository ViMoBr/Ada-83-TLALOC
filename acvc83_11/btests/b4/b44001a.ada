-- B44001A.ADA

-- OBJECTIVE:
--     CHECK THE DETECTION OF SYNTAX ERRORS IN EXPRESSIONS.

--     THE INTERNAL STRUCTURE OF A  <RELATION>  IS TESTED IN  4.5;
--     ACCORDINGLY, IN THIS TEST EACH  <RELATION>  IS REPRESENTED
--     BY A BOOLEAN VARIABLE.

-- HISTORY:
--     RM  09/18/80
--     DWC 09/22/87  MOVED CHECK THAT PROCEDURE CALL CANNOT BE
--                   PRIMARY TO B44001B.ADA.

PROCEDURE  B44001A  IS

     A , B , C , D , E : BOOLEAN:= TRUE;
     I , J , K         : INTEGER := 0;

     PROCEDURE  PROC1( X : INTEGER := 17 )  IS
     BEGIN
          NULL;
     END PROC1;

     PROCEDURE  PROC2  IS
     BEGIN
          NULL;
     END PROC2;

BEGIN

     -- (A) THE LOGICAL OPERATORS ( 'AND' , 'OR' , 'XOR' ,
     --    'AND THEN' , 'OR ELSE' ) CANNOT BE INTERMIXED IN EXPRESSIONS.
     --    UNLESS PARENTHESES ARE USED TO SEPARATE THE DIFFERENT
     --    OPERATORS.

     E  :=  A  AND  B  OR  C;                     -- ERROR: (A)
     NULL;
     E  :=  A  XOR  B  OR  C;                     -- ERROR: (A)
     NULL;
     E  :=  A AND B         XOR       C AND D;    -- ERROR: (A)
     NULL;
     E  :=  A AND B         OR ELSE   C AND D;    -- ERROR: (A)
     NULL;
     E  :=  A AND THEN E   OR ELSE   C AND D;     -- ERROR: (A)
     NULL;
     E  :=  A AND C AND THEN B;                   -- ERROR: (A)
     NULL;
     E  :=  A OR  C OR ELSE  B;                   -- ERROR: (A)
     NULL;
     E  :=  A OR  C AND THEN  B;                  -- ERROR: (A)
     NULL;
     E  :=  A  AND OR  B;    -- ERROR: (A) + CONSECUTIVE OPERATORS.
     NULL;
     E  :=  A  AND/OR  B;    -- ERROR: (A) + CONSECUTIVE OPERATORS.
     NULL;

     -- (B) A RELATION CAN HAVE AT MOST ONE RELATIONAL OPERATOR.

     IF  I  < J  <  K  THEN  NULL;  END IF;   -- ERROR: (B)
     NULL;
     IF  A  = B  =  C  THEN  NULL;  END IF;   -- ERROR: (B)
     NULL;
     IF  A <= B <=  C  THEN  NULL;  END IF;   -- ERROR: (B)
     NULL;
     IF  2 < 9 = TRUE  THEN  NULL;  END IF;   -- ERROR: (B)
     NULL;


     -- (C)  (UNLESS PARENTHESES ARE USED,)  A <SIMPLE_EXPRESSION>
     --      OR <FACTOR> CAN HAVE ONLY ONE UNARY OPERATOR, UNLESS THE
     --      INNERMOST UNARY OPERATOR HAS A HIGHER PRECEDENCE.

     A  :=  NOT NOT B;    -- ERROR: (C)
     NULL;
     I  :=  - ABS J;      -- OK.
     NULL;
     I  :=  ABS - J;      -- ERROR: (C)
     NULL;
     I  :=  -+J;          -- ERROR: (C)
     NULL;
     I  :=  - -J;         -- ERROR: (C)
     NULL;
     I  :=  K +-  J;      -- ERROR: (C)
     NULL;
     I  :=  K  * -J;      -- ERROR: (C)
     NULL;
     I  :=  K  * -2;      -- ERROR: (C)
     NULL;
     I  :=  K  ** -2;     -- ERROR: (C)
     NULL;
     I  :=  K  ** ABS J; -- ERROR: (C)
     NULL;

     -- (D) A FACTOR CAN HAVE AT MOST ONE EXPONENTIATION OPERATOR.

     I  :=  I ** J ** K;    -- ERROR: (D)
     NULL;

END  B44001A;
