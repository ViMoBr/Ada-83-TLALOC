-- C45101I.ADA


-- CHECK THE CORRECT OPERATION OF  'AND' , 'OR' , AND 'XOR'
--    WITH ARITHMETIC EXPRESSIONS AS OPERANDS
--    (THE CASE OF VARIABLES AS OPERNDS IS TREATED IN A COMPANION TEST).

-- PART 3: CHECKING THE TRUTH TABLES FOR 'AND' , 'OR' , 'XOR'


-- RM    6 OCTOBER 1980     (PART OF C45101C)
-- RM   11 JANUARY 1982
-- JWC 7/8/85   RENAMED TO -AB


WITH  REPORT ;
PROCEDURE  C45101I  IS

     USE REPORT;

     CVAR : BOOLEAN := FALSE ;     -- INITIAL VALUE IRRELEVANT

BEGIN

     TEST ("C45101I" , "CHECK THE TRUTH TABLES FOR 'AND', 'OR', 'XOR'");


     FIRST :
     FOR  I  IN  0..1  LOOP

          SECOND :
          FOR  J  IN  1..2  LOOP

               CVAR  :=   (I>0) AND (J>1) ;
               IF   (I>0)  THEN
                    IF  CVAR /=
                      (J>1)  THEN  FAILED("TT ERROR: 'AND(T,.)'");
                    END IF;
               ELSIF  CVAR  THEN  FAILED("TT ERROR: 'AND(F,.)'") ;
               END IF;

               CVAR  :=   (I>0) OR (J>1) ;
               IF   (I>0)  THEN
                    IF CVAR /= TRUE  THEN FAILED("TT ERROR: 'OR(T,.)'");
                    END IF;
               ELSIF  CVAR /=
                      (J>1)  THEN  FAILED("TT ERROR: 'OR(F,.)'") ;
               END IF;

               CVAR  :=   (I>0) XOR (J>1) ;
               IF   (I>0)  THEN
                    IF  CVAR =
                      (J>1)  THEN  FAILED("TT ERROR: 'XOR(T,.)'") ;
                    END IF;
               ELSIF  CVAR /=
                      (J>1)  THEN  FAILED("TT ERROR: 'XOR(F,.)'") ;
               END IF;

          END LOOP SECOND;

     END LOOP FIRST;


     RESULT;

END C45101I;
