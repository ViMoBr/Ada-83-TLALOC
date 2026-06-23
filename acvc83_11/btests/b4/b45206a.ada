-- B45206A.ADA


-- CHECK THAT THE RELATIONAL OPERATORS ARE NOT PREDEFINED FOR OPERANDS
--     OF DIFFERENT TYPES.  (SPECIAL CASE(S) OF THIS TEST OBJECTIVE,
--     NOT RELEVANT FOR ADA-80, ARE TREATED SEPARATELY UNDER THE SAME
--     OBJECTIVE; ANOTHER SPECIAL CASE IS SINGLED OUT AS
--     OBJECTIVE 4.5.2.A/T3 .)


-- THIS OBJECTIVE DOES NOT DEAL WITH MIXED-MODE COMPARISONS WHICH "MAKE
--     NO SENSE"; IT LIMITS ITSELF TO COMPARISONS WHICH ARE LEGAL IN
--     CERTAIN PROGRAMMING LANGUAGES.


-- CASES COVERED:

--   * NUMERIC (INTEGER) VS. BOOLEAN
--   * NUMERIC (INTEGER) VS. ARRAY OF BOOLEANS
--   * NUMERIC (INTEGER) VS. CHARACTER
--   * NUMERIC (INTEGER) VS. ARRAY OF INTEGERS
--   * USER-DEF. ENUMERATION VS. CHARACTER
--   * USER-DEF. ENUMERATION VS. INTEGER  


-- RM  2/9/82


PROCEDURE B45206A IS

BEGIN

     -------------------------------------------------------------------
     ---------------  NUMERIC (INTEGER) VS. BOOLEAN  -------------------

     DECLARE

          X , Y  : INTEGER :=  0 ;
          B      : BOOLEAN := FALSE ;

     BEGIN

          IF  B = 0                 -- ERROR: BAD RELATIONAL EXPRESSION.
          THEN
               NULL ;
          END IF;

          B := ( X /= FALSE ) ;     -- ERROR: BAD RELATIONAL EXPRESSION.

          IF  Y >= FALSE            -- ERROR: BAD RELATIONAL EXPRESSION.
          THEN
               NULL ;
          END IF;

     END ;


     -------------------------------------------------------------------
     ------------  NUMERIC (INTEGER) VS. ARRAY OF BOOLEANS  ------------

     DECLARE

          X , Y  : INTEGER :=  0 ;
          B      : ARRAY ( CHARACTER ) OF BOOLEAN 
                      := ( CHARACTER => FALSE ) ;

     BEGIN

          IF  B = 0                 -- ERROR: BAD RELATIONAL EXPRESSION.
          THEN
               NULL ;
          END IF;

          B := ( B /= FALSE ) ;     -- ERROR: BAD RELATIONAL EXPRESSION
                                    --    (BOOL VS AR).

          IF  Y >= B                -- ERROR: BAD RELATIONAL EXPRESSION.
          THEN
               NULL ;
          END IF;

     END ;

     -------------------------------------------------------------------
     --------------  NUMERIC (INTEGER) VS. CHARACTER  ------------------
                     
     DECLARE

          I , J  :  INTEGER    RANGE  0..127   :=   67 ; -- HEX 43 ('C')
          X , Y  :  CHARACTER  RANGE 'A'..'D'  :=  'C' ;
          B      :  BOOLEAN ;

     BEGIN

          IF  X = 67                -- ERROR: BAD RELATIONAL EXPRESSION.
          THEN
               NULL ;
          END IF;

          B := ( 'C' /= 67 ) ;      -- ERROR: BAD RELATIONAL EXPRESSION.

          IF  I <= 'C'              -- ERROR: BAD RELATIONAL EXPRESSION.
          THEN
               NULL ;
          END IF;

          IF  Y >= J                -- ERROR: BAD RELATIONAL EXPRESSION.
          THEN
               NULL ;
          END IF;

     END ;


     -------------------------------------------------------------------
     -------------- NUMERIC (INTEGER) VS. ARRAY OF INTEGERS  -----------
                            
     DECLARE

          I , J  :  INTEGER    RANGE  0..127   := 0 ;
          X , Y  :  ARRAY ( CHARACTER ) OF INTEGER
                       := ( CHARACTER => 0 ) ;
          B      :  BOOLEAN ;

     BEGIN

          IF  X > 0                 -- ERROR: BAD RELATIONAL EXPRESSION.
          THEN
               NULL ;
          END IF;

          B := ( Y = 0 ) ;          -- ERROR: BAD RELATIONAL EXPRESSION.
          B := ( X = I ) ;          -- ERROR: BAD RELATIONAL EXPRESSION.

     END ;

     -------------------------------------------------------------------
     ------------   USER-DEF. ENUMERATION VS. CHARACTER  ---------------

     DECLARE

          TYPE  ENUM  IS  ( AAA , BBB , 'C' , DDD , 'E' );

          X  :  CONSTANT CHARACTER  :=  'D'  ;
          Y  :           CHARACTER  :=  'D'  ;
          Z  :  CONSTANT ENUM       :=  DDD  ;
          U  :           ENUM       :=  DDD  ;

          B      : BOOLEAN              :=  TRUE ;

     BEGIN

          IF  U = 'D'               -- ERROR: BAD RELATIONAL EXPRESSION.
          THEN
               NULL ;
          END IF;

          B := ( Y /= U ) ;         -- ERROR: BAD RELATIONAL EXPRESSION.

          IF  Z <= 'D'              -- ERROR: BAD RELATIONAL EXPRESSION.
          THEN
               NULL ;
          END IF;

          B := ( X >= Z ) ;         -- ERROR: BAD RELATIONAL EXPRESSION.

     END ;


     -------------------------------------------------------------------
     ------------   USER-DEF. ENUMERATION VS. INTEGER  -----------------

     DECLARE

          TYPE  ENUM  IS  ( AAA , BBB , 'C' , DDD , 'E' );

          X  :  CONSTANT INTEGER    :=   3   ;-- POSITION NUMBER OF  DDD
          Y  :           INTEGER    :=   3   ;
          Z  :  CONSTANT ENUM       :=  DDD  ;
          U  :           ENUM       :=  DDD  ;

          B  : BOOLEAN              := FALSE ;

     BEGIN

          IF  U = 3                 -- ERROR: BAD RELATIONAL EXPRESSION.
          THEN
               NULL ;
          END IF;

          B := ( Y /= U ) ;         -- ERROR: BAD RELATIONAL EXPRESSION.

          IF  Z <= 3                -- ERROR: BAD RELATIONAL EXPRESSION.
          THEN
               NULL ;
          END IF;

          B := ( X >= Z ) ;         -- ERROR: BAD RELATIONAL EXPRESSION.
          B := ( DDD < 3) ;         -- ERROR: BAD RELATIONAL EXPRESSION.

     END ;

     -------------------------------------------------------------------


END B45206A;
