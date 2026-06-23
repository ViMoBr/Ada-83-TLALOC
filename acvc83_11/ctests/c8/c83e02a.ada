-- C83E02A.ADA


-- CHECK THAT WITHIN THE BODY OF A SUBPROGRAM A FORMAL PARAMETER CAN BE
--    USED DIRECTLY IN A RANGE CONSTRAINT, A DISCRIMINANT CONSTRAINT,
--    AND AN INDEX CONSTRAINT.

--    RM    8 JULY 1980


WITH REPORT;
PROCEDURE  C83E02A  IS

     USE REPORT;

     Z : INTEGER := 0 ;

     PROCEDURE  P1 ( A , B : INTEGER;  C : IN OUT INTEGER ) IS
          X : INTEGER RANGE A+1..1+B ;
     BEGIN
          X := A + 1 ;
          C := X * B + B * X * A ;         -- 4*3+3*4*3=48
     END ;

     PROCEDURE  P2 ( A , B : INTEGER;  C : IN OUT INTEGER ) IS
          TYPE  T (MAX : INTEGER)  IS
               RECORD
                    VALUE : INTEGER RANGE 1..3 ;
               END RECORD ;
          X : T(A);
     BEGIN
          X := ( MAX => 4 , VALUE => B ) ; -- ( 4 , 3 )
          C := 10*C + X.VALUE + 2 ;        -- 10*48+3+2=485
     END ;

     FUNCTION  F3 ( A , B : INTEGER )  RETURN INTEGER  IS
          TYPE  TABLE  IS  ARRAY( A..B ) OF INTEGER ;
          X : TABLE ;
          Y : ARRAY( A..B ) OF INTEGER ;
     BEGIN
          X(A) := A ;                      -- 5
          Y(B) := B ;                      -- 6
          RETURN X(A)-Y(B)+4 ;             -- 3
     END ;


BEGIN

     TEST( "C83E02A" , "CHECK THAT WITHIN THE BODY OF A SUBPROGRAM " &
                       " A FORMAL PARAMETER CAN BE USED DIRECTLY IN" &
                       " A RANGE CONSTRAINT, A DISCRIMINANT CONSTRAINT"&
                       ", AND AN INDEX CONSTRAINT" ) ;

     P1 ( 3 , 3 , Z );                     --  Z  BECOMES  48
     P2 ( 4 , F3( 5 , 6 ) , Z );           --  Z  BECOMES 485

     IF  Z /= 485  THEN
          FAILED( "ACCESSING ERROR OR COMPUTATION ERROR" );
     END IF;

     RESULT;

END C83E02A;
