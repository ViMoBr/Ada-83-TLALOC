-- C45662A.ADA


-- CHECK THE TRUTH TABLE FOR  'NOT' .

-- THE COMBINATIONS OF  'NOT'  WITH  'AND' , 'OR' , 'XOR'  ARE TESTED
--    IN C45101(A,G).


-- RM    28 OCTOBER 1980
-- TBN 10/21/85     RENAMED FROM C45401A.ADA.


WITH  REPORT ;
PROCEDURE  C45662A  IS

     USE REPORT;

     TVAR , FVAR , CVAR : BOOLEAN := FALSE ; -- INITIAL VALUE IRRELEVANT
     ERROR_COUNT : INTEGER := 0 ;            -- INITIAL VALUE ESSENTIAL

     PROCEDURE  BUMP  IS
     BEGIN
          ERROR_COUNT  :=  ERROR_COUNT + 1 ;
     END BUMP ;

BEGIN

     TEST( "C45662A" , "CHECK THE TRUTH TABLE FOR  'NOT'" ) ;

     FOR  A  IN  BOOLEAN  LOOP

          CVAR  :=  NOT A ;

          IF  NOT A  THEN
               IF  A  THEN  BUMP ;
               END IF ;
          END IF;

          IF  CVAR  THEN
               IF  A  THEN  BUMP ;
               END IF ;
          END IF;

          IF  NOT( NOT( NOT( NOT(   CVAR   ))))
          THEN
               IF  A  THEN  BUMP ;
               END IF ;
          END IF;

     END LOOP ;

     FOR  I  IN  1..2  LOOP

          CVAR  :=  NOT ( I > 1 ) ;

          IF  NOT ( I > 1 )  THEN
               IF  I>1  THEN  BUMP ;
               END IF ;
          END IF;

          IF  CVAR  THEN
               IF  I>1  THEN  BUMP ;
               END IF ;
          END IF;

     END LOOP ;

     IF  NOT TRUE   THEN  BUMP ;                END IF ;
     IF  NOT FALSE  THEN  NULL ;  ELSE  BUMP ;  END IF ;

     TVAR := IDENT_BOOL( TRUE );
     FVAR := IDENT_BOOL( FALSE );

     IF  NOT TVAR  THEN  BUMP ;                END IF ;
     IF  NOT FVAR  THEN  NULL ;  ELSE  BUMP ;  END IF ;


     IF  ERROR_COUNT  /= 0  THEN  FAILED( "'NOT' TRUTH TABLE" );
     END IF ;

     RESULT;

END C45662A;
