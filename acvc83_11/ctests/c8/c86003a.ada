-- C86003A.ADA

-- CHECK THAT  'STANDARD'  IS NOT TREATED AS A RESERVED WORD IN
--    SELECTED COMPONENT NAMES.

-- RM  01/21/80
-- EG  10/29/85  ELIMINATE THE USE OF NUMERIC_ERROR IN TEST.

WITH REPORT ;
PROCEDURE  C86003A  IS

     USE REPORT ;

BEGIN

     TEST("C86003A" , "CHECK THAT  'STANDARD'  IS NOT TREATED AS A" &
                      " RESERVED WORD IN SELECTED COMPONENT NAMES" );

     DECLARE    -- A
     BEGIN

          DECLARE

               PACKAGE  STANDARD  IS
                    CHARACTER      :  BOOLEAN ;
                    TYPE  INTEGER  IS (FALSE, TRUE) ;
                    CONSTRAINT_ERROR :  EXCEPTION ;
               END  STANDARD ;

               TYPE  REC2  IS
                    RECORD
                         AA , BB  :  BOOLEAN  := FALSE ;
                    END RECORD;

               TYPE  REC1  IS
                    RECORD
                         STANDARD : REC2 ;
                    END RECORD;

               A    :  REC1 ;
               TYPE  ASI  IS  ACCESS STANDARD.INTEGER ;
               VASI  :  ASI ;
               VI : INTEGER RANGE 1 .. 10;   -- THE "REAL" STANDARD
                                             -- TYPE 'INTEGER'

          BEGIN

               VASI  :=  NEW STANDARD.INTEGER'(STANDARD.FALSE);
               STANDARD.CHARACTER  :=  A.STANDARD.BB ;

               IF  STANDARD.CHARACTER  THEN FAILED( "RES. (VAR.)" );
               END IF;

               VI  :=  IDENT_INT(11);   -- TO CAUSE THE "REAL"
                                        -- (PREDEFINED) CONSTRAINT_ERROR
                                        -- EXCEPTION.

          EXCEPTION

               WHEN STANDARD.CONSTRAINT_ERROR => FAILED ("RES. (EXC.)");

               WHEN CONSTRAINT_ERROR => NULL;

               WHEN OTHERS => FAILED ("WRONG EXCEPTION RAISED - A");

          END ;

     EXCEPTION

          WHEN  OTHERS  =>  FAILED( "EXCEPTION RAISED BY DECL. (A)" );

     END ;    -- A


     DECLARE    -- B

          TYPE  REC  IS
               RECORD
                    INTEGER  :  BOOLEAN  := FALSE ;
               END RECORD;

          STANDARD :  REC ;

     BEGIN

          IF  STANDARD.INTEGER  THEN  FAILED( "RESERVED  -  REC.,INT.");
          END IF;

     END ;    -- B


     RESULT ;


END C86003A ;
