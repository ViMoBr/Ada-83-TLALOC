-- C83E04A.ADA


-- CHECK THAT DIFFERENT SUBPROGRAMS CAN HAVE FORMAL PARAMETERS WITH THE
--    SAME NAME (THEIR TYPES BEING EITHER IDENTICAL OR DIFFERENT).

--    RM   28 JULY 1980


WITH REPORT;
PROCEDURE  C83E04A  IS

     USE REPORT;

     Y , Z : INTEGER := 0 ;

     PROCEDURE  P1 ( D , A , B : INTEGER;  C : IN OUT INTEGER ) IS
     BEGIN
          C := D * B + B * D * A ;         --  (-1)*3 + 3*(-1)*(-2) = 3
     END ;

     PROCEDURE  P2 ( A : INTEGER;  C : IN OUT INTEGER ) IS
     BEGIN
          C := 10 * C + A ;                --  10*3 + 5 = 35
     END ;

     PROCEDURE  P3 ( A : BOOLEAN;  C : IN OUT INTEGER ) IS
     BEGIN
          IF  A  THEN
               C := 10 * C + 999 ;
          ELSE
               C := 10 * C + 7 ;           --  10*35 + 7 = 357
          END IF ;
     END ;

     FUNCTION  F1 ( C : INTEGER )  RETURN INTEGER  IS
     BEGIN
          RETURN C ;
     END ;

     FUNCTION  F2 ( C : INTEGER )  RETURN INTEGER  IS
     BEGIN
          RETURN  C + 4 ;
     END ;

     FUNCTION  F3 ( C : BOOLEAN )  RETURN INTEGER  IS
     BEGIN
          IF  C  THEN  RETURN  999 ;
          ELSE  RETURN  3 ;
          END IF ;
     END ;


BEGIN

     TEST( "C83E04A" , "CHECK THAT DIFFERENT SUBPROGRAMS CAN HAVE " &
                       " FORMAL PARAMETERS WITH THE SAME NAME (THEIR " &
                       " TYPES BEING EITHER IDENTICAL OR DIFFERENT)" ) ;

     P1 (-1 , -2 , 3 , Z );                --  Z  BECOMES  3

     IF  Z /= 3  THEN
          FAILED( "ACCESSING ERROR OR COMPUTATION ERROR (P1)" );
          Z := 3 ;
     END IF ;

     P2 ( A => 5 , C => Z );               --  Z  BECOMES  35

     IF  Z /= 35  THEN
          FAILED( "ACCESSING ERROR OR COMPUTATION ERROR (P2)" );
          Z := 35 ;
     END IF ;

     P3 ( FALSE , C => Z );                --  Z  BECOMES  357
     Y := 100 * F1(C => 4) + 10 * F2(2) + F3(C => FALSE) ;
                                           --  Y  BECOMES  463


     IF  Y /= 463  OR  Z /= 357  THEN
          FAILED( "ACCESSING ERROR OR COMPUTATION ERROR" );
     END IF;

     RESULT;

END C83E04A;
