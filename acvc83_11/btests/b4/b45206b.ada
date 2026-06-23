-- B45206B.ADA


-- CHECK THAT THE RELATIONAL OPERATORS ARE NOT PREDEFINED FOR OPERANDS
--     OF DIFFERENT TYPES.  (SPECIAL CASE(S), NOT APPLICABLE TO ADA-80.)


-- CASES COVERED:

--   * NUMERIC (INTEGER) VS. ADDRESS


-- RM  2/12/82


WITH SYSTEM; USE SYSTEM;

PROCEDURE B45206B IS

BEGIN

     -------------------------------------------------------------------
     ---------------  NUMERIC (INTEGER) VS. ADDRESS  -------------------

     DECLARE

          X , Y  : INTEGER :=  0; 
          B      : BOOLEAN := FALSE; 

     BEGIN

          IF  X = B'ADDRESS         -- ERROR: BAD RELATIONAL EXPRESSION.
          THEN
               NULL; 
          END IF;

          IF  Y >= B'ADDRESS        -- ERROR: BAD RELATIONAL EXPRESSION.
          THEN
               NULL; 
          END IF;

     END; 

     -------------------------------------------------------------------


END B45206B;
