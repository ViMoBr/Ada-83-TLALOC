-- C48009F.ADA

-- FOR ALLOCATORS OF THE FORM "NEW T'(X)", CHECK THAT CONSTRAINT_ERROR
-- IS RAISED IF T IS A CONSTRAINED OR UNCONSTRAINED MULTI-DIMENSIONAL
-- ARRAY TYPE AND ALL COMPONENTS OF X DO NOT HAVE THE SAME LENGTH OR
-- BOUNDS. 

-- RM  01/08/80
-- NL  10/13/81
-- SPS 10/26/82
-- JBG 03/03/83
-- EG  07/05/84

WITH REPORT;

PROCEDURE  C48009F  IS

     USE REPORT;

BEGIN

     TEST("C48009F","FOR ALLOCATORS OF THE FORM 'NEW T'(X)', CHECK " &
                    "THAT CONSTRAINT_ERROR IS RAISED WHEN "          &
                    "X IS AN ILL-FORMED MULTIDIMENSIONAL AGGREGATE");

     DECLARE

          TYPE  TG00  IS  ARRAY( 4..2 ) OF  INTEGER;
          TYPE  TG10  IS  ARRAY( 1..2 ) OF  INTEGER;
          TYPE  TG20  IS  ARRAY( INTEGER RANGE <> ) OF  INTEGER;

          TYPE  TG0  IS  ARRAY( 3..2 ) OF  TG00;
          TYPE  TG1  IS  ARRAY( 1..2 ) OF  TG10;
          TYPE  TG2  IS  ARRAY( INTEGER RANGE <> ) OF  TG20(1..3);

          TYPE  ATG0  IS  ACCESS TG0;
          TYPE  ATG1  IS  ACCESS TG1;
          TYPE  ATG2  IS  ACCESS TG2;

          VG0  : ATG0;
          VG1  : ATG1;
          VG2  : ATG2;

     BEGIN

          BEGIN
               VG0  :=  NEW TG0 '( 5..4 => ( 3..1 => 2 ) );
               FAILED ("NO EXCEPTION RAISED - CASE 0");
          EXCEPTION
               WHEN  CONSTRAINT_ERROR  =>  NULL;
               WHEN  OTHERS            =>
                    FAILED( "WRONG EXCEPTION RAISED - CASE 0" );
          END;

          BEGIN
               VG1  :=  NEW TG1 '( ( 1 , 2 ) , ( 3 , 4 , 5 ) );
               FAILED ("NO EXCEPTION RAISED - CASE 1");
          EXCEPTION
               WHEN  CONSTRAINT_ERROR  =>  NULL;
               WHEN  OTHERS            =>  
                    FAILED( "WRONG EXCEPTION RAISED - CASE 1" );
          END;

          BEGIN
               VG2 := NEW TG2'( 1 => ( 1..2 => 7) , 2 => ( 1..3 => 7));
               FAILED ("NO EXCEPTION RAISED - CASE 2");
          EXCEPTION
               WHEN  CONSTRAINT_ERROR  =>  NULL;
               WHEN  OTHERS            =>  
                    FAILED( "WRONG EXCEPTION RAISED - CASE 2" );
          END;

     END;

     RESULT;

END C48009F;
