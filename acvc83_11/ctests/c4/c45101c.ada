-- C45101C.ADA


-- CHECK THE CORRECT OPERATION OF  'AND' , 'OR' , AND 'XOR'

-- PART 3: CHECKING THE TRUTH TABLES FOR 'AND' , 'OR' , 'XOR'


--    RM    24 SEPT 1980     (PART OF C45101A)
--    RM    11 JAN  1982
-- JWC 7/8/85   RENAMED TO -AB


WITH  REPORT ;
PROCEDURE  C45101C  IS

     USE REPORT;

     CVAR : BOOLEAN := FALSE ;     -- INITIAL VALUE IRRELEVANT
     FLOW_INDEX : INTEGER := 0 ;   -- INITIAL VALUE ESSENTIAL

     PROCEDURE  BUMP  IS
     BEGIN
          FLOW_INDEX  :=  FLOW_INDEX + 1 ;
     END BUMP ;

BEGIN


     TEST( "C45101C" , "CHECK THE TRUTH TABLES FOR 'AND' , 'OR','XOR'");


     FIRST :
     FOR  A  IN  BOOLEAN  LOOP

          SECOND :
          FOR  B  IN  BOOLEAN  LOOP

               CVAR  :=  A AND B ;
               IF  A  THEN
                    IF  CVAR /= B  THEN  FAILED("TT ERROR: 'AND(T,.)'");
                    END IF;
               ELSIF  CVAR  THEN  FAILED("TT ERROR: 'AND(F,.)'") ;
               END IF;

               CVAR  :=  A OR B ;
               IF  A  THEN
                    IF CVAR /= TRUE  THEN FAILED("TT ERROR: 'OR(T,.)'");
                    END IF;
               ELSIF  CVAR /= B  THEN  FAILED("TT ERROR: 'OR(F,.)'") ;
               END IF;

               CVAR  :=  A XOR B ;
               IF  A  THEN
                    IF  CVAR = B  THEN  FAILED("TT ERROR: 'XOR(T,.)'") ;
                    END IF;
               ELSIF  CVAR /= B  THEN  FAILED("TT ERROR: 'XOR(F,.)'") ;
               END IF;

          END LOOP SECOND;

     END LOOP FIRST;


     RESULT;

END C45101C;
