-- C35502B.ADA

-- CHECK THAT THE ATTRIBUTE 'WIDTH' YIELDS THE CORRECT RESULTS 
-- WHEN THE PREFIX IS A GENERIC FORMAL DISCRETE TYPE WHOSE ACTUAL 
-- PARAMETER IS AN ENUMERATION TYPE OTHER THAN A BOOLEAN OR CHARACTER 
-- TYPE.   

-- RJW 5/05/86

WITH REPORT; USE REPORT;

PROCEDURE  C35502B  IS

BEGIN

     TEST( "C35502B" , "CHECK THAT THE ATTRIBUTE 'WIDTH' YIELDS " &
                       "THE CORRECT RESULTS WHEN THE PREFIX " &
                       "IS A GENERIC FORMAL DISCRETE TYPE " &
                       "WHOSE ACTUAL PARAMETER IS AN ENUMERATION " &
                       "TYPE" );

     DECLARE
          TYPE ENUM IS (A, BC, ABC, A_B_C, ABCD);
          SUBTYPE SUBENUM IS ENUM RANGE A .. ABC;
          SUBTYPE NOENUM IS ENUM RANGE ABC .. A;
          
          TYPE NEWENUM IS NEW ENUM;

          GENERIC
               TYPE E IS (<>);
               W : INTEGER;
          PROCEDURE P (STR : STRING);

          PROCEDURE P (STR : STRING) IS
               SUBTYPE NOENUM IS E RANGE 
                    E'VAL (IDENT_INT(2)) .. E'VAL (IDENT_INT(1));
          BEGIN
               IF E'WIDTH /= IDENT_INT(W) THEN 
                    FAILED ( "INCORRECT E'WIDTH FOR " & STR );
               END IF;
               IF NOENUM'WIDTH /= IDENT_INT(0) THEN
                    FAILED ( "INCORRECT NOENUM'WIDTH FOR " & STR );
               END IF;
          END P;

          PROCEDURE PROC1 IS NEW P (ENUM, 5);
          PROCEDURE PROC2 IS NEW P (SUBENUM, 3);
          PROCEDURE PROC3 IS NEW P (NEWENUM, 5);
          PROCEDURE PROC4 IS NEW P (NOENUM, 0);

     BEGIN
          PROC1 ( "ENUM" );
          PROC2 ( "SUBENUM" );
          PROC3 ( "NEWENUM" );
          PROC4 ( "NOENUM" );
     END;                    

     RESULT;
END C35502B;
