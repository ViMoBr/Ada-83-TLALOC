-- C58006A.ADA


-- CHECK THAT IF THE EVALUATION OF A RETURN STATEMENT'S EXPRESSION
-- RAISES AN EXCEPTION, THE EXCEPTION CAN BE HANDLED WITHIN THE BODY OF
-- THE FUNCTION. 

-- RM 05/11/81
-- SPS 10/26/82
-- SPS 3/8/83
-- JBG 9/13/83

WITH REPORT;
PROCEDURE  C58006A  IS

     USE  REPORT;

BEGIN

     TEST( "C58006A" , "CHECK THAT EXCEPTION RAISED BY A RETURN" &
                       " STATEMENT CAN BE HANDLED LOCALLY" );


     DECLARE
          SUBTYPE I1 IS INTEGER RANGE -10..90;
          SUBTYPE I2 IS INTEGER RANGE 1..10; 

          FUNCTION  FN1( X : I1 )
                    RETURN  I2  IS
          BEGIN
               RETURN  0;
          EXCEPTION
               WHEN CONSTRAINT_ERROR => 
                    COMMENT ("EXCEPTION RAISED - F1");
                    RETURN 1;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - FN1");
          END  FN1;

          FUNCTION  FN2( X : I1 )
                    RETURN  I2  IS
          BEGIN
               RETURN  X + IDENT_INT(0);
          EXCEPTION
               WHEN CONSTRAINT_ERROR => 
                    COMMENT ("EXCEPTION RAISED - F2");
                    RETURN 1;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - FN2");
          END  FN2;

          FUNCTION  FN3( X : I1 )
                    RETURN  I2  IS
               HUNDRED : INTEGER RANGE -100..100 := IDENT_INT(100);
          BEGIN
               RETURN  HUNDRED;
          EXCEPTION
               WHEN CONSTRAINT_ERROR => 
                    COMMENT ("EXCEPTION RAISED - F3");
                    RETURN 1;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - FN3");
          END  FN3;

     BEGIN

          BEGIN
               IF FN1( 0 ) /= IDENT_INT(1) THEN
                    FAILED ("NO EXCEPTION RAISED - FN1( 0 )");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION PROPAGATED - FN1( 0 )");
          END;

          BEGIN
               IF FN2( 0 ) /= IDENT_INT(1) THEN
                    FAILED ("NO EXCEPTION RAISED - FN2( 0 )");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION PROPAGATED - FN2( 0 )");
          END;

          BEGIN
               IF FN2(11 ) /= IDENT_INT(1) THEN
                    FAILED ("NO EXCEPTION RAISED - FN2(11 )");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION PROPAGATED - FN2(11 )");
          END;

          BEGIN
               IF FN3( 0 ) /= IDENT_INT(1) THEN
                    FAILED ("NO EXCEPTION RAISED - FN3( 0 )");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION PROPAGATED - FN3( 0 )");
          END;

     END;

     RESULT;

END C58006A;
