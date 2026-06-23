-- B45205A.ADA


-- CHECK THAT RELATIONAL EXPRESSIONS OF THE FORM   A < B < C  ARE
--     FORBIDDEN.


-- RM  2/9/82
-- JBG 4/15/85

PROCEDURE B45205A IS

BEGIN

     -------------------------------------------------------------------
     -------------------------  INTEGER  -------------------------------

     DECLARE

          X , Y  : INTEGER  RANGE 0..101  :=  1 ;
          B      : BOOLEAN ;

     BEGIN

          WHILE  0 < X < 101  LOOP  -- ERROR: BAD RELATIONAL EXPRESSION.
               NULL ;
          END LOOP;

          LOOP
               EXIT WHEN  100 >= X > 0 ;  -- ERROR: BAD REL. EXPRESSION.
          END LOOP;

          IF  0 /= X /= 17          -- ERROR: BAD RELATIONAL EXPRESSION.
          THEN
               NULL ;
          END IF;

          B := ( X = Y = 1 ) ;      -- ERROR: BAD RELATIONAL EXPRESSION.

     END ;


     -------------------------------------------------------------------
     -------------------  USER-DEFINED ENUMERATIONS  -------------------

     DECLARE

          TYPE  ENUM  IS  ( AA , BB , CC , DD , EE );

          X , Y  : ENUM  RANGE AA..DD  :=  CC ;
          B      : BOOLEAN ;

     BEGIN

          WHILE  EE > X > AA  LOOP  -- ERROR: BAD RELATIONAL EXPRESSION.
               NULL ;
          END LOOP;

          LOOP
               EXIT WHEN  AA < X <= DD ;  -- ERROR: BAD REL. EXPRESSION.
          END LOOP;

          IF  BB /= X /= DD         -- ERROR: BAD RELATIONAL EXPRESSION.
          THEN
               NULL ;
          END IF;

          B := ( X = Y = CC ) ;     -- ERROR: BAD RELATIONAL EXPRESSION.

     END ;


     -------------------------------------------------------------------
     ------------------------  CHARACTER  ------------------------------

     DECLARE

          X , Y  :  CHARACTER  RANGE 'A'..'D'  :=  'C' ;
          B      :  BOOLEAN ;

     BEGIN

          WHILE  'A' <= X < 'E'  LOOP     -- ERROR: BAD REL. EXPRESSION.
               NULL ;
          END LOOP;

          LOOP
               EXIT WHEN  'D' > X >= 'A' ;-- ERROR: BAD REL. EXPRESSION.
          END LOOP;

          IF  'B' /= X /= 'D'       -- ERROR: BAD RELATIONAL EXPRESSION.
          THEN

               NULL ;
          END IF;

          B := ( X = Y = 'C' ) ;    -- ERROR: BAD RELATIONAL EXPRESSION.

     END ;

     -------------------------------------------------------------------


END B45205A;
