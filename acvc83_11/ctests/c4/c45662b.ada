-- C45662B.ADA


-- CHECK THE TRUTH TABLE FOR  'NOT'  ON DERIVED-BOOLEAN-TYPE OPERANDS.

-- THE COMBINATIONS OF  'NOT'  WITH  'AND' , 'OR' , 'XOR'  ARE TESTED
--    IN C45101K.


-- RM    28 OCTOBER 1980
-- TBN 10/21/85     RENAMED FROM C45401B-AB.ADA.  REMOVED DUPLICATED
--                  CODE NEAR END.

WITH  REPORT; USE REPORT;
PROCEDURE  C45662B  IS

     TYPE  NB  IS  NEW BOOLEAN ;

     TVAR , FVAR , CVAR : NB := NB'(FALSE) ; -- INITIAL VALUE IRRELEVANT
     ERROR_COUNT : INTEGER := 0 ;            -- INITIAL VALUE ESSENTIAL

     PROCEDURE  BUMP  IS
     BEGIN
          ERROR_COUNT := ERROR_COUNT + 1 ;
     END BUMP ;

     FUNCTION  IDENT_NEW_BOOL( THE_ARGUMENT : NB )  RETURN  NB  IS
     BEGIN
          IF  EQUAL(2,2)  THEN  RETURN THE_ARGUMENT;
          ELSE  RETURN  NB'(FALSE) ;
          END IF;
     END ;


BEGIN

     TEST( "C45662B" , "CHECK THE TRUTH TABLE FOR  'NOT'" &
                       " ON DERIVED-BOOLEAN-TYPE OPERANDS" ) ;

     FOR  A  IN  NB  LOOP

          CVAR  :=  NOT A ;

          IF  BOOLEAN( NOT A )  THEN
               IF  BOOLEAN( A )  THEN  BUMP ;
               END IF ;
          END IF;

          IF  BOOLEAN( CVAR )  THEN
               IF  BOOLEAN( A )  THEN  BUMP ;
               END IF ;
          END IF;

          IF  BOOLEAN(

              NOT( NOT( NOT( NOT( NOT(
              NOT( NOT( NOT( NOT( NOT(
              NOT( NOT( NOT( NOT( NOT(
              NOT( NOT( NOT( NOT( NOT(   CVAR  ))))) ))))) ))))) )))))
                      )
          THEN
               IF  BOOLEAN( A )  THEN  BUMP ;
               END IF ;
          END IF;

     END LOOP ;

     FOR  I  IN  1..2  LOOP

          CVAR  :=  NOT( NB( I > 1 ) ) ;

          IF  BOOLEAN(  NOT(  NB( I > 1 )))  THEN
               IF  I>1  THEN  BUMP ;
               END IF ;
          END IF;

          IF  BOOLEAN( CVAR )  THEN
               IF  I>1  THEN  BUMP ;
               END IF ;
          END IF;

     END LOOP ;

     IF  BOOLEAN( NOT( NB'(TRUE ))) THEN  BUMP ;                END IF ;
     IF  BOOLEAN( NOT( NB'(FALSE))) THEN  NULL ;  ELSE  BUMP ;  END IF ;


     TVAR := IDENT_NEW_BOOL( NB'(TRUE ) );
     FVAR := IDENT_NEW_BOOL( NB'(FALSE) );

     IF  BOOLEAN( NOT TVAR )  THEN  BUMP ;                END IF ;
     IF  BOOLEAN( NOT FVAR )  THEN  NULL ;  ELSE  BUMP ;  END IF ;

     IF  ERROR_COUNT  /= 0  THEN  FAILED( "'NOT' TRUTH TABLE" );
     END IF ;

     RESULT;

END C45662B;
