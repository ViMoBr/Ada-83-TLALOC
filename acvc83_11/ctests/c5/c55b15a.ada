-- C55B15A.ADA

-- CHECK THAT IF A DISCRETE_RANGE OF THE FORM  'ST RANGE L..R'
--    RAISES AN EXCEPTION BECAUSE  L  OR  R  IS A NON-STATIC
--    EXPRESSION WHOSE VALUE IS OUTSIDE  THE RANGE OF VALUES
--    ASSOCIATED WITH  ST  (OR BECAUSE  ST'FIRST  IS NON-STATIC
--    AND  L  IS STATIC AND LESS THAN  ST'FIRST ; SIMILARLY FOR
--     ST'LAST  AND  R ), CONTROL DOES NOT ENTER THE LOOP.

-- RM  04/13/81
-- SPS 11/01/82
-- BHS 07/13/84
-- EG  10/28/85  FIX NUMERIC_ERROR/CONSTRAINT_ERROR ACCORDING TO
--               AI-00387.

WITH SYSTEM;
WITH REPORT;
PROCEDURE  C55B15A  IS

     USE  REPORT ;

BEGIN

     TEST( "C55B15A" , "WHEN  'FOR  I  IN  ST RANGE L..R  LOOP' "     &
                       "RAISES AN EXCEPTION, CONTROL DOES NOT ENTER " &
                       "THE BODY OF THE LOOP" );

     -------------------------------------------------------------------
     ----------------- STATIC (SUB)TYPE, DYNAMIC RANGE -----------------

     DECLARE

          SUBTYPE  ST  IS  INTEGER RANGE 1..4 ;

          FIRST   :  CONSTANT INTEGER := IDENT_INT( 1) ;
          SECOND  :  CONSTANT INTEGER := IDENT_INT( 2) ;
          THIRD   :  CONSTANT INTEGER := IDENT_INT( 3) ;
          FOURTH  :  CONSTANT INTEGER := IDENT_INT( 4) ;
          FIFTH   :  CONSTANT INTEGER := IDENT_INT( 5) ;
          TENTH   :  CONSTANT INTEGER := IDENT_INT(10) ;
          ZEROTH  :  CONSTANT INTEGER := IDENT_INT( 0) ;

     BEGIN

          BEGIN

               FOR  I  IN  ST RANGE 3..TENTH  LOOP
                    FAILED( "EXCEPTION NOT RAISED (I1)" );
               END LOOP;

          EXCEPTION

               WHEN  CONSTRAINT_ERROR => NULL ;
               WHEN  OTHERS           =>
                    FAILED( "WRONG EXCEPTION RAISED (I1)" );

          END ;


          BEGIN

               FOR  I  IN  ST RANGE 0..THIRD  LOOP
                    FAILED( "EXCEPTION NOT RAISED (I2)" );
               END LOOP;

          EXCEPTION

               WHEN  CONSTRAINT_ERROR => NULL ;
               WHEN  OTHERS           =>
                    FAILED( "WRONG EXCEPTION RAISED (I2)" );

          END ;


          DECLARE

               TYPE MAX_INT IS RANGE -SYSTEM.MAX_INT .. SYSTEM.MAX_INT;

               LOWERBOUND : CONSTANT := SYSTEM.MAX_INT - 10 ;
               -- IF  MAX_INT - 10 > INTEGER'LAST, NUMERIC_ERROR/
               --    CONSTRAINT_ERROR SHOULD BE RAISED; OTHERWISE,
               --    WE HAVE AN ORDINARY NULL RANGE AND NO
               --    NUMERIC_ERROR/CONSTRAINT_ERROR. THE OBSERVABLE
               --    BEHAVIOR OF THE TEST SHOULD BE THE SAME FOR THESE
               --    TWO CASES.

          BEGIN

               FOR  I  IN  ST RANGE LOWERBOUND..LOWERBOUND-15  LOOP
                    FAILED( "EXCEPTION NOT RAISED (I3)" );
               END LOOP;

          EXCEPTION

               WHEN  NUMERIC_ERROR =>
                    IF SYSTEM.MAX_INT > MAX_INT(INTEGER'LAST) THEN
                         COMMENT ("NUMERIC_ERROR RAISED");
                    ELSE
                         FAILED( "NUMERIC_ERROR RAISED WHEN " &
                                 "MAX_INT <= INTEGER'LAST (I3)" );
                    END IF;
               WHEN CONSTRAINT_ERROR =>
                    IF SYSTEM.MAX_INT > MAX_INT(INTEGER'LAST) THEN
                         COMMENT ("CONSTRAINT_ERROR RAISED");
                    ELSE
                         FAILED( "CONSTRAINT_ERROR RAISED WHEN " &
                                 "MAX_INT <= INTEGER'LAST (I3)" );
                    END IF;
               WHEN  OTHERS  =>
                    FAILED( "WRONG EXCEPTION RAISED (I3)" );

          END ;

     END ;


     -------------------------------------------------------------------
     ----------------- DYNAMIC (SUB)TYPE, STATIC RANGE -----------------

     DECLARE

          TYPE  ENUM   IS  ( AMINUS , A,B,C,D,E,  F,G,H,I,J );

          SUBTYPE  ST  IS  ENUM RANGE ENUM'VAL( IDENT_INT( 1) ) ..
                                      ENUM'VAL( IDENT_INT( 4) ) ;

          FIRST   :  CONSTANT ENUM := A ;
          SECOND  :  CONSTANT ENUM := B ;
          THIRD   :  CONSTANT ENUM := C ;
          FOURTH  :  CONSTANT ENUM := D ;
          FIFTH   :  CONSTANT ENUM := E ;
          TENTH   :  CONSTANT ENUM := J ;
          ZEROTH  :  CONSTANT ENUM := AMINUS ;

     BEGIN

          BEGIN

               FOR  I  IN  ST RANGE C..TENTH  LOOP
                    FAILED( "EXCEPTION NOT RAISED (E1)" );
               END LOOP;

          EXCEPTION

               WHEN  CONSTRAINT_ERROR => NULL ;
               WHEN  OTHERS           =>
                    FAILED( "WRONG EXCEPTION RAISED (E1)" );

          END ;


          BEGIN

               FOR  I  IN  ST RANGE AMINUS..THIRD  LOOP
                    FAILED( "EXCEPTION NOT RAISED (E2)" );
               END LOOP;

          EXCEPTION

               WHEN  CONSTRAINT_ERROR => NULL ;
               WHEN  OTHERS           =>
                    FAILED( "WRONG EXCEPTION RAISED (E2)" );

          END ;

     END ;


     DECLARE

          SUBTYPE  ST  IS  CHARACTER RANGE IDENT_CHAR( 'A' ) ..
                                           IDENT_CHAR( 'D' ) ;

          FIRST   :  CONSTANT CHARACTER := 'A' ;
          SECOND  :  CONSTANT CHARACTER := 'B' ;
          THIRD   :  CONSTANT CHARACTER := 'C' ;
          FOURTH  :  CONSTANT CHARACTER := 'D' ;
          FIFTH   :  CONSTANT CHARACTER := 'E' ;
          TENTH   :  CONSTANT CHARACTER := 'J' ;
          ZEROTH  :  CONSTANT CHARACTER := '0' ;--ZERO; PRECEDES LETTERS

     BEGIN

          BEGIN

               FOR  I  IN  ST RANGE 'C'..TENTH  LOOP
                    FAILED( "EXCEPTION NOT RAISED (C1)" );
               END LOOP;

          EXCEPTION

               WHEN  CONSTRAINT_ERROR => NULL ;
               WHEN  OTHERS           =>
                    FAILED( "WRONG EXCEPTION RAISED (C1)" );

          END ;


          BEGIN

               FOR  I  IN  ST RANGE '0'..THIRD  LOOP -- ZERO..'C'
                    FAILED( "EXCEPTION NOT RAISED (C2)" );
               END LOOP;

          EXCEPTION

               WHEN  CONSTRAINT_ERROR => NULL ;
               WHEN  OTHERS           =>
                    FAILED( "WRONG EXCEPTION RAISED (C2)" );

          END ;

     END ;


     RESULT ;


END  C55B15A ;
