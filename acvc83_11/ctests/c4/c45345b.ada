-- C45345B.ADA


-- CHECK THAT  CONSTRAINT_ERROR  IS NOT RAISED IF THE RESULT OF
--     CATENATION HAS PRECISELY THE MAXIMUM LENGTH PERMITTED BY THE
--     INDEX SUBTYPE.


-- RM  2/26/82


WITH REPORT;
USE REPORT;
PROCEDURE C45345B IS


BEGIN

     TEST ( "C45345B" , "CHECK THAT  CONSTRAINT_ERROR  IS NOT RAISED" &
                        " IF THE RESULT OF CATENATION HAS PRECISELY" &
                        " THE MAXIMUM LENGTH PERMITTED BY THE" &
                        " INDEX SUBTYPE" );


     -------------------------------------------------------------------
     -----------------  STRG_VAR := STRG_LIT & STRG_LIT  ---------------

     DECLARE

          X : STRING(1..5) ;

     BEGIN

          X := "ABCD" & "E" ;

     EXCEPTION

          WHEN  CONSTRAINT_ERROR =>
               FAILED( "'STRING & STRING' RAISED  CONSTRAINT_ERROR " );

          WHEN  OTHERS =>
               FAILED( "'STRING & STRING' RAISED ANOTHER EXCEPTION" );

     END;


     -------------------------------------------------------------------
     -----------------  STRG_VAR := STRG_LIT & CHARACTER  --------------

     DECLARE

          X : STRING(1..5) ;

     BEGIN

          X := "ABCD" & 'E' ;

     EXCEPTION

          WHEN  CONSTRAINT_ERROR =>
               FAILED( "'STRING & STRING' RAISED  CONSTRAINT_ERROR " );

          WHEN  OTHERS =>
               FAILED( "'STRING & STRING' RAISED ANOTHER EXCEPTION" );

     END;

     -------------------------------------------------------------------
     -----------------  STRG_VAR := STRG_VAR & STRG_VAR  ---------------

     DECLARE

          X :          STRING(1..5) ;
          A : CONSTANT STRING       := "A" ;
          B :          STRING(1..4) := IDENT_STR("BCDE") ;

     BEGIN

          X :=  A & B ;

     EXCEPTION

          WHEN  CONSTRAINT_ERROR =>
               FAILED( "'STRING & STRING' RAISED  CONSTRAINT_ERROR " );

          WHEN  OTHERS =>
               FAILED( "'STRING & STRING' RAISED ANOTHER EXCEPTION" );

     END;

     -------------------------------------------------------------------


     RESULT;


END C45345B;
