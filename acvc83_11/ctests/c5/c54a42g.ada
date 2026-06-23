-- C54A42G.ADA


-- CHECK THAT A  CASE_STATEMENT CORRECTLY HANDLES SEVERAL NON-CONTIGUOUS
--    RANGES OF INTEGERS COVERED BY A SINGLE  'OTHERS'  ALTERNATIVE.


-- (OPTIMIZATION TEST.)


-- RM 03/30/81


WITH REPORT;
PROCEDURE  C54A42G  IS

     USE  REPORT ;

BEGIN

     TEST( "C54A42G" , "TEST THAT A  CASE_STATEMENT CORRECTLY HANDLES" &
                       " SEVERAL NON-CONTIGUOUS RANGES OF INTEGERS"    &
                       " COVERED BY A SINGLE  'OTHERS'  ALTERNATIVE"  );

     DECLARE

          NUMBER  : CONSTANT          := 2000 ;
          LITEXPR : CONSTANT          := NUMBER + 2000 ;
          STATCON : CONSTANT INTEGER  := 2002 ;
          DYNVAR  :          INTEGER  := IDENT_INT( 0 );
          DYNCON  : CONSTANT INTEGER  := IDENT_INT( 1 );

     BEGIN

          CASE  INTEGER'(-4000)  IS
               WHEN  100..1999       =>  FAILED("WRONG ALTERNATIVE F1");
               WHEN  INTEGER'FIRST..0=>  NULL ;
               WHEN  2001            =>  FAILED("WRONG ALTERNATIVE F3");
               WHEN  2100..INTEGER'LAST=>FAILED("WRONG ALTERNATIVE F4");
               WHEN  OTHERS          =>  FAILED("WRONG ALTERNATIVE F5");
          END CASE;

          CASE  IDENT_INT(NUMBER)   IS
               WHEN  100..1999       =>  FAILED("WRONG ALTERNATIVE G1");
               WHEN  INTEGER'FIRST..0=>  FAILED("WRONG ALTERNATIVE G2");
               WHEN  2001            =>  FAILED("WRONG ALTERNATIVE G3");
               WHEN  2100..INTEGER'LAST=>FAILED("WRONG ALTERNATIVE G4");
               WHEN  OTHERS          =>  NULL ;
          END CASE;

          CASE  IDENT_INT(LITEXPR)  IS
               WHEN  100..1999       =>  FAILED("WRONG ALTERNATIVE H1");
               WHEN  INTEGER'FIRST..0=>  FAILED("WRONG ALTERNATIVE H2");
               WHEN  2001            =>  FAILED("WRONG ALTERNATIVE H3");
               WHEN  2100..INTEGER'LAST=>NULL ;
               WHEN  OTHERS          =>  FAILED("WRONG ALTERNATIVE H5");
          END CASE;

          CASE  IDENT_INT(STATCON)  IS
               WHEN  100..1999       =>  FAILED("WRONG ALTERNATIVE I1");
               WHEN  INTEGER'FIRST..0=>  FAILED("WRONG ALTERNATIVE I2");
               WHEN  2001            =>  FAILED("WRONG ALTERNATIVE I3");
               WHEN  2100..INTEGER'LAST=>FAILED("WRONG ALTERNATIVE I4");
               WHEN  OTHERS          =>  NULL ;
          END CASE;

          CASE  DYNVAR   IS
               WHEN  100..1999       =>  FAILED("WRONG ALTERNATIVE J1");
               WHEN  INTEGER'FIRST..0=>  NULL ;
               WHEN  2001            =>  FAILED("WRONG ALTERNATIVE J3");
               WHEN  2100..INTEGER'LAST=>FAILED("WRONG ALTERNATIVE J4");
               WHEN  OTHERS          =>  FAILED("WRONG ALTERNATIVE J5");
          END CASE;

          CASE  DYNCON   IS
               WHEN  100..1999       =>  FAILED("WRONG ALTERNATIVE K1");
               WHEN  INTEGER'FIRST..0=>  FAILED("WRONG ALTERNATIVE K2");
               WHEN  2001            =>  FAILED("WRONG ALTERNATIVE K3");
               WHEN  2100..INTEGER'LAST=>FAILED("WRONG ALTERNATIVE K4");
               WHEN  OTHERS          =>  NULL ;
          END CASE;

          CASE  IDENT_INT( -3900 )  IS
               WHEN  -3000..1999     =>  FAILED("WRONG ALTERNATIVE X1");
               WHEN  INTEGER'FIRST..
                           -4000     =>  FAILED("WRONG ALTERNATIVE X2");
               WHEN  2001            =>  FAILED("WRONG ALTERNATIVE X3");
               WHEN  2100..INTEGER'LAST=>FAILED("WRONG ALTERNATIVE X4");
               WHEN  OTHERS          =>  NULL ;
          END CASE;

     END ;


     RESULT ;


END  C54A42G ;
